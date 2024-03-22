import 'dart:io' as io;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:media_blade/utils/download_history_helper.dart';

import 'package:path_provider/path_provider.dart';

// Use the google apis
import 'package:googleapis/drive/v3.dart' as gApi;
import 'package:googleapis_auth/googleapis_auth.dart' as gAuth;

import "package:http/http.dart" as http;
import 'package:toast/toast.dart';

// The saved file
const tempFileName = "temp.db";
const fileName = 'mediablade_history.db';
const fileMime = 'application/vnd.google-apps.file';

// The App's specific folder
const appDataFolderName = 'media_blade';
const folderMime = 'application/vnd.google-apps.folder';

// This is the Http client that carries the calles with the needed headers
class AuthClient extends http.BaseClient {
  final http.Client _baseClient;
  final Map<String, String> _headers;

  AuthClient(this._baseClient, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _baseClient.send(request);
  }
}

class GoogleDriveClient {
  late String _accessToken;
  late GoogleSignInAccount _googleAccount;
  late gApi.DriveApi _driveApi;

  GoogleDriveClient._create(
      GoogleSignInAccount googleAccount, String accessToken) {
    _googleAccount = googleAccount;
    _accessToken = accessToken;
  }

  static Future<GoogleDriveClient?> create(
      GoogleSignInAuthentication auth) async {
    final googleSignIn =
        GoogleSignIn.standard(scopes: [DriveApi.driveFileScope]);
    var googleUser = await googleSignIn.signInSilently(suppressErrors: true);
    if (googleUser != null) {
      var component =
          GoogleDriveClient._create(googleUser, auth.accessToken ?? '');
      await component._initGoogleDriveApi();

      return component;
    }
    return null;
  }

  // Attach the needed headers to the http client.
  // Initializes the DriveApi with the auth client
  Future<void> _initGoogleDriveApi() async {
    final gAuth.AccessCredentials credentials = gAuth.AccessCredentials(
      gAuth.AccessToken(
        'Bearer',
        _accessToken,
        DateTime.now().toUtc().add(const Duration(days: 365)),
      ),
      null, // We don't have a refreshToken at this example
      [gApi.DriveApi.driveAppdataScope],
    );
    var client = gAuth.authenticatedClient(http.Client(), credentials);
    var localAuthHeaders = await _googleAccount.authHeaders;
    var headers = localAuthHeaders;
    var authClient = AuthClient(client, headers);
    _driveApi = gApi.DriveApi(authClient);
  }

  // Download the wanted file to the device in the specified folder
  Future<io.File?> _downloadFileToDevice(String fileId,
      {asTemp = false}) async {
    gApi.Media? file = (await _driveApi.files.get(fileId,
        downloadOptions: gApi.DownloadOptions.fullMedia)) as gApi.Media?;
    if (file != null) {
      final directory = await getApplicationDocumentsDirectory();
      final saveFile =
          io.File('${directory.path}/${asTemp ? tempFileName : fileName}');
      await file.stream.pipe(saveFile.openWrite());
      return saveFile;
    }
    return null;
  }

  Future<File> _getDriveFileMetadata(String fileId) async {
    File file = (await _driveApi.files
        .get(fileId, downloadOptions: gApi.DownloadOptions.fullMedia)) as File;
    return file;
  }

  // Gets the id of the file from Google Drive
  // If the file doesn't exist it returns null
  Future<File?> _getFileFromGoogleDrive(String fileName) async {
    gApi.FileList found = await _driveApi.files.list(
      q: "name = '$fileName'",
    );
    final files = found.files;
    if (files == null) {
      return null;
    }

    if (files.isNotEmpty) {
      return files.first;
    }
    return null;
  }

  // Creates a file with the content, and uploads it to google drive
  Future<String?> _createFileOnGoogleDrive(String newFileName,
      {String? mimeType, List<String> parents = const []}) async {
    gApi.Media? media;

    // Checks if the file already exists on Google Drive.
    // If it does, we delete it here and create a new one.
    var currentFile = await _getFileFromGoogleDrive(newFileName);
    if (currentFile != null) {
      await _driveApi.files.delete(currentFile.id ?? '');
    }

    if (newFileName == fileName) {
      final directory = await getApplicationDocumentsDirectory();
      var created = io.File("${directory.path}/$fileName");
      var bytes = await created.readAsBytes();
      media = gApi.Media(http.ByteStream.fromBytes(bytes), bytes.length,
          contentType: 'application/octet-stream');
    }

    gApi.File file = gApi.File();
    file.name = newFileName;
    file.mimeType = mimeType;
    file.parents = parents;

    // The acual file creation on Google Drive
    final fileCreation = await _driveApi.files.create(file, uploadMedia: media);
    if (fileCreation.id == null) {
      throw PlatformException(
        code: 'Error remoteStorageException',
        message: 'unable to create file on Google Drive',
      );
    }

    print("Created File ID: ${fileCreation.id} on RemoteStorage");
    return fileCreation.id!;
  }

  syncHistory() async {
    try {
      var file = await _getFileFromGoogleDrive(fileName);
      if (file != null) {
        final directory = await getApplicationDocumentsDirectory();
        var driveFile =
            await _downloadFileToDevice(file.id ?? '', asTemp: true);
        var localFile = io.File("${directory.path}/$fileName");
        if (driveFile != null) {
          var localBytes = await localFile.readAsBytes();
          var driveBytes = await driveFile.readAsBytes();
          if (!listEquals(localBytes, driveBytes)) {
            var merged =
                await DownloadHistoryHelper.mergeCloudHistory(tempFileName);
            if (merged) {
              await uploadFile();
            }
            Toast.show("History Synced");
          }
        } else {
          Toast.show("Download history up to date");
        }
      } else {
        await uploadFile();
        Toast.show("History Synced");
      }
    } catch (err) {
      print("Failed to sync");
      print(err);
      Toast.show("Failed to sync the history");
    }
  }

  // Public client API:
  uploadFile() async {
    try {
      String? folderId = await _createFileOnGoogleDrive(appDataFolderName,
          mimeType: folderMime);
      if (folderId != null) {
        await _createFileOnGoogleDrive(fileName, parents: [folderId]);
      }
    } catch (e) {
      print("GoogleDrive, uploadfileContent $e");
    }
  }

  Future<String?> downloadFile() async {
    try {
      var file = await _getFileFromGoogleDrive(fileName);

      if (file != null) {
        final fileContent = await _downloadFileToDevice(file.id ?? '');
        return await fileContent?.readAsString();
      }
      print("File not found on storage");
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

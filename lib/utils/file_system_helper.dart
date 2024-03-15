import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_blade/constants/common_constants.dart';

class FileSystemHelper {
  static Future<bool> createAppFolder() async {
    try {
      var appDirectory = Directory(app_directory_url);
      if (!appDirectory.existsSync()) {
        await appDirectory.create(recursive: true);
      }
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  static Future<String?> requestNewPath(BuildContext context) {
    return FilesystemPicker.open(
      title: 'Select a folder for downloads',
      context: context,
      rootDirectory: Directory("/storage/emulated/0/"),
      fsType: FilesystemType.folder,
      showGoUp: true,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      theme: FilesystemPickerTheme(
          fileList: FilesystemPickerFileListThemeData(
              folderIconColor: Colors.white,
              upIconColor: Colors.white,
              fileTextStyle: TextStyle(color: Colors.white),
              folderTextStyle: TextStyle(color: Colors.white),
              upTextStyle: TextStyle(color: Colors.white)),
          topBar: FilesystemPickerTopBarThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.white),
          )),
      pickText: 'Save file to this folder',
    );
  }
}

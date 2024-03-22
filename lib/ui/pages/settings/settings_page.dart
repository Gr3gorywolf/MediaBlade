import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:media_blade/utils/auth_helper.dart';
import 'package:media_blade/utils/file_system_helper.dart';
import 'package:media_blade/utils/google_drive_helper.dart';
import 'package:media_blade/utils/settings_helper.dart';
import 'package:media_blade/utils/ytdl_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var downloadUrl = "";
  var version = "";
  var isUpgrading = false;
  var isSyncing = false;
  var closeIfIntentEnabled = false;

  var titleTextStyle = TextStyle(color: Colors.white, fontSize: 12);
  var subTitleTextStyle = TextStyle(color: Colors.white, fontSize: 10);
  void init() async {
    var settedUrl =
        await SettingsHelper.getSetting(SettingKey.downloadPath) ?? "Not set";
    var closeIfIntent =
        await SettingsHelper.getSetting(SettingKey.closeIfIntent) == 'true' ??
            false;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      downloadUrl = settedUrl;
      closeIfIntentEnabled = closeIfIntent;
    });
  }

  void selectNewPath() async {
    var newPath = await FileSystemHelper.requestNewPath(context);
    if (newPath != null) {
      SettingsHelper.setSetting(SettingKey.downloadPath, newPath);
      setState(() {
        downloadUrl = newPath;
      });
    }
  }

  void upgradeExtractor() async {
    if (isUpgrading) return;
    setState(() {
      isUpgrading = true;
    });
    try {
      await YtdlHelper.upgradeYTDL();
      Toast.show("Extractor upgraded successfully!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    } catch (err) {
      Toast.show("Failed to upgrade the extractor",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
    setState(() {
      isUpgrading = false;
    });
  }

  void toggleCloseIfIntent() async {
    var newVal = !closeIfIntentEnabled;
    await SettingsHelper.setSetting(
        SettingKey.closeIfIntent, newVal.toString());
    setState(() {
      closeIfIntentEnabled = newVal;
    });
  }

  void handleStartBackup() async {
    setState(() {
      isSyncing = true;
    });
    var auth = await AuthHelper.signInWithGoogle();
    if (auth != null) {
      var googleDrive = await GoogleDriveClient.create(auth);
      if (googleDrive != null) {
        await googleDrive.syncHistory();
      }
    }

    setState(() {
      isSyncing = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ToastContext().init(context);
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Column(
          children: [
            ListTile(
              onTap: () {
                selectNewPath();
              },
              leading: Icon(
                Icons.download,
                size: 35,
                color: Colors.white,
              ),
              title: Text(
                "Download path",
                style: titleTextStyle,
              ),
              subtitle: Text(
                downloadUrl,
                style: subTitleTextStyle,
              ),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            ),
            ListTile(
              onTap: () {
                selectNewPath();
              },
              leading: Icon(
                Icons.clear_all,
                size: 35,
                color: Colors.white,
              ),
              title: Text(
                "Close after download",
                style: titleTextStyle,
              ),
              subtitle: Text(
                "Closes the app when was opened from a external app once you hit a download option",
                style: subTitleTextStyle,
              ),
              trailing: Switch(
                  value: closeIfIntentEnabled,
                  onChanged: (newVal) => toggleCloseIfIntent()),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            ),
            ListTile(
              onTap: () {
                upgradeExtractor();
              },
              leading: isUpgrading
                  ? CircularProgressIndicator()
                  : Icon(
                      Icons.upgrade,
                      size: 35,
                      color: Colors.white,
                    ),
              title: Text(
                "Upgrade extractor",
                style: titleTextStyle,
              ),
              subtitle: Text(
                "Upgrades the extractor to the latest version",
                style: subTitleTextStyle,
              ),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            ),
            ListTile(
              onTap: () {
                handleStartBackup();
              },
              leading: isSyncing
                  ? CircularProgressIndicator()
                  : Icon(
                      Icons.backup,
                      size: 35,
                      color: Colors.white,
                    ),
              title: Text(
                "Sync history to drive",
                style: titleTextStyle,
              ),
              subtitle: Text(
                "Syncs the download history to your personal google drive account",
                style: subTitleTextStyle,
              ),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            ),
            ListTile(
              onTap: () {
                launchUrl(
                    Uri.parse("https://github.com/Gr3gorywolf/MediaBlade"));
              },
              leading: Icon(
                Icons.code,
                size: 35,
                color: Colors.white,
              ),
              title: Text(
                "Source code",
                style: titleTextStyle,
              ),
              subtitle: Text(
                "https://github.com/Gr3gorywolf/MediaBlade",
                style: subTitleTextStyle,
              ),
              trailing: Icon(
                Icons.open_in_new,
                color: Colors.white,
              ),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                size: 35,
                color: Colors.white,
              ),
              title: Text(
                "App version",
                style: titleTextStyle,
              ),
              subtitle: Text(
                version,
                style: subTitleTextStyle,
              ),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            )
          ],
        ));
  }
}

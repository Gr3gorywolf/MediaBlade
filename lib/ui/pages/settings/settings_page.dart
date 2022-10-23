import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:media_blade/utils/file_system_helper.dart';
import 'package:media_blade/utils/settings_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var downloadUrl = "";
  var version = "";

  var titleTextStyle = TextStyle(color: Colors.white, fontSize: 12);
  var subTitleTextStyle = TextStyle(color: Colors.white, fontSize: 10);
  void init() async {
    var settedUrl =
        await SettingsHelper.getSetting(SettingKey.downloadPath) ?? "Not set";
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      downloadUrl = settedUrl;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

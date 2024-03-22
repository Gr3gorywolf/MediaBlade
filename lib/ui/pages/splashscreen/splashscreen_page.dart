import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:media_blade/utils/assets_helper.dart';
import 'package:media_blade/utils/download_history_helper.dart';
import 'package:media_blade/utils/file_system_helper.dart';
import 'package:media_blade/utils/settings_helper.dart';
import 'package:media_blade/utils/ytdl_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import '../../../utils/auth_helper.dart';
import '../../../utils/google_drive_helper.dart';

class SplashScreenPage extends StatefulWidget {
  final Function? onFullFilled;
  const SplashScreenPage({super.key, this.onFullFilled});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  var status = "Loading app";
  void initState() {
    super.initState();
    ToastContext().init(context);
    initApp();
  }

  initApp() async {
    if (Platform.isAndroid) {
      await initPlugins();
    }
    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      widget.onFullFilled!();
    });
  }

  Future initFS() async {
    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied || status.isDenied) {
      Map<Permission, PermissionStatus> statuses =
          await [Permission.storage].request();
      if (statuses[Permission.storage] == PermissionStatus.granted) {
        return;
      }
    }
  }

  Future initPlugins() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
    await SettingsHelper.initSettings();
    setState(() {
      status = "Initializing file system";
    });
    await initFS();
    await FileSystemHelper.createAppFolder();
    setState(() {
      status = "Syncing history";
    });
    await DownloadHistoryHelper.initHistory();
    setState(() {
      status = "Initializing scrappers";
    });
    YtdlHelper.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FadeIn(
      duration: Duration(milliseconds: 2000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetsHelper.getIcon("katana", size: 250),
          SizedBox(
            height: 10,
          ),
          Text(status, style: TextStyle(color: Colors.blue))
        ],
      ),
    )));
  }
}

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:media_blade/utils/assets_helper.dart';
import 'package:media_blade/utils/ytdl_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class SplashScreenPage extends StatefulWidget {
  final Function? onFullFilled;
  const SplashScreenPage({super.key, this.onFullFilled});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
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
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage
      ].request();
      if (statuses[Permission.storage] == PermissionStatus.granted &&
          statuses[Permission.manageExternalStorage] ==
              PermissionStatus.granted) {
        return;
      }
    }
  }

  Future initPlugins() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
    await initFS();
    YtdlHelper.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FadeIn(
      duration: Duration(milliseconds: 2000),
      child: AssetsHelper.getIcon("katana", size: 250),
    )));
  }
}

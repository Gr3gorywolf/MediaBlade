import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:media_blade/ui/pages/main/main_page.dart';
import 'package:media_blade/ui/pages/splashscreen/splashscreen_page.dart';
import 'package:media_blade/utils/ytdl_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isInitialized = false;

  void handleAppInitialized() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    setState(() => {this.isInitialized = true});
  }

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState(); 
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Widget buildHomePage() {
    if (!isInitialized) {
      return SplashScreenPage(
        onFullFilled: handleAppInitialized,
      );
    }
    return MainPage();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        highlightColor: Colors.white,
        appBarTheme: AppBarTheme(
            textTheme: TextTheme(
                headline4: TextStyle(color: Colors.white),
                subtitle1: TextStyle(color: Colors.white))),
        iconTheme: IconThemeData(color: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey[100]),
            helperStyle: TextStyle(color: Colors.white)),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[800],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: buildHomePage(),
    );
  }
}

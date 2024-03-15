import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';

import '../../../models/download_registry.dart';
import '../../../utils/common_helper.dart';
import '../../../utils/download_history_helper.dart';
import '../../../utils/file_system_helper.dart';
import '../../../utils/settings_helper.dart';
import '../../widgets/media_visualizer.dart';

class HistoryElementDetailsPage extends StatelessWidget {
  final File file;
  HistoryElementDetailsPage(this.file, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Media details")),
      body: MediaVisualizer(file: file),
      backgroundColor: Colors.black,
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_blade/get_controllers/download_history_controller.dart';
import 'package:media_blade/ui/pages/history/history_element.dart';
import 'package:media_blade/ui/pages/history/history_element_details.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/download_registry.dart';
import '../../../utils/common_helper.dart';
import '../../dialogs/download_dialog.dart';
import '../../widgets/video_preview.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DownloadHistoryController downloadHistoryController = Get.find();
  List<DownloadRegistry> get history {
    var historyList =
        downloadHistoryController.downloadHistory.value.values.toList();
    historyList.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return historyList;
  }

  refreshHistory() {
    downloadHistoryController.downloadHistory.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Download history"),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              downloadHistoryController.downloadHistory.refresh();
            },
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 9 / 11,
              children: List.generate(
                history.length,
                (index) {
                  return Obx(() {
                    var registry = history[index];
                    var fileExists = File(registry.fileUrl).existsSync();
                    return InkWell(
                        onTap: () => {
                              if (fileExists)
                                {
                                  Get.to(
                                      () => HistoryElementDetailsPage(registry))
                                }
                            },
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: HistoryElement(
                                    fileExists: fileExists,
                                    registry: registry))));
                  });
                },
              ),
            )));
  }
}

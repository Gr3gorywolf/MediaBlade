import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_blade/get_controllers/download_history_controller.dart';
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
    var historyList = downloadHistoryController.downloadHistory.values.toList();
    historyList.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return historyList;
  }

  void handleItemAction(DownloadRegistry registry, String action) {
    switch (action) {
      case 'download':
        DownloadDialog.show(context, registry.webpageUrl);
        break;
      case 'view':
        Get.to(() => HistoryElementDetailsPage(
            File.fromUri(Uri.parse(registry.fileUrl))));
        break;
      case 'open':
        launchUrl(Uri.parse(registry.webpageUrl));
        break;
      case 'share':
        Share.shareXFiles([XFile(registry.fileUrl)]);
        break;
    }
  }

  Widget buildListItemInfo(DownloadRegistry registry,
      {required Widget children, required bool fileExists}) {
    const infoTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );
    var isFromWsp = registry.image ==
        CommonHelper().getWebpageFavicon("https://web.whatsapp.com");
    return Stack(fit: StackFit.expand, children: [
      children,
      Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5), // Semi-transparent black color
          alignment: Alignment.center, // Center the content
        ),
      ),
      registry.type == "video" && fileExists
          ? Center(
              child: Icon(Icons.play_arrow, size: 50),
            )
          : Container(),
      Positioned.fill(
        child: Container(
          padding: EdgeInsets.only(right: 40, top: 10, left: 10),
          child: Text(registry.title,
              overflow: TextOverflow.ellipsis, style: infoTextStyle),
        ),
      ),
      Positioned(
        top: 10,
        right: 10,
        child: PopupMenuButton<String>(
          child: Icon(
            Icons.more_vert,
            size: 18,
            color: Colors.white,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: !isFromWsp && !fileExists,
              value: 'download',
              child: Text('Download'),
            ),
            PopupMenuItem(
              enabled: fileExists,
              value: 'share',
              child: Text('Share'),
            ),
            PopupMenuItem(
              enabled: fileExists,
              value: 'view',
              child: Text('View'),
            ),
            PopupMenuItem(
              enabled: !isFromWsp,
              value: 'open',
              child: Text('Open source url'),
            ),
          ],
          onSelected: (value) => handleItemAction(registry, value),
        ),
      ),
      Positioned(
          bottom: 10,
          left: 10,
          child: Row(children: [
            Image.network(CommonHelper().getWebpageFavicon(registry.webpageUrl),
                width: 14, height: 14),
            SizedBox(width: 2),
            Icon(
              fileExists ? Icons.file_download : Icons.file_download,
              size: 18,
              color: fileExists ? Colors.green : Colors.red,
            ),
            SizedBox(width: 2),
            Text(CommonHelper().formatDate(registry.downloadedAt),
                style: infoTextStyle)
          ]))
    ]);
  }

  Widget buildListItem(DownloadRegistry registry, bool fileExists) {
    if (registry.type == 'video' && fileExists) {
      return buildListItemInfo(
        registry,
        fileExists: fileExists,
        children: VideoPreview(File.fromUri(Uri.parse(registry.fileUrl))),
      );
    }
    return buildListItemInfo(registry,
        fileExists: fileExists,
        children: fileExists && registry.type == 'image'
            ? Image.file(File(registry.fileUrl), fit: BoxFit.cover)
            : Image.network(registry.image, fit: BoxFit.cover));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Download history"),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 9 / 11,
          children: List.generate(
            history.length,
            (index) {
              var registry = history[index];
              var fileExists = File(registry.fileUrl).existsSync();
              return InkWell(
                  onTap: () => {
                        if (fileExists) {handleItemAction(registry, "view")}
                      },
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: buildListItem(registry, fileExists))));
            },
          ),
        ));
  }
}

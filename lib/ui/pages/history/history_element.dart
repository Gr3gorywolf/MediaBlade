import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:media_blade/constants/common_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/download_registry.dart';
import '../../../utils/common_helper.dart';
import '../../dialogs/download_dialog.dart';
import '../../widgets/video_preview.dart';
import 'history_element_details.dart';

class HistoryElement extends StatefulWidget {
  DownloadRegistry registry;
  bool fileExists;
  HistoryElement({required this.registry, required this.fileExists, super.key});

  @override
  State<HistoryElement> createState() => _HistoryElementState();
}

class _HistoryElementState extends State<HistoryElement> {
  get isPlayableKind {
    return ['audio', 'video'].contains(widget.registry.type);
  }

  void handleItemAction(String action) {
    switch (action) {
      case 'download':
        DownloadDialog.show(context, widget.registry.downloadUrl);
        break;
      case 'view':
        Get.to(() => HistoryElementDetailsPage(
            File.fromUri(Uri.parse(widget.registry.fileUrl))));
        break;
      case 'open':
        launchUrl(Uri.parse(widget.registry.downloadUrl));
        break;
      case 'share':
        Share.shareXFiles([XFile(widget.registry.fileUrl)]);
        break;
    }
  }

  Widget buildListItemInfo(
      {required Widget children, required bool fileExists}) {
    const infoTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
    );
    var isFromWsp = widget.registry.image ==
        CommonHelper().getWebpageFavicon("https://web.whatsapp.com");
    return Stack(fit: StackFit.expand, children: [
      children,
      Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5), // Semi-transparent black color
          alignment: Alignment.center, // Center the content
        ),
      ),
      isPlayableKind && fileExists
          ? Center(
              child: Icon(Icons.play_arrow, size: 50),
            )
          : Container(),
      Positioned.fill(
        child: Container(
          padding: EdgeInsets.only(right: 40, top: 10, left: 27),
          child: Text(widget.registry.title,
              overflow: TextOverflow.ellipsis, style: infoTextStyle),
        ),
      ),
      Positioned(
        top: 10.5,
        left: 10,
        child: Image.network(
            CommonHelper().getWebpageFavicon(widget.registry.downloadUrl),
            width: 13,
            height: 13),
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
          onSelected: (value) => handleItemAction(value),
        ),
      ),
      Positioned(
          bottom: 10,
          left: 10,
          child: Row(children: [
            Icon(
              fileExists ? Icons.file_download : Icons.file_download,
              size: 14,
              color: fileExists ? Colors.green : Colors.red,
            ),
            SizedBox(width: 2),
            Icon(
              media_type_icons[widget.registry.type],
              size: 13,
            ),
            SizedBox(width: 2),
            Text(CommonHelper().formatDate(widget.registry.downloadedAt),
                style: infoTextStyle)
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.registry.type == 'video' && widget.fileExists) {
      return buildListItemInfo(
        fileExists: widget.fileExists,
        children:
            VideoPreview(File.fromUri(Uri.parse(widget.registry.fileUrl))),
      );
    }
    return buildListItemInfo(
        fileExists: widget.fileExists,
        children: widget.fileExists && widget.registry.type == 'image'
            ? Image.file(File(widget.registry.fileUrl), fit: BoxFit.cover)
            : Image.network(widget.registry.image, fit: BoxFit.cover));
  }
}

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

class WhatsappStatusExtractorDetailsPage extends StatefulWidget {
  final File file;
  WhatsappStatusExtractorDetailsPage(this.file, {Key? key}) : super(key: key);

  @override
  State<WhatsappStatusExtractorDetailsPage> createState() =>
      _WhatsappStatusExtractorDetailsPageState();
}

class _WhatsappStatusExtractorDetailsPageState
    extends State<WhatsappStatusExtractorDetailsPage> {
  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    
  }

  void downloadFile() async {
    var path = await SettingsHelper.getSetting(SettingKey.downloadPath);
    if (path == null) {
      path = await FileSystemHelper.requestNewPath(context);
      await SettingsHelper.setSetting(SettingKey.downloadPath, path);
    }
    if (path == null) {
      return;
    }
    try {
      var newFilePath = path + '/' + widget.file.uri.pathSegments.last;
      var isVideo = widget.file.uri.toFilePath().contains('.mp4');
      var lastModified = await widget.file.lastModified();
      if (!File(newFilePath).existsSync()) {
        await widget.file.copy(newFilePath);
        if (isVideo) {
          await GallerySaver.saveVideo(newFilePath);
        } else {
          await GallerySaver.saveImage(newFilePath);
        }
        DownloadHistoryHelper.insertDownloadToHistory(DownloadRegistry(
            title: "Whatsapp status ${CommonHelper().formatDate(lastModified)}",
            downloadUrl:
                "https://web.whatsapp.com/${widget.file.uri.pathSegments.last}",
            webpageUrl:
                "https://web.whatsapp.com/${widget.file.uri.pathSegments.last}",
            fileUrl: newFilePath,
            image: CommonHelper().getWebpageFavicon("https://web.whatsapp.com"),
            type: isVideo ? 'video' : 'audio',
            downloadedAt: DateTime.now()));
      }

      Toast.show("File downloaded!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    } on Exception catch (err) {
      Toast.show("Failed to retrieve the file!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status details")),
      body: MediaVisualizer(file: widget.file),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => downloadFile(),
        label: Text("Download"),
        icon: Icon(Icons.download),
      ),
    );
  }
}

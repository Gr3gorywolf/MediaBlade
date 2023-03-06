import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:toast/toast.dart';

import '../../../utils/file_system_helper.dart';
import '../../../utils/settings_helper.dart';
import '../../widgets/video_preview.dart';

class WhatsappStatusExtractorPage extends StatefulWidget {
  const WhatsappStatusExtractorPage({super.key});

  @override
  State<WhatsappStatusExtractorPage> createState() =>
      _WhatsappStatusExtractorPageState();
}

class _WhatsappStatusExtractorPageState
    extends State<WhatsappStatusExtractorPage> {
  var isLoading = false;
  var files = [];

  void fetchWhatsappCache() async {
    setState(() {
      isLoading = true;
    });
    final dir = Directory(
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');
    if (dir.existsSync()) {
      List<File> fetchedFiles = <File>[];
      await for (FileSystemEntity entity
          in dir.list(recursive: false, followLinks: false)) {
        FileSystemEntityType type = await FileSystemEntity.type(entity.path);
        if (type == FileSystemEntityType.file) {
          fetchedFiles.add(entity as File);
        }
      }
      fetchedFiles.sort((a, b) =>
          b.lastModifiedSync().microsecondsSinceEpoch -
          a.lastModifiedSync().microsecondsSinceEpoch);
      fetchedFiles = fetchedFiles
          .where((element) => !element.uri.toFilePath().contains('nomedia'))
          .toList();
      setState(() => {files = fetchedFiles});
    } else {
      Toast.show("Whatsapp cache not found!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
      Navigator.pop(context);
    }
    setState(() {
      isLoading = false;
    });
  }

  void copyToDownloads(File file) async {
    var path = await SettingsHelper.getSetting(SettingKey.downloadPath);
    if (path == null) {
      path = await FileSystemHelper.requestNewPath(context);
      await SettingsHelper.setSetting(SettingKey.downloadPath, path);
    }
    if (path == null) {
      return;
    }
    try {
      var newFilePath = path + '/' + file.uri.pathSegments.last;
      if (!File(newFilePath).existsSync()) {
        await file.copy(newFilePath);
        if (file.uri.toFilePath().contains('.mp4')) {
          await GallerySaver.saveVideo(newFilePath);
        } else {
          await GallerySaver.saveImage(newFilePath);
        }
      }

      Toast.show("File downloaded!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    } on Exception catch (err) {
      print(err);
      Toast.show("Failed to retrieve the file!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  Widget buildImage(File file) {
    if (file.uri.toFilePath().contains('.mp4')) {
      return VideoPreview(file);
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
    );
  }

  @override
  void initState() {
    ToastContext().init(context);
    super.initState();
    this.fetchWhatsappCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Whatsapp status extractor")),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                files.length,
                (index) {
                  return InkWell(
                      onTap: () => copyToDownloads(files[index]),
                      child: Card(
                        margin: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: buildImage(files[index]),
                        ),
                      ));
                },
              ),
            ),
    );
  }
}

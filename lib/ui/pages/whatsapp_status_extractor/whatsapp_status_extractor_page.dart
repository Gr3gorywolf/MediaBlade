import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:media_blade/ui/pages/whatsapp_status_extractor/whatsapp_status_extractor_details_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import '../../../utils/alerts_helper.dart';
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

  Future<bool> requestManageStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // ignore: use_build_context_synchronously
      AlertsHelper.showAlertDialog(context, "Warning",
          "The Watsapp's statuses folder are hidden so you have to grant the manage storage permission to proceed",
          buttons: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                )),
            TextButton(
                onPressed: () {
                  Permission.manageExternalStorage.request().then((value) {
                    if (value == PermissionStatus.granted) {
                      fetchWhatsappCache();
                    }
                    Navigator.pop(context);
                  });
                },
                child: const Text("Grant"))
          ]);
      return false;
    }
    return true;
  }

  Future<void> fetchWhatsappCache() async {
    setState(() {
      isLoading = true;
    });
    if (!await requestManageStoragePermission()) {
      setState(() {
        isLoading = false;
      });
      return;
    }
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

  void goToDetails(File file) async {
    var mediaType = file.uri.toFilePath().contains('.mp4') ? 'video' : 'image';
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WhatsappStatusExtractorDetailsPage(file, mediaType)));
  }

  Widget buildImage(File file) {
    if (file.uri.toFilePath().contains('.mp4')) {
      return Stack(children: [
        VideoPreview(file),
        Center(
          child: Icon(Icons.play_arrow, size: 50),
        )
      ]);
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
          : RefreshIndicator(
              onRefresh: fetchWhatsappCache,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 9 / 11,
                children: List.generate(
                  files.length,
                  (index) {
                    return InkWell(
                        onTap: () => goToDetails(files[index]),
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: buildImage(files[index]))));
                  },
                ),
              ),
            ),
    );
  }
}

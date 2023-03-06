import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/file_system_helper.dart';
import '../../../utils/settings_helper.dart';

class WhatsappStatusExtractorDetailsPage extends StatefulWidget {
  final File file;
  WhatsappStatusExtractorDetailsPage(this.file, {Key? key}) : super(key: key);

  @override
  State<WhatsappStatusExtractorDetailsPage> createState() =>
      _WhatsappStatusExtractorDetailsPageState();
}

class _WhatsappStatusExtractorDetailsPageState
    extends State<WhatsappStatusExtractorDetailsPage> {
  late VideoPlayerController _controller;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _controller = VideoPlayerController.file(widget.file,
        videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: false, mixWithOthers: false))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.play();
        _controller.setLooping(true);
        setState(() {
          _controller;
        });
      });
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
      if (!File(newFilePath).existsSync()) {
        await widget.file.copy(newFilePath);
        if (widget.file.uri.toFilePath().contains('.mp4')) {
          await GallerySaver.saveVideo(newFilePath);
        } else {
          await GallerySaver.saveImage(newFilePath);
        }
      }

      Toast.show("File downloaded!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    } on Exception catch (err) {
      Toast.show("Failed to retrieve the file!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  void handleVideoTap() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _controller;
    });
  }

  Widget buildBody() {
    if (widget.file.uri.toFilePath().contains('.mp4')) {
      return GestureDetector(
        onTap: () => handleVideoTap(),
        child: Stack(children: [
          Center(
            child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller)),
          ),
          !_controller.value.isPlaying
              ? Center(
                  child: Icon(Icons.play_arrow, size: 50),
                )
              : Container()
        ]),
      );
    }

    return Center(
      child: Image.file(widget.file),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status details")),
      body: buildBody(),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => downloadFile(),
        label: Text("Download"),
        icon: Icon(Icons.download),
      ),
    );
  }
}

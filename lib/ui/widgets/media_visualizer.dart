import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaVisualizer extends StatefulWidget {
  File file;
  MediaVisualizer({super.key, required this.file});

  @override
  State<MediaVisualizer> createState() => _MediaVisualizerState();
}

class _MediaVisualizerState extends State<MediaVisualizer> {
  late VideoPlayerController _controller;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
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
}

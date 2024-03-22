import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaVisualizer extends StatefulWidget {
  File file;
  String mediaType;
  String? imageUrl;
  MediaVisualizer(
      {super.key, required this.file, required this.mediaType, this.imageUrl});

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
    //Video media type
    if (['video', 'audio'].contains(widget.mediaType)) {
      return Stack(children: [
        GestureDetector(
          onTap: handleVideoTap,
          child: widget.mediaType == 'video'
              ? Center(
                  child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller)),
                )
              : Center(
                  child: Image.network(
                  widget.imageUrl ?? '',
                  fit: BoxFit.cover,
                )),
        ),
        !_controller.value.isPlaying
            ? Center(
                child: IconButton(
                    onPressed: handleVideoTap,
                    icon: Icon(Icons.play_arrow, size: 50)),
              )
            : Container(),
        Positioned(
            bottom: 17,
            width: MediaQuery.of(context).size.width,
            child: VideoProgressIndicator(_controller,
                colors: VideoProgressColors(playedColor: Colors.white),
                allowScrubbing: true)),
      ]);
    }
    if (widget.mediaType == 'image') {
      return Center(
        child: Image.file(widget.file),
      );
    }
    return Container();
  }
}

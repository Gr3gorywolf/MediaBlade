import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:media_blade/models/media_results.dart';
import 'package:media_blade/utils/ytdl_helper.dart';
import 'package:toast/toast.dart';


class DownloadDialog extends StatefulWidget {
  final String? url;
  const DownloadDialog({super.key, this.url});
  static show(BuildContext context, String url) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DownloadDialog(
              url: url,
            ));
  }

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  MediaResults? results;
  int selectedTab = 0;
  final mediaTypes = ['image', 'video', 'audio'];

  void fetchResults() async {
    try {
      var res = await YtdlHelper.getMediaResults(widget.url ?? '');
      setState(() {
        results = res;
      });
    } on Exception catch (err) {
      print(err.toString());
      //Navigator.pop(context);
      Toast.show("Failed to retrieve the content");
    }
  }

  List<Formats> getSelectedMedia({String? type}) {
    type ??= mediaTypes[selectedTab];
    if (results != null) {
      return results?.formats?.where((element) {
            switch (type) {
              case 'image':
                return element.acodec == 'none' && element.vcodec == 'none';
              case 'video':
                return element.acodec != 'none' && element.vcodec != 'none';
              case 'audio':
                return element.acodec != 'none' && element.vcodec == 'none';
              default:
                return false;
            }
          }).toList() ??
          [];
    }
    return [];
  }

  void startDownload(Formats format) async {
    var title = results?.title ?? "";
    var extension = results?.ext ?? "";
    try {
     
      FlutterDownloader.enqueue(
        url: format.url ?? '',
        savedDir: '/storage/emulated/0/Download',
        saveInPublicStorage: true,
        fileName: "$title.$extension",
        showNotification: true,
        openFileFromNotification: true,
      );
       Toast.show("Download started");
      
    } on Exception catch (err) {
      Toast.show("Failed to download file");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchResults();
  }

  Widget buildFormats() {
    var selectedMedia = getSelectedMedia();
    const icons = [
      Icon(Icons.image),
      Icon(Icons.video_library_sharp),
      Icon(Icons.audio_file)
    ];
    return Column(children: [
      DefaultTabController(
          length: 3,
          child: TabBar(
            onTap: (tabIndex) {
              setState(() {
                selectedTab = tabIndex;
              });
            },
            tabs: icons.map((e) {
              return Tab(
                icon: e,
              );
            }).toList(),
          )),
      Container(
        height: 60,
        child: ListView.builder(
          itemCount: selectedMedia.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var format = selectedMedia[index];
            var title = "[${format.ext}] ${format.format}";
            return Container(
              margin: EdgeInsets.only(right: 10, top: 15),
              child: InkWell(
                  onTap: () {
                    startDownload(format);
                  },
                  child: Chip(
                    avatar: CircleAvatar(
                      foregroundColor: Colors.blue,
                      child: icons[selectedTab],
                    ),
                    label: Text(title),
                  )),
            );
          },
        ),
      )
    ]);
  }

  List<Widget> buildContent() {
    if (results == null) {
      return [
        Center(
          child: Container( margin: EdgeInsets.all(10),child: CircularProgressIndicator()),
        )
      ];
    }
    return [
      Row(
        children: [
          Image.network(
            results?.thumbnail ?? '',
            height: 96,
            width: 96,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    results?.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${results?.description}",
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
                mainAxisSize: MainAxisSize.min),
          ),
        ],
      ),
      buildFormats()
      //  Row(
      //   mainAxisSize: MainAxisSize.min,
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     SizedBox(
      //       width: 12,
      //     ),
      //     IconButton(
      //       onPressed: handleShare,
      //       icon: Icon(
      //         Icons.share,
      //         size: _iconsSize,
      //       ),
      //       color: Colors.green,
      //     ),
      //   ],
      // )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 2,
            color: Colors.blue,
            margin: EdgeInsets.only(bottom: 10),
          ),
          ...buildContent(),
        ]),
      ),
    );
  }
}

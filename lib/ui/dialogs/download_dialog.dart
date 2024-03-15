import 'dart:io';
import 'package:path/path.dart' as CustomPath;
import 'package:animate_do/animate_do.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:media_blade/models/download_registry.dart';
import 'package:media_blade/models/enums/media_types.dart';
import 'package:media_blade/models/media_results.dart';
import 'package:media_blade/utils/common_helper.dart';
import 'package:media_blade/utils/download_history_helper.dart';
import 'package:media_blade/utils/file_system_helper.dart';
import 'package:media_blade/utils/settings_helper.dart';
import 'package:media_blade/utils/ytdl_helper.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadDialog extends StatefulWidget {
  final String? url;
  final bool fromIntent;
  const DownloadDialog({super.key, this.url, this.fromIntent = false});
  static show(BuildContext context, String url, {bool fromIntent = false}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => DownloadDialog(
              url: url,
              fromIntent: fromIntent,
            ));
  }

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  MediaResults? results;
  int selectedTab = 0;
  var mappedFormats = Map<String, List<Formats>>();
  Map<String, IconData> icons = {
    'video': Icons.video_collection_rounded,
    'audio': Icons.audiotrack,
    'image': Icons.image,
  };

  MediaTypes getFormatType(Formats format) {
    if (format.acodec == 'none' && format.vcodec == 'none') {
      return MediaTypes.image;
    }
    if (format.acodec != 'none' && format.vcodec != 'none') {
      return MediaTypes.video;
    }
    if (format.acodec != 'none' && format.vcodec == 'none') {
      return MediaTypes.audio;
    }
    return MediaTypes.undefined;
  }

  void fetchResults() async {
    try {
      var res = await YtdlHelper.getMediaResults(widget.url ?? '');
      mappedFormats.clear();
      if ((res.formats ?? []).isEmpty) {
        throw Exception("Failed");
      }
      res.formats?.forEach((format) {
        var type = getFormatType(format);
        if (type != MediaTypes.undefined) {
          var formatsArray = mappedFormats[type.name] ?? [];
          mappedFormats[type.name] = [...formatsArray, format];
        }
      });
      setState(() {
        mappedFormats;
        results = res;
      });
    } on Exception catch (err) {
      print(err.toString());
      Toast.show("Failed to retrieve the content",
          duration: Toast.lengthLong, gravity: Toast.bottom);

      Navigator.pop(context);
    }
  }

  void startDownload(Formats format) async {
    var normalizedTitle =
        CommonHelper().normalizeFilename(results?.title ?? "");
    var extension = results?.ext ?? "";
    var hash = CommonHelper().createHash(results?.webpageUrl ?? "");
    var path = await SettingsHelper.getSetting(SettingKey.downloadPath);
    if (path == null) {
      path = await FileSystemHelper.requestNewPath(context);
      await SettingsHelper.setSetting(SettingKey.downloadPath, path);
    }
    if (path == null) {
      return;
    }
    var closeIfIntent =
        await SettingsHelper.getSetting(SettingKey.closeIfIntent) == 'true' ??
            false;
    try {
      var fileName = "$normalizedTitle-$hash.$extension";
      FlutterDownloader.enqueue(
        url: format.url ?? '',
        savedDir: path,
        saveInPublicStorage: true,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      Toast.show("Download started");
      DownloadHistoryHelper.insertDownloadToHistory(DownloadRegistry(
          title: results?.title ?? "",
          downloadUrl: results?.webpageUrl ?? '',
          webpageUrl: results?.webpageUrl ?? '',
          fileUrl: CustomPath.join(path, fileName),
          image: results?.thumbnail ?? '',
          type: getFormatType(format).name,
          downloadedAt: DateTime.now()));
      if (closeIfIntent && widget.fromIntent) {
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } on Exception catch (err) {
      Toast.show("Failed to download file");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ToastContext().init(context);
    fetchResults();
  }

  Widget buildMediaInfo() {
    return Row(
      children: [
        Image.network(
          results?.thumbnail ?? '',
          height: 45,
          width: 45,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                results?.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                "${results?.webpageUrl}",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFormatsTabBar() {
    return mappedFormats.isNotEmpty
        ? DefaultTabController(
            length: mappedFormats.keys.length,
            child: TabBar(
              onTap: (tabIndex) {
                setState(() {
                  selectedTab = tabIndex;
                });
              },
              tabs: mappedFormats.keys.map((e) {
                return Tab(
                  icon: Icon(icons[e]),
                );
              }).toList(),
            ))
        : Container();
  }

  Widget buildFormatsList({ScrollController? scrollController}) {
    var selectedMediaType = mappedFormats.keys.toList()[selectedTab];
    var selectedMedia = mappedFormats[selectedMediaType] ?? [];
    return Expanded(
      child: ListView.builder(
        itemCount: selectedMedia.length,
        scrollDirection: Axis.vertical,
        controller: scrollController,
        itemBuilder: (context, index) {
          var format = selectedMedia[index];
          var title = format.format ?? '';
          var size = 0;
          if ((format.filesize ?? 0) > 0) {
            size = format.filesize ?? 0;
          }
          if ((format.filesizeApprox ?? 0) > 0) {
            size = format.filesize ?? 0;
          }
          var formattedSize = CommonHelper().formatBytes(size, 2);
          var icon = icons[selectedMediaType];
          return ListTile(
            leading: Icon(icon ?? Icons.abc, color: Colors.white, size: 40),
            title: Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "${format.ext}  ${formattedSize}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () => {startDownload(format)},
                    icon: Icon(
                      Icons.download,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () => {launchUrl(Uri.parse(format.url ?? ''))},
                    icon: Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildContent({ScrollController? scrollController}) {
    if (results == null) {
      return [
        Expanded(
          child: Center(
            child: Container(
                margin: EdgeInsets.all(10), child: CircularProgressIndicator()),
          ),
        )
      ];
    }
    return [
      buildMediaInfo(),
      Container(margin: EdgeInsets.only(top: 10), child: buildFormatsTabBar()),
      buildFormatsList(scrollController: scrollController)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.43,
      minChildSize: 0.2,
      maxChildSize: 0.75,
      builder: (ctx, controller) {
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80,
              height: 2,
              color: Colors.blue,
              margin: EdgeInsets.only(bottom: 20),
            ),
            ...buildContent(scrollController: controller),
          ]),
        );
      },
    );
  }
}

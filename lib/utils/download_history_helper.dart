import 'dart:io';
import 'package:json_store/json_store.dart';
import 'package:get/get.dart';
import 'package:media_blade/constants/common_constants.dart';
import 'package:media_blade/get_controllers/download_history_controller.dart';
import 'package:media_blade/models/download_registry.dart';

import 'common_helper.dart';

class DownloadHistoryHelper {
  static var _historyFileUrl = app_directory_url + '/mediablade_history.json';
  static late JsonStore jsonStore;

  static Future<List<DownloadRegistry>> _readDownloadHistory() async {
    var registries = await jsonStore.getListLike('download-registry%');
    if (registries == null) {
      return [];
    }
    return registries.map((e) => DownloadRegistry.fromJson(e)).toList();
  }

  static Future<void> initHistory() async {
    jsonStore = JsonStore(
      dbName: '/mediablade_history',
      dbLocation: Directory(app_directory_url),
    );

    var history = await DownloadHistoryHelper._readDownloadHistory();
    final DownloadHistoryController c = Get.find();
    c.setHistory(history);
  }

  static Future<void> insertDownloadToHistory(DownloadRegistry registry) async {
    var registryId =
        CommonHelper().createHash(registry.downloadUrl, maxLength: 20);
    await jsonStore.setItem(
        "download-registry-$registryId-${registry.type}", registry.toJson());
    final DownloadHistoryController c = Get.find();
    c.setRegistry(registry);
  }
}

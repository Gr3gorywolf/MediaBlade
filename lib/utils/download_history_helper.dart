import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:json_store/json_store.dart';
import 'package:get/get.dart';
import 'package:media_blade/constants/common_constants.dart';
import 'package:media_blade/get_controllers/download_history_controller.dart';
import 'package:media_blade/models/download_registry.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'common_helper.dart';

class DownloadHistoryHelper {
  static var _backupFilePath = app_directory_url + '/mediablade_history.db';
  static const dbName = 'mediablade_history';
  static late JsonStore jsonStore;
  static Future<String> _getAppDatabasePath() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "storage/emulated/0/Android/data/${packageInfo.packageName}/databases";
  }

  static Future<File> _getDatabaseFile() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    return File("${documentsDirectory.path}/$dbName.db");
  }

  static Future<List<DownloadRegistry>> _readDownloadHistory() async {
    var registries = await jsonStore.getListLike('download-registry%');
    if (registries == null) {
      return [];
    }
    return registries.map((e) => DownloadRegistry.fromJson(e)).toList();
  }

  static Future<void> initHistory() async {
    jsonStore = JsonStore(dbName: "/$dbName");
    var history = await DownloadHistoryHelper._readDownloadHistory();
    final DownloadHistoryController c = Get.find();
    c.setHistory(history);
  }

  static Future<bool> mergeCloudHistory(String tmpDatabasePath) async {
    var cloudData =
        await jsonStore.getTempDatabaseData(databaseName: tmpDatabasePath);
    final DownloadHistoryController currentHistory = Get.find();
    if (cloudData != null) {
      var cloudHistory =
          cloudData.map((e) => DownloadRegistry.fromJson(e)).toList();
      var batch = await jsonStore.startBatch();
      await Future.forEach(cloudHistory, (registry) async {
        var itemKey = "download-registry-${registry.id}-${registry.type}";
        if (currentHistory.downloadHistory.containsKey(itemKey)) {
          registry.fileUrl =
              currentHistory.downloadHistory[itemKey]?.fileUrl ?? '';
        }
        await jsonStore.setItem(
          itemKey,
          registry.toJson(),
          batch: batch,
        );
      });
      await jsonStore.commitBatch(batch);
      await initHistory();
      return true;
    } else {
      return false;
    }
  }

  static Future<void> insertDeleteDownloadFromRegistry(
      DownloadRegistry registry) async {
    var itemKey = "download-registry-${registry.id}-${registry.type}";
    await jsonStore.deleteItem(itemKey);
    final DownloadHistoryController c = Get.find();
    c.deleteRegistry(registry);
  }

  static Future<void> insertDownloadToHistory(DownloadRegistry registry) async {
    var itemKey = "download-registry-${registry.id}-${registry.type}";
    var oldItem = await jsonStore.getItem(itemKey);
    late DownloadRegistry newRegistry;
    if (oldItem != null) {
      newRegistry = DownloadRegistry.fromJson(oldItem);
      newRegistry.fileUrl = registry.fileUrl;
    } else {
      newRegistry = registry;
    }

    await jsonStore.setItem(itemKey, newRegistry.toJson());
    final DownloadHistoryController c = Get.find();
    c.setRegistry(registry);
  }
}

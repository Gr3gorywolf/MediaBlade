import 'package:get/get.dart';
import 'package:media_blade/models/download_registry.dart';
import 'package:media_blade/utils/common_helper.dart';

class DownloadHistoryController extends GetxController {
  RxMap<String, DownloadRegistry> downloadHistory =
      RxMap<String, DownloadRegistry>();
  _composeRegistryKey(DownloadRegistry registry) {
    return '${CommonHelper().createHash(registry.downloadUrl, maxLength: 20)}-${registry.type}';
  }

  setHistory(List<DownloadRegistry> history) {
    for (var element in history) {
      downloadHistory.putIfAbsent(_composeRegistryKey(element), () => element);
    }
  }

  setRegistry(DownloadRegistry newRegistry) {
    downloadHistory.putIfAbsent(
        _composeRegistryKey(newRegistry), () => newRegistry);
  }
}

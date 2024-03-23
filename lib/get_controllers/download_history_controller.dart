import 'package:get/get.dart';
import 'package:media_blade/models/download_registry.dart';

class DownloadHistoryController extends GetxController {
  RxMap<String, DownloadRegistry> downloadHistory =
      RxMap<String, DownloadRegistry>();
  _composeRegistryKey(DownloadRegistry registry) {
    return 'download-registry-${registry.id}-${registry.type}';
  }

  setHistory(List<DownloadRegistry> history) {
    for (var element in history) {
      downloadHistory[_composeRegistryKey(element)] = element;
    }
  }

  deleteRegistry(DownloadRegistry registry) {
    downloadHistory.remove(_composeRegistryKey(registry));
  }

  setRegistry(DownloadRegistry newRegistry) {
    downloadHistory[_composeRegistryKey(newRegistry)] = newRegistry;
  }
}

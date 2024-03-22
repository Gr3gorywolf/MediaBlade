import 'package:get/get.dart';
import 'package:media_blade/models/download_registry.dart';

class UpdatesController extends GetxController {
  var showDownloadDialog = true.obs;
  disableDownloadDialog() {
    showDownloadDialog = false.obs;
  }
}

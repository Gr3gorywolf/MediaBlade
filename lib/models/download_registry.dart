import 'package:media_blade/utils/common_helper.dart';
import 'package:media_blade/utils/settings_helper.dart';

class DownloadRegistry {
  late String title;
  late String downloadUrl;
  late String image;
  late String type;
  late DateTime downloadedAt;
  String get fileUrl {
    return _perDevicePaths[SettingsHelper.deviceId] ?? '';
  }

  set fileUrl(String newFileUrl) {
    _perDevicePaths[SettingsHelper.deviceId] = newFileUrl;
  }

  get id {
    return CommonHelper().createHash(downloadUrl, maxLength: 20);
  }

  Map<String, String> _perDevicePaths = new Map<String, String>();
  DownloadRegistry(
      {required this.title,
      required this.downloadUrl,
      required fileUrl,
      required this.image,
      required this.type,
      required this.downloadedAt}) {
    this.fileUrl = fileUrl;
  }

  DownloadRegistry.fromJson(Map<String, dynamic> json) {
    _perDevicePaths = CommonHelper().convertMap(json['fileUrls']);
    title = json['title'];
    downloadUrl = json['downloadUrl'];
    image = json['image'];
    type = json['type'];
    downloadedAt = DateTime.parse(json['downloadedAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = title;
    data['downloadUrl'] = downloadUrl;
    data['image'] = image;
    data['type'] = type;
    data['fileUrls'] = _perDevicePaths;
    data['downloadedAt'] = downloadedAt.toString();
    return data;
  }
}

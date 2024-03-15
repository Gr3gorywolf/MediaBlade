class DownloadRegistry {
  late String title;
  late String downloadUrl;
  late String webpageUrl;
  late String fileUrl;
  late String image;
  late String type;
  late DateTime downloadedAt;

  DownloadRegistry(
      {required this.title,
      required this.downloadUrl,
      required this.webpageUrl,
      required this.fileUrl,
      required this.image,
      required this.type,
      required this.downloadedAt});

  DownloadRegistry.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    downloadUrl = json['downloadUrl'];
    webpageUrl = json['webpageUrl'];
    fileUrl = json['fileUrl'];
    image = json['image'];
    type = json['type'];
    downloadedAt = DateTime.parse(json['downloadedAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = title;
    data['downloadUrl'] = downloadUrl;
    data['webpageUrl'] = webpageUrl;
    data['fileUrl'] = fileUrl;
    data['image'] = image;
    data['type'] = type;
    data['downloadedAt'] = downloadedAt.toString();
    return data;
  }
}

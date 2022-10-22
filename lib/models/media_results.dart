class MediaResults {
  List<dynamic>? categories;
  String? description;
  int? duration;
  String? ext;
  String? extractor;
  String? format;
  List<Formats>? formats;
  String? fulltitle;
  int? height;
  String? id;
  String? license;
  String? resolution;
  List<dynamic>? tags;
  String? thumbnail;
  List<Thumbnails>? thumbnails;
  String? title;
  String? uploader;
  String? url;
  int? width;
  dynamic averageRating;
  int? dislikeCount;
  String? displayId;
  String? extractorKey;
  int? filesize;
  int? filesizeApprox;
  String? formatId;
  HttpHeaders? httpHeaders;
  String? likeCount;
  String? manifestUrl;
  String? playerUrl;
  String? repostCount;
  dynamic requestedFormats;
  String? uploadDate;
  String? uploaderId;
  String? viewCount;
  String? webpageUrl;
  String? webpageUrlBasename;

  MediaResults(
      {this.categories,
      this.description,
      this.duration,
      this.ext,
      this.extractor,
      this.format,
      this.formats,
      this.fulltitle,
      this.height,
      this.id,
      this.license,
      this.resolution,
      this.tags,
      this.thumbnail,
      this.thumbnails,
      this.title,
      this.uploader,
      this.url,
      this.width,
      this.averageRating,
      this.dislikeCount,
      this.displayId,
      this.extractorKey,
      this.filesize,
      this.filesizeApprox,
      this.formatId,
      this.httpHeaders,
      this.likeCount,
      this.manifestUrl,
      this.playerUrl,
      this.repostCount,
      this.requestedFormats,
      this.uploadDate,
      this.uploaderId,
      this.viewCount,
      this.webpageUrl,
      this.webpageUrlBasename});

  MediaResults.fromJson(Map<String, dynamic> json) {
    categories = json['categories'];
    description = json['description'];
    duration = json['duration'];
    ext = json['ext'];
    extractor = json['extractor'];
    format = json['format'];
    if (json['formats'] != null) {
      formats = <Formats>[];
      json['formats'].forEach((v) {
        formats!.add(new Formats.fromJson(v));
      });
    }
    fulltitle = json['fulltitle'];
    height = json['height'];
    id = json['id'];
    license = json['license'];
    resolution = json['resolution'];
    tags = json['tags'];
    thumbnail = json['thumbnail'];
    if (json['thumbnails'] != null) {
      thumbnails = <Thumbnails>[];
      json['thumbnails'].forEach((v) {
        thumbnails!.add(new Thumbnails.fromJson(v));
      });
    }
    title = json['title'];
    uploader = json['uploader'];
    url = json['url'];
    width = json['width'];
    averageRating = json['average_rating'];
    dislikeCount = json['dislike_count'];
    displayId = json['display_id'];
    extractorKey = json['extractor_key'];
    filesize = json['filesize'];
    filesizeApprox = json['filesize_approx'];
    formatId = json['format_id'];
    httpHeaders = json['http_headers'] != null
        ? new HttpHeaders.fromJson(json['http_headers'])
        : null;
    likeCount = json['like_count'];
    manifestUrl = json['manifest_url'];
    playerUrl = json['player_url'];
    repostCount = json['repost_count'];
    requestedFormats = json['requested_formats'];
    uploadDate = json['upload_date'];
    uploaderId = json['uploader_id'];
    viewCount = json['view_count'];
    webpageUrl = json['webpage_url'];
    webpageUrlBasename = json['webpage_url_basename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categories'] = this.categories;
    data['description'] = this.description;
    data['duration'] = this.duration;
    data['ext'] = this.ext;
    data['extractor'] = this.extractor;
    data['format'] = this.format;
    if (this.formats != null) {
      data['formats'] = this.formats!.map((v) => v.toJson()).toList();
    }
    data['fulltitle'] = this.fulltitle;
    data['height'] = this.height;
    data['id'] = this.id;
    data['license'] = this.license;
    data['resolution'] = this.resolution;
    data['tags'] = this.tags;
    data['thumbnail'] = this.thumbnail;
    if (this.thumbnails != null) {
      data['thumbnails'] = this.thumbnails!.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['uploader'] = this.uploader;
    data['url'] = this.url;
    data['width'] = this.width;
    data['average_rating'] = this.averageRating;
    data['dislike_count'] = this.dislikeCount;
    data['display_id'] = this.displayId;
    data['extractor_key'] = this.extractorKey;
    data['filesize'] = this.filesize;
    data['filesize_approx'] = this.filesizeApprox;
    data['format_id'] = this.formatId;
    if (this.httpHeaders != null) {
      data['http_headers'] = this.httpHeaders!.toJson();
    }
    data['like_count'] = this.likeCount;
    data['manifest_url'] = this.manifestUrl;
    data['player_url'] = this.playerUrl;
    data['repost_count'] = this.repostCount;
    data['requested_formats'] = this.requestedFormats;
    data['upload_date'] = this.uploadDate;
    data['uploader_id'] = this.uploaderId;
    data['view_count'] = this.viewCount;
    data['webpage_url'] = this.webpageUrl;
    data['webpage_url_basename'] = this.webpageUrlBasename;
    return data;
  }
}

class Formats {
  int? abr;
  String? acodec;
  int? asr;
  String? ext;
  String? format;
  int? fps;
  int? height;
  int? preference;
  int? tbr;
  String? url;
  String? vcodec;
  int? width;
  int? filesize;
  int? filesizeApprox;
  String? formatId;
  String? formatNote;
  HttpHeaders? httpHeaders;
  String? manifestUrl;

  Formats(
      {this.abr,
      this.acodec,
      this.asr,
      this.ext,
      this.format,
      this.fps,
      this.height,
      this.preference,
      this.tbr,
      this.url,
      this.vcodec,
      this.width,
      this.filesize,
      this.filesizeApprox,
      this.formatId,
      this.formatNote,
      this.httpHeaders,
      this.manifestUrl});

  Formats.fromJson(Map<String, dynamic> json) {
    abr = json['abr'];
    acodec = json['acodec'];
    asr = json['asr'];
    ext = json['ext'];
    format = json['format'];
    fps = json['fps'];
    height = json['height'];
    preference = json['preference'];
    tbr = json['tbr'];
    url = json['url'];
    vcodec = json['vcodec'];
    width = json['width'];
    filesize = json['filesize'];
    filesizeApprox = json['filesize_approx'];
    formatId = json['format_id'];
    formatNote = json['format_note'];
    httpHeaders = json['http_headers'] != null
        ? new HttpHeaders.fromJson(json['http_headers'])
        : null;
    manifestUrl = json['manifest_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['abr'] = this.abr;
    data['acodec'] = this.acodec;
    data['asr'] = this.asr;
    data['ext'] = this.ext;
    data['format'] = this.format;
    data['fps'] = this.fps;
    data['height'] = this.height;
    data['preference'] = this.preference;
    data['tbr'] = this.tbr;
    data['url'] = this.url;
    data['vcodec'] = this.vcodec;
    data['width'] = this.width;
    data['filesize'] = this.filesize;
    data['filesize_approx'] = this.filesizeApprox;
    data['format_id'] = this.formatId;
    data['format_note'] = this.formatNote;
    if (this.httpHeaders != null) {
      data['http_headers'] = this.httpHeaders!.toJson();
    }
    data['manifest_url'] = this.manifestUrl;
    return data;
  }
}

class HttpHeaders {
  String? userAgent;
  String? accept;
  String? acceptLanguage;
  String? secFetchMode;
  String? cookie;

  HttpHeaders(
      {this.userAgent,
      this.accept,
      this.acceptLanguage,
      this.secFetchMode,
      this.cookie});

  HttpHeaders.fromJson(Map<String, dynamic> json) {
    userAgent = json['User-Agent'];
    accept = json['Accept'];
    acceptLanguage = json['Accept-Language'];
    secFetchMode = json['Sec-Fetch-Mode'];
    cookie = json['Cookie'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['User-Agent'] = this.userAgent;
    data['Accept'] = this.accept;
    data['Accept-Language'] = this.acceptLanguage;
    data['Sec-Fetch-Mode'] = this.secFetchMode;
    data['Cookie'] = this.cookie;
    return data;
  }
}

class Thumbnails {
  String? id;
  String? url;

  Thumbnails({this.id, this.url});

  Thumbnails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}


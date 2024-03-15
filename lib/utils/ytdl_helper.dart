import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:media_blade/models/media_results.dart';

class YtdlHelper {
  static const _platform = MethodChannel('ytdl');
  static Function(String?)? _listener = null;
  static init() {
    _platform.setMethodCallHandler((call) async {
      if (call.method == 'newIntent') {
        _listener!(call.arguments);
      }
    });
  }

  static void setIntentCallListener(Function(String?) listener) {
    _listener = listener;
  }

  static Future<MediaResults> getMediaResults(String url,
      {Map<String, String>? options}) async {
    try {
      Map<String, dynamic> args = {'url': url};
      if (options != null) {
        args['params'] = options;
      }
      var result = await _platform.invokeMethod('getVideoResults', args);
      var data = jsonDecode(result);
      return MediaResults.fromJson(data);
    } on PlatformException catch (e) {
      throw Exception("Failed to get youtube info: '${e.message}'.");
    }
  }

  static Future<void> upgradeYTDL() async {
    try {
      var result = await _platform.invokeMethod('upgrade');
      return result;
    } on PlatformException catch (e) {
      throw Exception("Failed to upgrade YTDL");
    }
  }

  static Future<String?> getIntentUrl() async {
    try {
      var result = await _platform.invokeMethod('getIntentUrl');
      return result;
    } on PlatformException catch (e) {
      throw Exception("Failed to get intent URL");
    }
  }
}

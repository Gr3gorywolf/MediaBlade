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

  static Future<MediaResults> getMediaResults(String url) async {
    try {
      var result =
          await _platform.invokeMethod('getVideoResults', {'url': url});
      var data = jsonDecode(result);
      return MediaResults.fromJson(data);
    } on PlatformException catch (e) {
      throw Exception("Failed to get youtube info: '${e.message}'.");
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

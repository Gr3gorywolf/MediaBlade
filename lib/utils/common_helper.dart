import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class CommonHelper {
  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  String normalizeFilename(String name) {
    String normalized = name.replaceAll(' ', '_');
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]+'), '');
    normalized = normalized.toLowerCase();
    if (normalized.length > 40) {
      normalized = "${normalized.substring(0, 40)}...";
    }
    return normalized;
  }

  String extractBaseUrl(String url) {
    Uri uri = Uri.parse(url);

    // Rebuild the URL with only scheme, authority, and path segments up to the first one
    String baseUrl = '${uri.scheme}://${uri.host}';
    return baseUrl;
  }

  String formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy hh:mm a');
    return formatter.format(dateTime);
  }

  String getWebpageFavicon(String url) {
    print(extractBaseUrl(url));
    return extractBaseUrl(url) + '/favicon.ico';
  }

  String createHash(String input, {maxLength: 5}) {
    return sha256
        .convert(utf8.encode(input))
        .toString()
        .substring(0, maxLength);
  }
}

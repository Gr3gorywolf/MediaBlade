import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingKey { downloadPath, closeIfIntent }

class SettingsHelper {
  static String deviceId = "android-device";
  static initSettings() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.id;
  }

  static getSetting(SettingKey key) async {
    final prefs = await SharedPreferences.getInstance();
    print(key.name);
    try {
      return prefs.getString("mblade-settings-${key.name}");
    } catch (err) {
      return null;
    }
  }

  static Future setSetting(SettingKey key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("mblade-settings-${key.name}", value);
  }
}

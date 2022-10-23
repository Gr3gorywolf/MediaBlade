import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';


 enum SettingKey {
    downloadPath
  }

class SettingsHelper {
  static getSetting(SettingKey key) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString("mblade-settings-${key.name}");
    } catch (err) {
      return null;
    }
  }

  static Future setSetting(SettingKey key,  String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("mblade-settings-${key.name}", value);
  }

}

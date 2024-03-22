import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetsHelper {
  static getImage(String name, {double size = 24}) {
    return Image.asset(
      "assets/images/$name.png",
      height: size,
      width: size,
    );
  }

  static getText(String name, {extension = ".json"}) {
    return rootBundle.loadString(
      "assets/data/$name$extension",
    );
  }

  static getIcon(String name, {double size = 24}) {
    return Image.asset(
      "assets/icons/$name.png",
      height: size,
      width: size,
    );
  }
}

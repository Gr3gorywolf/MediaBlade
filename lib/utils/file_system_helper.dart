import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FileSystemHelper{
 static Future<String?> requestNewPath(BuildContext context){
    return FilesystemPicker.open(
        title: 'Select a folder for downloads',
        context: context,
        rootDirectory: Directory("/storage/emulated/0/"),
        fsType: FilesystemType.folder,
        showGoUp: true,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        theme: FilesystemPickerTheme(
            topBar: FilesystemPickerTopBarThemeData(
                backgroundColor: Colors.blue, foregroundColor: Colors.white)),
        pickText: 'Save file to this folder',
      );
  }
}
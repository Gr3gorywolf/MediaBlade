import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:media_blade/get_controllers/download_history_controller.dart';
import 'package:media_blade/ui/dialogs/download_dialog.dart';
import 'package:toast/toast.dart';

import '../../../utils/assets_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var url = '';
  var textController = TextEditingController(text: "");
  void handleOpenUrl() {
    var url = textController.text;
    if (Uri.parse(url).isAbsolute) {
      DownloadDialog.show(context, url);
    } else {
      Toast.show("Invalid URL");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ToastContext().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MediaBlade"),
      ),
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: textController,
            onChanged: (newVal) {
              setState(() {
                textController;
              });
            },
            cursorColor: Colors.blue,
            style: TextStyle(color: Colors.blue),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 0.0),
              ),
              border: const OutlineInputBorder(),
              hintText: "Paste the media URL here",
              prefixIcon: !textController.text.isEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          textController.text = "";
                        });
                      },
                    )
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                onPressed: () {
                  handleOpenUrl();
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetsHelper.getIcon("katana", size: 160),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(50),
                  child: Text(
                    "Share the media and select MediaBlade from the chooser or paste the link on the searchbar",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}

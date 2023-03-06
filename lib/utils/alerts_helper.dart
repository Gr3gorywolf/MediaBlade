import 'package:flutter/material.dart';

class AlertsHelper {
  static showAlertDialog(BuildContext context, String title, String content,
      {List<Widget> buttons = const []}) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: buttons,
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

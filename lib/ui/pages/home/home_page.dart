import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../utils/assets_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          AssetsHelper.getIcon("katana", size: 250),
          SizedBox(height: 30),
          Text(
            "Share the media and select MediaBlade from the chooser",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue),
          )
        ]),
      ),
    );
  }
}

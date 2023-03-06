import 'package:flutter/material.dart';
import 'package:media_blade/ui/pages/whatsapp_status_extractor/whatsapp_status_extractor_page.dart';

class ToolsPage extends StatefulWidget {
  ToolsPage({Key? key}) : super(key: key);

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  var titleTextStyle = TextStyle(color: Colors.white, fontSize: 12);
  var subTitleTextStyle = TextStyle(color: Colors.white, fontSize: 10);

  void navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tools"),
        ),
        body: Column(
          children: [
            ListTile(
              onTap: () {
                navigate(WhatsappStatusExtractorPage());
              },
              leading: Icon(
                Icons.whatsapp,
                size: 35,
                color: Colors.white,
              ),
              title: Text(
                "Whatsapp status extractor",
                style: titleTextStyle,
              ),
              subtitle: Text(
                "Extracts the Whatsapp statuses stored on cache",
                style: subTitleTextStyle,
              ),
            ),
            Divider(
              height: 2,
              color: Colors.white24,
            ),
          ],
        ));
  }
}

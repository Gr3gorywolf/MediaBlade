import 'package:flutter/material.dart';
import 'package:media_blade/ui/dialogs/download_dialog.dart';
import 'package:media_blade/ui/pages/home/home_page.dart';
import 'package:media_blade/ui/pages/settings/settings_page.dart';
import 'package:media_blade/utils/ytdl_helper.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String url = "";

  void handleUrlReceived(String? receivedUrl) {
    if (receivedUrl != null) {
      print(receivedUrl);
      DownloadDialog.show(context, receivedUrl);
    }
  }

  retrieveUrl() async {
    try {
      var url = await YtdlHelper.getIntentUrl();
      handleUrlReceived(url);
    } catch (err) {
      print('Failed to retrieve url');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    YtdlHelper.setIntentCallListener(handleUrlReceived);
    retrieveUrl();
  }

  List<Widget> routes = [HomePage(), SettingsPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MediaBlade"),
        ),
        body: routes[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            )
          ],
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ));
  }
}

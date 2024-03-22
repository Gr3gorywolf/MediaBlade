import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_blade/ui/dialogs/download_dialog.dart';
import 'package:media_blade/ui/pages/history/history_page.dart';
import 'package:media_blade/ui/pages/home/home_page.dart';
import 'package:media_blade/ui/pages/settings/settings_page.dart';
import 'package:media_blade/ui/pages/tools/tools_page.dart';
import 'package:media_blade/utils/ytdl_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../get_controllers/updates_controller.dart';
import '../../../utils/alerts_helper.dart';
import '../../../utils/updates_helper.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String url = "";
  UpdatesController updatesController = Get.find();
  void handleUrlReceived(String? receivedUrl) {
    if (receivedUrl != null) {
      DownloadDialog.show(context, receivedUrl, fromIntent: true);
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
    super.initState();
    YtdlHelper.setIntentCallListener(handleUrlReceived);
    retrieveUrl();
    if (updatesController.showDownloadDialog.value) {
      lookForUpdates();
    }
  }

  lookForUpdates() async {
    var newRelease = await UpdatesHelper().fetchNewRelease();
    if (newRelease != null) {
      // ignore: use_build_context_synchronously
      AlertsHelper.showAlertDialog(context, "New update available",
          "There's a new update available with the following changes:\n ${newRelease.body ?? newRelease.name}",
          buttons: [
            TextButton(
                onPressed: () {
                  updatesController.disableDownloadDialog();
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                )),
            TextButton(
                onPressed: () {
                  var apkAsset = newRelease.assets?.firstWhere(
                      (element) => element.name == "app-release.apk");
                  if (apkAsset != null) {
                    launchUrl(Uri.parse(apkAsset.browserDownloadUrl ?? ''),
                        mode: LaunchMode.externalApplication);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Go to download"))
          ]);
    }
  }

  List<Widget> routes = [
    HomePage(),
    HistoryPage(),
    ToolsPage(),
    SettingsPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: routes[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman),
              label: "Tools",
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

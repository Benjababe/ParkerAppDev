// external packages
import 'package:app/control/PermissionsMgr.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:app/boundary/CarparksInterface.dart';
import 'package:app/boundary/CarparksNearMeInterface.dart';
import 'package:app/boundary/SettingsInterface.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  PermissionsMgr permissionsMgr = new PermissionsMgr();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    initBookmarks();
  }

  // set bookmarks to an empty list, prevent it from being null when first referenced.
  void initBookmarks() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = _prefs.getStringList("bookmarks");
    if (bookmarks == null) {
      bookmarks = [];
      await _prefs.setStringList("bookmarks", bookmarks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.title),
            Padding(
              padding: EdgeInsets.all(100),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.search, size: 16),
              label: Text(AppLocalizations.of(context)!.searchButton),
              onPressed: () async {
                String error = await permissionsMgr.checkLocationService();
                // if no errors with location services
                if (error == "")
                  navigateToCarparks();
                // pops up error message if navigate function returns non null string
                else {
                  permissionsMgr.popupPermissions(context, error);
                }
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.bookmark_outline, size: 16),
              label: Text(AppLocalizations.of(context)!.bookmarksButton),
              onPressed: () {},
            ),
            // Navigate to carparks near me
            /*ElevatedButton.icon(
              icon: Icon(Icons.local_parking_outlined, size: 16),
              label: Text('Carparks Near Me'),
              onPressed: () => navigateToCarparksNearMe(),
            ),*/
            ElevatedButton.icon(
              icon: Icon(Icons.settings, size: 16),
              label: Text('Settings'),
              onPressed: () => navigateToSettings(),
            ),
          ],
        ),
      ),
    );
  }

  dynamic navigateToCarparks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarparksInterface(),
      ),
    );
  }

  dynamic navigateToCarparksNearMe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarparksNearMeInterface(),
      ),
    );
  }

  dynamic navigateToSettings(){
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsInterface(),
      ),
    );

  }
}

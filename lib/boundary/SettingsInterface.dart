import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsInterface extends StatefulWidget {
  SettingsInterface({Key? key}) : super(key: key);

  @override
  _SettingsInterfaceState createState() => _SettingsInterfaceState();
}

class _SettingsInterfaceState extends State<SettingsInterface> {
  static const keyLanguage = 'key-language';
  
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color:Colors.white) ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            SettingsGroup(
              title: 'General',
              children: <Widget>[
                buildLanguage(),
                buildHelp(),
              ],
            ),
            SizedBox(height: 10),
            SettingsGroup(
              title: 'More Information\n',
              children: <Widget>[
                buildAbout(),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget buildAbout() => SimpleSettingsTile(
    title: 'About',
    subtitle: 'Version 1.0'
  );
  Widget buildLanguage() => DropDownSettingsTile(
    settingKey: keyLanguage,
    title: 'Language',
    subtitle: '',
    selected: 1,
    onChange: (value)
    {

    },
    values: <int, String>{
      1: "Default (English)",
    },  
  ); 
  Widget buildHelp() => SimpleSettingsTile(
    title: 'Help (English)',
    subtitle:'How to use the app',
    onTap: () async => { await launch("https://www.youtube.com/watch?v=o4uXLVvNmw4") },
  );

}










  

  
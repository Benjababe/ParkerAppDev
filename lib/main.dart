// external packages
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:showcaseview/showcaseview.dart';

// local files
import 'boundary/MainInterface.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future main() async {
  await Settings.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(
    primarySwatch: Colors.lightBlue,
    canvasColor: Colors.white,
    textTheme: TextTheme(
      bodyText2: TextStyle(
        color: Colors.white,
        fontSize: 32,
      ),
    ),

    // default theme for elevated buttons, blue background white foreground
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.blue,
        fixedSize: Size(300, 14),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parker App',
      // set default global theme for the app
      theme: appTheme,
      // hide debug banner on top right of debug install
      debugShowCheckedModeBanner: false,
      // what to apply localisation text to
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // list of supported languages
      supportedLocales: [
        Locale("en", ""),
        Locale("zh", "CN"),
        Locale("ms", "SG"),
        Locale("ta", "SG")
      ],
      home: ShowCaseWidget(
        builder: Builder(
          builder: (context) {
            return MainMenu(title: "Parker");
          },
        ),
      ),
    );
  }
}

// external packages
import 'package:flutter/material.dart';

// local files
import 'boundary/main_menu.dart';

void main() {
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
    print("Hello there");
    return MaterialApp(
      title: 'Parker App',
      // set default global theme for the app
      theme: appTheme,
      //home: MyHomePage(title: 'Parker'),
      home: MainMenu(title: "Parker"),
    );
  }
}

// external packages
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// local files
import 'search_page.dart';
import 'bookmark.dart';
import 'bloc/maps_bloc.dart';

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
    return ChangeNotifierProvider(
      create: (context) => BackendService(),
      child: MaterialApp(
        title: 'Parker App',
        // set default global theme for the app
        theme: appTheme,
        home: MyHomePage(title: 'Parker'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ParkerHome createState() => _ParkerHome();
}

class _ParkerHome extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Hello World"),
            Padding(
              padding: EdgeInsets.all(100),
            ),
            /* disabled for now
            ElevatedButton.icon(
              icon: Icon(Icons.map_outlined, size: 16),
              label: Text('Carparks Nearby'),
              onPressed: () => {},
            ),
            */
            ElevatedButton.icon(
              icon: Icon(Icons.search, size: 16),
              label: Text('Search'),
              onPressed: () async {
                var error = await checkLocationService();
                // if no errors with location services
                if (error == null)
                  navigateToSearch();
                // pops up error message if navigate function returns non null string
                else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: new Text("Location Permission Issue"),
                      content: new Text(error),
                      actions: <Widget>[
                        if (error.toString().contains("denied"))
                          TextButton(
                            onPressed: () {
                              openAppSettings();
                              Navigator.pop(context, "OK");
                            },
                            child: Text("Open Settings"),
                          ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, "Cancel"),
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.bookmark_outline, size: 16),
              label: Text('Bookmarks'),
              onPressed: () {
                showBookmarkMenu(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  dynamic checkLocationService() async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled)
      return "Location services disabled, please enable location services on your smartphone for Parker to work properly";

    int count = 0;
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever)
      return "Permission denied forever, please enable permission for Parker to work properly";

    while (permission == LocationPermission.denied) {
      if (count >= 3)
        return "Permissions denied multiple times, please allow location permissions for Parker to work properly";
      await LocationPermissions().requestPermissions();
      permission = await Geolocator.checkPermission();
      count++;
    }
  }

  dynamic navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(),
      ),
    );
  }
}

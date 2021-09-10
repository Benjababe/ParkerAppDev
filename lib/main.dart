// external packages
import 'package:location_permissions/location_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// local files
import 'search_page.dart';
import 'backend.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BackendService(),
      child: MaterialApp(
        title: 'Parker App',
        // set default global theme for the app
        theme: ThemeData(
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
        ),
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
            ElevatedButton.icon(
              icon: Icon(Icons.map_outlined, size: 16),
              label: Text('Carparks Nearby'),
              onPressed: () => {},
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.search, size: 16),
              label: Text('Search'),
              onPressed: () => navigateToSearch(),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.bookmark_outline, size: 16),
              label: Text('Bookmarks'),
              onPressed: () => {},
            ),
          ],
        ),
      ),
    );
  }

  void navigateToSearch() async {
    var status = await Permission.location.status;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(),
      ),
    );
  }
}

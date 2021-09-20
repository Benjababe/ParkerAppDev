import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/maps_bloc.dart';
import 'search_page.dart';

void showBookmarkMenu(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? bookmarks = prefs.getStringList("bookmarks");
  if (bookmarks == null) return;

  BackendService backend = new BackendService();
  Map carparkData = await backend.readCarparkLocation();

  List<Widget> bookmarkWidgets = [];

  for (String carparkNo in bookmarks) {
    Map carpark = carparkData[carparkNo];
    bookmarkWidgets.add(
      TextButton(
        onPressed: () {
          prefs.setString("activeDestination", carparkNo);
          prefs.setDouble("activeLat", carpark["lat"]);
          prefs.setDouble("activeLng", carpark["lng"]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(),
            ),
          );
        },
        child: Text(
          carpark["address"],
        ),
      ),
    );
  }

  showDialog(
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          "Bookmarks",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        content: ListView.separated(
          itemBuilder: (context, index) => bookmarkWidgets[index],
          separatorBuilder: (context, index) => Divider(
            color: Colors.white,
          ),
          itemCount: bookmarkWidgets.length,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          side: BorderSide(
            color: Colors.white,
          ),
        ),
      );
    },
    context: context,
  );
}

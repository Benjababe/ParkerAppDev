import 'package:app/boundary/CarparksInterface.dart';
import 'package:app/control/CarparksMgr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookmarksInterface {
  CarparksMgr _cpMgr = new CarparksMgr();
  late SharedPreferences _prefs;

  // returns AlertDialog which contains listview for bookmarks
  Future<AlertDialog> generateBookmarksMenu(BuildContext context) async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = _prefs.getStringList("bookmarks");
    List<Widget> _bookmarkWidgets = [];

    // if no bookmarks, just return a window informing the user they have no bookmarks
    if (bookmarks == null || bookmarks.length == 0) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookmarksButton),
        content: Text(AppLocalizations.of(context)!.noBookmarksTxt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      );
    }

    // if they have bookmarks, get carpark data for latlng positions
    Map carparkData = await _cpMgr.getCarparkLocations();
    for (String cpNum in bookmarks) {
      Map carpark = carparkData[cpNum];
      _bookmarkWidgets.add(
        TextButton(
          onPressed: () {
            // when bookmark is pressed, store latlng which will be used in carparkinterface
            _prefs.setDouble("activeLat", carpark["lat"]);
            _prefs.setDouble("activeLng", carpark["lng"]);

            // closes alertdialog because it doesn't update to the latest bookmarks automatically
            Navigator.pop(context);

            // and open carparkinterface.
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CarparksInterface()));
          },
          child: Text(
            carpark["address"],
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: Colors.black87,
      title: Text(
        AppLocalizations.of(context)!.bookmarksButton,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      // wrap listview in container because of some individual size counting crap
      content: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: ListView.separated(
          itemBuilder: (context, index) => _bookmarkWidgets[index],
          separatorBuilder: (context, index) => Divider(
            color: Colors.white,
          ),
          itemCount: _bookmarkWidgets.length,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancelButton),
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
  }
}

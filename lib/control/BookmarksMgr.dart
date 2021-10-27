import 'package:app/boundary/BookmarksInterface.dart';
import 'package:app/entity/Bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksMgr implements BookmarksInterface {
  late List<Bookmarks> bList;
  late SharedPreferences _prefs;
  //class constructor (composition of Bookmarks)
  BookmarksMgr();

  //aggregating bookmarks into bookmarksMgr
  void addBookmarks(Bookmarks b) {
    bList.add(b);
  }

  void bookmarkMarker(String cpNum) async {
    // retrieves bookmark list from storage
    _prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = _prefs.getStringList("bookmarks")!;

    // toggles bookmark from list
    if (!bookmarks.contains(cpNum))
      bookmarks.add(cpNum);
    else
      bookmarks.remove(cpNum);

    // stores bookmark list to storage
    _prefs.setStringList("bookmarks", bookmarks);
  }

  //display all bookmarks information
  void displayBookmarks() {}

  //realising interface
  void bookmarks() {}

  //select one of the bookmark
  void selectBookmarks(Bookmarks b) {}
}

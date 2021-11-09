import 'package:app/entity/Bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksMgr {
  List<String> _bookmarks = [];
  late List<Bookmarks> bList;
  late SharedPreferences _prefs;

  //class constructor (composition of Bookmarks)
  BookmarksMgr();

  //aggregating bookmarks into bookmarksMgr
  void addBookmarks(Bookmarks b) {
    bList.add(b);
  }

  void initBookmarks() async {
    // retrieves bookmark list from storage
    _prefs = await SharedPreferences.getInstance();
    _bookmarks = _prefs.getStringList("bookmarks")!;
  }

  bool isBookmarked(String cpNum) {
    return _bookmarks.contains(cpNum);
  }

  Future<bool> bookmarkMarker(String cpNum) async {
    // toggles bookmark from list
    if (!_bookmarks.contains(cpNum))
      _bookmarks.add(cpNum);
    else
      _bookmarks.remove(cpNum);

    // stores bookmark list to storage
    _prefs.setStringList("bookmarks", _bookmarks);

    return isBookmarked(cpNum);
  }

  //display all bookmarks information
  void displayBookmarks() {}

  //realising interface
  void bookmarks() {}

  //select one of the bookmark
  void selectBookmarks(Bookmarks b) {}
}

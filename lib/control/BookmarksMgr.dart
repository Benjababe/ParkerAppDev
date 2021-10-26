import 'package:app/boundary/BookmarksInterface.dart';
import 'package:app/entity/Bookmarks.dart';

class BookmarksMgr implements BookmarksInterface
{
  late List<Bookmarks> bList;
  //class constructor (composition of Bookmarks)
  BookmarksMgr();

  //aggregating bookmarks into bookmarksMgr
  void addBookmarks(Bookmarks b)
  {
    bList.add(b);
  }
  


  //display all bookmarks information
  void displayBookmarks()
  {

  }

  //realising interface
  void bookmarks()
  {

  }

  //select one of the bookmark
  void selectBookmarks(Bookmarks b)
  {
    
  }
}
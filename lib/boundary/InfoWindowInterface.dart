import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:app/control/NavigateMgr.dart';
import 'package:app/control/BookmarksMgr.dart';

class InfoWindowInterface {
  NavigateMgr navMgr = new NavigateMgr();
  BookmarksMgr bkMgr = new BookmarksMgr();

  double _infoWindowPos = -200;
  String _infoWindowText = "", _infoWindowTitle = "", _cpNum = "";
  bool _infoWindowBookmarked = false, _activeAvailable = true;
  late AnimatedPositioned infoWindow;

  InfoWindowInterface() {
    refresh();
  }

  // variables to be displayed
  void setIWValues(String cpName, String cpInfo, String cpNum) {
    _infoWindowTitle = cpName;
    _infoWindowText = cpInfo;
    _cpNum = cpNum;
    refresh();
  }

  void setDestination(double lat, double lng) {
    navMgr.setEndLocation(lat, lng);
  }

  void setCPNum(String cpNum) {
    _cpNum = cpNum;
    refresh();
  }

  void showWindow() {
    _infoWindowPos = 20;
    refresh();
  }

  void hideWindow() {
    _infoWindowPos = -200;
    refresh();
  }

  void refresh() {
    infoWindow = new AnimatedPositioned(
      bottom: _infoWindowPos,
      left: 0,
      right: 0,
      duration: Duration(
        milliseconds: 200,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(10),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 10,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _infoWindowTitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _infoWindowText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
              // just padding between text and button
              Container(
                width: 60,
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  ),
                  Container(
                    padding: EdgeInsets.all(0),
                    height: 24,
                    child: IconButton(
                      icon: Icon((_infoWindowBookmarked)
                          ? Icons.bookmark
                          : Icons.bookmark_border_outlined),
                      padding: EdgeInsets.only(
                        top: 3,
                      ),
                      color: null,
                      onPressed: () {
                        bkMgr.bookmarkMarker(_cpNum);
                        _infoWindowBookmarked = !_infoWindowBookmarked;
                      },
                    ),
                  ),
                  // only shows confirmation button when lots are available
                  if (_activeAvailable)
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                      child: TextButton(
                        child: Text("Confirm"),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.lightBlue,
                        ),
                        onPressed: () {
                          navMgr.displayMap();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

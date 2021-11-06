import 'dart:io';

import 'package:app/boundary/NavigateInterface.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigateMgr implements NavigateInterface {
  late String _startLocation;
  List<double> _endLoc = [0, 0];

  //class constructor
  NavigateMgr();

  //set function
  void setStartLocation(String startLocation) {
    this._startLocation = _startLocation;
  }

  void setEndLocation(double lat, double lng) {
    this._endLoc = [lat, lng];
  }

  //implementing navigate from NavigateInterface
  dynamic navigate() {}

  //verifying startLocation & endLocation is valid (use google maps?)
  bool verify(String _startLocation, String _endLocation) {
    return true;
  }

  //confirming startLocation & endLocation of carpark is valid
  bool confirm(String _startLocation, String _endLocation) {
    return true;
  }

  //displaying map
  void displayMap() async {
    // only open map uri on android and ios
    if (Platform.isAndroid || Platform.isIOS) {
      // generates uri for respective maps app
      Uri uri = (Platform.isAndroid)
          ? Uri.parse("google.navigation:q=${_endLoc[0]},${_endLoc[1]}&mode=d")
          : Uri.parse("https://maps.apple.com/?q=${_endLoc[0]},${_endLoc[1]}");

      // if uri is supported natively, open it. this will open the app
      if (await canLaunch(uri.toString()))
        await launch(uri.toString());
      else
        throw "Could not launch ${uri.toString()}";
    }
  }
}

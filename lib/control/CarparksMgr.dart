import 'dart:convert';

import 'package:app/entity/Carparks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import 'package:app/boundary/InfoWindowInterface.dart';

class CarparksMgr {
  late int _range;
  late List<Carparks> cpList;
  late BitmapDescriptor customIconFree, customIconFull;
  Set<Marker> _markers = {};

  late InfoWindowInterface _iwInterface;

  //class constructor
  CarparksMgr();

  void setIWInterface(InfoWindowInterface iwInterface) {
    _iwInterface = iwInterface;
  }

  //aggregating carparks into carparksMgr
  void addCarparks(Carparks c) {
    cpList.add(c);
  }

  Set<Marker> getMarkers() {
    return _markers;
  }

  Future<void> readCarparkLocations() async {
    customIconFree = await getCustomIcon(true);
    customIconFull = await getCustomIcon(false);

    String s = await rootBundle.loadString("assets/carpark_static_data.json");
    Map data = await json.decode(s);

    await populateCPMarkers(data);
    return null;
  }

  Future<void> populateCPMarkers(Map data) async {
    for (String carparkNum in data.keys) {
      Map record = data[carparkNum];
      double cpLat = record["lat"], cpLng = record["lng"];
      LatLng cpLatLng = new LatLng(cpLat, cpLng);

      MarkerId id = MarkerId("marker_id_" + _markers.length.toString());

      Marker cpMarker = Marker(
        markerId: id,
        icon: customIconFree,
        position: cpLatLng,
        onTap: () {
          markerOnTap(record);
        },
      );

      _markers.add(cpMarker);
    }
    return null;
  }

  void markerOnTap(Map record) async {
    String cpName = record["address"],
        cpNum = record["car_park_no"],
        liveURL = "https://parkerlivelots.benjababe.repl.co/carpark/" + cpNum;

    Response res = await get(Uri.parse(liveURL));
    String availStr = res.body;

    if (availStr == "Carpark doesn't exist!") return;

    Map availLots = json.decode(availStr);

    String cpInfo = "Lots Available: " +
        availLots["lots_available"] +
        "\n" +
        "Lots Total: " +
        availLots["total_lots"] +
        "\n" +
        "Type: " +
        record["car_park_type"];

    _iwInterface.setValues(cpName, cpInfo, cpNum);
    _iwInterface.showWindow();
  }

  Future<BitmapDescriptor> getCustomIcon(bool free) async {
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        (free) ? "assets/parking_logo.png" : "assets/parking_logo_full.png");
    return icon;
  }

  //set function
  void setRange(int _range) {
    this._range = _range;
  }

  //get function
  int getRange() {
    return _range;
  }

  //realising interface
  dynamic carparks() {}

  Future<LatLng> getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentPos = new LatLng(pos.latitude, pos.longitude);
    return currentPos;
  }

  //displaying available carparks within range
  void displayCarparks(int _range) {}

  //selecting carpark from the available ones
  void selectCarparks(Carparks c) {}
  //displaying information of selected carparks
  void displayInfo(Carparks c) {}
}

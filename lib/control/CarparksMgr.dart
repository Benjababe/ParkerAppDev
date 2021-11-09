import 'dart:convert';

import 'package:app/entity/Carparks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:app/boundary/InfoWindowInterface.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarparksMgr {
  late int _range;
  late Map<String, Carpark> cpMap = new Map();
  late BitmapDescriptor customIconFree;
  late BuildContext _ctx;
  Set<Marker> _markers = {};

  // interface is passed from CarparkInterface
  late InfoWindowInterface _iwInterface;

  //class constructor
  CarparksMgr();

  void setIWInterface(InfoWindowInterface iwInterface) {
    _iwInterface = iwInterface;
  }

  //aggregating carparks into carparksMgr
  void addCarpark(String cpNum, Carpark c) {
    cpMap[cpNum] = c;
  }

  Set<Marker> getMarkers() {
    return _markers;
  }

  Future<Map> getCarparkLocations() async {
    String s = await rootBundle.loadString("assets/carpark_static_data.json");
    Map data = await json.decode(s);
    return data;
  }

  Future<void> readCarparkLocations() async {
    customIconFree = await getCustomIcon(true);

    String s = await rootBundle.loadString("assets/carpark_static_data.json");
    Map data = await json.decode(s);

    await populateCPMarkers(data);
    return null;
  }

  Future<void> populateCPMarkers(Map data) async {
    for (String cpNum in data.keys) {
      Map record = data[cpNum];

      Carpark carpark = new Carpark(cpNum, record["lat"], record["lng"],
          record["type_of_parking_system"], record["address"]);
      addCarpark(cpNum, carpark);

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

  Future<void> addSearchMarker(LatLng pos) async {
    // removes and previously existing search markers
    _markers.removeWhere((Marker marker) {
      return marker.markerId.value == "marker_search";
    });

    // adds marker of search result into total set
    _markers.add(
      Marker(
        markerId: MarkerId("marker_search"),
        position: pos,
        consumeTapEvents: true,
      ),
    );
  }

  // retrieves corresponding carpark's live availability and outputs infowindow
  void markerOnTap(Map record) async {
    String cpName = record["address"],
        cpNum = record["car_park_no"],
        liveURL = "http://benjababe.ddns.net:3000/carpark/" + cpNum;

    print("Getting from url: " + liveURL);
    http.Response res = await http.get(Uri.parse(liveURL));
    String availStr = res.body;
    Map availLots = json.decode(availStr);

    String cpInfo = AppLocalizations.of(_ctx)!.lotsAvailableTxt +
        ": " +
        availLots["lots_available"] +
        "\n" +
        AppLocalizations.of(_ctx)!.lotsTotalTxt +
        ": " +
        availLots["total_lots"] +
        "\n" +
        AppLocalizations.of(_ctx)!.typeTxt +
        ": " +
        record["car_park_type"];

    _iwInterface.setIWValues(cpName, cpInfo, cpNum);
    _iwInterface.setDestination(record["lat"], record["lng"]);
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

  // retrieves current location from gps
  Future<LatLng> getCurrentLocation() async {
    LatLng currentPos;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble("activeLat"),
        lng = prefs.getDouble("activeLng");

    await prefs.setDouble("activeLat", -1);
    await prefs.setDouble("activeLng", -1);

    // if not coming from bookmarks, use user location
    if (lat == null || lng == null || lat == -1 || lng == -1) {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPos = new LatLng(pos.latitude, pos.longitude);
    }

    // if coming from bookmarks, use memory location and plop a marker
    else {
      currentPos = new LatLng(lat, lng);
      addSearchMarker(currentPos);
    }

    return currentPos;
  }

  // pass context from ui because of localisation
  void setCtx(BuildContext ctx) {
    _ctx = ctx;
  }
}

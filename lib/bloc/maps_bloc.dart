import 'dart:developer';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proj4dart/proj4dart.dart';

import '../static/constants.dart' as constants;

// class will notify main function on changes through notifyListeners()
class BackendService with ChangeNotifier {
  final String autoCompleteURL =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=:input:&components=country:sg&key=" +
          constants.API_KEY;

  final String findPlaceIdURL =
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=:input:&inputtype=textquery&key=" +
          constants.API_KEY;

  final String getMarkerByIdURL =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=:input:&key=" +
          constants.API_KEY;

  final String getLotsURL =
      "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=:input:";

  // definition for EPSG:3414 (SG)
  final String def =
      "+proj=tmerc +lat_0=1.366666666666667 +lon_0=103.8333333333333 +k=1 +x_0=28001.642 +y_0=38744.572 +ellps=WGS84 +units=m +no_defs ";

  List suggestions = [];
  LatLng activeLocation = new LatLng(0, 0);
  Set<Marker> markers = {};
  int markerCount = 0;

  Map<String, Map<String, String>> carkparkLots = new Map();

  // populates markers with carpark markers
  Future<void> readCarparkLocation() async {
    print("Finding carparks...");
    await getLiveLots();
    BitmapDescriptor customIcon = await getCustomIcon();

    // projections for converting EPSG:3414 (SG Coordinates) to EPSG:4326 (Lat Lng)
    Projection projSrc = Projection.add("EPSG:3414", def);
    Projection projDst = Projection.get("EPSG:4326")!;

    String jsonPath = "assets/carpark_static_data.json";
    String s = await rootBundle.loadString(jsonPath);
    Map data = await json.decode(s);

    // loop through all records of static carpark locations
    // and give each a marker with its own infowindow
    for (String carparkNo in data.keys) {
      Map record = data[carparkNo];
      double x = double.parse(record["x_coord"]);
      double y = double.parse(record["y_coord"]);

      // if there is no data on carpark lots for this marker, skip
      if (!this.carkparkLots.keys.contains(carparkNo)) continue;

      Point carparkPt = new Point(x: x, y: y);
      Point latlng = projSrc.transform(projDst, carparkPt);

      MarkerId id = MarkerId("marker_id_" + (markerCount++).toString());
      Marker cpMarker = Marker(
        markerId: id,
        icon: customIcon,
        position: LatLng(latlng.y, latlng.x),
        infoWindow: InfoWindow(
          title: record["address"],
          snippet: "Lots Available: " +
              this.carkparkLots[carparkNo]!["lotsAvailable"]! +
              "\nTotal Lots: " +
              this.carkparkLots[carparkNo]!["lotsTotal"]! +
              "\nLast Updated: " +
              this.carkparkLots[carparkNo]!["lastUpdate"]! +
              "\nType: " +
              record["car_park_type"],
        ),
      );
      markers.add(cpMarker);
    }
    notifyListeners();
  }

  // follows format: YYYY-MM-DDTHH:MM:SS
  String getCurrentDateTime() {
    String datetime = "";
    DateTime dt = DateTime.now();

    datetime += dt.year.toString() + "-";
    datetime += ((dt.month < 10) ? "0" : "") + dt.month.toString() + "-";
    datetime += ((dt.day < 10) ? "0" : "") + dt.day.toString() + "T";
    datetime += ((dt.hour < 10) ? "0" : "") + dt.hour.toString() + ":";
    datetime += ((dt.minute < 10) ? "0" : "") + dt.minute.toString() + ":";
    datetime += ((dt.second < 10) ? "0" : "") + dt.second.toString();

    return datetime;
  }

  // populates carparkLots Map before adding markers
  Future<void> getLiveLots() async {
    String datetime = getCurrentDateTime();
    Uri uri = Uri.parse(getLotsURL.replaceAll(":input:", datetime));
    Response res = await get(uri);
    Map data = jsonDecode(res.body)["items"][0];
    List carparkData = data["carpark_data"];

    for (Map carpark in carparkData) {
      String cpNum = carpark["carpark_number"];
      Map cpInfo = carpark["carpark_info"][0];

      this.carkparkLots[cpNum] = {
        "lastUpdate": carpark["update_datetime"],
        "lotsAvailable": cpInfo["lots_available"],
        "lotsTotal": cpInfo["total_lots"],
      };
    }
  }

  Future<BitmapDescriptor> getCustomIcon() async {
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/parking_logo.png");
    return icon;
  }

  // returns a list of up to 5 json objects with keys "bold" and "rem" indicating which
  // part of the text is to be bolded
  void getSuggestions(String query) async {
    if (query == "") {
      suggestions = [];
      notifyListeners();
      return;
    }

    String url = autoCompleteURL.replaceAll(":input:", query);
    Uri uri = Uri.parse(url);
    Response res = await post(uri);

    dynamic data = jsonDecode(res.body);
    List predictions = data["predictions"];

    List results = [], matches = [];

    for (var prediction in predictions) {
      Map struct = prediction["structured_formatting"];
      String result = struct["main_text"];
      Map matched = struct["main_text_matched_substrings"][0];
      int matchLen = matched["length"];
      log(result + ", " + matchLen.toString());

      results.add(result);
      matches.add(matchLen);
    }
    log("\n");

    suggestions = List.generate(predictions.length, (i) {
      String result = results[i];
      int matchLen = matches[i];
      return {
        // characters to be in bold
        'bold': result.substring(0, matchLen),
        // characters to be displayed normally
        'rem': result.substring(matchLen, result.length),
        // full string of location
        'text': result,
      };
    });
    notifyListeners();
  }

  void clearSuggestions() {
    suggestions = [];
    notifyListeners();
  }

  searchMap(String search) async {
    double lat = 0, lng = 0;
    String url = findPlaceIdURL.replaceAll(":input:", search);
    Uri uri = Uri.parse(url);
    Response res = await post(uri);

    dynamic data = jsonDecode(res.body);

    if (data["status"] == "OK") {
      Map candidate = data["candidates"][0];
      String placeID = candidate["place_id"];

      url = getMarkerByIdURL.replaceAll(":input:", placeID);
      uri = Uri.parse(url);
      res = await post(uri);
      data = jsonDecode(res.body);

      Map searchResult = data["result"];
      Map location = searchResult["geometry"]["location"];
      lat = location["lat"];
      lng = location["lng"];
    }

    activeLocation = LatLng(lat, lng);
    markers.removeWhere(
      (Marker marker) {
        return marker.markerId.value == "marker_search";
      },
    );
    markers.add(
      Marker(
        markerId: MarkerId("marker_search"),
        position: activeLocation,
      ),
    );
    notifyListeners();
  }
}

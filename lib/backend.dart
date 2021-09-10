import 'dart:developer';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'constants.dart' as constants;

// contains all the dumbass weebshit
class BackendService with ChangeNotifier {
  final String autoCompleteURL =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=:input:&components=country:sg&key=" +
          constants.API_KEY;

  final String findPlaceIdURL =
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=:input:&inputtype=textquery&key=" +
          constants.API_KEY;

  final String GetMarkerByIdURL =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=:input:&key=" +
          constants.API_KEY;

  List suggestions = [];
  LatLng activeLocation = new LatLng(1.3418, 103.9480);
  Set<Marker> markers = {};

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

      url = GetMarkerByIdURL.replaceAll(":input:", placeID);
      uri = Uri.parse(url);
      res = await post(uri);
      data = jsonDecode(res.body);

      Map searchResult = data["result"];
      Map location = searchResult["geometry"]["location"];
      lat = location["lat"];
      lng = location["lng"];
    }

    activeLocation = LatLng(lat, lng);
    markers.clear();
    markers
        .add(Marker(markerId: MarkerId("marker_0"), position: activeLocation));
    notifyListeners();
  }
}

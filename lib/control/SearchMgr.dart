import 'dart:convert';
import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import 'package:app/static/constants.dart';

class SearchMgr {
  final String _autoCompleteURL =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=:input:&components=country:sg&key=" +
          API_KEY;

  final String _findPlaceIdURL =
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=:input:&inputtype=textquery&key=" +
          API_KEY;

  final String _getMarkerByIdURL =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=:input:&key=" +
          API_KEY;

  List suggestions = [];

  SearchMgr();

  void getSuggestions(String query) async {
    if (query == "") {
      suggestions = [];
      return;
    }

    String url = _autoCompleteURL.replaceAll(":input:", query);
    Response res = await post(Uri.parse(url));

    dynamic data = json.decode(res.body);
    List predictions = data["predictions"], results = [], matches = [];

    for (var prediction in predictions) {
      Map struct = prediction["structured_formatting"];
      String result = struct["main_text"];
      Map matched = struct["main_text_matched_substrings"][0];
      int matchedLen = matched["length"];
      log(result + ", " + matchedLen.toString());

      results.add(result);
      matches.add(matchedLen);
    }

    log("\n");

    suggestions = List.generate(
      predictions.length,
      (i) {
        String result = results[i];
        int matchedLen = matches[i];

        return {
          "bold": result.substring(0, matchedLen),
          "rem": result.substring(matchedLen, result.length),
          "text": result,
        };
      },
    );
  }

  void clearSuggestions() {
    suggestions = [];
  }

  Future<LatLng> searchMap(String search) async {
    double lat = 0, lng = 0;
    String url = _findPlaceIdURL.replaceAll(":input:", search);
    Response res = await post(Uri.parse(url));

    dynamic data = json.decode(res.body);

    if (data["status"] == "OK") {
      Map candidate = data["candidates"][0];
      String placeID = candidate["place_id"];

      url = _getMarkerByIdURL.replaceAll(":input:", placeID);
      res = await post(Uri.parse(url));
      data = json.decode(res.body);

      Map searchResult = data["result"];
      Map location = searchResult["geometry"]["location"];
      lat = location["lat"];
      lng = location["lng"];
    }

    return LatLng(lat, lng);
  }
}

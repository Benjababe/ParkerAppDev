import 'dart:developer';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'constants.dart' as constants;

class BackendService {
  static const String AUTO_COMPLETE_URL =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=:input:&components=country:sg&key=" +
          constants.API_KEY;

  static const String FIND_PLACE_ID_URL =
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=:input:&inputtype=textquery&key=" +
          constants.API_KEY;

  static const String GET_MARKER_BY_ID_URL =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=:input:&key=" +
          constants.API_KEY;

  // returns a list of up to 5 json objects with keys "bold" and "rem" indicating which
  // part of the text is to be bolded
  static Future<List> getSuggestions(String query) async {
    if (query == "")
      return List.generate(0, (index) => {"bold": "", "rem": ""});

    String url = AUTO_COMPLETE_URL.replaceAll(":input:", query);
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

    return List.generate(predictions.length, (i) {
      String result = results[i];
      int matchLen = matches[i];
      return {
        // characters to be in bold
        'bold': result.substring(0, matchLen),
        // characters to be displayed normally
        'rem': result.substring(matchLen, result.length),
      };
    });
  }

  static Future<LatLng> searchMap(String search) async {
    double lat = 0, lng = 0;
    String url = FIND_PLACE_ID_URL.replaceAll(":input:", search);
    Uri uri = Uri.parse(url);
    Response res = await post(uri);

    dynamic data = jsonDecode(res.body);

    if (data["status"] == "OK") {
      Map candidate = data["candidates"][0];
      String placeID = candidate["place_id"];

      url = GET_MARKER_BY_ID_URL.replaceAll(":input:", placeID);
      uri = Uri.parse(url);
      res = await post(uri);
      data = jsonDecode(res.body);

      Map searchResult = data["result"];
      Map location = searchResult["geometry"]["location"];
      lat = location["lat"];
      lng = location["lng"];
    }

    return LatLng(lat, lng);
  }
}

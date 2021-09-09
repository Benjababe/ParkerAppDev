import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'backend.dart' as backend;
import 'search_results.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _listController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // what a fucking abomination of design
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: this._listController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await backend.BackendService.getSuggestions(pattern);
                },
                itemBuilder: (context, dynamic suggestion) {
                  return ListTile(
                    dense: true,
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: suggestion["bold"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: suggestion["rem"]),
                        ],
                      ),
                    ),
                  );
                },
                onSuggestionSelected: (dynamic suggestion) {
                  String place = suggestion["bold"] + suggestion["rem"];
                  this._listController.text = place;
                },
              ),
              ElevatedButton(
                onPressed: navigateToResults,
                child: Text("Search"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void navigateToResults() async {
    LatLng searchPos =
        await backend.BackendService.searchMap(_listController.text);

    Navigator.push(
      context,
      MaterialPageRoute(
        // passes search text to result screen to find on map
        builder: (context) => SearchResults(searchPos: searchPos),
      ),
    );
  }
}

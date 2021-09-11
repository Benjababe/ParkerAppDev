import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'bloc/maps_bloc.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();

  // listview starts as hidden, you are able to scroll the map freely
  // use a variable for height as it overlays the map widget
  double suggestionHeight = 0, mapZoom = 16.5;

  void toggleListView(bool status) {
    setState(() {
      suggestionHeight = (status) ? 290 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // initialisation of backend class
    final backend = Provider.of<BackendService>(context);

    // what a fucking abomination of design
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Search Destination",
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (String query) {
                    backend.getSuggestions(query);
                    // show suggestion listview
                    toggleListView(true);
                  },
                  onTap: backend.clearSuggestions,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 590,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: new LatLng(1.3418, 103.9480),
                      zoom: mapZoom,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                        // populates map with carpark markers on creation
                        backend.readCarparkLocation();
                      }
                    },
                    markers: backend.markers,
                    onTap: (LatLng pos) {
                      // make map the focus (hides soft keyboard)
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                  ),
                ),
                if (backend.suggestions.length > 0)
                  Container(
                    height: suggestionHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      backgroundBlendMode: BlendMode.darken,
                    ),
                  ),
                Container(
                  height: suggestionHeight,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: backend.suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: backend.suggestions[index]["bold"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: backend.suggestions[index]["rem"],
                                ),
                              ]),
                        ),
                        onTap: () {
                          // makes listview the focus (hides soft keyboard)
                          FocusScope.of(context).requestFocus(new FocusNode());
                          suggestionTap(backend, index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void suggestionTap(BackendService backend, int index) async {
    // set text in search textfield to suggestion text
    _searchController.text = backend.suggestions[index]["text"];

    // hide suggestion listview
    backend.clearSuggestions();
    toggleListView(false);

    // gets latlng of suggestion
    await backend.searchMap(_searchController.text);

    // pans camera to latlng of above
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: backend.activeLocation,
          zoom: mapZoom,
        ),
      ),
    );
  }
}

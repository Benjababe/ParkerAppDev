import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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
  double suggestionHeight = 0, _mapZoom = 16.5;

  // dark theme for maps
  String _mapStyle = "";

  var _backend;

  void toggleListView(bool status) {
    setState(() {
      suggestionHeight = (status) ? 290 : 0;
    });
  }

  @override
  void initState() {
    super.initState();

    // sets current camera to user location
    getCurrentLocation();

    // retrieves map style from assets
    rootBundle.loadString("assets/map_style.json").then((style) {
      this._mapStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    // initialisation of backend class
    this._backend = Provider.of<BackendService>(context, listen: true);

    // what a fucking abomination of design
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          // prevent scrolling because of map
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
                    this._backend.getSuggestions(query);
                    // show suggestion listview
                    toggleListView(true);
                  },
                  onTap: () => toggleListView(true),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 590,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: new LatLng(0, 0),
                      zoom: _mapZoom,
                    ),
                    onMapCreated: (GoogleMapController controller) async {
                      if (!_mapController.isCompleted) {
                        // populates map with carpark markers
                        this._backend.readCarparkLocation();
                        controller.setMapStyle(this._mapStyle);
                        _mapController.complete(controller);
                      }
                    },
                    markers: this._backend.markers,
                    onTap: (LatLng pos) {
                      // make map the focus (hides soft keyboard)
                      FocusScope.of(context).requestFocus(new FocusNode());

                      // hides suggestion listview
                      toggleListView(false);
                    },
                  ),
                ),
                if (this._backend.suggestions.length > 0)
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
                    // prevent scrolling because of map
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: this._backend.suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: this._backend.suggestions[index]
                                      ["bold"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: this._backend.suggestions[index]["rem"],
                                ),
                              ]),
                        ),
                        onTap: () {
                          // makes listview the focus (hides soft keyboard)
                          FocusScope.of(context).requestFocus(new FocusNode());
                          suggestionTap(this._backend, index);
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
    moveCamera(backend.activeLocation, animate: true);
  }

  void getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentPos = new LatLng(pos.latitude, pos.longitude);
    moveCamera(currentPos);
  }

  void moveCamera(LatLng pos, {bool animate = false}) async {
    CameraUpdate newCam = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: pos,
        zoom: _mapZoom,
      ),
    );
    GoogleMapController controller = await _mapController.future;
    if (animate)
      controller.animateCamera(newCam);
    else
      controller.moveCamera(newCam);
  }
}

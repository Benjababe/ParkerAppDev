import 'dart:async';

import 'package:app/control/SearchMgr.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/boundary/InfoWindowInterface.dart';
import "package:app/control/CarparksMgr.dart";

class CarparksInterface extends StatefulWidget {
  CarparksInterface({Key? key}) : super(key: key);

  @override
  _CarparksInterfaceState createState() => _CarparksInterfaceState();
}

class _CarparksInterfaceState extends State<CarparksInterface> {
  final TextEditingController _txtBoxController = TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();

  InfoWindowInterface _iwInterface = new InfoWindowInterface();
  CarparksMgr _cpMgr = new CarparksMgr();
  SearchMgr _searchMgr = new SearchMgr();

  String _mapStyle = "";
  double _mapZoom = 16.5, _suggestionHeight = 0;

  late Timer _everySecond;

  @override
  void initState() {
    super.initState();

    // retrieves map style from assets
    rootBundle.loadString("assets/map_style.json").then((style) {
      _mapStyle = style;
    });

    // pass interface class to controller as it needs to modify it
    _cpMgr.setIWInterface(_iwInterface);

    // check state update every 0.2s
    // for infowindow interface updating
    _everySecond = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            generateSearchBar(),
            Stack(
              children: [
                Container(
                  height: 590,
                  child: generateMap(),
                ),
                _iwInterface.infoWindow,
                if (_searchMgr.suggestions.length > 0)
                  generateSuggestionCover(),
                Container(
                  height: _suggestionHeight,
                  child: generateSuggestionLV(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // generates widget for search bar
  Container generateSearchBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: TextField(
          controller: _txtBoxController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Search Destination",
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (String query) {
            _searchMgr.getSuggestions(query);
            toggleListView(true);
          },
          onTap: () {
            _iwInterface.hideWindow();
            toggleListView(true);
          },
        ),
      ),
    );
  }

  // generates widget for google map
  GoogleMap generateMap() {
    return GoogleMap(
      mapType: MapType.normal,
      markers: _cpMgr.getMarkers(),
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: CameraPosition(
        target: new LatLng(0, 0),
        zoom: _mapZoom,
      ),
      onMapCreated: (GoogleMapController mapController) async {
        moveCamera(await _cpMgr.getCurrentLocation());
        await _cpMgr.readCarparkLocations();
        mapController.setMapStyle(_mapStyle);
        _mapController.complete(mapController);
      },
      onTap: (LatLng pos) {
        _iwInterface.hideWindow();
        toggleListView(false);
      },
    );
  }

  // generates widget that contains listview of suggestions
  ListView generateSuggestionLV() {
    return ListView.builder(
      // prevent scrolling because of map
      physics: NeverScrollableScrollPhysics(),
      itemCount: _searchMgr.suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: RichText(
            text: TextSpan(
                style: TextStyle(
                  color: Colors.white,
                ),
                // text is split into 2 parts
                // left is bold (matched string)
                // right is remainder (autocompleted string)
                children: <TextSpan>[
                  TextSpan(
                    text: _searchMgr.suggestions[index]["bold"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _searchMgr.suggestions[index]["rem"],
                  ),
                ]),
          ),
          onTap: () {
            // makes listview the focus (hides soft keyboard)
            FocusScope.of(context).requestFocus(
              new FocusNode(),
            );
            onSuggestionTap(index);
          },
        );
      },
    );
  }

  // generates widget that overlays the suggestions, giving it colour
  Container generateSuggestionCover() {
    return Container(
      height: _suggestionHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        backgroundBlendMode: BlendMode.darken,
      ),
    );
  }

  void toggleListView(bool status) {
    setState(() {
      _suggestionHeight = (status) ? 290 : 0;
    });
  }

  void onSuggestionTap(int index) async {
    // set text in textbox to full suggestion text
    _txtBoxController.text = _searchMgr.suggestions[index]["text"];

    _searchMgr.clearSuggestions();
    toggleListView(false);

    LatLng pos = await _searchMgr.searchMap(_txtBoxController.text);
    moveCamera(pos, animate: true);
  }

  // pans camera to location "pos"
  // animate to determine to animate the camera movement
  void moveCamera(LatLng pos, {bool animate = false}) async {
    CameraUpdate newCamPos = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: pos,
        zoom: _mapZoom,
      ),
    );

    GoogleMapController mapController = await _mapController.future;
    if (animate)
      mapController.animateCamera(newCamPos);
    else
      mapController.moveCamera(newCamPos);
  }
}

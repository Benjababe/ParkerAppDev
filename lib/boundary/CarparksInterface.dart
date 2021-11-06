import 'dart:async';

import 'package:app/control/SearchMgr.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/boundary/InfoWindowInterface.dart';
import "package:app/control/CarparksMgr.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CarparksInterface extends StatefulWidget {
  CarparksInterface({Key? key}) : super(key: key);

  @override
  _CarparksInterfaceState createState() => _CarparksInterfaceState();
}

class _CarparksInterfaceState extends State<CarparksInterface> {
  // controller for checking textfield changes for search bar
  TextEditingController _txtBoxController = TextEditingController();

  // controller for handling google map updates
  Completer<GoogleMapController> _mapController = Completer();

  // self declared boundaries and controllers
  InfoWindowInterface _iwInterface = new InfoWindowInterface();
  CarparksMgr _cpMgr = new CarparksMgr();
  SearchMgr _searchMgr = new SearchMgr();

  String _mapStyle = "";
  double _mapZoom = 16.5, _suggestionHeight = 0;

  List _suggestions = [];

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
    Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _cpMgr.setCtx(context);
    _iwInterface.setCtx(context);
    _iwInterface.refresh();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: generateSearchBar(),
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: [
            // maps uses all available space
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: generateMap(),
            ),

            // include info window for carpark info
            _iwInterface.infoWindow,

            // only show suggestion transluscent cover when suggestions exist
            if (_suggestions.length > 0) generateSuggestionCover(),

            // adjust listview height according to number of suggestions
            Container(
              height: _suggestionHeight / 5 * _suggestions.length,
              child: generateSuggestionLV(),
            ),
          ],
        ),
      ),
    );
  }

  // generates widget for search bar
  Container generateSearchBar() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: TextField(
          controller: _txtBoxController,
          decoration: InputDecoration(
            focusedBorder: InputBorder.none,
            hintText: AppLocalizations.of(context)!.searchPlaceholder,
            hintStyle: TextStyle(
              color: Colors.white,
            ),
            suffixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
          ),
          onChanged: (String query) async {
            // if query is empty, clear suggestions
            if (query == "") {
              _suggestions = [];
              return;
            }
            print("Searching query");
            // gets list of suggestions from google autocomplete api
            _suggestions = await _searchMgr.getSuggestions(query);
            // show suggestions listview
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
        FocusScope.of(context).requestFocus(
          new FocusNode(),
        );
      },
    );
  }

  // generates widget that contains listview of suggestions
  ListView generateSuggestionLV() {
    return ListView.builder(
      // prevent scrolling because of map
      physics: NeverScrollableScrollPhysics(),
      itemCount: _suggestions.length,
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
                    text: _suggestions[index]["bold"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _suggestions[index]["rem"],
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
      height: _suggestionHeight / 5 * _suggestions.length,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        backgroundBlendMode: BlendMode.darken,
      ),
    );
  }

  // shows/hides the suggestion list view
  void toggleListView(bool status) {
    setState(() {
      _suggestionHeight = (status) ? 290 : 0;
    });
  }

  void onSuggestionTap(int index) async {
    // set text in textbox to full suggestion text
    _txtBoxController.text = _suggestions[index]["text"];

    // clears suggestions and hide listview
    _suggestions = [];
    toggleListView(false);

    // get latlng of selected search location
    LatLng pos = await _searchMgr.searchMap(_txtBoxController.text);
    await _cpMgr.addSearchMarker(pos);
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

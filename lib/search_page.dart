import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double _suggestionHeight = 0, _mapZoom = 16.5, _infoWindowPos = -100;

  // dark theme for maps
  String _mapStyle = "",
      _infoWindowTitle = "Hello world",
      _infoWindowText = "",
      _infoCPNo = "";

  // is active parking lot available
  bool _activeAvailable = false, _infoWindowBookmarked = false;

  late SharedPreferences _prefs;

  // definition for EPSG:3414 (SG)
  final String def =
      "+proj=tmerc +lat_0=1.366666666666667 +lon_0=103.8333333333333 +k=1 +x_0=28001.642 +y_0=38744.572 +ellps=WGS84 +units=m +no_defs ";

  late BackendService _backend;

  late LatLng _activeLocation;

  void toggleListView(bool status) {
    setState(() {
      _suggestionHeight = (status) ? 290 : 0;
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
                  onTap: () {
                    hideInfoWindow();
                    toggleListView(true);
                  },
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 590,
                  child: generateParkerMap(),
                ),
                generateInfoWindow(),
                if (this._backend.suggestions.length > 0)
                  Container(
                    height: _suggestionHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      backgroundBlendMode: BlendMode.darken,
                    ),
                  ),
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

  GoogleMap generateParkerMap() {
    return GoogleMap(
      mapType: MapType.normal,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: CameraPosition(
        target: new LatLng(0, 0),
        zoom: _mapZoom,
      ),
      onMapCreated: (GoogleMapController controller) async {
        // populates map with carpark markers
        Map data = await this._backend.readCarparkLocation();

        setState(() {
          initSharedPreferences();
          addMarkers(data);
        });

        controller.setMapStyle(this._mapStyle);
        _mapController.complete(controller);
      },
      markers: this._backend.markers,
      onTap: (LatLng pos) {
        // make map the focus (hides soft keyboard)
        FocusScope.of(context).requestFocus(new FocusNode());
        hideInfoWindow();

        // hides suggestion listview
        toggleListView(false);
      },
    );
  }

  ListView generateSuggestionLV() {
    return ListView.builder(
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
                    text: this._backend.suggestions[index]["bold"],
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
            suggestionTap(index);
            hideInfoWindow();
          },
        );
      },
    );
  }

  AnimatedPositioned generateInfoWindow() {
    return AnimatedPositioned(
      bottom: _infoWindowPos,
      left: 0,
      right: 0,
      duration: Duration(
        milliseconds: 200,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(10),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 10,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _infoWindowTitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _infoWindowText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
              // just padding between text and button
              Container(
                width: 60,
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                  ),
                  Container(
                    padding: EdgeInsets.all(0),
                    height: 24,
                    child: IconButton(
                      icon: Icon(_infoWindowBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border_outlined),
                      padding: EdgeInsets.only(
                        top: 3,
                      ),
                      color: null,
                      onPressed: bookmarkMarker,
                    ),
                  ),
                  // only shows confirmation button when lots are available
                  if (_activeAvailable)
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                      child: TextButton(
                        child: Text("Confirm"),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.lightBlue,
                        ),
                        onPressed: () => openDirections(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openDirections() async {
    // TODO iOS untested
    double lat = _activeLocation.latitude, lng = _activeLocation.longitude;
    if (Platform.isAndroid || Platform.isIOS) {
      Uri uri = (Platform.isAndroid)
          ? Uri.parse("google.navigation:q=$lat,$lng&mode=d")
          : Uri.parse("https://maps.apple.com/?q=$lat,$lng");

      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        throw "Could not launch ${uri.toString()}";
      }
    }
  }

  void bookmarkMarker() async {
    List<String>? bookmarks = _prefs.getStringList("bookmarks");

    if (bookmarks == null) bookmarks = [];

    if (!bookmarks.contains(_infoCPNo))
      bookmarks.add(_infoCPNo);
    else
      bookmarks.remove(_infoCPNo);

    _prefs.setStringList("bookmarks", bookmarks);

    setState(() {
      _infoWindowBookmarked = !_infoWindowBookmarked;
    });
  }

  void initSharedPreferences() async {
    // get local storage variables
    _prefs = await SharedPreferences.getInstance();

    List<String>? bookmarks = _prefs.getStringList("bookmarks");
    if (bookmarks == null) bookmarks = [];
    _prefs.setStringList("bookmarks", bookmarks);
  }

  void addMarkers(Map data) async {
    // projections for converting coordinates
    Projection projSrc = Projection.add("EPSG:3414", def);
    Projection projDst = Projection.get("EPSG:4326")!;

    // loop through all records of static carpark locations
    // and give each a marker with its own infowindow
    for (String carparkNo in data.keys) {
      Map record = data[carparkNo];
      double x = double.parse(record["x_coord"]);
      double y = double.parse(record["y_coord"]);

      // if there is no data on carpark lots for this marker, skip
      if (!_backend.carkparkLots.keys.contains(carparkNo)) continue;

      Point carparkPt = new Point(x: x, y: y);
      Point latlngPt = projSrc.transform(projDst, carparkPt);
      LatLng latlng = LatLng(latlngPt.y, latlngPt.x);

      MarkerId id =
          MarkerId("marker_id_" + (_backend.markerCount++).toString());
      Marker cpMarker = Marker(
        markerId: id,
        icon: _backend.customIcon,
        position: latlng,
        onTap: () {
          setState(() {
            _activeLocation = latlng;
            _activeAvailable = (int.parse(
                    _backend.carkparkLots[carparkNo]!["lotsAvailable"]!) >
                0);
            _infoWindowPos = 20;
            _infoWindowTitle = record["address"]!;
            _infoWindowText = "Lots Available: " +
                _backend.carkparkLots[carparkNo]!["lotsAvailable"]! +
                "\nTotal Lots: " +
                _backend.carkparkLots[carparkNo]!["lotsTotal"]! +
                "\nType: " +
                record["car_park_type"];
            _infoWindowBookmarked =
                _prefs.getStringList("bookmarks")!.contains(carparkNo);
            _infoCPNo = carparkNo;
          });
        },
        infoWindow: InfoWindow(
          title: record["address"],
        ),
      );
      _backend.markers.add(cpMarker);
    }
  }

  void hideInfoWindow() {
    setState(() {
      _infoWindowPos = -100;
    });
  }

  void suggestionTap(int index) async {
    // set text in search textfield to suggestion text
    _searchController.text = _backend.suggestions[index]["text"];

    // hide suggestion listview
    _backend.clearSuggestions();
    toggleListView(false);

    // gets latlng of suggestion
    await _backend.searchMap(_searchController.text);

    // pans camera to latlng of above
    moveCamera(_backend.activeLocation, animate: true);
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

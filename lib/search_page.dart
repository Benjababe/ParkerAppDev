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
      // title for custom InfoWindow
      _infoWindowTitle = "Hello world",
      // carpark info in custom InfoWindow
      _infoWindowText = "",
      // associated carpark no. for custom InfoWindow
      _infoCPNo = "";

  // position of current carpark associated with custom InfoWindow
  late LatLng _activeLatLng;

  // whether there are available lots for current carpark associated with custom InfoWindow
  bool _activeAvailable = false,
      // whether current carpark associated with custom InfoWindow is bookmarked
      _infoWindowBookmarked = false;

  // set SharedPreferences to be global, bypass await in non UI methods
  late SharedPreferences _prefs;

  // definition for EPSG:3414 (SG)
  final String def =
      "+proj=tmerc +lat_0=1.366666666666667 +lon_0=103.8333333333333 +k=1 +x_0=28001.642 +y_0=38744.572 +ellps=WGS84 +units=m +no_defs ";

  late BackendService _backend;

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

  // returns a GoogleMap object which will be displayed in UI
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

  // returns a ListView object which will be displayed in UI
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

  // returns the custom InfoWindow which will be displayed in UI
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

  // opens directions in maps app
  void openDirections() async {
    // TODO iOS untested
    double lat = _activeLatLng.latitude, lng = _activeLatLng.longitude;
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

  // either sets/unsets bookmark in local storage and updates UI accordingly
  void bookmarkMarker() async {
    // retrieves bookmark list from storage
    List<String> bookmarks = _prefs.getStringList("bookmarks")!;

    // toggles bookmark from list
    if (!bookmarks.contains(_infoCPNo))
      bookmarks.add(_infoCPNo);
    else
      bookmarks.remove(_infoCPNo);

    // stores bookmark list to storage
    _prefs.setStringList("bookmarks", bookmarks);

    // updates UI
    setState(() {
      _infoWindowBookmarked = !_infoWindowBookmarked;
    });
  }

  void initSharedPreferences() async {
    // get local storage variables
    _prefs = await SharedPreferences.getInstance();

    // initialises empty list and stores if null
    List<String>? bookmarks = _prefs.getStringList("bookmarks");
    if (bookmarks == null) {
      bookmarks = [];
      _prefs.setStringList("bookmarks", bookmarks);
    }
  }

  // populate markers in backend object
  void addMarkers(Map data) async {
    // loop through all records of static carpark locations
    // and give each a marker with its own infowindow
    for (String carparkNo in data.keys) {
      Map record = data[carparkNo];
      double cpLat = double.parse(record["lat"]);
      double cpLng = double.parse(record["lng"]);

      // if there is no data on carpark lots for this marker, skip
      if (!_backend.carkparkLots.keys.contains(carparkNo)) continue;

      LatLng cpLatLng = LatLng(cpLat, cpLng);

      MarkerId id =
          MarkerId("marker_id_" + (_backend.markerCount++).toString());
      Marker cpMarker = Marker(
        markerId: id,
        icon: _backend.customIcon,
        position: cpLatLng,
        onTap: () {
          // sets local variables to be used in InfoWindow and bookmark
          setState(() {
            _activeLatLng = cpLatLng;
            _activeAvailable =
                int.parse(_backend.carkparkLots[carparkNo]!["lotsAvailable"]!) >
                    0;
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
        // basic gmaps infowindow
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

  // gets location and pans camera when a search suggestion is tapped
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
    _prefs = await SharedPreferences.getInstance();
    String? activeDestination = _prefs.getString("activeDestination");

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentPos = new LatLng(pos.latitude, pos.longitude);
    moveCamera(currentPos);
  }

  void moveCamera(LatLng pos, {bool animate = false}) async {
    // initialises new camera position
    CameraUpdate newCamPos = CameraUpdate.newCameraPosition(
      CameraPosition(
        target: pos,
        zoom: _mapZoom,
      ),
    );

    // gets map controller to pan camera
    GoogleMapController controller = await _mapController.future;
    if (animate)
      controller.animateCamera(newCamPos);
    else
      controller.moveCamera(newCamPos);
  }
}

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/boundary/InfoWindowInterface.dart';
import "package:app/control/CarparksMgr.dart";

class CarparksNearMeInterface extends StatefulWidget {
  CarparksNearMeInterface({Key? key}) : super(key: key);

  @override
  _CarparksNearMeInterface createState() => _CarparksNearMeInterface();
}

class _CarparksNearMeInterface extends State<CarparksNearMeInterface> {
  Completer<GoogleMapController> _mapController = Completer();

  late InfoWindowInterface _iwInterface;
  CarparksMgr _cpMgr = new CarparksMgr();

  String _mapStyle = "";
  double _mapZoom = 16.5;

  @override
  void initState() {
    super.initState();

    // retrieves map style from assets
    rootBundle.loadString("assets/map_style.json").then((style) {
      _mapStyle = style;
    });

    // pass interface class to controller as it needs to modify it
    _cpMgr.setIWInterface(_iwInterface);
  }

  @override
  Widget build(BuildContext context) {
    _iwInterface = new InfoWindowInterface();

    return Scaffold(
      // Back button
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Stack(
              children: [
                Container(
                  height: 590,
                  child: generateMap(),
                ),
              ],
            ),
          ],
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
    );
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

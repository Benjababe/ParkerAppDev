import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchResults extends StatelessWidget {
  SearchResults({Key? key, required this.searchPos}) : super(key: key);

  // LatLng value passed in from SearchPage Widget
  final LatLng searchPos;
  int markerCount = 0;

  @override
  Widget build(BuildContext context) {
    Set<Marker> marketSets = <Marker>{};
    Marker searchMarker = Marker(
      markerId: MarkerId("marker_id_$markerCount"),
      position: searchPos,
    );
    marketSets.add(searchMarker);
    markerCount++;

    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: marketSets,
        initialCameraPosition: CameraPosition(
          target: this.searchPos,
          zoom: 16,
        ),
      ),
    );
  }
}

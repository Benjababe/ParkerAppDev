import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsMgr {
  // only returns a string on error
  dynamic checkLocationService() async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled)
      return "Location services disabled, please enable location services on your smartphone for Parker to work properly";

    int count = 0;
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return "Location Permissions are denied.";
    }

    if (permission == LocationPermission.deniedForever)
      return "Permission denied forever. Please enable permission for Parker to work properly";

    /*while (permission == LocationPermission.denied) {
      if (count >= 3)
        return "Permissions denied multiple times, please allow location permissions for Parker to work properly";
      await LocationPermissions().requestPermissions();
      permission = await Geolocator.checkPermission();
      count++;
    }*/
    return "";
  }

  void popupPermissions(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: new Text("Location Permission Issue"),
        content: new Text(error),
        actions: <Widget>[
          if (error.toString().contains("denied"))
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context, "OK");
              },
              child: Text("Open Settings"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, "Cancel"),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

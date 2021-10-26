import 'package:app/boundary/NavigateInterface.dart';

class NavigateMgr implements NavigateInterface
{
  late String _startLocation;
  late String _endLocation;

  //class constructor
  NavigateMgr(String _startLocation, String _endLocation)
  {
    this._startLocation = _startLocation;
    this._endLocation = _endLocation;
  }

  //set function
  void setStartLocation(String startLocation)
  {
    this._startLocation = _startLocation;

  }
  void setEndLocation (String endLocation)
  {
    this._endLocation = _endLocation;
  }

  //implementing navigate from NavigateInterface
  dynamic navigate()
  { }



  //verifying startLocation & endLocation is valid (use google maps?)
  bool verify (String _startLocation, String _endLocation)
  {
    return true;
  }

  //confirming startLocation & endLocation of carpark is valid 
  bool confirm (String _startLocation, String _endLocation)
  {
    return true;
  }

  //displaying map
  void displayMap()
  {

  }







}
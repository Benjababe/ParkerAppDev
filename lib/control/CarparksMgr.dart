import 'package:app/boundary/CarparksInterface.dart';
import 'package:app/entity/Carparks.dart';

class CarparksMgr implements CarparksInterface
{
  late int _range;
  late List<Carparks> cList;

  //class constructor
  CarparksMgr(int _range)
  {
    this._range = _range;
  }

  //aggregating carparks into carparksMgr
  void addCarparks(Carparks c)
  {
    cList.add(c);
  }


  //set function
  void setRange(int _range)
  {
    this._range = _range;
  }

  //get function
  int getRange()
  {
    return _range;
  }

  //realising interface
  dynamic carparks()
  {

  }

  //displaying available carparks within range
  void displayCarparks (int _range)
  {

  }

  //selecting carpark from the available ones
  void selectCarparks (Carparks c)
  {

  }
  //displaying information of selected carparks
  void displayInfo(Carparks c)
  {

  }






} 
class Carparks
{
  late List<String> _info;
  late List<String> _coordinate; //not sure about this

  //class constructor
  Carparks(List<String> _info, List<String> _coordinate)
  {
    this._info = _info;
    this._coordinate = _coordinate;
  }

  //get function
  List<String> getInfo()
  {
    return _info;
  }
  List<String> getCoordinate()
  {
    return _coordinate;
  }





}
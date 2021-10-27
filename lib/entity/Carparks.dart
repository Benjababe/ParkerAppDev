class Carpark {
  late String _cpNum, _type, _address;
  double _lat = -1, _lng = -1;

  //class constructor
  Carpark(String cpNum, double lat, double lng, String type, String address) {
    _cpNum = cpNum;
    _lat = lat;
    _lng = lng;
    _type = type;
    _address = address;
  }

  String getNum() {
    return _cpNum;
  }

  List<double> getCoordinates() {
    return [_lat, _lng];
  }
}

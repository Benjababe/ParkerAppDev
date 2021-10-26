class Bookmarks
{
  late String _endLocation;

  //class constructor
  Bookmarks(String endLocation)
  {
    this._endLocation = endLocation;
  }
  //set function
  void setEndLocation(String _endLocation)
  {
    this._endLocation = _endLocation;
  }

  //get function
  String getEndLocation()
  {
    return _endLocation;
  }


}
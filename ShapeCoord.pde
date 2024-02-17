class ShapeCoord {
  double lon, lat, px, py;
  float x, y;
  
  ShapeCoord(double lon, double lat) {
    //println(lon, lat);
    this.lon = lon;
    this.lat = lat;
    px = lon / 360;
    py = calcMercatorLat(lat) / 6.25;
  }
  
  void rescale(double minX, double minY, double scale) {
    x = (float) ((px - minX) * scale);
    y = (float) ((py - minY) * scale);
  }

}


public  double calcMercatorLat(double lat) {
  double radiansLat = lat * PI / 180.0;
  double cosRadiansLat = Math.cos(radiansLat);
  double inverseCosRadiansLat = 1.0/cosRadiansLat;
  double tanRadiansLat = Math.tan(radiansLat);
  double logged = Math.log(tanRadiansLat + inverseCosRadiansLat);
  return -logged;
}

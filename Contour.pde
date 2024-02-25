class Contour {
  List<ShapeCoord> coordinates;
  String id;
  String[] data; 
  List<Float> acs;
  
  Contour(String id, String[] data) {
    this.id = id;
    this.data = data;
    acs = new ArrayList();
    coordinates = new ArrayList();
  }
  
  void add(ShapeCoord c) {
    coordinates.add(c);
  }
  
  void addACS(float f) {
    acs.add(f);
  }
  
  float getACSColumnValue(int i) {
    return acs.get(i);
  }
  
  
  void rescale(double minX, double minY, double scale) {
    for (ShapeCoord c : coordinates) {
      c.rescale(minX, minY, scale);
    }
  }

  
  void draw(PGraphics g, float x, float y) {
    g.pushMatrix();
    g.stroke(0, 0, 40);
    g.noFill();
    g.beginShape();
    for (int i = 0; i < coordinates.size(); i++) {
      ShapeCoord c = coordinates.get(i);
      g.vertex(x + c.x, y + c.y);
    }
    g.endShape();
    g.popMatrix();
  }
  
}

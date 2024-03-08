class Slider {
  int x; 
  int y; 
  int w; 
  int h;
  float min;
  float max;
  float pct;
  boolean vertical; 

  Slider(int x, int y, int w, int h, float min, float max) {
    this.x = x;
    this.y = y;
    this.w = w; 
    this.h = h;
    this.min = min;
    this.max = max;
    this.pct = 0.5; 
    this.vertical = h >= w;
  }
  
  void draw() {
    noFill();
    rect(x, y, w, h);
    if (vertical) line(x, y+pct*h, x+w, y+pct*h);
    else line(x+pct*w, y, x+pct*w, y+h);
  }
  
  float getValue() {
    return min + pct * (max - min);
  }
  
  boolean contains(float mx, float my) {
    return mx >= x && my >= y && mx <= x + w && my <= y + h;
  } 
  
  void setTo(float mx, float my) {
    if (vertical) pct = (my - y) / h;
    else pct = (mx - x) / w;
  }
  

}

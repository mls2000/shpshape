import java.util.regex.*;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import com.benfry.carto.Shapefile;
import com.benfry.table.DbfTable;

PImage theOtherMap;
final String MAP_NAME = "s-l1600.jpeg";
int mapImageW, mapImageH;

boolean loaded = false;
List<Contour> shapes;
double minX, maxX, minY, maxY, scale;
Map<String, Contour> lookup;

Slider opacity;
Slider vertical;
Slider horizontal;
Slider rotation;
Slider imageScale;
Slider[] controls;
Slider active = null;

/* roads */
final String[] SOURCE_FILES = new String[] {"tl_2021_33015_roads", "tl_2021_33017_roads"};
final String ID_COLUMN = "LINEARID";
final String[] dataColumns = new String[]{"FULLNAME","RTTYP","MTFCC"};
final String exportFileName = "tl_2021_33015_roads";

boolean exporting = false;


void setup() {
  size(600, 800);
  thread("loadData");
  colorMode(HSB, 360, 100, 100);
  textSize(25);
  smooth(4);
  strokeWeight(0.5);  
}



void loadData() {
  loadMaps();  
  theOtherMap = loadImage(MAP_NAME);
  mapImageW = theOtherMap.width; 
  mapImageH = theOtherMap.height;
  opacity = new Slider(width - 130, height - 170, 20, 100, 0, 255);
  vertical = new Slider(width - 100, height - 170, 20, 100, -height, height);
  rotation = new Slider(width - 70, height - 170, 20, 100, -PI, PI); // TAU = PI * 2
  imageScale = new Slider(width - 40, height - 170, 20, 100, 0.1, 0.5);
  horizontal = new Slider(width - 130, height - 50, 110, 20, -width, width);
  controls = new Slider[]{opacity, vertical, horizontal, rotation, imageScale};
  active = null;
  loaded = true;
}


void loadMaps() {
  try {
    minX = Double.NaN;
    shapes = new ArrayList();
    lookup = new HashMap();
    for (String fname : SOURCE_FILES) {
      List<Contour> fileShapes = loadShapefile(fname);
      /* there's probably a better way to concatenate arrays */
      for (Contour kant : fileShapes) {
        shapes.add(kant);
        lookup.put(kant.id, kant);
        //println(kant.id);
      }
    }
    /*
    compare the aspect ratio of the map to the aspect ratio
    of the screen to see which is the constraint
    */
    double dx = maxX - minX;
    double dy = maxY - minY;
    double aspect = dx / dy;
    double windowAspect = 1.0 * width / height;
    scale = windowAspect > aspect ? height / dy : width / dx;  
    //scale *= 0.8;
    for (Contour kant : shapes) {
      kant.rescale(minX, minY, scale);
    }
  } catch (IOException ioe) {
    throw new RuntimeException(ioe);
  }
}

ArrayList<Contour> loadShapefile(String prefix) throws IOException {
  Shapefile source = new Shapefile(new File(dataPath(prefix + "/" + prefix + ".shp")));
  DbfTable     dbf = new DbfTable(new File(dataPath(prefix + "/" + prefix + ".dbf")));
  String[] ids = dbf.getStringColumn(ID_COLUMN);
  String[][] rowData = new String[dataColumns.length][ids.length];
  for (int i = 0; i < dataColumns.length; i++) {
    rowData[i] = dbf.getStringColumn(dataColumns[i]);
  }
  ArrayList<Contour> container = new ArrayList();
  int rCount = 0;
  for (Shapefile.Record rec : source.getRecords()) {
    int[] offsets = rec.getPartOffsets();
    //println("record", rCount, "offets", offsets.length);
    for (int part = 0; part < offsets.length; part++) {
      int first = offsets[part];
      int last = (part == offsets.length - 1) ? rec.getPointCount() : offsets[part+1];
      String[] row = new String[dataColumns.length];
      for (int i = 0; i < dataColumns.length; i++) {
        row[i] = rowData[i][rCount];
      }
      Contour kant = new Contour(ids[rCount], row);
      container.add(kant);
      for (int p = first; p < last; p++) {
        ShapeCoord c = new ShapeCoord(rec.getX(p), rec.getY(p));
        kant.add(c);
        if (Double.isNaN(minX)) {
          minX = c.px;
          maxX = c.px;
          minY = c.py;
          maxY = c.py;
        } else {
          minX = Double.min(c.px, minX);
          maxX = Double.max(c.px, maxX);
          minY = Double.min(c.py, minY);
          maxY = Double.max(c.py, maxY);
        }
      }
    }   
    rCount++;
  }
  return container;
}

 //<>//

void draw() {
  background(0, 0, 100);
  if (!loaded) {
    text("loading", width/2, 100);
    fill(0);
  } else {
    noFill();
    stroke(0);
    for (Contour kant : shapes) {
      kant.draw(g, 0, 0);
    }
    drawImage();
    drawControls();
    
    noLoop();
    if (exporting) {
      export();
      exporting = false;
    }
  }
}






void drawImage() {
  
  pushMatrix();
  pushStyle();
  translate(width/2 + horizontal.getValue(), height/2 + vertical.getValue());
  rotate(rotation.getValue());
  scale(imageScale.getValue());
  tint(255, opacity.getValue());  // Display at half opacity
  image(theOtherMap, -mapImageW/2, -mapImageH/2);
  popStyle();
  popMatrix();
}


void drawControls() {
  opacity.draw();
  vertical.draw();
  rotation.draw();
  imageScale.draw();
  horizontal.draw();
}


void mousePressed() {
  active = null;
  for (int i = 0; i < controls.length; i++) {
    if (controls[i].contains(mouseX, mouseY)) {
      active = controls[i];
    }
  }
}

void mouseDragged() {
  if (active != null) {
    active.setTo(mouseX, mouseY);
  }
  loop();
}



void export() {
  float minX = Float.NaN;
  float minY = Float.NaN;
  float maxX = Float.NaN;
  float maxY = Float.NaN;
  for (Contour kant : shapes) {
    for (ShapeCoord c : kant.coordinates) {
      if (Float.isNaN(minX)) {
        minX = c.x; 
        minY = c.y; 
        maxX = c.x;
        maxY = c.y;
      } else {
        minX = min(minX, c.x); 
        minY = min(minY, c.y); 
        maxX = max(c.x, maxX);
        maxY = max(c.y, maxY);
      }
    }   
  }
  float xRange = maxX - minX;
  float yRange = maxY - minY;
  float range = 10000 / max(xRange, yRange); 
  PrintWriter writer = createWriter("output/" + exportFileName + ".json");
  boolean first = true;
  writer.println(String.format("{\"bounds\":[0.0,0.0,%d,%d],",round(xRange*range), round(yRange*range)));
  writer.println("\"projection\":\"Mercator\",");
  writer.println("\"shapes\":[");
  for (Contour kant : shapes) {
    if (first) {
      first = false;
    } else {
      writer.println(",");
    }
    //StringBuilder lonlat = new StringBuilder();
    StringBuilder xy = new StringBuilder();
    boolean firstCoord = true;
    for (ShapeCoord c : kant.coordinates) {
      if (firstCoord ) {
        firstCoord = false;
      } else {
        //lonlat.append(",");
        xy.append(",");
      }
      //lonlat.append("["+c.lon+","+c.lat+"]");
      //xy.append("["+c.px+","+c.py+"]");
      xy.append(String.format("%d,%d", round((c.x - minX) * range), round((c.y - minY) * range)));
    }
    writer.print("{\"id\":\"" + kant.id + "\"");
    for (int i = 0; i < dataColumns.length; i++) {
      writer.print(String.format(",\"%s\":\"%s\"", dataColumns[i], kant.data[i]));
    }
    //writer.print(",\"lonlat\":["+lonlat+"]");
    writer.print(",\"xy\":["+xy+"]}");
  }
  writer.println("]");
  writer.println("}");
  writer.flush();
  writer.close();
}

void mouseMoved() {
  loop();
}

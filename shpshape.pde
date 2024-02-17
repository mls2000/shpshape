import java.util.regex.*;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import com.benfry.carto.Shapefile;
import com.benfry.table.DbfTable;


boolean loaded = false;
List<Contour> shapes;
double minX, maxX, minY, maxY, scale;

//final String SOURCE_FILE = "tl_2021_33_bg";
//final String ID_COLUMN = "GEOID";
//final String[] dataColumns = new String[]{"NAMELSAD" , "COUNTYFP"};
final String SOURCE_FILE = "tl_2021_33015_roads";
final String ID_COLUMN = "LINEARID";
final String[] dataColumns = new String[]{"FULLNAME","RTTYP","MTFCC"};


boolean exporting = true;


void setup() {
  size(600, 800);
  thread("loadData");
  colorMode(HSB, 360, 100, 100);
  textSize(25);
  smooth(4);
}



void loadData() {
  loadMaps();  
  loaded = true;
}


void loadMaps() {
  try {
    minX = Double.NaN;
    shapes = loadShapefile(SOURCE_FILE);
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
  Shapefile source = new Shapefile(new File(dataPath(prefix + ".shp")));
  DbfTable     dbf = new DbfTable(new File(dataPath(prefix + ".dbf")));
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


void draw() {
  background(0, 0, 100);
  if (!loaded) {
    text("loading", width/2, 100);
    fill(0);
  } else {
    noFill();
    pushMatrix();
    stroke(0);
    for (Contour kant : shapes) {
      kant.draw(g, 0, 0);
    }
    popMatrix();
    noLoop();
    if (exporting) {
      export();
      exporting = false;
    }
  }
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
  PrintWriter writer = createWriter("output/" + SOURCE_FILE + ".json");
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

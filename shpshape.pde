import java.util.regex.*;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import com.benfry.carto.Shapefile;
import com.benfry.table.DbfTable;


boolean loaded = false;
List<Contour> shapes;
double minX, maxX, minY, maxY, scale;
Map<String, Contour> lookup;
List<String> acsColumns = new ArrayList();

String numeratorCol = "C17002e2";
String denominatorCol = "C17002e1";
int numeratorIndex; 
int denominatorIndex;




/* block groups, which can be merged with ACS data */
final String[] SOURCE_FILES = new String[]{"tl_2021_33_bg"};
final String ID_COLUMN = "GEOID";
final String[] dataColumns = new String[]{"NAMELSAD" , "COUNTYFP"};
final String exportFileName = "tl_2021_33_bg";

/* convert ACS files via python */
final String[] ACS_FILES = new String[]{"X17_POVERTY.csv"};
/* available columns are available from data/acs/BG_METADATA_2021.csv */
/* in the ACS files, the first column is a sequence, second the geo */
final int ACS_COL_START_INDEX = 2;

/* roads */
//final String[] SOURCE_FILES = new String[] {"tl_2021_33015_roads", "tl_2021_33017_roads"};
//final String ID_COLUMN = "LINEARID";
//final String[] dataColumns = new String[]{"FULLNAME","RTTYP","MTFCC"};
//final String exportFileName = "tl_2021_33015_roads";

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
  loadDemoData();
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

void loadDemoData() {
  Table table = loadTable("acs/bg/BG_METADATA_2021.csv", "header");
  Map<String, String> names = new HashMap(); //<>//
  for (int i = 0; i < table.getRowCount(); i++) {
    names.put(table.getString(i, "Short_Name"), table.getString(i, "Full_Name"));
  }
  acsColumns = new ArrayList();
  for (String fname : ACS_FILES) {
    table = loadTable("acs/bg/" + fname, "header");
    String [] colNames = table.getColumnTitles();
    for (int c = ACS_COL_START_INDEX; c < colNames.length; c++) {
      String shortName = colNames[c];
      String fullName = names.get(shortName);
      acsColumns.add(fullName);
      if (numeratorCol.equals(shortName)) {
        numeratorIndex = c - ACS_COL_START_INDEX;
      }
      if (denominatorCol.equals(shortName)) {
        denominatorIndex = c - ACS_COL_START_INDEX;
      }      
    }
    /* geo id in the ACS file has a prefix of "15000US" */
    final int idStart = "15000US".length();
    for (int r = 0; r < table.getRowCount(); r++) {
      String geoId = table.getString(r, 1).substring(idStart);
      Contour kant = lookup.get(geoId);
      if (kant != null) {
        for (int c = ACS_COL_START_INDEX; c < colNames.length; c++) {
           float f = table.getFloat(r, c);
           kant.addACS(f);
        }
      }
    }
  }
  //println(columns);
  

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

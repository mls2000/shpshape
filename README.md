# block group shapefiles
https://www2.census.gov/geo/tiger/TIGER2021/BG/tl_2021_33_bg.zip

# roads
https://www2.census.gov/geo/tiger/TIGER2021/ROADS/tl_2021_33017_roads.zip
https://www2.census.gov/geo/tiger/TIGER2021/ROADS/tl_2021_33015_roads.zip

# demographics from 
https://www2.census.gov/geo/tiger/TIGER_DP/2021ACS/ACS_2021_5YR_BG_33.gdb.zip
https://www2.census.gov/geo/tiger/TIGER_DP/2021ACS/Metadata/BG_METADATA_2021.txt


# to convert demographics from gdb to csv
```
python3 -m venv venv
. venv/bin/activate
pip install pandas
pip install geopandas
# make the output folder
mkdir -p data/acs/bg

python3
import geopandas as gpd
import fiona
path = 'data/ACS_2021_5YR_BG_33_NEW_HAMPSHIRE.gdb'
for flayer in fiona.listlayers(path):
  fc = gpd.read_file(path, driver='FileGDB', layer=flayer)
  fc.to_csv(f'./data/acs/bg/{flayer}.csv')
```


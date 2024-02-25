# Making census data maps with [Processing](https://processing.org/)

This example takes shapefiles provided by the US Census and generates maps from them. It provides an code example of generating a data driven map where census block groups are color coded by percent of the population with income at less than 50% of the poverty level. 

Note that the example isn't a completed visualization: there is no legend, no interaction, etc. To recreate the example, you will need to download census data (see the section "To run the example" below). 

## Background
In order to generate these maps, we use a couple different kinds of data provided by the US Census. The first thing to know is that the Census provides data aggreagated at different geographic resolutions. In addition to national, state, and county levels, the census also defines tracts, blocks, and block groups. Blocks are the finest resolution data. 

Information for states and counties is coded using Federal Information Processing System (FIPS) Codes. For example, the FIPS code for Massachusetts is `25`, and the code for Suffolk county is `25025`. A list of state and county codes can be found [here](https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt)

The official census is taken once every ten years, but annual updates are estimated via the American Community Survey (ACS). The data are aggregated for each of the above geographic resolutions. 

In addition to population and demographic data by location, the census provides cartographic data via the [TIGER](https://www2.census.gov/geo/tiger/TIGER2023/) files. These can get updated year to year, so be sure to look at the correct year. These are in an industry standard format where contours of the areas are in `.shp` files and accompanying data will be in a `.dbf` file. These files are available for states, counties, tracts, block groups, etc., as well as [all the streets and roads](https://www2.census.gov/geo/tiger/TIGER2023/ROADS/) in the US. [Here's](https://benfry.com/allstreets/) an example of a map made up of only the roads in the 48 contiguous states in the US. 


## Prerequisites
Some of this code assumes a comfort level running python code from the terminal or other command line interface. 

You'll need [Processing](https://processing.org/download/) to generate the maps, and python3 to preprocess ACS data. In python3, you will need libraries for `geopandas`
and `fiona`. Here's a python tip you may know: because different python projects might need different versions of the same libraries, it can be useful to create a virtual environment for each project. This creates a sandbox where you can install the library, isolated from other projects. Assuming you have python3, you can create the virtual environment and install the libraries with 
```
# open the terminal and cd to this folder
# create the virtual environment
python3 -m venv venv
# activate the virtual environment
. venv/bin/activate
# install the libraries
pip install pandas
pip install geopandas
pip install fiona
```

You will also need to download files from the census. 

## To run the example

The census data to run the example is not included in this git repository. You'll need to download files from the census, and save them to the `data` file of this project. There you can unzip them. 

Download the [TIGER files for the block groups in New Hampshire](https://www2.census.gov/geo/tiger/TIGER2021/BG/tl_2021_33_bg.zip) (FIPS code 33). 

Download the [ACS data](https://www2.census.gov/geo/tiger/TIGER_DP/2021ACS/ACS_2021_5YR_BG_33.gdb.zip). Once this file is unzipped, you will have a folder called `ACS_2021_5YR_BG_33_NEW_HAMPSHIRE.gdb`. In order to convert into something we can use, you'll need to run the  instructions in the "to convert demographics from gdb to csv" below. 


Once all the data is unzipped and transformed in the `data` file for this project, open Processing. In Processing, from the `File` dialog, choose `Open` and select the `shpshape.pde` file in this project. Press the "play" button at the top, and it should open up a new window that looks like this: 



There is an extra example of mapping roads data. For that you will need [these](https://www2.census.gov/geo/tiger/TIGER2021/ROADS/tl_2021_33017_roads.zip) [two](https://www2.census.gov/geo/tiger/TIGER2021/ROADS/tl_2021_33015_roads.zip) files. 


##  to convert demographics from gdb to csv
The ACS data is downloaded in a format that isn't supported by the Processing libraries we are using. But we can convert from that format to a simple `.csv` file using python. Assuming you installed the python libraries we need according to the "Prerequisites" section above, run these commands in a command line interface, from this project folder.

```
# make sure the virtual environment is active
. venv/bin/activate
# make the output folder. Since this example is using ACS Block Group data, 
# we'll call it 'acs/bg'
mkdir -p data/acs/bg
# import the libraries you need
import geopandas as gpd
import fiona
# specify the .gdb folder we want to convert? 
path = 'data/ACS_2021_5YR_BG_33_NEW_HAMPSHIRE.gdb'
# go through the available layers of .gdb data and convert each of them. 
for flayer in fiona.listlayers(path):
  fc = gpd.read_file(path, driver='FileGDB', layer=flayer)
  fc.to_csv(f'./data/acs/bg/{flayer}.csv')
```

once this is complete you should see a bunch of files in the `acs/bg` folder like 
```
X01_AGE_AND_SEX.csv
X02_RACE.csv
X03_HISPANIC_OR_LATINO_ORIGIN.csv
```
etc.
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

You'll need [Processing](https://processing.org/download/) to generate the maps. 

You will also need to download files from the census. 

## To run the example

The census data to run the example is not included in this git repository. You'll need to download files from the census, and save them to the `data` file of this project. There you can unzip them. 

This branch has an example of mapping roads data. You will need to download and unzip [these](https://www2.census.gov/geo/tiger/TIGER2021/ROADS/tl_2021_33017_roads.zip) [two](https://www2.census.gov/geo/tiger/TIGER2021/ROADS/tl_2021_33015_roads.zip) files. 


Once all the data is unzipped in the `data` file for this project, open Processing. In Processing, from the `File` dialog, choose `Open` and select the `shpshape.pde` file in this project. Press the "play" button at the top, and it should open up a new window that looks like this: 


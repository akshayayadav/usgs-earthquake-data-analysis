# USGS EARTHQUAKE DATA ANALYSIS

## Abstract

The United States Geological Survey (USGS) maintains detailed information on earthquakes experienced around the world. The information such as location, intensity, time and date of earthquakes around the globe can be accessed through the web-APIs provided by USGS. For this project, I intend to build data access and analysis methods in R that can get user-defined earthquake data from USGS and display it in suitable formats.
I will have to use the methods in R that process XML/JSON since the data obtained from web-APIs will be in these formats. I will also use the date-time processing functions in R to convert the timestamps of earthquakes into easily accessible formats.

One of my main tasks for these projects will be infering the region names like country/continent from the longitude-latitude coordinates provided by the database. This will be useful in filtering earthquake data by country or continents.
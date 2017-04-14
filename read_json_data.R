library(jsonlite)
library(tidyverse)
library(purrr)
library(sp)
library(rworldmap)

convert_coords_to_regions = function(points)
{  
  countriesSP <- getMap(resolution='low')
  #countriesSP <- getMap(resolution='high') #you could use high res map from rworldxtra if you were concerned about detail
  
  # converting points to a SpatialPoints object
  # setting CRS directly to that from rworldmap
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  
  
  # use 'over' to get indices of the Polygons object containing each point 
  indices = over(pointsSP, countriesSP)
  
  #indices$continent   # returns the continent (6 continent model)
  
  #return(indices$REGION)   # returns the continent (7 continent model)
  #indices$ADMIN  #returns country name
  #indices$ISO3 # returns the ISO3 code 
  outdataframe<-data.frame(continents=indices$REGION,countries=indices$ADMIN)
  return(outdataframe)
}

attach_regions<-function(inTable){
  lon_lat_dataframe<-data.frame(lon=inTable$longitude,lat=inTable$latitude)
  regions_dataframe<-convert_coords_to_regions(lon_lat_dataframe)
  outTable<-cbind.data.frame(inTable,regions_dataframe)
  return(outTable)
}

get_lat_log_depth<-function(coord_list){
  return_table<-cbind.data.frame(longitude=coord_list[1],latitude=coord_list[2],depth=coord_list[3])
  return(data.frame(return_table))
}

get_table_from_json <- function(starttime=2014-01-01,endtime=2014-01-02){
  link="https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2014-01-01&endtime=2014-01-02"
  geojson<-fromJSON(link)
  
  geojson.table<-as.data.frame(geojson$features)
  
  names(geojson.table$properties)[names(geojson.table$properties)=="type"]<-"properties-type"
  names(geojson.table$geometry)[names(geojson.table$geometry)=="type"]<-"geometry-type"
  quake.table<-cbind.data.frame(id=geojson.table$id,geojson.table$properties,geojson.table$geometry)
  
  quake.table<-quake.table %>% mutate(coords=map(coordinates,get_lat_log_depth)) %>% unnest(coords)
  return(quake.table)
}
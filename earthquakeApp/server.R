
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(jsonlite)
library(dplyr)
library(tidyr)
library(purrr)
library(sp)
library(rworldmap)
library(ggplot2)
#library(ggmap)
library(plotly)
#source("../read_json_data.R")
#source("../util_functions.R")

#################################################################################################

convert_coords_to_regions = function(points){  
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
  regions_dataframe$countries<-as.character(regions_dataframe$countries)
  regions_dataframe$continents<-as.character(regions_dataframe$continents)
  regions_dataframe[is.na(regions_dataframe)]<-"Unclassified"
  outTable<-cbind.data.frame(inTable,regions_dataframe)
  return(outTable)
}

get_lat_log_depth<-function(coord_list){
  #return_table<-list(longitude=coord_list[1],latitude=coord_list[2],depth=coord_list[3])
  return_table<-data.frame(matrix(coord_list,nrow=1,ncol=3))
  names(return_table)<-c("longitude","latitude","depth")
  return(return_table)
}

get_table_from_json <- function(starttime="2014-01-01",endtime="2014-01-02"){
  baselink="https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&"
  link=paste0(baselink,"starttime=",starttime,"&endtime=",endtime)
  geojson<-fromJSON(link)
  
  geojson.table<-as.data.frame(geojson$features)
  
  names(geojson.table$properties)[names(geojson.table$properties)=="type"]<-"properties-type"
  names(geojson.table$geometry)[names(geojson.table$geometry)=="type"]<-"geometry-type"
  quake.table<-cbind.data.frame(id=geojson.table$id,geojson.table$properties,geojson.table$geometry)
  
  quake.table<-quake.table %>% mutate(coords=lapply(coordinates,get_lat_log_depth)) %>% unnest(coords)
  return(quake.table)
}

get_earthquake_data<-function(starttime="2014-01-01",endtime="2014-01-02"){
  quake.data.table<-get_table_from_json(starttime=starttime,endtime=endtime)
  quake.data.table<-attach_regions(quake.data.table)
  return(quake.data.table)
}

##########################################################################################################

get_option_list<-function(invalues){
  outValues<-unique(na.omit(invalues))
  outValues<-as.list(outValues)
  return(outValues)
}

##########################################################################################################

shinyServer(function(input, output) {

  observeEvent(input$GetData, {
    dates<-format(input$startdate)
    quake.data.table<-get_earthquake_data(starttime=dates[1],endtime=dates[2])
    mp <- NULL
    mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
    
    output$sigSlider<-renderUI({
      sigDataRange<-c(min(quake.data.table$sig),max(quake.data.table$sig))
    sliderInput("significance", label = "Filter by Significance", min = sigDataRange[1], 
                max = sigDataRange[2], value = sigDataRange[1])
    })
    
    observeEvent(input$significance,{
      filtered.quake.data.table <- reactive({
        sigRange<-input$significance
        quake.data.table %>% filter(sig>=sigRange)
      })
      
      
      
      output$scatter1<-renderPlotly({
        ggplty<-filtered.quake.data.table() %>% ggplot(aes(x=sig,y=depth,label=place))+
          geom_point(data=filtered.quake.data.table(),aes_string(colour=input$histBy))
        ggplotly(ggplty)
      })
      
      output$scatter2<-renderPlotly({
        ggplty<-filtered.quake.data.table() %>% ggplot(aes(x=sig,y=mag,label=place))+
          geom_point(data=filtered.quake.data.table(),aes_string(colour=input$histBy))
        ggplotly(ggplty)
      })
      
      
      output$histplot <- renderPlotly({
        histplty<-ggplot(data = filtered.quake.data.table(),aes_string(x = input$histBy,fill=input$histBy)) +
        geom_bar(stat="count") + 
        scale_x_discrete(labels = abbreviate)
        theme(axis.text.x=element_blank(),axis.title.x=element_blank())
        
        ggplotly(histplty,tooltip="count")
      })
      output$mapPlotOptions<-renderUI({
        tagList(
          selectInput("contiSelect", label = "Select Continent to display", 
                      choices = get_option_list(filtered.quake.data.table()$continents)),
          
          actionButton("mapPlot", label = "Show on Map")
        )
      })
      
      observeEvent(input$mapPlot,{
        filtered.data.table.map<-filtered.quake.data.table() %>% filter(continents==input$contiSelect)
        
        output$mapPlotOutput<-renderPlotly({
          mp <- ggplot(data = filtered.data.table.map,aes(label=place)) + mapWorld
          mapPlotly<-mp+ geom_point(aes(x = longitude, y = latitude) ,color="red", size=2)
          ggplotly(mapPlotly)
        })
        
      })
      
      })
    
    
    })
    

})

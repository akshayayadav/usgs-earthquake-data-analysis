
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
source("../read_json_data.R")
source("../util_functions.R")

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
        histplty<-ggplot(data = filtered.quake.data.table(), aes_string(x = input$histBy, fill = input$histBy)) +
          geom_bar(stat="count") +
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
          mp <- ggplot(data=filtered.data.table.map,aes(label=place)) + mapWorld
          mapPlotly<-mp+ geom_point(data = filtered.data.table.map, aes(x = longitude, y = latitude) ,color="red", size=2)
          ggplotly(mapPlotly)
        })
        
      })
      
      })
    
    
    })
    

})

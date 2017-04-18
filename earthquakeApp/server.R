
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(jsonlite)
library(tidyverse)
library(purrr)
library(sp)
library(rworldmap)
library(ggmap)
library(ggvis)
source("../usgs-earthquake-data-analysis/read_json_data.R")

shinyServer(function(input, output) {

  observeEvent(input$GetData, {
    dates<-format(input$startdate)
    quake.data.table<-get_table_from_json(starttime=dates[1],endtime=dates[2])
    quake.data.table<-attach_regions(quake.data.table)
    
    filtered.quake.data.table <- reactive({
      sigRange<-input$significance
      quake.data.table %>% filter(sig>=sigRange)
    })
    
    output$plot <- renderPlot({
      ggplot(data = filtered.quake.data.table(), aes_string(x = input$histBy, fill = input$histBy)) +
        geom_bar(stat = "count") +
        theme_bw() +
        theme(axis.text.x=element_text(angle=30, hjust=1,size = 10),axis.title.x=element_blank())
      }) 
    
    observeEvent(input$mapPlot,{
      filtered.data.table.map<-filtered.quake.data.table()
      locationbox<-c(min(filtered.data.table.map$longitude),
                     min(filtered.data.table.map$latitude),
                     max(filtered.data.table.map$longitude),
                     max(filtered.data.table.map$latitude))
      selectedmap <-get_map(location = input$contiSelect,
                zoom = 3, maptype = "hybrid", scale = 2)
      
      output$mapPlotOutput<-renderPlot({
        ggmap(selectedmap,extent="device") +
          geom_point(data = filtered.data.table.map, aes(x = longitude, y = latitude, fill = "red", alpha = 0.8), size = 5, shape = 21) +
          guides(fill=FALSE, alpha=FALSE, size=FALSE) + coord_fixed(ratio=2/2)
      })
      
    })
    
    })
    
  

  
  

})

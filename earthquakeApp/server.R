
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
#library(ggmap)
library(plotly)
source("../read_json_data.R")
source("../util_functions.R")

shinyServer(function(input, output) {

  observeEvent(input$GetData, {
    dates<-format(input$startdate)
    quake.data.table<-get_earthquake_data(starttime=dates[1],endtime=dates[2])
    
    output$sigSlider<-renderUI({
    sliderInput("significance", label = "Filter by Significance", min = 0, 
                max = max(quake.data.table$sig), value = 0)
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
      
      output$histplot <- renderPlotly({
        histplty<-ggplot(data = filtered.quake.data.table(), aes_string(x = input$histBy, fill = input$histBy)) +
          geom_bar(stat = "count") +
          theme_bw() +
          theme(axis.text.x=element_text(angle=0, hjust=1,size = 10),axis.title.x=element_blank())
        ggplotly(histplty)
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
        #locationbox<-make_bbox(lon=longitude,lat=latitude,data=filtered.data.table.map,f=0.1)
        #selectedmap <-get_map(location = locationbox,zoom = 3, scale = 2)
        
        output$mapPlotOutput<-renderPlotly({
          #ggmap(selectedmap,extent="panel") +
          # geom_point(data = filtered.data.table.map, aes(x = longitude, y = latitude, fill = "red", alpha = 0.8), size = 4, shape = 21) +
          #guides(fill=FALSE, alpha=FALSE, size=FALSE) + coord_fixed()
          
          mp <- NULL
          mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
          mp <- ggplot(data=filtered.data.table.map,aes(label=place)) + mapWorld
          mapPlotly<-mp+ geom_point(data = filtered.data.table.map, aes(x = longitude, y = latitude) ,color="red", size=2)
          ggplotly(mapPlotly)
        })
        
      })
      
      })
    
    
    })
    

})

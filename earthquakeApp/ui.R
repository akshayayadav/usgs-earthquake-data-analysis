library(shiny)
library(plotly)

shinyUI(fluidPage(

  # Application title
  titlePanel("USGS Earthquake Data Analysis"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("startdate", "Select start date", min = NULL, max = NULL,
                format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                language = "en", width = NULL),
      actionButton("GetData", label = "Get Earthquake Data"),
      
      radioButtons("histBy", label = h3("Distribution by"),
                   choices = list("By Country" = "countries", "By Continent" = "continents"), 
                   selected = "countries"),
      
      sliderInput("significance", label = h3("Filter by Significance"), min = 0, 
                  max = 1000, value = 0),
      
      uiOutput("mapPlotOptions")
    ),
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Tab1",plotOutput("plot"), plotlyOutput("mapPlotOutput")),
        tabPanel("Tab2",plotlyOutput("scatter1"))
      )
    )
  )
  
))

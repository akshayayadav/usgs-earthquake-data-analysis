library(shiny)
library(plotly)

shinyUI(fluidPage(

  # Application title
  titlePanel("USGS Earthquake Data Analysis"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("startdate", "Select from and to dates", min = NULL, max = NULL,
                format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                language = "en", width = NULL),
      actionButton("GetData", label = "Get Earthquake Data"),
      
      radioButtons("histBy", label = "Distribution by",
                   choices = list("By Country" = "countries", "By Continent" = "continents"), 
                   selected = "countries"),
      
      uiOutput("sigSlider"),
      
      
      uiOutput("mapPlotOptions")
    ),
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Distribution and Map",plotlyOutput("histplot",width = "800px", height = "500px"), plotlyOutput("mapPlotOutput",width = "800px", height = "500px")),
        tabPanel("Scatter Plots",plotlyOutput("scatter1",width = "800px", height = "500px"),plotlyOutput("scatter2",width = "800px", height = "500px"))
      )
    )
  )
  
))

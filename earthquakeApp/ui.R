library(shiny)

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
      
      selectInput("contiSelect", label = h3("Select Continent to display"), 
                  choices = list("Africa" = "africa", 
                                 "Antartica"="antartica",
                                 "Asia" = "asia", 
                                 "Australia/Oceania" = "australia",
                                 "Europe"="europe",
                                 "North America" = "north america",
                                 "South America" = "south america"
                                 ), 
                  selected = "Africa"),
      
      actionButton("mapPlot", label = "Show on Map")
      
      
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plot"),
      plotOutput("mapPlotOutput")
    )
  )
  
))

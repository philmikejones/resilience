#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library("shiny")
library("sf")
library("tmap")
oa = readRDS("../data/oa.rds")


ui <- bootstrapPage(

  titlePanel("Resilient characteristics"),

  selectInput(
    inputId  = "choose_variable",
    label    = "Choose variable",
    choices  = c("cheese", "coffee"),
    selected = "cheese"
  ),

  plotOutput("map")

)


server <- function(input, output) {

  map =
    tmap::tm_shape(oa) +
    tmap::tm_polygons("pop_16_plus") +
    tmap::tm_layout(frame = FALSE)

  output$map <- renderPlot({
    map
  })

}

shinyApp(ui = ui, server = server)

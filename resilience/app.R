#
#    http://shiny.rstudio.com/
#

library("shiny")
library("tidyverse")
library("sf")
library("tmap")
don = readRDS("../data/don.rds")


ui <- fluidPage(

  titlePanel("Resilient characteristics"),

  sidebarLayout(

    sidebarPanel(
      selectInput(
        inputId  = "choose_variable",
        label    = "Choose variable",
        choices  = c("cheese", "coffee"),
        selected = "cheese"
      )
    ),

    mainPanel(
      plotOutput("map", height = "700px")
    )

  )

)


server <- function(input, output) {

  map =
    tmap::tm_shape(don) +
    tmap::tm_polygons("pop_16_plus") +
    tmap::tm_layout(frame = TRUE)

  output$map <- renderPlot({
    map
  })

}

shinyApp(ui = ui, server = server)

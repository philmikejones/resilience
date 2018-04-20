#
#    http://shiny.rstudio.com/
#

library("shiny")
library("magrittr")
library("sf")
library("leaflet")

don = readRDS("../data/don.rds")
vars = readRDS("../data/vars.rds")


ui <- fluidPage(

  titlePanel("Resilient characteristics"),

  sidebarLayout(

    sidebarPanel(
      selectInput(
        inputId  = "chosen_var",
        label    = "Choose variable:",
        choices  = vars,
        selected = vars[1]
      ),
      width = 3
    ),

    mainPanel(
      leafletOutput(outputId = "map", height = "700px")
    )

  )

)


server <- function(input, output) {

  output$map <- renderLeaflet({

    leaflet(don) %>%
      addProviderTiles(
        "OpenStreetMap.Mapnik",
      ) %>%
      addPolygons(
        weight = 1,
        fillColor = input$chosen_var
      )

  })

}

shinyApp(ui = ui, server = server)

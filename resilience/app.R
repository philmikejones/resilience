library("shiny")
library("magrittr")
library("dplyr")
library("sf")
library("leaflet")

don  = readRDS("../data/don.rds")
vars = readRDS("../data/vars.rds")

ui <- fluidPage(

  mainPanel(
    leafletOutput(outputId = "map", height = "700px"),
    width = 12
  )

)


server <- function(input, output) {

  output$map <- renderLeaflet({

    pal = colorNumeric("YlOrRd", don$`Neighbourhood cohesion`)

    leaflet(don) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        weight = 1,
        fillColor = ~pal(don$`Neighbourhood cohesion`),
        fillOpacity = 0.6
      ) %>%
      addLegend(
        "bottomright",
        pal = pal,
        values = ~ don$`Neighbourhood cohesion`,
        opacity = 0.6,
        title = "Count (persons)"
      )

  })

}

shinyApp(ui = ui, server = server)

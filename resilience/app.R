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
        inputId  = "choose_variable",
        label    = "Choose variable",
        choices  = vars,
        selected = vars[1]
      ),
      width = 3
    ),

    mainPanel(
      leafletOutput("map", height = "700px")
    )

  )

)


server <- function(input, output) {

  colour = colorNumeric(
    palette = "Blues",
    domain  = don$pop_16_plus
  )

  output$map <- renderLeaflet({
    leaflet(don) %>%
      addPolygons(
        weight = 1,
        fillOpacity = 0.8,
        fillColor = ~colour(pop_16_plus)
      ) %>%
      addProviderTiles(
        "OpenStreetMap.Mapnik",
        options = providerTileOptions(opacity = 0.33)
      ) %>%
      addLegend(
        "bottomright",
        pal = colour,
        values = ~pop_16_plus,
        title = "Doncaster resilience",
        opacity = 0.8
      )
  })

}

shinyApp(ui = ui, server = server)

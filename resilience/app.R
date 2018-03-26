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
      textOutput("var"),
      leafletOutput("map", height = "700px")
    )

  )

)


server <- function(input, output) {

  output$var = renderText(input$choose_variable)
  output$map <- renderLeaflet({

    pal = reactive(colorNumeric(
      palette = "YlGn",
      domain  = don()[[input$choose_variable]]
    ))

    fillPal = reactive(~pal()(don[[input$choose_variable]]))

    leaflet(don) %>%
      addProviderTiles(
        "OpenStreetMap.Mapnik",
        options = providerTileOptions(opacity = 0.33)
      ) %>%
      addPolygons(
        weight = 1,
        fillOpacity = 0.6,
        fillColor = fillPal
      )

  })

}

shinyApp(ui = ui, server = server)

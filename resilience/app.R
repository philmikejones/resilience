library("shiny")
library("magrittr")
library("dplyr")
library("sf")
library("leaflet")

don  = readRDS("../data/don.rds")
vars = readRDS("../data/vars.rds")

ui <- fluidPage(

  mainPanel(

    selectInput(
      inputId  = "selected_var",
      label    = "Choose variable to plot",
      selected = vars[2],
      choices  = vars
    ),

    leafletOutput(outputId = "map", height = "700px"),
    width = 12

  )

)


server <- function(input, output) {

  output$map <- renderLeaflet({

    var = reactive(don %>% select(code, name, input$selected_var))
    pal = colorNumeric("YlOrRd", domain = c(0, 16555))

    leaflet(don) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        weight = 1,
        fillColor = ~ pal(var()[[input$selected_var]]),
        fillOpacity = 0.6
      ) %>%
      addLegend(
        "bottomright",
        pal = pal,
        values = ~ c(0, 16555),
        opacity = 0.6,
        title = "Count (persons)"
      )

  })

}

shinyApp(ui = ui, server = server)

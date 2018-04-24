
library("shiny")
library("leaflet")
library("dplyr")
library("sf")

don  = readRDS("../data/don.rds")
vars = readRDS("../data/vars.rds")
don_pal = readRDS("../data/don_pal.rds")


ui <- fluidPage(

  mainPanel(

    selectInput(
      inputId  = "selected_var",
      label    = "Choose variable to plot",
      selected = vars[2],
      choices  = vars
    ),

    leafletOutput(outputId = "map", width = "100%", height = "700px"),
    width = 12
  )

)


server <- function(input, output) {

  colorpal <- reactive({
    colorNumeric("Blues", don[[input$selected_var]])
  })

  output$map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lat = 53.53, lng = -1.1, zoom = 11)

  })

  observe({

    pal <- colorpal()

    leafletProxy("map", data = don) %>%
      clearShapes() %>%
      addPolygons(weight = 1, fillColor = ~pal(don[[input$selected_var]]))

  })

  observe({

    pal <- colorpal()

    leafletProxy("map", data = don) %>%
      clearControls() %>%
      addLegend(
        position = "bottomright",
        pal = pal, values = ~ don[[input$selected_var]],
        title = "Number of persons"
      )

  })

}

shinyApp(ui = ui, server = server)

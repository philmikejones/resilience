library("shiny")
library("magrittr")
library("dplyr")
library("sf")
library("leaflet")

don  = readRDS("../data/don.rds")
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
      DT::dataTableOutput(outputId = "table"),
      leafletOutput(outputId = "map", height = "700px")
    )

  )

)


server <- function(input, output) {

  don_subset <-
    reactive({
      don %>%
        select(code, name, input$chosen_var)
    })

  output$table <- DT::renderDataTable({
    don_subset() %>% sf::st_set_geometry(NULL)
  })

  colourpal <- reactive({
    colorBin("Blues", domain = don[[input$chosen_var]])
  })

  output$map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles("OpenStreetMap.Mapnik")

  })

  observe({
    leafletProxy("map", data = don_subset()) %>%
      addPolygons(weight = 1, fillColor = colourpal, fillOpacity = 0.4)
  })

}

shinyApp(ui = ui, server = server)

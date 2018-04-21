library("shiny")
library("magrittr")
library("sf")
library("leaflet")

don = readRDS("../data/don.rds")
vars = readRDS("../data/vars.rds")
pal_range = c(50, 17000)

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

    pal = colorNumeric("Blues", pal_range)

    leaflet(don) %>%
      addProviderTiles("OpenStreetMap.Mapnik") %>%
      addPolygons(
        weight = 1,
        fillColor = ~ pal(don[[input$chosen_var]]),
        fillOpacity = 0.7
      )

  })

}

shinyApp(ui = ui, server = server)

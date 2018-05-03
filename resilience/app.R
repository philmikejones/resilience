
library("shiny")
library("leaflet")
library("sf")

don  = readRDS("data/don.rds")
vars = readRDS("data/vars.rds")
ghq  = readRDS("data/ghq-notes.rds")

ui <- fluidPage(

  mainPanel(

    selectInput(
      inputId  = "selected_var",
      label    = "Choose variable to plot",
      selected = vars[2],
      choices  = vars
    ),

    leafletOutput(outputId = "map", width = "100%", height = "700px"),
    tags$h4("GHQ items"),
    DT::DTOutput("ghq_notes"),
    width = 12
  )

)


server <- function(input, output) {

  colorpal <- reactive({
    colorNumeric("BuGn", don[[input$selected_var]])
  })

  output$map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lat = 53.53, lng = -1.1, zoom = 11)

  })

  observe({

    if (input$selected_var == "Population (16+)") {
      var = don[[input$selected_var]]
    } else {
      var = paste0(
        format(don[[input$selected_var]] * 100, digits = 4),
        "%"
      )
    }

    labels <- sprintf(
      "<strong>%s</strong><br/>%s",
      don$name, var
    ) %>% lapply(htmltools::HTML)

    pal <- colorpal()

    leafletProxy("map", data = don) %>%
      clearShapes() %>%
      addPolygons(
        weight = 1,
        fillColor = ~pal(don[[input$selected_var]]),
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          color = "white", weight = 2, bringToFront = TRUE
        ),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"
        )
      )

  })

  observe({

    pal <- colorpal()

    if (input$selected_var == "Population (16+)") {
      title = "Number of persons 16+"
    } else {
      title = "Proportion of persons 16+"
    }

    title <- sprintf(
      "%s<br/>%s",
      input$selected_var, title
    ) %>% lapply(htmltools::HTML)

    leafletProxy("map", data = don) %>%
      clearControls() %>%
      addLegend(
        position = "bottomright",
        pal = pal, values = ~ don[[input$selected_var]],
        title = title,
        opacity = 0.7
      )

  })

  output$ghq_notes <- DT::renderDT(
    ghq,
    options = list(pageLength = nrow(ghq))
  )

}

shinyApp(ui = ui, server = server)

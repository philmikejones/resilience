
library("shiny")
library("shinythemes")
library("leaflet")
library("sf")

don  = readRDS("data/don.rds")
vars = readRDS("data/vars.rds")
ghq  = readRDS("data/ghq-notes.rds")

ui <- fluidPage(

  theme = shinytheme("lumen"),

  mainPanel(

    wellPanel(
      selectInput(
        inputId  = "selected_var",
        label    = "Choose variable to plot",
        selected = vars[2],
        choices  = vars
      )
    ),

    tabsetPanel(
      tabPanel(
        "Plot",
        leafletOutput(outputId = "map", width = "100%", height = "650px")
      ),

      tabPanel(
        "Notes",
        tags$br(),
        tags$ul(
          tags$li("Copyright 2018 Phil Mike Jones."),
          tags$li("Population (16+) from 2011 Census."),
          tags$li("Other variables are simulated using data from 2011 Census and Understanding Society."),
          tags$li(
            "For details on the simulation method see ",
            tags$a(
              "Jones, P M (2017) ",
              tags$em("A Spatial Microsimulation Analysis of Health Inequalities and Health Resilience"),
              ". PhD thesis, University of Sheffield.",
              href = "http://etheses.whiterose.ac.uk/19283/"
            )
          )
        )
      ),

      tabPanel(
        "GHQ items",
        p(
          "Variables labelled \"GHQ:\" are items in the General Health Questionnaire, copyright ",
          tags$a("GL Assessment", href = "https://www.gl-assessment.co.uk/products/general-health-questionnaire-ghq/"),
          ", and asked in Understanding Society.",
          "The scores for some items have been reversed to make scoring direction consistent, and scores of 1-2 were coded as resilient."
        ),

        DT::DTOutput("ghq_notes")
      ),

      tabPanel(
        "Sources",
        {
          tags$dl(
            tags$dt("Boundary data"),
            tags$dd(
              "Office for National Statistics, 2011 Census: Digitised Boundary Data (England and Wales) [computer file]. UK Data Service Census Support. Downloaded from: ",
              tags$a("https://borders.ukdataservice.ac.uk/")
            ),

            tags$dt("2011 Census"),
            tags$dd(
              "Office for National Statistics (2016): 2011 Census aggregate data. UK Data Service (Edition: June 2016). DOI: ",
              tags$a("http://dx.doi.org/10.5257/census/aggregate-2011-1")
            ),

            tags$dt("Understanding Society"),
            tags$dd(
              "University of Essex. Institute for Social and Economic Research, NatCen Social Research, Kantar Public. (2017). Understanding Society: Waves 1-7, 2009-2016 and Harmonised BHPS: Waves 1-18, 1991-2009. [data collection]. 9th Edition. UK Data Service. SN: 6614"
            )
          )
        }
      )

    ),

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

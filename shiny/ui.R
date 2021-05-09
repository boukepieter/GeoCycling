library(leaflet)

# Choices for drop-downs
vars <- c(
  "Is SuperZIP?" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "Population" = "adultpop"
)


navbarPage("GeoCycling", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="100%"
                    ),
      absolutePanel(
        id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
        width = 550, height = "auto",
        HTML('<div class="wrapper"><button data-toggle="collapse" data-target="#explainer">Minimize</button></div>'),
        h2("The GeoCycling Project"),
        tags$div(id = 'explainer',  class = "collapse in",
                 tags$img(src = "pic.jpeg", width = "500px", align = "center"),
                 tags$br(), tags$br(),
                 'This project brings three hobbies of me, Bouke Pieter Ottow, together; Geography, IT and cycling. 
                 The plan is to cycle through the province of Utrecht while visiting all the places, 
                 one municipality at a time and making selfies of the place name signs.
                 This dashboard provides you the opportunity to track my progress and discover the outcome.' ,
                 tags$br(),
                 'The name GeoCycling makes a verb out of a nickname I have used for years: GeoCycle.', 
                 tags$br(), tags$br(),
                 'To change the visible layers; click on the layers icon in the bottom left.',
                 tags$br(), tags$br(),
                 'Follow me on ', tags$a("Strava", href = "https://www.strava.com/athletes/5107070"), ', ', 
                 tags$a("Twitter", href = "https://twitter.com/BoukePieter"), ', ',
                 tags$a("LinkedIn", href = "https://www.linkedin.com/in/bouke-pieter-ottow/"), ', or ',
                 tags$a("GitHub", href = "https://github.com/boukepieter/GeoCycling"), '.',
                 tags$br(),
                 'Or my blog; ', tags$a("Wondering Nomads", href = "https://wonderingnomads.world/"), '.',
                 tags$br(),
                 #checkboxInput('input_draw_point', 'Draw point', FALSE ),
                 verbatimTextOutput('summary'))
    
      #   selectInput("color", "Color", vars),
      #   selectInput("size", "Size", vars, selected = "adultpop"),
      #   conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
      #     # Only prompt for threshold when coloring or sizing by superzip
      #     numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
      #   ),
      # 
      #   plotOutput("histCentile", height = 200),
      #   plotOutput("scatterCollegeIncome", height = 250)
      #),
      # 
      # tags$div(id="cite",
      #   'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
      )
    )
  ),

  # tabPanel("Data explorer",
  #   fluidRow(
  #     column(3,
  #       selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
  #     ),
  #     column(3,
  #       conditionalPanel("input.states",
  #         selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
  #       )
  #     ),
  #     column(3,
  #       conditionalPanel("input.states",
  #         selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
  #       )
  #     )
  #   ),
  #   fluidRow(
  #     column(1,
  #       numericInput("minScore", "Min score", min=0, max=100, value=0)
  #     ),
  #     column(1,
  #       numericInput("maxScore", "Max score", min=0, max=100, value=100)
  #     )
  #   ),
  #   hr(),
  #   DT::dataTableOutput("ziptable")
  # ),

  conditionalPanel("false", icon("crosshair"))
)


##### shRlog #####

###security hub in R using graylog###
### shiny server ###
# inspired by http://shiny.rstudio.com/gallery/movie-explorer.html #
# last changes: 06.07.2018


library(ggvis)

tags$style(".recalculating { opacity: inherit !important; }")

# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

fluidPage(
  titlePanel("Graylog - Analysis"),
  fluidRow(
    column(3,
           wellPanel(
             selectInput("xvar", "X-axis variable", axis_vars, selected = "Org"),
             selectInput("yvar", "Y-axis variable", axis_vars, selected = "Connect")
           ),
           wellPanel(
             h4("Filter"),
             sliderInput("connect", "Minimum and Maximum of Connections",
                         1, 1000, 1, value = c(1, 1000)),
             sliderInput("day", "Day of connection",1, 31, value = c(1, 31)),
             sliderInput("hour", "Hour of connection",00,23,value = c(00,23)),
             textInput("srcip", "Select internal IP-Adresse, z.B. 192.168.200.10"),
             textInput("org", "Select organisation or external IP-adresse, z.B. Microsoft Hosting")
           )
           
    ),
    column(9,
           ggvisOutput("plot1"),
           wellPanel(
             span("Number of connections selected:",
                  textOutput("n_moves")
             )
           )
    )
  )
)
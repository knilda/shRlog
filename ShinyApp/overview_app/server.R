
##### shRlog #####

###security hub in R using graylog###
### shiny server ###
# inspired by http://shiny.rstudio.com/gallery/movie-explorer.html #
# last changes: 06.07.2018

library(ggvis)
library(dplyr)
library(shiny)


# set working directory of your data (can be any place, but must be the same as in file data.R)

setwd("C:/tmp")  

visits <- read.csv2("Visits_Hour.csv", stringsAsFactors = FALSE)


# Define server logic required to draw a graph
# define variables that can be put on the x and y axes


function(input, output, session) {
  
  
  
  moves <- reactive({
    
    sourceip <- input$srcip
    orga <- input$org
    minday <- input$day[1]
    maxday <- input$day[2]
    minhour <- input$hour[1]
    maxhour <- input$hour[2]
    minconnect <- input$connect[1]
    maxconnect <- input$connect[2]
    
    
    
    # Apply Filter
    v <- visits %>% 
      filter(
        Day >= minday,
        Day <= maxday,
        Hour >= minhour, 
        Hour <= maxhour, 
        Connect >= minconnect,
        Connect <= maxconnect
      )
    
    
    
    # Optional: filter by srcip
    if (!is.null(input$srcip) && input$srcip != "") {
      srcip <- paste0(input$srcip)
      v <- v %>% dplyr::filter(Srcip == srcip)
    }
    
    # Optional: filter by org
    if (!is.null(input$org) && input$org != "") {
      orgi <- paste0(input$org)
      v <- v %>% dplyr::filter(Org == orgi)
    }
    v <- as.data.frame(v)      
  })
  
  
  # Function for generation tooltip text
  
  visits_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)
    
    # Pick out the visit with this ID
    visits <- isolate(moves())
    visit <- visits[visits$ID == x$ID, ]
    
    paste0("<b>", visit$Org, "</b><br>", visit$Srcip,"<br>",
           visit$Date, "<br>", "h:", visit$Hour
    )
  }
  
  # a reactive expression with the ggvis plot
  vis <- reactive({
    #Labels for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    
    xvar <- ggvis::prop("x", as.symbol(input$xvar))
    yvar <- ggvis::prop("y", as.symbol(input$yvar))
    
    
    moves %>%
      ggvis(x = xvar, y = yvar) %>% 
      layer_points(size := 50, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5,
                   stroke = ~Org, key := ~ID) %>%
      add_tooltip(visits_tooltip, "hover") %>%
      add_axis("x", title = "", properties = axis_props(
        labels = list(angle = 45, align = "left",fontSize = 12))) %>%
      add_axis("y", title = "") %>%
      set_options(width = 500, height = 500) %>%
      hide_legend("stroke")
  })
  
  vis %>% bind_shiny("plot1")
  
  output$n_moves <- renderText({ nrow(moves()) })
}
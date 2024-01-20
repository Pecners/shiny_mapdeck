library(shiny)
library(leaflet)
library(sf)
library(mapdeck)
library(shinycssloaders)


d <- readRDS("data.rda")
st_dd <- st_transform(d$st_d, crs = 4326)
texture <- d$texture
set_token(d$mt)



# swatchplot(texture)


ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Marhey&display=swap');
          h1 {
            margin-bottom: 30px;
          }
          body {
            font-family: 'Marhey';
            background: #f0f0f0;
          }
                    ")
    )
  ),
  
  # App title ----
  titlePanel(h1("Texas Population Density", align = "center"),
             windowTitle = "Texas Population Density"),
  fluidRow(
    column(width = 6, offset = 0, 
           withSpinner(mapdeckOutput("map"), type = 1,  
                       color = "#CB4335")),
    column(width = 6, offset = 0, leafletOutput(
      outputId = "observed_click"
    ))
  ))

server <- function(input, output) {
  output$map <- renderMapdeck({
    mapdeck(style = mapdeck_style("dark"), 
            zoom = 4.5, # https://docs.mapbox.com/help/glossary/zoom-level/
            bearing = 10,
            min_pitch = 10,
            pitch = 45) %>%
      add_polygon(
        data = st_dd,
        elevation = "population",
        auto_highlight = TRUE, 
        tooltip = "population", 
        elevation_scale = 5,
        layer_id = "h3", 
        fill_colour = "population", 
        fill_opacity = .25,
        stroke_opacity = .25,
        palette = texture
      )
  })
  
  observeEvent(input$map_polygon_click, {
    
    event <- input$map_polygon_click
    e <- jsonlite::fromJSON(event)
    all <- as.numeric(e[[3]][[3]][[1]][[2]])
    this_sf <- data.frame(lat = all[1:7],
                      long = all[8:14]) |> 
      sf::st_as_sf(coords = c("lat", "long")) |> 
      dplyr::summarise(do_union = FALSE) |> 
      st_cast("POLYGON")
    
    output$observed_click <- renderLeaflet({
      leaflet() |> 
        addTiles() |> 
        addPolygons(data = this_sf)
    })
  })
}

shinyApp(ui, server)

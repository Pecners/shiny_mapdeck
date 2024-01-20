library(sf)
library(tigris)
library(tidyverse)
library(NatParksPalettes)
library(colorspace)

map <- "texas"

# Kontur data source: https://data.humdata.org/organization/kontur
d_layers <- st_layers("../rayshader_portraits/data/kontur/kontur_population_US_20220630.gpkg")
d_crs <- d_layers[["crs"]][[1]][[2]]

s <- states() |> 
  st_transform(crs = d_crs)

st <- s |> 
  filter(NAME == str_to_title(str_replace_all(map, "_", " ")))

wkt_st <- st_as_text(st[[1,"geometry"]])

data <- st_read("../rayshader_portraits/data/kontur/kontur_population_US_20220630.gpkg",
                wkt_filter = wkt_st)


st_d <- st_join(data, st, left = FALSE)


# Color palette

c1 <- natparks.pals("Acadia", n = 10)
c2 <- natparks.pals("Redwood", n = 10)

colors <- c(lighten(c2[1], .75),
            lighten(c2[1], .5),
            lighten(c2[1], .25), 
            c2[1], c1[10:6])

# swatchplot(colors)

texture <- grDevices::colorRamp(c(alpha(colors[9], .5), alpha(colors[5], .5)),
                                  bias = .5, alpha = TRUE)((1:256)/256)

# mapbox token 

mt <- "pk.eyJ1IjoibXJwZWNuZXJzIiwiYSI6ImNsZjF0bHdvNTBidnkzeWxoYnB4bzU5cDAifQ.bfPhvoBQ-IFSM_l9px9eFg"

d <- list(st_d = st_d,
     texture = texture,
     mt = mt)

saveRDS(d, "data.rda")

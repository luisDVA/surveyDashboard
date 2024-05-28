library(echarts4r)
library(echarts4r.maps)
library(dplyr)
library(rnaturalearth)
library(sf)
library(ggplot2)
library(smoothr)
library(tidyr)
library(geojsonio)
library(stringr)
library(viridis)
library(readr)

chilesf <- ne_states(country="Chile",returnclass = "sf") %>% 
  select(name)

regsSimp <- 
chilesf %>% smoothr::drop_crumbs(units::set_units(3500, km^2)) %>%
  smooth(method = "chaikin") %>% 
  smooth(method = "spline") 

regsSimp <- regsSimp %>% rename(region=name)

cons <- read.csv("data/consumptionRegion.csv",
                 sep=",", na.strings=c("", "NA"))


consW <- cons %>% select(region,Mean,Category) %>%  pivot_wider(names_from = Category,values_from = Mean)

consW <- 
consW %>% mutate(region= str_replace(region,"Bio Bio","Bío-Bío")) %>% 
          mutate(region= str_replace(region,"R. Metropolitana","Región Metropolitana de Santiago"))

consDF <- left_join(st_drop_geometry(regsSimp),consW)

chCons_json <- geojsonio::geojson_list(regsSimp)

write_csv(consDF,"data/consRegs.csv")
geojson_write(chCons_json,file = "data/chgeojson.json")
consW

# plot 
consDF |>
  e_charts(region) |>
  e_map_register("Chcons", chCons_json) |>
  e_map(fish, map = "Chcons", nameProperty="region",name = "Consumo mensual") |>
  e_visual_map(fish,color=viridis(9,option="F")) |>
  e_tooltip()

# plot 
consDF |>
  e_charts(region) |>
  e_map_register("Chcons", chCons_json) |>
  e_map(seafood, map = "Chcons", nameProperty="region") |>
  e_visual_map(seafood)

e_charts() %>% 
  em_map("Chile") %>% 
  e_map(map = "Chile") %>% 
  e_visual_map(fish)


chilesf

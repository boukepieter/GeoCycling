library(dplyr)
library(sf)
library(leaflet)

# allzips <- readRDS("data/superzip.rds")
# allzips$latitude <- jitter(allzips$latitude)
# allzips$longitude <- jitter(allzips$longitude)
# allzips$college <- allzips$college * 100
# allzips$zipcode <- formatC(allzips$zipcode, width=5, format="d", flag="0")
# row.names(allzips) <- allzips$zipcode
# 
# cleantable <- allzips %>%
#   select(
#     City = city.x,
#     State = state.x,
#     Zipcode = zipcode,
#     Rank = rank,
#     Score = centile,
#     Superzip = superzip,
#     Population = adultpop,
#     College = college,
#     Income = income,
#     Lat = latitude,
#     Long = longitude
#   )

#setwd(dirname(rstudioapi::getSourceEditorContext()$path))
plaatsen <- read.csv("data/plaatsen_nederland.csv", encoding = "UTF-8") %>% 
  filter(!is.na(Latitude)) %>% 
  mutate(label = Woonplaatsen)

gemeentes <- st_read("data/gemeentes_utrecht.gpkg")

routes <- st_read("data/plaatsenFietstochtGeodata.gpkg", layer = "gefietst_bunnik_wijkbijduurstede") %>% 
  st_zm(drop = T, what = "ZM")

pics <- st_read("data/geopics.gpkg") %>% 
  mutate(relpath = paste0("", substring(gsub(" ", "", RelPath), 7))) %>% 
  mutate(alt = strsplit(Name, "\\.")[[1]][1]) %>% mutate(icon = "pic")

icons <- iconList(
  pic = makeIcon("icon_photo_50px_red.png", "icon_photo_50px.png", 20, 20),
  pic2 = makeIcon("icon_photo_50px.png", "icon_photo_50px.png", 24, 24)
)

if (F){
  leaflet() %>%
    addTiles("https://tiles.wmflabs.org/osm-no-labels/{z}/{x}/{y}.png") %>%
    setView(lng = 5.12, lat = 52.09, zoom = 10) %>% 
    addPolygons(data = gemeentes, fillOpacity = 0, color = "black", weight = 2,
                group = "Municipality borders", options = pathOptions(clickable = F)) %>% 
    addLabelOnlyMarkers(data = plaatsen, lng = ~Longitude, lat = ~Latitude, 
                        label = ~label,
                        labelOptions = labelOptions(noHide = T, opacity = 0.60, textsize = "10px", direction = "center",
                                                    style = list("padding" = "0px")),
                        group = "Places Utrecht") %>% 
    addMarkers(data = pics, lng = ~Lon, lat = ~Lat, popup = paste0("<img src = ", pics$relpath, " width='400'>"),
               group = "Photo's of place name signs", options = markerOptions(alt = pics$alt),
               popupOptions = popupOptions(minWidth = 420), icon = icons[pics$icon]) %>% 
    addPolylines(data = routes, group = "Bicycle routes") %>% 
    addLayersControl(position = "bottomleft", overlayGroups = c("Photo's of place name signs", "Bicycle routes",
                                                                "Places Utrecht",
                                                             "Municipality borders"))
}
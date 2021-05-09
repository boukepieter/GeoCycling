library(dplyr)
library(sf)
library(leaflet)
library(RPostgreSQL)
library(hexView)
source("secrets.R")
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

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user = "postgres", password = password, host = host,
                 port = "5432", dbname = "geocycle")
# res <- dbGetQuery(con, "SELECT imgname, encode(img, 'base64') AS image from geocycle.images;")
# dir.create("images")
# for (i in 1:length(res$image)){
#   imageData <- res$image[i]
#   imageDataDecoded <- jsonlite::base64_dec(imageData)
#   loc <- sprintf("www/images/%s.jpg", res$imgname[i])
#   print(loc)
#   writeBin(imageDataDecoded, loc)
# }

res <- dbGetQuery(con, "SELECT * from geocycle.imagelocations;")
pics <- st_as_sf(res, coords = c("longitude", "latitude"), crs = 4326) %>% mutate(icon = "pic") %>% 
  mutate(relpath = sprintf("https://raw.githubusercontent.com/boukepieter/GeoCycling-images/main/%s.jpg", name))

#setwd(dirname(rstudioapi::getSourceEditorContext()$path))
plaatsen <- read.csv("data/plaatsen_nederland.csv", encoding = "UTF-8") %>% 
  filter(!is.na(Latitude)) %>% 
  mutate(label = Woonplaatsen)

gemeentes <- st_read("data/gemeentes_utrecht.gpkg")

routes <- st_read("data/plaatsenFietstochtGeodata.gpkg", layer = "gefietst_bunnik_wijkbijduurstede") %>% 
  st_zm(drop = T, what = "ZM")

# pics <- st_read("data/geopics.gpkg") %>% 
#   mutate(relpath = paste0("", substring(gsub(" ", "", RelPath), 7))) %>% 
#   mutate(alt = strsplit(Name, "\\.")[[1]][1]) %>% mutate(icon = "pic")

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
    addMarkers(data = pics, popup = paste0("<img src = ", pics$relpath, " width='400'>"),
               group = "Photo's of place name signs", 
               popupOptions = popupOptions(minWidth = 420), icon = icons[pics$icon]) %>% 
    addPolylines(data = routes, group = "Bicycle routes") %>% 
    addLayersControl(position = "bottomleft", overlayGroups = c("Photo's of place name signs", "Bicycle routes",
                                                                "Places Utrecht",
                                                             "Municipality borders"))
}
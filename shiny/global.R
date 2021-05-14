library(dplyr)
library(sf)
library(leaflet)
library(rpostgis)
library(hexView)

#setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("secrets.R")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user = "postgres", password = password, host = host,
                 port = "5432", dbname = "geocycle")

res <- dbGetQuery(con, "SELECT * from geocycle.imagelocations;")
pics <- st_as_sf(res, coords = c("longitude", "latitude"), crs = 4326) %>% mutate(icon = "pic") %>% 
  mutate(relpath = sprintf("https://raw.githubusercontent.com/boukepieter/GeoCycling/main/data/processed/images/small/%s.jpg", name),
         bigpath = sprintf("https://raw.githubusercontent.com/boukepieter/GeoCycling/main/data/processed/images/%s.jpg", name))

plaatsen <- read.csv("data/plaatsen_nederland.csv", encoding = "UTF-8") %>% 
  filter(!is.na(Latitude)) %>% 
  mutate(label = Woonplaatsen)

query <- paste0("SELECT wpg.id, wpg.geom, wpg.gemnaam, wpg.naam, prov.statnaam ", 
                "FROM geocycle.woonplaatsgrenzen AS wpg ",
                "LEFT JOIN geocycle.provincies AS prov ",
                "ON st_within(st_pointonsurface(wpg.geom), prov.geom) ",
                "WHERE prov.statnaam = 'Utrecht';")
woonplaatsgrenzen <- pgGetGeom(con, query = query)
woonplaatsgrenzen <- st_as_sf(woonplaatsgrenzen)

gemeentes <- st_read("data/gemeentes_utrecht.gpkg")

query <- "SELECT gid, geom FROM geocycle.routes;" 
routes <- pgGetGeom(con, name = c("geocycle","routes"), gid = "gid")
routes <- st_as_sf(routes)
# routes <- st_read("data/plaatsenFietstochtGeodata.gpkg", layer = "gefietst_bunnik_wijkbijduurstede") %>% 
#   st_zm(drop = T, what = "ZM")

icons <- iconList(
  pic = makeIcon("icon_photo_50px_red.png", "icon_photo_50px.png", 20, 20),
  pic2 = makeIcon("icon_photo_50px.png", "icon_photo_50px.png", 24, 24)
)

if (F){
  leaflet() %>%
    addTiles("https://tiles.wmflabs.org/osm-no-labels/{z}/{x}/{y}.png") %>%
    setView(lng = 5.12, lat = 52.09, zoom = 10) %>% 
    addPolygons(data = gemeentes, fillOpacity = 0, color = "black", weight = 2,
                group = "Gemeentegrenzen", options = pathOptions(clickable = F)) %>% 
    addPolygons(data = woonplaatsgrenzen, fillOpacity = 0, color = "black", weight = 1,
                group = "Woonplaatsgrenzen", options = pathOptions(clickable = F)) %>% 
    addLabelOnlyMarkers(data = plaatsen, lng = ~Longitude, lat = ~Latitude, 
                        label = ~label,
                        labelOptions = labelOptions(noHide = T, opacity = 0.60, textsize = "10px", direction = "center",
                                                    style = list("padding" = "0px")),
                        group = "Plaatsen Utrecht") %>% 
    addMarkers(data = pics, popup = sprintf("<a href='%s' target='_blank' rel='noopener noreferrer'><img src = '%s' width='400'></a>", pics$bigpath, pics$relpath),
               group = "Foto's plaatsnaamborden", 
               popupOptions = popupOptions(minWidth = 420), icon = icons[pics$icon]) %>% 
    addPolylines(data = routes, group = "Fietsroutes") %>% 
    addLayersControl(position = "bottomleft", overlayGroups = c("Plaatsen Utrecht", "Foto's plaatsnaamborden", 
                                                                "Gemeentegrenzen", "Woonplaatsgrenzen",
                                                                "Fietsroutes"))
}

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
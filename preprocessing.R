library(dplyr)
library(magick)
library(exifr)
library(rgdal)
library(rpostgis)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("shiny/secrets.R")
dir <- "data/input"
dir_out <- "data/processed"
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user = "postgres", password = password, host = host,
                 port = "5432", dbname = "geocycle")

test <- function(con) {
  out <- tryCatch({
    res <- postgresqlExecStatement(con, "SELECT COUNT(*) from geocycle.routes;")
    postgresqlFetch(res)
  }, error = function(e) {
    #message(e)
    return(0)
  })
  return(out)
}


### Processing routes
files <- list.files(dir, pattern = ".gpx")
for (file in files) {
  count <- test(con)
  route <- readOGR(paste(dir, file, sep = "/"), layer = "tracks")
  route$gid = count + 1
  pgInsert(con, c("geocycle","routes"), route)
  file.copy(paste(dir, file, sep = "/"), sprintf("%s/routes/%s", dir_out, file))
  file.remove(paste(dir, file, sep = "/"))
}


### Processing images
files <- list.files(dir, pattern = ".jpg")

# dbSendQuery(con, "DROP TABLE geocycle.imageLocations; ")
# dbSendQuery(con, "CREATE TABLE geocycle.imageLocations (name text, latitude real, longitude real);")
# dbCommit(con)

for (file in files){
  print(strsplit(file, "\\.")[[1]][1])
  img <- image_read(paste(dir, file, sep = "/"))
  resized <- image_scale(img,"10%")
  image_write(resized, sprintf("%s/images/small/%s", dir_out, file))
  image_write(img, sprintf("%s/images/%s", dir_out, file))
  exifinfo <- read_exif(paste(dir, file, sep = "/"))
  dbSendQuery(con, "INSERT INTO geocycle.imageLocations (name, latitude, longitude) VALUES ($1, $2, $3)",
              list(strsplit(file, "\\.")[[1]][1], exifinfo$GPSLatitude, exifinfo$GPSLongitude))
  dbCommit(con)
  file.remove(paste(dir, file, sep = "/"))
}

### Upload images to DB

dir2 <- paste(dir, "small", sep = "/")
files <- list.files(dir2)

library(hexView)
for (file in files){
  name <- strsplit(file, "\\.")[[1]][1]
  full_file <- paste(dir2, file, sep = "/")
  my_file <- readRaw(full_file)$fileRaw
  res <-
    dbExecute(
      con,
      "INSERT INTO geocycle.images (imgname, img) VALUES ($1, $2)",
      list(name, paste0("\\x", paste(my_file, collapse = "")))
    )
}

# # Test read
# res <- dbGetQuery(con, "SELECT encode(img, 'base64') AS image from geocycle.images;")
# imageData <- res$image
# imageDataDecoded <- jsonlite::base64_dec(imageData)
# identical(imageDataDecoded, my_file)
# writeBin(imageDataDecoded, "test.jpg")

## adding other data to the database
woonplaatsgrenzen <- readOGR("data/background_data/BAG-Woonplaatsgrenzen.shp", "BAG-Woonplaatsgrenzen")
pgInsert(con, c("geocycle","woonplaatsgrenzen"), woonplaatsgrenzen)

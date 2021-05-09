### Resizing images
library(magick)
library(exifr)
source("shiny/secrets.R")
dir <- "data/input"
files <- list.files(dir, pattern = ".jpg")
dir_out <- "data/processed/images"

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user = "postgres", password = password, host = host,
                 port = "5432", dbname = "geocycle")
# dbSendQuery(con, "DROP TABLE geocycle.imageLocations; ")
# dbSendQuery(con, "CREATE TABLE geocycle.imageLocations (name text, latitude real, longitude real);")
# dbCommit(con)

for (file in files){
  print(strsplit(file, "\\.")[[1]][1])
  img <- image_read(paste(dir, file, sep = "/"))
  resized <- image_scale(img,"10%")
  image_write(resized, sprintf("%s/small/%s", dir_out, file))
  image_write(img, sprintf("%s/%s", dir_out, file))
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

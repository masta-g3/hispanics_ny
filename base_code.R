library(tigris)
library(leaflet)
library(dplyr)

options(tigris_year = 2015)

pops <- tbl_df(read.csv('ACS_15_5YR_B03001/ACS_15_5YR_B03001.csv', stringsAsFactors = F))
names <- colnames(pops)

## Remove error columns.
filter_names <- grep('HD02', names, value=TRUE, invert=TRUE)
filter_pops <- pops[filter_names]
name_map <- t(filter_pops[1,])
filter_pops <- filter_pops[2:nrow(filter_pops), ]

## Convert to numeric (except geo-name).
names_numeric <- grep('HD01', names, value=TRUE)
filter_pops[names_numeric] <- sapply(filter_pops[names_numeric], as.numeric)

## Create shapefile.
ny <- tracts(state = 'NY')

## Join both sources.
ny_merged <- geo_join(ny, filter_pops, 'GEOID', 'GEO.id2')

## Color palette.
pal <- colorQuantile("Greens", NULL, n = 10)

popup <- paste0("Puerto Ricans on ", as.character(ny_merged$GEO.display.label), ": ", as.character(ny_merged$HD01_VD05))

## Map!
leaflet() %>%
  addProviderTiles("Stamen.Toner") %>%
  addPolygons(data = ny_merged, 
              fillColor = ~pal(ny_merged$HD01_VD05), 
              color = 'black',
              fillOpacity = 0.5, 
              weight = 0.1, 
              smoothFactor = 0.2, 
              popup = popup) %>%
  addLegend(pal = pal, 
            values = ny_merged$HD01_VD05, 
            position = "bottomright", 
            title = "Puerto Ricans")
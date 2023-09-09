library(magrittr)
library(RSQLite)
library(DBI)
library(stringr)

# prepare the ZIP code table for US districts
temp <- tempfile()
"http://download.geonames.org/export/zip/US.zip" %>% download.file(., temp)
zipCodeTable <- temp %>%
  unz(., "US.txt") %>%
  read.table(., sep="\t")
unlink(temp)
names(zipCodeTable) = c("CountryCode", "zip", "PlaceName", "AdminName1", "AdminCode1", "AdminName2", "AdminCode2", "AdminName3", "AdminCode3", "latitude", "longitude", "accuracy")

# select delta, filter zip code, and add the "county" column
texasDeltaMeta <- "../raw_data/Texas_cumulative.csv" %>%
  read.table(., sep=",", header=TRUE) %>%
  dplyr::filter(clade_Nextclade_clade=="21A (Delta)") #select delta
zipAndCounty <- texasDeltaMeta %>%
  dplyr::count(., zip, sort = TRUE) %>%
  merge(., zipCodeTable) %>%
  dplyr::select(zip, n, AdminName1, AdminName2)
zipAndCounty <- zipAndCounty[zipAndCounty$AdminName1=="Texas",] %>%
  dplyr::select(zip, AdminName2) #only select Texas
texasDeltaMeta <- merge(texasDeltaMeta, zipAndCounty)
rm(zipAndCounty, zipCodeTable, temp)

# recheck with the GISAID database, make sure sequences are available
conn <- dbConnect(RSQLite::SQLite(), "../data/00_meta.db")
texasDeltaMeta %>% dplyr::select(GISAID_name) %>% dbWriteTable(conn, "texasDeltaMeta_GISAID_name", ., overwrite=TRUE) #dbListTables(conn)
texasDeltaMetaClean <- "SELECT * FROM GISAID_meta WHERE Virus_name in (SELECT GISAID_name FROM texasDeltaMeta_GISAID_name) AND Variant LIKE '%Delta%' AND Is_high_coverage_ Like '%True%' AND Is_complete_ Like '%True%'" %>%
  dbGetQuery(conn, .) #vendorDeltaMeta[vendorDeltaMeta$GISAID_name %in% texasSeqMeta$Virus_name, ]

texasDeltaMetaClean <- texasDeltaMeta %>% 
  dplyr::select(GISAID_name, AdminName2) %>% 
  merge(texasDeltaMetaClean, ., by.x = 'Virus_name', by.y ='GISAID_name')
colnames(texasDeltaMetaClean)[length(colnames(texasDeltaMetaClean))] <- "County"

countyAndMetro <- "../raw_data/MetroAreasInTexas.txt" %>%
  read.table(., sep="\t", header=T) %>%
  dplyr::select(County.name, Metro.area)
texasDeltaMetaClean <- merge(texasDeltaMetaClean, countyAndMetro, by.x = 'County', by.y ='County.name') 

save(texasDeltaMetaClean, file = "../data/01_texasDeltaMetaClean.RData")

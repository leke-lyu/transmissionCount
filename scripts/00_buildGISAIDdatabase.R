library(RSQLite)
library(DBI)

GISAID_meta <- read.table("../raw_data/GISAID_2023_01_12/metadata.tsv",
                         sep="\t",
                         header=T,
                         fill = T,
                         quote = "",
                         row.names = NULL,
                         stringsAsFactors = FALSE)
names(GISAID_meta) <- gsub("\\.", "_", names(GISAID_meta)) #change name tags
conn <- dbConnect(RSQLite::SQLite(), "../data/00_meta.db")
dbWriteTable(conn, "GISAID_meta", GISAID_meta)
rm(GISAID_meta)

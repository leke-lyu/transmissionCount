## sample the Texas genome dataset
#devtools::install_github("leke-lyu/subsamplerr")
library(subsamplerr)
library(magrittr)
library(aweek)
library(lubridate)
library(dplyr)
library(ggplot2)
library(ggpubr)
texasSeq <- texasSeqMeta %>% metaTableToMatrix(., "location", "date") %>% exactDateToEpiweek(.)
texasCase %<>% exactDateToEpiweek(.)
p1 <- plotSequencingPercentage(texasSeq, texasCase)
p1 <- p1 + guides(color=guide_legend(nrow=2, byrow=TRUE)) + rremove("xlab") + rremove("ylab")
texasSample <- expectedSampleMatrix(0.006, texasSeq, texasCase)
id <- proportionalSampling(texasSample, texasSeqMeta)
id %>% write.table(., "../data/03_texasSeq.list", sep = ",", append=FALSE, col.names = F, row.names = F, quote = F)
p2 <- plotSequencingPercentage(texasSample, texasCase)
p2 <- p2 + guides(color=guide_legend(nrow=2, byrow=TRUE)) + rremove("xlab") + rremove("ylab")
p3 <- ggarrange(p1, p2, ncol = 1, nrow = 2, align = "v", common.legend = TRUE)
ggsave("../results/03_texasSamplingScheme.pdf", width = 18, height = 10, units = "in")

## sample the context genome dataset
library(magrittr)
library(RSQLite)
library(DBI)
library(dplyr)
library(lubridate)
library(aweek)
# worldwide delta dataset
load("../data/01_texasDeltaMetaClean.RData")
max(texasDeltaMetaClean$Collection_date)
conn <- dbConnect(RSQLite::SQLite(), "../data/00_meta.db")
dbListTables(conn)
allDelta <- dbGetQuery(conn, 
                       "SELECT Accession_ID, Location, Collection_date
                       FROM GISAID_meta
                       WHERE Location LIKE '% / % / %' AND
                        Variant LIKE '%Delta%' AND
                        Host LIKE '%Human%' AND
                        Is_high_coverage_ Like '%True%' AND
                        Collection_date GLOB '20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]' AND 
                        Collection_date < '2021-10-25'")
continents <- vapply(strsplit(allDelta[,2],"[/]"), `[`, 1, FUN.VALUE=character(1)) %>% trimws()
counties <- vapply(strsplit(allDelta[,2],"[/]"), `[`, 2, FUN.VALUE=character(1)) %>% trimws()
allDelta$newLocation = paste0(continents, "_", counties)
allDelta$Collection_date %<>% as.Date()
allDelta$Epiweek <- paste0(epiyear(allDelta$Collection_date), sprintf("%02d", epiweek(allDelta$Collection_date)))
# sample the context dataset
strat_samp <- allDelta %>% group_by(newLocation, Epiweek) %>% sample_frac(size = .0035)
strat_samp_clean <- strat_samp[!grepl(" Texas",strat_samp$Location),]
strat_samp_clean$newLocation %>% table() %>% sort(., decreasing = T)
strat_samp_clean %>% .$Accession_ID %>% write.table(., "../data/03_contextSeq.list", sep = ",", append=FALSE, col.names = F, row.names = F, quote = F)
save(strat_samp_clean, file = "../data/03_contextDeltaMetaClean.RData")
load("../data/03_contextDeltaMetaClean.RData")

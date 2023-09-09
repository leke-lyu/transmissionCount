library(magrittr)

load("../data/01_texasDeltaMetaClean.RData")
texasSeqMeta <- texasDeltaMetaClean %>% dplyr::select(Accession_ID, Collection_date, Metro.area)
colnames(texasSeqMeta) <- c("gisaid_epi_isl", "date", "location")
save(texasSeqMeta, file = "../data/02_texasSeqMeta.rda")

countyAndMetro <- "../raw_data/MetroAreasInTexas.txt" %>%
  read.table(., sep="\t", header=T) %>%
  dplyr::select(County.name, Metro.area)
texasCaseTB <- "../raw_data/TexasCOVID-19NewConfirmedCasesbyCounty_2021.csv" %>%
  read.table(., sep = ",", header = F, fill = T, quote = "", row.names = NULL, stringsAsFactors = FALSE)
date <- texasCaseTB[1, 2:(ncol(texasCaseTB)-2)] %>% as.character() %>% as.Date(., "%m/%d/%Y") %>% as.character()
metro <- vector()
for(i in 2:nrow(texasCaseTB)){
  metro[i-1] <- countyAndMetro[countyAndMetro$County.name == texasCaseTB[i, 1], "Metro.area"]
}
texasCase <- texasCaseTB[2:nrow(texasCaseTB), 2:(ncol(texasCaseTB)-2)] %>% as.matrix()
texasCase <- matrix(as.numeric(texasCase), nrow(texasCaseTB)-1, ncol(texasCaseTB)-3)
rownames(texasCase) <- metro
colnames(texasCase) <- date
texasCase <- rowsum(texasCase, row.names(texasCase))
save(texasCase, file = "../data/02_texasCase.rda")


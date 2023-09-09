options(warn=-1)
args = commandArgs(trailingOnly=TRUE)
library(magrittr)

load("/scratch/ll22780/04_buildTree/01_texasDeltaMetaClean.RData")
nextstrainMeta <- paste0(args[1], "/", args[3], ".metadata.tsv") %>%
	read.table(., sep = "\t", header = T, fill = T, quote = "", row.names = NULL, stringsAsFactors = FALSE)
nextstrainMeta[!is.na(nextstrainMeta$sex) & nextstrainMeta$sex!="Male" & nextstrainMeta$sex!="Female", "sex"] <- "Unknown"
for(i in 1:nrow(nextstrainMeta)){
	id <- nextstrainMeta[i, "gisaid_epi_isl"]
	nextstrainMeta[i, "division"] <- "Texas"
	nextstrainMeta[i, "division_exposure"] <- "Texas"
	nextstrainMeta[i, "location"] <- texasDeltaMetaClean[texasDeltaMetaClean$Accession_ID==id, "Metro.area"]
}
write.table(nextstrainMeta, paste0(args[2], "/", args[3], ".metadata.tsv"), sep="\t", row.names = F, col.names = T, quote=F, fileEncoding = "UTF-8")


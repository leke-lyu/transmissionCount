options(warn=-1)
args = commandArgs(trailingOnly=TRUE)
library(magrittr)

nextstrainMeta <- paste0(args[1], "/", args[3], ".metadata.tsv") %>%
	read.table(., sep = "\t", header = T, fill = T, quote = "", row.names = NULL, stringsAsFactors = FALSE)
nextstrainMeta[!is.na(nextstrainMeta$sex) & nextstrainMeta$sex!="Male" & nextstrainMeta$sex!="Female", "sex"] <- "Unknown"
for(i in 1:nrow(nextstrainMeta)){
	nextstrainMeta[i, "division"] <- "context"
	nextstrainMeta[i, "division_exposure"] <- "context"
	nextstrainMeta[i, "location"] <- "context"
}
write.table(nextstrainMeta, paste0(args[2], "/", args[3], ".metadata.tsv"), sep="\t", row.names = F, col.names = T, quote=F, fileEncoding = "UTF-8")

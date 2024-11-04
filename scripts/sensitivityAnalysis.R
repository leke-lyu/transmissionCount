source("scripts/transmissionCount.R")
library(magrittr)

# Initialize a list to store the results of each vector
list_SSS <- list()
list_LIS <- list()

# Define the file path and the number of files
file_path <- "data/"
file_prefix <- "texas_"
file_suffix <- ".nexus"

# Loop through the files (texas_0.nexus to texas_9.nexus)
for (i in 0:9) {
  file_name <- paste0(file_path, file_prefix, i, file_suffix)
  migrationTable <- treeToTable(file_name, "location", 15)
  locations <- migrationTable$To %>% unique() %>% sort()
  locations <- locations[!is.na(locations)]
  locations <- locations[locations!="context"]
  v_SSS <- accumulatedIndicator(migrationTable, locations, "SSS")
  list_SSS[[paste0("SSS_", i)]] <- v_SSS
  v_LIS <- accumulatedIndicator(migrationTable, locations, "LIS")
  list_LIS[[paste0("LIS_", i)]] <- v_LIS
}
N <- list_SSS[["SSS_0"]] %>% names()
df_SSS <- as.data.frame(do.call(rbind, lapply(list_SSS, function(vec) vec[N])))
df_LIS <- as.data.frame(do.call(rbind, lapply(list_LIS, function(vec) vec[N])))
column_means <- colMeans(df_SSS)
df_SSS <- df_SSS[, order(column_means, decreasing = TRUE)]
df_LIS <- df_LIS[, order(column_means, decreasing = TRUE)]
df_SSS$Statistic <- rownames(df_SSS)
df_LIS$Statistic <- rownames(df_LIS)

# make plot
library(reshape2)
library(ggplot2)
library(ggpubr)

coullocation <- hcl.colors(10, palette = "Sunset")
names(coullocation) <- df_SSS[,27]
SSS_long <- melt(df_SSS, id.vars = "Statistic", variable.name = "Location", value.name = "Value")
p1 <- ggplot(SSS_long, aes(x = Location, y = Value, group = Statistic)) +
  geom_point(aes(color = Statistic)) +
  geom_line(aes(color = Statistic)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = NULL, y = "Source Sink Score") +
  scale_color_manual(values = coullocation) +
  theme_minimal() +
  theme(axis.title.x = element_blank(), axis.text.x=element_blank(), legend.position = "none")

names(coullocation) <- df_LIS[,27]
LIS_long <- melt(df_LIS, id.vars = "Statistic", variable.name = "Location", value.name = "Value")
p2 <- ggplot(LIS_long, aes(x = Location, y = Value, group = Statistic)) +
  geom_point(aes(color = Statistic)) +
  geom_line(aes(color = Statistic)) +
  labs(x = NULL, y = "Local Import Score") +
  scale_color_manual(values = coullocation) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = "none")
p <- ggarrange(p1, p2, nrow = 2, ncol = 1, labels = c("A", "B"), heights = c(1, 1.5), align = "v")
ggsave("results/sensitivityAnalysis.pdf", width = 17.8, height = 15, units = "cm")

# inspect RUCC
df_SSS$RUCC1 <- rowMeans(df_SSS[, c("Dallas-Fort Worth", "Houston", "San Antonio", "Austin")], na.rm = TRUE)
df_SSS$RUCC2 <- rowMeans(df_SSS[, c("McAllen", "El Paso", "Killeen", "Corpus Christi", "Brownsville", 
                                    "Beaumont-Port Arthur", "Lubbock", "Waco", "Amarillo", 
                                    "Bryan-College Station", "Laredo")], na.rm = TRUE)
df_SSS$RUCC3 <- rowMeans(df_SSS[, c("Tyler", "Longview", "Abilene", "Midland", "Odessa", 
                                    "Wichita Falls", "Sherman", "San Angelo", "Victoria", "Texarkana")], na.rm = TRUE)
save(df_SSS, df_LIS, file = "results/list.RData")

source("scripts/transmissionCount.R")
library(magrittr)
library(ggplot2)
library(igraph)
library(mapdata)

tb <- treeToTable("data/texas_6.nexus", "location")
links <- data.frame(from = tb$From, to = tb$To, weight = 1) %>% 
  na.omit(.) %>%
  aggregate(weight ~ from + to, data = ., FUN = sum)
id <- unique(tb$To)
id <- id[!is.na(id)]
nodes <- data.frame(id)
net <- graph_from_data_frame(d = links, vertices = nodes, directed = T) %>%
  as.undirected() %>%
  simplify(., remove.multiple = FALSE, remove.loops = TRUE)
nodeList <- V(net) %>% names() 
nodeList <- nodeList[! nodeList %in% c("context", "rural")]
subnet <- induced.subgraph(graph = net, vids = nodeList)
library(qgraph)
cTB <- centrality_auto(subnet)$node.centrality %>% as.data.frame()
cTB[order(cTB$Betweenness),]


# read geo-coordinates
temp <- tempfile()
"https://raw.githubusercontent.com/leke-lyu/surveillanceInTexas/main/lat_longs.tsv" %>% download.file(., temp)
coords <- temp %>% read.table(., sep="\t", header=F)
coords <- coords[coords$V1=="location", ]
coords <- data.frame(id = coords$V2, lat = coords$V3, long = coords$V4)

# build edge df for plot
EDGE <- as.data.frame(get.edgelist(subnet))
colnames(EDGE) <- c("x", "y")
EDGE_for_plot <- EDGE %>%
  dplyr::left_join(coords, by = c('x' = 'id')) %>%
  dplyr::rename(x.long = long, x.lat = lat) %>%
  dplyr::left_join(coords, by = c('y' = 'id')) %>%
  dplyr::rename(y.long = long, y.lat = lat)
EDGE_for_plot$weight <- E(subnet)$weight


coords$RUCC <- c("RUCC 1", "RUCC 1", "RUCC 1", "RUCC 1", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 2", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3", "RUCC 3")
tx <- "state" %>% map_data() %>% subset(., region == "texas")

p1 <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group), data =  tx, color = "black", fill = "#F3E79A", linewidth = 1.0) +
  geom_curve(aes(x = x.long, y = x.lat, xend = y.long, yend = y.lat, linewidth = weight), data = EDGE_for_plot, curvature = 0.1, color = "dimgray") +
  geom_point(aes(x = long, y = lat, fill = RUCC, size = RUCC), data = coords, color = "black", shape = 21, stroke = 0) +  # Use shape = 21 for fill control
  scale_fill_manual(values = c("RUCC 1" = "#704D9E", "RUCC 2" = "#CF63A6", "RUCC 3" = "#F7A086")) +  # Define colors
  scale_size_manual(values = c("RUCC 1" = 8, "RUCC 2" = 4, "RUCC 3" = 2)) +
  scale_linewidth_continuous(range = c(0.2, 2.0)) +
  theme_bw() +
  theme(legend.position="top",
        legend.title = element_text(face="bold"),
        legend.text = element_text(face="bold"),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        plot.caption = element_text(color="black", face="bold"),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
  )

migrationTable <- treeToTable("data/texas_6.nexus", "location", 15)
locations <- migrationTable$To %>% unique() %>% sort()
locations <- locations[!is.na(locations)]
locations <- locations[locations!="context"]
df_SourceSink <- accumulatedIndicator(migrationTable, locations, "SSS")
df_SourceSink %>% sort()
df_LocalImport <- accumulatedIndicator(migrationTable, locations, "LIS")
df_LocalImport %>% sort()

RUCC <- "data/MetroAreasInTexas.txt" %>% read.table(., sep="\t", header=T) %>% dplyr::select(Metro.area, Rural.Urban.Continuum.Code) %>% dplyr::distinct()
colnames(RUCC) <- c("ma", "rucc")
RUCC$ssd <- df_SourceSink[RUCC$ma] %>% unname()
coullocation <- hcl.colors(4, palette = "Sunset")
names(coullocation) <- RUCC$rucc %>% unique() %>% sort()

p2 <- ggplot(RUCC, aes(x = rucc, y = ssd)) +
  geom_boxplot(aes(group = rucc, fill = rucc), colour = "black", outlier.shape = NA) +
  scale_fill_manual(values = coullocation, name = "Rural-Urban Continuum Code") +
  geom_point(alpha = 0.3, size = 5) +
  theme_classic() +
  theme(legend.position="none",
        legend.title = element_text(face="bold"),
        legend.text = element_text(face="bold"),
        axis.title.x = element_blank(),
        axis.text.x = element_text(face="bold"),
        axis.title.y = element_blank(),
        axis.text.y = element_text(face="bold")
  )

library(ggpubr)
p <- ggarrange(
  p1, p2, 
  nrow = 1, 
  ncol = 2, 
  labels = c("A", "B"),
  common.legend = TRUE,  # Share the legend between p1 and p2
  legend = "top"         # Place the common legend on top
)

ggsave("results/transmissionHeterogeneity.pdf", p, width = 17.8, height = 9, units = "cm")


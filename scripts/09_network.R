source("05_transmissionCount.R")
library(magrittr)
library(ggplot2)
library(igraph)
library(mapdata)

tb <- treeToTable("../data/05_texas.nexus", "location")
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
E(subnet)$width <- E(subnet)$weight

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

tx_county <- "county" %>% map_data() %>% subset(., region == "texas")
RUCC <- "../raw_data/MetroAreasInTexas.txt" %>% read.table(., sep="\t", header=T) %>% dplyr::select(County.name, Metro.area, Rural.Urban.Continuum.Code) 
RUCC[RUCC$County.name=="DeWitt", "County.name"] <- "De Witt"
RUCC[,1] <- tolower(RUCC[,1])
colnames(RUCC) <- c("subregion", "metro", "RUCC")
tx_map <- tx_county %>% dplyr::left_join(RUCC, by = "subregion")
coullocation <- hcl.colors(4, palette = "OrRd")
names(coullocation) <- tx_map$RUCC %>% unique() %>% sort()

ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group, fill = RUCC), data =  tx_map, color = "black", linewidth = 0.4) +
  scale_fill_manual(values = coullocation, name = "Rural-Urban Continuum Code") +
  geom_curve(aes(x = x.long, y = x.lat, xend = y.long, yend = y.lat, alpha = weight), data = EDGE_for_plot, curvature = 0, color = "dodgerblue4", linewidth = 3.2) +
  scale_alpha(range = c(0.18, 1)) +
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
ggsave("../results/09_network.pdf", width = 8.5, height = 8.5, units = "in")

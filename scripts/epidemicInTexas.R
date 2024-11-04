source("scripts/transmissionCount.R")
library(magrittr)
library(ggplot2)

migrationTable <- treeToTable("data/texas_6.nexus", "division", 15)
location <- "Texas"

import <- countSaptialTransmissionLinkages(migrationTable, "importation", location)
sum(import)
year <- names(import) %>% substr(., 1, 4)
week <- names(import) %>% substr(., 5, 6)
Date <- aweek::get_date(week, year)
Import <- data.frame(date = Date, num = unname(import))
Import %<>% dplyr::mutate(Transmission = "importation")

localtransmission <- countSaptialTransmissionLinkages(migrationTable, "transmission linkage", c(location, location))
sum(localtransmission)
Localtransmission <- data.frame(date = Date, num = unname(localtransmission))
Localtransmission %<>% dplyr::mutate(Transmission = "localtransmission")

export <- countSaptialTransmissionLinkages(migrationTable, "exportation", location)
sum(export)
Export <- data.frame(date = Date, num = unname(export))
Export %<>% dplyr::mutate(Transmission = "exportation")

p1 <- dplyr::bind_rows(Import, Localtransmission, Export) %>% 
  ggplot(., aes(x = date, y = num, col = Transmission)) + 
  geom_point(size = 2) + 
  geom_line(linewidth = 1.5) +
  scale_x_date(date_breaks="1 months", date_labels = "%Y-%b", limits = as.Date(c("2021-01-01", "2021-11-9"))) +
  guides(col = guide_legend("Transmission Type")) +
  theme_classic() +
  theme(axis.text.x = element_text(face="bold"),
        plot.title = element_text(color="red", face="bold.italic"),
        axis.title.x = element_text(color="blue", face="bold"),
        axis.title.y = element_text(color="#993333", face="bold"),
        legend.position="bottom"
  ) +
  labs(title = paste0("Weekly Surveillance in ", location),
       y="Transmission counts"
  ) %>% return()
ggsave("results/epidemicInTexas.pdf", p1, width = 14, height = 3.5, units = "in")

library(ggtree)
tb <- "data/texas_6.nexus" %>% treeio::read.beast(.) %>% tidytree::as_tibble(.)
From <- vector(mode = "character", length = nrow(tb))
for(i in 1:nrow(tb)){
  From[i] <- dplyr::pull(tb[tb$node == tb$parent[i], "division"])
}
To <- tb %>% dplyr::pull(., "division") %>% unname(.)
Color <- rep(NA, nrow(tb))
for(i in 1:nrow(tb)){
  if(!is.na(From[i])){
    if(From[i] == "context" & To[i] == "context"){
      Color[i] = "grey"
    }else if(From[i] == "context" & To[i] == "Texas"){
      Color[i] = "#00BA38"
    }else if(From[i] == "Texas" & To[i] == "Texas"){
      Color[i] = "#619CFF"
    }else if(From[i] == "Texas" & To[i] == "context"){
      Color[i] = "#F8766D"
    }
  }
}

tb %<>% dplyr::mutate(color = Color)
t <- tb %>%
  dplyr::select(c("parent", "node","branch.length", "label", "color")) %>%
  tidytree::as.treedata(.)
p2 <- ggtree(t, aes(color=I(color)), mrsd=(tb$num_date %>% max() %>% as.numeric() %>% lubridate::date_decimal() %>% as.Date())) + theme_tree2() 
p3 <- viewClade(p2, 12161)
ggsave("results/texasTree.pdf", p3, width = 14, height = 14, units = "in")


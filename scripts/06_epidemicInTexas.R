source("05_transmissionCount.R")
library(magrittr)
library(ggplot2)

migrationTable <- treeToTable("../data/05_texas.nexus", "country", 15)
location <- "USA"
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

dplyr::bind_rows(Import, Localtransmission, Export) %>% 
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
ggsave("../results/06_epidemicInTexas.pdf", width = 14, height = 3.5, units = "in")

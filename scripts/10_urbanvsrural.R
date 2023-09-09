source("05_transmissionCount.R")
library(magrittr)
library(ggplot2)
library(ggpubr)
printEpiTrend <- function(migrationTable, location){
  
  import <- countSaptialTransmissionLinkages(migrationTable, "importation", location)
  year <- names(import) %>% substr(., 1, 4)
  week <- names(import) %>% substr(., 5, 6)
  Date <- aweek::get_date(week, year)
  Import <- data.frame(date = Date, num = unname(import))
  Import %<>% dplyr::mutate(Transmission = "importation")
  Import %<>% dplyr::mutate(LineType = "All")
  
  importfromcontext <- countSaptialTransmissionLinkages(migrationTable, "transmission linkage", c("context", location))
  Importfromcontext <- data.frame(date = Date, num = unname(importfromcontext))
  Importfromcontext %<>% dplyr::mutate(Transmission = "importation")
  Importfromcontext %<>% dplyr::mutate(LineType = "Context")
  
  localtransmission <- countSaptialTransmissionLinkages(migrationTable, "transmission linkage", c(location, location))
  Localtransmission <- data.frame(date = Date, num = unname(localtransmission))
  Localtransmission %<>% dplyr::mutate(Transmission = "localtransmission")
  Localtransmission %<>% dplyr::mutate(LineType = "All")
  
  exporttocontext <- countSaptialTransmissionLinkages(migrationTable, "transmission linkage", c(location, "context"))
  Exporttocontext <- data.frame(date = Date, num = unname(exporttocontext))
  Exporttocontext %<>% dplyr::mutate(Transmission = "exportation")
  Exporttocontext %<>% dplyr::mutate(LineType = "Context")
  
  export <- countSaptialTransmissionLinkages(migrationTable, "exportation", location)
  Export <- data.frame(date = Date, num = unname(export))
  Export %<>% dplyr::mutate(Transmission = "exportation")
  Export %<>% dplyr::mutate(LineType = "All")
  
  dplyr::bind_rows(Import, Importfromcontext, Localtransmission, Exporttocontext, Export) %>% 
    ggplot(., aes(x = date, y = num, col = Transmission, linetype = LineType)) + 
    geom_point(size = 2) + 
    geom_line(linewidth = 1.5) +
    scale_x_date(date_breaks="2 week", date_labels = "%Y-%U", limits = as.Date(c("2021-03-01", "2021-11-01"))) +
    guides(col = guide_legend("Transmission Type"), linetype = "none") +
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
  
}
printIndicatorTrend <- function(migrationTable, location, indicator){
  
  if(indicator == "IOI"){
    import <- countSaptialTransmissionLinkages(migrationTable, "importation", location)
    localtransmission <- countSaptialTransmissionLinkages(migrationTable, "transmission linkage", c(location, location))
    year <- names(import) %>% substr(., 1, 4)
    week <- names(import) %>% substr(., 5, 6)
    Date <- aweek::get_date(week, year)
    data.frame(date = Date, num = unname((import/(import + localtransmission)))) %>% 
      ggplot(.,aes(x=date, y=num)) + 
      geom_bar(position="stack", stat="identity", fill="black", width = 2) +
      scale_x_date(date_breaks="2 week", date_labels = "%Y-%U", limits = as.Date(c("2021-03-01", "2021-11-01"))) +
      theme_classic() +
      theme(axis.text.x = element_text(face="bold"),
            plot.title = element_text(color="red", face="bold.italic"),
            axis.title.x = element_text(color="blue", face="bold"),
            axis.title.y = element_text(color="#993333", face="bold"),
            legend.position="bottom")  +  
      scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
      labs(title = "Importance of Importation") +
      geom_hline(yintercept=(sum(import)/(sum(import)+sum(localtransmission))), linetype="dotted", color = "blue", size=2)
  }else if(indicator == "SSD"){
    import <- countSaptialTransmissionLinkages(migrationTable, "importation", location)
    export <- countSaptialTransmissionLinkages(migrationTable, "exportation", location)
    year <- names(import) %>% substr(., 1, 4)
    week <- names(import) %>% substr(., 5, 6)
    Date <- aweek::get_date(week, year)
    data.frame(date = Date, num = unname(((export - import)/(export + import)))) %>% 
      ggplot(.,aes(x=date, y=num)) + 
      geom_bar(position="stack", stat="identity", fill="black", width = 2) +
      scale_x_date(date_breaks="2 week", date_labels = "%Y-%U", limits = as.Date(c("2021-03-01", "2021-11-01"))) +
      theme_classic() +
      theme(axis.text.x = element_text(face="bold"),
            plot.title = element_text(color="red", face="bold.italic"),
            axis.title.x = element_text(color="blue", face="bold"),
            axis.title.y = element_text(color="#993333", face="bold"),
            legend.position="bottom")  + 
      scale_y_continuous(labels = scales::percent, limits = c(-1, 1)) +
      labs(title = "Source-Sink Dynamics") +
      geom_hline(yintercept=0, linetype="dashed", color = "red", size=2) +
      geom_hline(yintercept=((sum(export) - sum(import))/(sum(export) + sum(import))), linetype="dotted", color = "blue", size=2)
  }else{
    stop("check the `indicator`!!!")
  }
  
}

migrationTable <- treeToTable("../data/05_texas.nexus", "location", 15)
p1 <- printEpiTrend(migrationTable, "Houston") #printEpiTrend(migrationTable, "Dallas-Fort Worth") #printEpiTrend(migrationTable, "rural")
p2 <- printIndicatorTrend(migrationTable, "Houston", "IOI") #printIndicatorTrend(migrationTable, "Dallas-Fort Worth", "IOI")
p3 <- printIndicatorTrend(migrationTable, "Houston", "SSD") #printIndicatorTrend(migrationTable, "Dallas-Fort Worth", "SSD")
p4 <- printEpiTrend(migrationTable, "rural")
p5 <- printIndicatorTrend(migrationTable, "rural", "IOI")
p6 <- printIndicatorTrend(migrationTable, "rural", "SSD")
p <- ggarrange(p1 + rremove("xlab") + rremove("ylab"),
               p4 + rremove("xlab") + rremove("ylab"),
               p2 + rremove("xlab") + rremove("ylab"),
               p5 + rremove("xlab") + rremove("ylab"),
               p3 + rremove("xlab") + rremove("ylab"),
               p6 + rremove("xlab") + rremove("ylab"),
               ncol = 2,
               nrow = 3,
               align = "v")
ggsave("../results/10_urbanvsrural.pdf", width = 32, height = 12, units = "in")

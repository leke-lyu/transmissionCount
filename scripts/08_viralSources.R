source("05_transmissionCount.R")
library(magrittr)
library(ggplot2)

migrationTable <- treeToTable("../data/05_texas.nexus", "location", 15)
locations <- migrationTable$To %>% unique() %>% sort()
locations <- locations[!is.na(locations)]
locations <- locations[locations!="context"]
df_SourceSink <- accumulatedIndicator(migrationTable, locations, "SSD") 

RUCC <- "../raw_data/MetroAreasInTexas.txt" %>% read.table(., sep="\t", header=T) %>% dplyr::select(Metro.area, Rural.Urban.Continuum.Code) %>% dplyr::distinct()
colnames(RUCC) <- c("ma", "rucc")
RUCC$ssd <- df_SourceSink[RUCC$ma] %>% unname()
coullocation <- hcl.colors(4, palette = "Sunset")
names(coullocation) <- RUCC$rucc %>% unique() %>% sort()

p <- ggplot(RUCC, aes(x = rucc, y = ssd)) +
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
ggsave("../results/08_viralSourceInTexas.pdf", p, width = 6, height = 6, units = "in")

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
p1 <- printIndicatorTrend(migrationTable, "San Antonio", "SSD")
ggsave("../results/08_sanantonio.pdf", width = 16, height = 4, units = "in")
p2 <- printIndicatorTrend(migrationTable, "Dallas-Fort Worth", "SSD")
ggsave("../results/08_dallas.pdf", width = 16, height = 4, units = "in")
p3 <- printIndicatorTrend(migrationTable, "Austin", "SSD")
ggsave("../results/08_austin.pdf", width = 16, height = 4, units = "in")


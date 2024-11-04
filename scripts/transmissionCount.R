library(magrittr)
library(ggplot2)
treeToTable <- function(path, trait, bc = Inf){
  
  treeTable <- path %>% treeio::read.beast(.) %>% ggtree::fortify(.)
  myCols <- c("parent", "node", "num_date", trait, "branch.length") %>% match(., names(treeTable))
  treeTable %<>% dplyr::select(all_of(myCols))
  treeTable$num_date %<>% as.numeric()
  
  Epiweek <- paste0(lubridate::epiyear(lubridate::date_decimal(treeTable$num_date)), sprintf("%02d", lubridate::epiweek(lubridate::date_decimal(treeTable$num_date))))
  From <- vector(mode="character", length=length(treeTable$parent))
  for(i in 1:length(treeTable$parent)){
    From[i] <- dplyr::pull(treeTable[treeTable$node==treeTable$parent[i], trait])
  }
  To <- treeTable %>% dplyr::pull(., 4) %>% unname(.)
  migrationTable <- data.frame(Epiweek, From, To, BranchLength=treeTable$branch.length*365) %>% dplyr::filter(., BranchLength < bc)
  return(migrationTable)
  
}
countSaptialTransmissionLinkages <- function(migrationTable, category, location){
  
  Epiweek <- migrationTable$Epiweek %>% unique() %>% sort()
  v <- vector(mode = "numeric", length = (Epiweek %>% length()))
  names(v) <- Epiweek
  
  if(category == "importation"){
    stopifnot("`location` must contain one region." = (length(location) == 1))
    for(i in names(v)){
      v[i] <- migrationTable %>% dplyr::filter(., Epiweek == i) %>% dplyr::filter(., From != location) %>% dplyr::filter(., To == location) %>% nrow()
    }
    return(v)
  }else if(category == "transmission linkage"){
    stopifnot("`location` must contain two region." = (length(location) == 2))
    for(i in names(v)){
      v[i] <- migrationTable %>% dplyr::filter(., Epiweek == i) %>% dplyr::filter(., From == location[1]) %>% dplyr::filter(., To == location[2]) %>% nrow()
    }
    return(v)
  }else if(category == "exportation"){
    stopifnot("`location` must contain one region." = (length(location) == 1))
    for(i in names(v)){
      v[i] <- migrationTable %>% dplyr::filter(., Epiweek == i) %>% dplyr::filter(., From == location) %>% dplyr::filter(., To != location) %>% nrow()
    }
    return(v)
  }else{
    stop("check the `category`!!!")
  }
  
}
accumulatedIndicator <- function(migrationTable, locations, indicator){
  
  v <- vector(mode = "numeric", length = length(locations))
  names(v) <- locations
  
  if(indicator == "LIS"){
    for(i in names(v)){
      import <- countSaptialTransmissionLinkages(migrationTable, "importation", i)
      localtransmission <- countSaptialTransmissionLinkages(migrationTable, "transmission linkage", c(i, i))
      v[i] <- (sum(import)/(sum(import)+sum(localtransmission)))
    }
  }else if(indicator == "SSS"){
    for(i in names(v)){
      import <- countSaptialTransmissionLinkages(migrationTable, "importation", i)
      export <- countSaptialTransmissionLinkages(migrationTable, "exportation", i)
      v[i] <- ((sum(export) - sum(import))/(sum(export) + sum(import)))
    }
  }else{
    stop("check the `indicator`!!!")
  }
  return(v)
  
}
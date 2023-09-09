library(magrittr)
library(ggtree)

tb <- "../data/05_texas.nexus" %>%
  treeio::read.beast(.) %>%
  tidytree::as_tibble(.)

From <- vector(mode = "character", length = nrow(tb))
for(i in 1:nrow(tb)){
  From[i] <- dplyr::pull(tb[tb$node == tb$parent[i], "country"])
}
To <- tb %>% dplyr::pull(., 7) %>% unname(.)
Color <- rep(NA, nrow(tb))
for(i in 1:nrow(tb)){
  if(!is.na(From[i])){
    if(From[i] == "context" & To[i] == "context"){
      Color[i] = "grey"
    }else if(From[i] == "context" & To[i] == "USA"){
      Color[i] = "#00BA38"
    }else if(From[i] == "USA" & To[i] == "USA"){
      Color[i] = "#619CFF"
    }else if(From[i] == "USA" & To[i] == "context"){
      Color[i] = "#F8766D"
    }
  }
}

tb %<>% dplyr::mutate(color = Color)
t <- tb %>%
  dplyr::select(c("parent", "node","branch.length", "label", "color")) %>%
  tidytree::as.treedata(.)
p <- ggtree(t, aes(color=I(color)), mrsd=(tb$num_date %>% max() %>% as.numeric() %>% lubridate::date_decimal() %>% as.Date())) + theme_tree2() 
viewClade(p, 12137)
ggsave("../results/07_TexasTree.pdf", width = 14, height = 14, units = "in")

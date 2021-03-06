krsa_ball_model_2 <- function(kinase_hits, lfc_table,frq, Nsize, Tsize,layout ) {
  
  
  lfc_table %>%
    select(Kinase, Z) %>% 
    mutate(breaks = cut(abs(Z), breaks = c(0, 1, 1.5, 2, Inf),
                        right = F,
                        labels = c("Z <= 1", "1 >= Z < 1.5", "1.5 >= Z < 2", "Z >= 2"))) -> Ztable
  
  nodes2 <- ballModel_nodes
  edges <- ballModel_edges
  
  nodes2 %>% dplyr::filter(FinName %in% kinase_hits) %>% pull(FinName) -> sigHITS
  edges %>% dplyr::filter(Source %in% sigHITS | Target %in% sigHITS, Source != Target) -> modEdges
  
  modsources <- pull(modEdges, Source)
  modtargets <- pull(modEdges, Target)
  
  modALL <- unique(c(modsources,modtargets))
  
  nodes2 %>% dplyr::filter(FinName %in% modALL) -> nodesF
  
  edges %>% dplyr::filter(Source %in% nodesF$FinName & Target %in% nodesF$FinName, Source != Target) -> modEdges
  
  modEdges %>% mutate(line = ifelse(Source %in% sigHITS | Target %in% sigHITS, 2,1 )) -> modEdges
  
  modsources <- pull(modEdges, Source)
  modtargets <- pull(modEdges, Target)
  
  modALL <- c(modsources,modtargets)
  as.data.frame(table(modALL)) -> concts
  
  concts %>% rename(FinName = modALL) -> concts
  
  concts$FinName <-  as.character(concts$FinName)
  
  right_join(nodesF,concts) -> nodesF
  
  
  nodesF %>% left_join(select(Ztable, Kinase, breaks) %>% distinct(), by = c("FinName"= "Kinase")) %>% mutate(cl = case_when(
    breaks == "1 >= Z < 1.5" ~ "#FCAE91",
    breaks == "Z <= 1" ~ "#FEE5D9",
    breaks == "1.5 >= Z < 2" ~ "#FB6A4A",
    breaks == "Z >= 2" ~ "#CB181D",
    T ~ "grey"
  )) -> nodesF
  
  #nodesF %>% mutate(cl = ifelse(FinName %in% sigHITS, "red", "gray")) -> nodesF
  
  nodesF %>% dplyr::filter(Freq>=frq| !cl %in% c("grey", "#FEE5D9", "#FCAE91")) %>% pull(FinName) -> FinKinases
  
  modEdges %>% dplyr::filter(Source %in% FinKinases & Target %in% FinKinases) -> modEdges
  nodesF %>% dplyr::filter(FinName %in% FinKinases) %>% mutate(Freq = ifelse(Freq < 4, 4, Freq) )-> nodesF
  
  net <- igraph::graph_from_data_frame(d=modEdges, vertices=nodesF, directed=T)
  net <- igraph::simplify(net,remove.loops = F, remove.multiple = F)
  
  V(net)$size = log2(V(net)$Freq)*Nsize
  colrs <- c("#FEE5D9", "#FCAE91", "#FB6A4A", "#CB181D", "grey")
  V(net)$color <- V(net)$cl
  
  colrs2 <- c("gray", "black")
  E(net)$color <- colrs2[E(net)$line]
  
  
  plot(net, edge.arrow.size=.05,
       vertex.label=V(net)$FinName,
       vertex.label.color = "black",
       vertex.label.cex=log2(V(net)$Freq)/Tsize, 
       layout = if(layout=="Circle"){layout_in_circle} else if(layout=="Fruchterman-Reingold")
         {layout_with_fr}else if(layout=="Kamada Kawai")
           {layout_with_kk} else if(layout=="LGL"){layout_with_lgl}
       )
  
  legend("bottomleft", c("Z <= 1", "1 >= Z < 1.5", "1.5 >= Z < 2", "Z >= 2", "NA"), pch=21,
         col="#777777", pt.bg=colrs, pt.cex=2, cex=.8, bty="n", ncol=1)
}
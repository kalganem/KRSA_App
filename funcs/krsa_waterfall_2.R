krsa_waterfall_2 <- function(data, lfc_thr, byChip =  T) {
  
  if(byChip == T) {
  data$colMean <- cut(data$totalMeanLFC, breaks = c(-Inf,-1*lfc_thr, lfc_thr, Inf), labels = c("red", "black", "red"))
  data$colFC <- cut(data$LFC, breaks = c(-Inf,-1*lfc_thr, lfc_thr, Inf), labels = c("black", "gray", "black"))
  }
  else {
    data$colFC <- cut(data$LFC, breaks = c(-Inf,-1*lfc_thr, lfc_thr, Inf), labels = c("red", "black", "red"))
  }
  
  ggplot(data) -> gg
  
  if(byChip == T) {
    gg <- gg + 
      geom_point(aes(LFC, reorder(Peptide,LFC)), color = data$colFC, size = 0.75) +
      geom_point(aes(totalMeanLFC, reorder(Peptide,totalMeanLFC)), color = data$colMean, size = 1.2) +
      geom_line(aes(LFC, reorder(Peptide,totalMeanLFC)), alpha = 1/3)
  }
      
  else {
    gg <- gg + 
      geom_segment( aes(x=0, xend=LFC, y=reorder(Peptide,LFC), yend=reorder(Peptide,LFC)), color="grey") +
      geom_point(aes(LFC, reorder(Peptide,LFC)), color = data$colFC, size = 2)
  }
    
  
  
  
  gg +
    geom_vline(xintercept = 0) +
    geom_vline(xintercept = -1 * lfc_thr,linetype="dashed") +
    geom_vline(xintercept = lfc_thr,linetype="dashed")+
    labs(x = "Log2 Fold Change",
         y=""
    ) +
    theme(plot.title  = element_text(size = 7),
          axis.text.y = element_text(size= 5)
    ) + theme_bw()
}
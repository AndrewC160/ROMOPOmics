#composite_geo_table()

composite_geo_table   <- function(geo_input=NULL){
  if(is.null(geo_input)){return(NULL)}
  mds <- lapply(geo_input, function(x) x$metadata)
  
  #GDS details.
  if(is.null(mds$GDS)){stop("No GDS slot present with column data.")}
  col_dat   <- mds$GDS$coldata %>% ungroup()
  gds_md    <- mds$GDS$metadata %>% 
                mutate(detail=paste("gds",detail,sep="_")) %>%
                expand_and_tpose(rows_out = nrow(col_dat))
  col_dat   <- cbind(col_dat,gds_md) %>% as_tibble()
  
  #GPL details.
  if(!is.null(mds$GPL)){
    gpl_md    <- mds$GPL$metadata %>% 
                  mutate(detail=paste("gpl",detail,sep="_")) %>%
                  filter(values != " ") %>%
                  expand_and_tpose(rows_out = nrow(col_dat))
    col_dat   <- cbind(col_dat,gpl_md) %>% as_tibble()
  }
  
  #GSE details.
  if(!is.null(mds$GSE)){
    gse_md    <- lapply(names(mds$GSE), function(x){
                  nm  <- gsub("_series_matrix.txt.+$","",x)
                  md  <- mds$GSE[[x]]
                  rf  <- enframe(md$raw_files,name="sample",value = "ftp_loc")
                  md  <- md$metadata %>% 
                          mutate(detail = paste("gse",detail,sep="_")) %>%
                          expand_and_tpose(rows_out = nrow(rf))
                  return(cbind(rf,md) %>% as_tibble)
                 }) %>%
      do.call(rbind,.)
    col_dat   <- merge(col_dat,gse_md,all.x = TRUE,all.y = FALSE) %>% as_tibble()
  }
  return(col_dat)
}

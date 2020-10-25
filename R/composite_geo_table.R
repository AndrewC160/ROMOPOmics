#' composite_geo_table
#' 
#' Background function (not user-facing).
#' 
#' Given a GEO list object from one of the fetch functions, composite_geo_table
#' builds a table of metadata based on metadata from comprised GDS, GSE, and 
#' GPL objects.
#' 
#' @param geo_input GEO input objet (list) from a fetch function.
#' 
#' @import tidyverse
#' 
#' composite_geo_table()
#' 
#' @export

composite_geo_table   <- function(geo_input=NULL){
  if(is.null(geo_input)){return(NULL)}
  mds     <- lapply(geo_input, function(x) x$metadata)
  col_dat <- NULL
  gds_md  <- NULL
  
  
  #GDS details.
  if(is.null(mds$GDS)){gds_md   <- NULL}else{
    col_dat <- mds$GDS$coldata %>% ungroup()
    gds_md  <- mds$GDS$metadata %>% 
                mutate_if(is.factor,as.character) %>%
                mutate(detail=paste("gds",detail,sep="_")) %>%
                expand_and_tpose(rows_out = nrow(col_dat))
    col_dat <- cbind(col_dat,gds_md) %>% as_tibble()
  }
  
  #GSE details.
  if(is.null(mds$GSE)){gse_md <- NULL}else{
    gse_md<- lapply(names(mds$GSE), function(x){
      nm  <- gsub("_series_matrix.txt.+$","",x)
      md  <- mds$GSE[[x]]$metadata %>% 
              rename_all(function(x) paste0("gse_",x)) %>%
              rename(sample = gse_geo_accession) %>%
              mutate(gse_id = nm)
    }) %>%
      Reduce(function(x,y) merge(x,y,all=TRUE),.)
    if(!is.null(col_dat)){
      col_dat <- merge(col_dat,gse_md,all=TRUE) %>% as_tibble()
    }else{
      col_dat <- gse_md
    }
  }
  
  #GPL details.
  if(!is.null(mds$GPL)){
    gpl_md    <- mds$GPL$metadata %>% 
                  mutate(detail=paste("gpl",detail,sep="_"))
    
    #If GSE and/or GDS present, expand and transpose GPL to match.
    if(is.null(col_dat)){
      col_dat <- gpl_md
    }else{
      col_dat <- cbind(col_dat,
                       expand_and_tpose(input_frame = gpl_md,rows_out = nrow(col_dat)))
    }
  }
  return(as_tibble(col_dat))
}

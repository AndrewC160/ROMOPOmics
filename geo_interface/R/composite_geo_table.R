#composite_geo_table

composite_geo_table   <- function(gds_id=NULL,gds_md=NULL,gpl_md=NULL,gse_md=NULL,data_dir=NULL){
  if(!is.null(gds_id)){
    #Start from scratch with GDS ID.
    geo_data  <- fetch_geo_dataset(gds_id,data_dir=data_dir)
    if(!is.null(geo_data)){
      gds_md  <- geo_data$GDS$metadata$metadata %>% mutate(detail=paste("gds",detail,sep="_"))
      gpl_md  <- geo_data$GPL$metadata$metadata %>% mutate(detail=paste("gpl",detail,sep="_"))
      gse_md  <- geo_data$GSE$metadata
      gse_meta<- lapply(names(gse_md), function(x) {
        md    <- gse_md[[x]]$metadata
        fls   <- enframe(gse_md[[x]]$raw_files,value = "remote_raw_file")
        
        
        
        x$metadata})
      gse_fls <- lapply(geo_data$GSE$metadata, function(x) enframe(x$raw_files))
      col_dat <- gds_md$coldata
    }
  }else{
    stop("Unable to retrieve data with ID provided.")
  }
  md  <- rbind(gds_md,gpl_md)
  
  
}
#' fetch_geo_datasets
#' 
#' Wrapper for most GEO import functions when incorporating GEOquery datasets.
#' Given a GEO dataset ID (i.e. "GDS507") or list of such IDs, function 
#' retrieves S4 metadata obejcts from GEOquery for each dataset, its associated
#' platform (GPL), series (GSE), and column data. Function also produces a
#' metadata table for each such component, and stores these within nested list.
#' A comprehensive metadata table is also produced and stored. If multiple IDs 
#' are submitted, these are imported recursively, and metadata from each is a
#' merged into a comprehensive metadata table in the top-level list. Invalid ID
#' entries are identified by checking the validity of their purported URL: if 
#' invalid, a warning message is displayed. With multiple IDs, these are added
#' to a text object denoting which failed.
#' 
#' @param geo_dataset_ids GEO dataset ID (e.g. "GDS507") or a list of such IDs.
#' @param data_dir Directory into which retrieved data objects should be stored. NULL by default, in which case saved to memory in a temp folder.
#' 
#' @import tidyverse
#' 
#' fetch_geo_datasets()
#' 
#' @export

fetch_geo_datasets  <- function(geo_dataset_ids,data_dir = NULL){
  if(length(geo_dataset_ids) > 1){
    geo       <- lapply(geo_dataset_ids,fetch_geo_datasets,data_dir=data_dir)
    char_ents <- which(sapply(geo_dataset_ids,is.character))
    names(geo)[char_ents]   <- geo_dataset_ids[char_ents]
    
    #Provide merged metadata table, include only valid metadata.
    valid_ents<- sapply(geo, is, class="list")
    invld_lst <- names(valid_ents)[!valid_ents]
    geo       <- geo[valid_ents]
    geo$merged_metadata   <- lapply(names(geo), function(x) mutate(geo[[x]]$metadata,gds_id = x)) %>% 
                              Reduce(f=function(x,y) merge(x,y,all=TRUE),.) %>%
                              as_tibble()
    geo$blank_mask        <- metadata_mask(geo$merged_metadata)
    if(length(invld_lst) > 0){
      geo$invalid_ids     <- invld_lst
    }
  }else if(!is.character(geo_dataset_ids)){
    return("Invalid URL.")
  }else{
    #Check for valid string entry.
    gdid  <- toupper(geo_dataset_ids)
    if(!str_detect(gdid,pattern = "^GDS[:digit:]+$")){
      message('Dataset ID should fit the format "GDSnnn".')
      return("Invalid URL.")
    }
    
    #Check that the provided ID leads to a real URL.
    if(!check_geo_by_url(gdid)){
      message(paste('ID leads to an invalid URL:\n\t',gdid))
      return("Invalid URL.")
    }
    
    #Gather GEO data.
    if(is.null(data_dir)){data_dir  <- tempdir()}
    gds <- getGEO(gdid,destdir = data_dir)
    gpl <- getGEO(Meta(gds)$platform,destdir=data_dir)
    gse <- getGEO(gds@header$reference_series,destdir=data_dir)
    gds_md  <- parse_metadata(gds)
    gpl_md  <- parse_metadata(gpl)
    gse_md  <- parse_metadata(gse)
    geo     <- list(GDS=list(GDS=gds,metadata=gds_md),
                    GPL=list(GPL=gpl,metadata=gpl_md),
                    GSE=list(GSE=gse,metadata=gse_md))
    #geo$summary <- dataset_summary_text(gdid,geo_data = geo)
    #Get metadata table.
    geo$metadata  <- composite_geo_table(geo_input = geo)
    geo$blank_mask<- metadata_mask(metadata_table = geo$metadata)
  }
  return(geo)
}

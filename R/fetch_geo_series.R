#' fetch_geo_series
#' 
#' Wrapper for most GEO import functions when incorporating GEOquery sample
#' series'. Given a GEO series ID (i.e. "GSE158946") or list of such IDs,
#' function retrieves S4 metadata obejcts from GEOquery for each dataset, as 
#' well as its associated platform (GPL) and column data. Function also 
#' produces a metadata table for each such component, and stores these within
#' nested list. A comprehensive metadata table is also produced and stored. If
#' multiple IDs are submitted, these are imported recursively, and metadata 
#' from each is a merged into a comprehensive metadata table in the top-level
#' list. Invalid ID entries are identified by checking the validity of their 
#' purported URL: if invalid, a warning message is displayed. With multiple
#' IDs, these are added to a text object denoting which failed.
#' 
#' @param geo_dataset_ids GEO series ID (e.g. "GSE158946") or a list of such IDs.
#' @param data_dir Directory into which retrieved data objects should be stored. NULL by default, in which case saved to memory in a temp folder.
#' 
#' @import tidyverse
#' @import stringr
#' 
#' @export

fetch_geo_series  <- function(geo_series_ids,data_dir = NULL){
  if(length(geo_series_ids) > 1){
    geo       <- lapply(geo_series_ids,fetch_geo_series,data_dir=data_dir)
    char_ents <- which(sapply(geo_series_ids,is.character))
    names(geo)[char_ents]   <- geo_series_ids[char_ents]
    
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
  }else if(!is.character(geo_series_ids)){
    return("Invalid URL.")
  }else{
    #Check for valid string entry.
    gdid  <- toupper(geo_series_ids)
    if(!stringr::str_detect(gdid,pattern = "^GSE[:digit:]+$")){
      message('Series ID should fit the format "GSEnnnnnn".')
      return("Invalid URL.")
    }

    #Check that the provided ID leads to a real URL.
    if(!check_geo_by_url(gdid)){return("Invalid URL.")}
    
    #Gather GEO data.
    if(is.null(data_dir)){data_dir  <- tempdir()}
    #Error: can't load GSE144622, something wrong with GEO/GEOquery? For now just stop.
    
    #tryCatch(expr = {gse <- getGEO(gdid,destdir=data_dir)},
    #         error = message(paste0("Unable to download ",gdid,".")))
    #https://stackoverflow.com/questions/8852406/r-script-how-to-continue-code-execution-on-error
    #possibly()
    #if(is.null(gds)){stop("Unable to retrieve ",gdid,".")}
    gse   <- getGEO(gdid,destdir=data_dir)
    gpl   <- getGEO(unique(as.character(gse[[1]]$platform_id)),destdir = data_dir)
    gse_md  <- parse_metadata(gse)
    gpl_md  <- parse_metadata(gpl)
    
    geo     <- list(GPL=list(GPL=gpl,metadata=gpl_md),
                    GSE=list(GSE=gse,metadata=gse_md))
    
    #Get combined metadata table.
    geo$metadata  <- composite_geo_table(geo_input = geo)
    geo$blank_mask<- metadata_mask(geo$metadata)
  }
  return(geo)
}

#fetch_geo_series

fetch_geo_series  <- function(geo_series_ids=c("GSE158946","GSE146796"),data_dir = NULL){
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
    if(!str_detect(gdid,pattern = "^GSE[:digit:]+$")){
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

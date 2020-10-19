#fetch_geo_datasets

fetch_geo_datasets  <- function(geo_dataset_ids=c("GDS507","GDS508"),data_dir = NULL){
  if(length(geo_dataset_ids) > 1){
    geo   <- lapply(geo_dataset_ids,fetch_geo_datasets,data_dir=data_dir)
    char_ents   <- which(sapply(geo_dataset_ids,is.character))
    names(geo)[char_ents]   <- geo_dataset_ids[char_ents]
    
    #Provide merged metadata table.
    geo$merged_metadata   <- lapply(names(geo), function(x) mutate(geo[[x]]$metadata,gds_id = x)) %>% 
                              Reduce(f=function(x,y) merge(x,y,all=TRUE),.) %>%
                              as_tibble()
  }else if(!is.character(geo_dataset_ids)){
    return("Invalid URL.")
  }else{
    #Check for valid string entry.
    gdid  <- toupper(geo_dataset_ids)
    if(!str_detect(gdid,pattern = "^GDS[:digit:]{3}$")){
      message('Dataset ID should fit the format "GDSnnn".')
      return("Invalid URL.")
    }
    url <- paste0("https://ftp.ncbi.nlm.nih.gov/geo/datasets/GDSnnn/GDS",
                  substr(gdid,start = 4,stop = nchar(gdid)))
    #Check that the provided ID leads to a real URL.
    if(!url.exists(url)){
      message(paste('ID leads to an invalid URL:\n\t',url))
      return("Invalid URL.")
    }
    
    #Gather GEO data.
    if(is.null(data_dir)){data_dir  <- tempdir()}
    gds <- getGEO(geo_dataset_ids,destdir = data_dir)
    gpl <- getGEO(Meta(gds)$platform,destdir=data_dir)
    gse <- getGEO(gds@header$reference_series,destdir=data_dir)
    gds_md  <- parse_metadata(gds)
    gpl_md  <- parse_metadata(gpl)
    gse_md  <- parse_metadata(gse)
    geo     <- list(GDS=list(GDS=gds,metadata=gds_md),
                    GPL=list(GPL=gpl,metadata=gpl_md),
                    GSE=list(GSE=gse,metadata=gse_md))
    #Get metadata table.
    geo$metadata  <- composite_geo_table(geo)
  }
  return(geo)
}

#gather_geo_dataset

fetch_geo_dataset  <- function(geo_dataset_id="GDS507",data_dir = NULL){
  #Check for valid string entry.
  gdid  <- toupper(geo_dataset_id)
  if(!str_detect(gdid,pattern = "^GDS[:digit:]{3}$")){
    message('Dataset ID should fit the format "GDSnnn".')
    return(NULL)
  }
  url <- paste0("https://ftp.ncbi.nlm.nih.gov/geo/datasets/GDSnnn/GDS",
                substr(gdid,start = 4,stop = nchar(gdid)))
  #Check that the provided ID leads to a real URL.
  if(!url.exists(url)){
    message(paste('ID leads to an invalid URL:\n\t',url))
    return(NULL)
  }
  
  #Gather GEO data.
  if(is.null(data_dir)){data_dir  <- tempdir()}
  gds <- getGEO(geo_dataset_id,destdir = data_dir)
  gpl <- getGEO(Meta(gds)$platform,destdir=data_dir)
  gse <- getGEO(gds@header$reference_series,destdir=data_dir)
  gds_md  <- parse_metadata(gds)
  gpl_md  <- parse_metadata(gpl)
  gse_md  <- parse_metadata(gse)
  
  return(
    list(
      GDS=list(GDS=gds,metadata=gds_md),
      GPL=list(GPL=gpl,metadata=gpl_md),
      GSE=list(GSE=gse,metadata=gse_md)))
}

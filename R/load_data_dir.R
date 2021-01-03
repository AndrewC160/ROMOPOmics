#' load_mask_dir
#' 
#' Given a directory containing data files, read each and approximate a 
#' a name from the file name (basename, and remove ".tsv"). Throws an 
#' error if no files are found. Also removes any files with the substring "mask"
#' 
#' @param dir_name Name of directory to search for masks.
#' 
#' load_data_dir()
#' 
#' @import tibble
#' 
load_data_dir <- function(dir_name){
  data_fls    <- Sys.glob(file.path(dir_name,"*.[ct]sv"))
  data_fls <- data_fls[!grepl("mask",data_fls)]
  if(identical(data_fls,character(0))){
    stop(paste0("No data files ending in '.tsv' or '.csv' found in ",dir_name,"."))
  }
  nms         <- gsub(".[ct]sv","",basename(data_fls))
  datas       <- lapply(data_fls,read_data)
  names(datas)<- nms
  return(datas)
}

#' load_mask_dir
#' 
#' Given a directory containing mask TSV files, read each and approximate a 
#' a name from the file name (basename, and remove "_mask.tsv"). Throws an 
#' error if no files are found.
#' 
#' @param dir_name Name of directory to search for masks.
#' 
#' load_mask_dir()
#' 
#' @import tibble
#' 
#' @export

load_mask_dir <- function(dir_name){
  mask_fls    <- Sys.glob(file.path(dir_name,"*.[ct]sv"))
  if(identical(mask_fls,character(0))){
    stop(paste0("No mask files ending in '.tsv' found in ",dir_name,"."))
  }
  nms         <- gsub("_mask.[ct]sv","",basename(mask_fls))
  nms         <- gsub(".[ct]sv$","",nms)
  masks       <- lapply(mask_fls,read_mask)
  names(masks)<- nms
  return(masks)
}
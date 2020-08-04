#' loadModelMasks
#'
#' Function reads in all "mask" tables, either within a directory of mask files
#' ending in ".tsv," a vector of file names of individual mask TSVs, or both.
#' Automatically adds essential columns table, alias, and field: 'Alias'
#' denotes the value being input, 'field' denotes the data model's equivalent
#' field name, and 'table' denotes the data model table where that field
#' resides. If multiple files are provided, they are returned in a list named
#' from the basenames of the loaded files. If the list of mask files is already
#' named, these names are used instead.
#' 
#' @param mask_files Either one or more file names of mask TSVs, or a directory of mask TSVs.
#'
#' loadModelMasks()
#'
#' @import tibble
#' @import data.table
#' @import magrittr
#'
#' @export

loadModelMasks<- function(mask_files){
  if(missing(mask_files)){
    stop("No mask file or directory specified.")
  }
  #Read directories.
  dir_inputs  <- sapply(mask_files,dir.exists)
  dir_msks    <- do.call("c",lapply(mask_files[dir_inputs],load_mask_dir))
  
  #Read individual files.
  fls_inputs  <- sapply(mask_files,file.exists) & !dir_inputs
  fls_msks    <- lapply(mask_files[fls_inputs],read_mask_tsv)
  nms         <- names(mask_files)[fls_inputs]
  if(is.null(nms)){
    nms       <- gsub("\\.tsv$","",basename(mask_files[fls_inputs]))
    nms       <- gsub("_mask$","",nms)
  }
  names(fls_msks) <- nms
  
  #Concatenate into one list.
  msks        <- c(dir_msks,fls_msks)
  
  #Report errors.
  err_inputs  <- !dir_inputs & !fls_inputs
  if(sum(err_inputs) > 0){
    message(paste0("The following file/directory input(s) were not found:\n\t",
                   paste(mask_files[err_inputs],collapse="\n\t")))
  }
  if(length(msks) == 1){
    return(msks[[1]])
  }else{
    return(msks)
  }
}

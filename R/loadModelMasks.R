#' Read a mask file
#' 
#' \code{read_mask()} takes and reads a mask file TSV/CSV. 
#' The function attempts to read it using fread and returns
#' an error message if it fails. Returns table with all applicable columns
#' appended.
#' 
#' @param file_name File name to be read. Should specify a TSV/CSV file.
#' 
#' read_mask()
#' 
#' @importFrom data.table fread
#' @importFrom tidyr as_tibble
#' @importFrom dplyr mutate select
#' @importFrom magrittr %>%
read_mask <- function(file_name){
  set_value <- field_idx <- NULL
  tb  <- fread(file_name,header = TRUE,stringsAsFactors = FALSE) %>%
    as_tibble() %>%
    mutate(set_value = if("set_value" %in% names(.)){set_value}else{NA},
           field_idx = if("field_idx" %in% names(.)){field_idx}else{NA},
           set_value = ifelse(set_value=="",NA,set_value),
           field_idx = ifelse(field_idx=="",NA,field_idx)) %>%
    select(table,alias,field,set_value,field_idx,everything())
  if(!exists("tb")){
    stop(paste0("Failed to read mask file '",file_name,"'."))
  }
  return(tb)
}

#' Load then read mask files from a directory
#' 
#' \code{load_mask_dir()} takes a directory, reads in each file (includes only 
#' mask files which contain the string 'mask'), and approximates a 
#' a name from the file name (basename, and remove "_mask.[ct]sv"). Throws an 
#' error if no files are found.
#' 
#' @param dir_name Name of directory to search for masks.
#' 
#' load_mask_dir()
#' 
#' @import tibble
load_mask_dir <- function(dir_name){
  mask_fls    <- Sys.glob(file.path(dir_name,"*mask.[ct]sv"))
  if(identical(mask_fls,character(0))){
    stop(paste0("No mask files ending in '.tsv' or '.csv' found in ",
                dir_name,"."))
  }
  nms         <- gsub("_mask.[ct]sv","",basename(mask_fls))
  masks       <- lapply(mask_fls,read_mask)
  names(masks)<- nms
  return(masks)
}

#' Load the data dictionary for corresponding data fields to the CDM
#'
#' \code{loadModelMasks} reads in all "mask" tables, which correspond the 
#' input data fields to the common data model fields and tables. 
#' 
#' The function automatically adds essential columns table, alias, and field: 
#' 'Alias' denotes the value being input, 'field' denotes the data model's 
#' equivalent field name, and 'table' denotes the data model table where that 
#' field resides. If multiple files are provided, they are returned in a list 
#' named from the basenames of the loaded files. If the list of mask files is 
#' already named, these names are used instead.
#' 
#' @param mask_files Either one or more file names of mask CSVs or TSVs, 
#' or a directory string containing the mask files.
#'
#' loadModelMasks()
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
  fls_msks    <- lapply(mask_files[fls_inputs],read_mask)
  nms         <- names(mask_files)[fls_inputs]
  if(is.null(nms)){
    nms       <- gsub("\\.[ct]sv$","",basename(mask_files[fls_inputs]))
    nms       <- gsub("_mask$","",nms)
  }
  names(fls_msks) <- nms
  
  #Concatenate files from directory and/or vector into one list.
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

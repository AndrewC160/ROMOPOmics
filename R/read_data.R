#' read_mask
#' 
#' Given a data file TSV/CSV, function attempts to read it using fread and returns
#' an error message if it fails. Returns table with all applicable columns
#' appended.
#' 
#' @param file_name File name to be read. Should specify a TSV/CSV file.
#' 
#' read_data()
#' 
#' @importFrom data.table fread
#' @import dplyr
#' 
read_data <- function(file_name){
  tb  <- fread(file_name,header = TRUE,stringsAsFactors = FALSE) %>%
    as_tibble() 
  if(!exists("tb")){
    stop(paste0("Failed to read data file '",file_name,"'."))
  }
  return(tb)
}

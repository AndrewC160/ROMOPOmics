#' read_mask_tsv
#' 
#' Given a mask file TSV, function attempts to read it using fread and returns
#' an error message if it fails. Returns table with all applicable columns
#' appended.
#' 
#' @param file_name File name to be read. Should specify a TSV file.
#' 
#' read_mask_tsv()
#' 
#' @importFrom data.table fread
#' @import tidyverse
#' 
#' @export

read_mask_tsv <- function(file_name){
  tb  <- fread(file_name,header = TRUE,stringsAsFactors = FALSE,sep = "\t") %>%
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
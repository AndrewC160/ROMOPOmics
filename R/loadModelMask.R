#' loadModelMask
#'
#' Function reads in an individual "mask" table which include three essential
#' columns: table, alias, and field. 'Alias' denotes the value being input, 
#' 'field' denotes the data model's equivalent field name, and 'table' denotes
#' the data model table where that field resides.
#'
#' loadModelMask()
#'
#' @import tidyverse
#' @import data.table
#'
#' @export

loadModelMask  <- function(mask_tsv,data_model=loadDataModel()){
  if(missing(mask_tsv)){
    stop("No mask file specified.")
  }
  fread(mask_tsv,sep="\t",header=TRUE) %>%
    as_tibble() %>%
    #Check that set_value and entry_index columns are present, if not add blanks.
    mutate(set_value = if("set_value" %in% names(.)){set_value}else{NA},
           field_idx = if("field_idx" %in% names(.)){field_idx}else{NA},
           set_value = ifelse(set_value=="",NA,set_value),
           field_idx = ifelse(field_idx=="",NA,field_idx)) %>%
    select(table,alias,field,set_value,field_idx,everything()) %>%
    return()
}

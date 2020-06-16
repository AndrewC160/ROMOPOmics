#' expand_entry_columns
#' 
#' Function takes in a table with duplicated fields and a field_index column 
#' (the output of readInputFiles, effectively) and spreads them wider, i.e. 
#' one column per patient to one column per treatment. Probably more useful
#' when called by readInputFiles rather than by users.
#' 
#' @param table_in Table to be expanded, generally intermediate format within readInputFiles().
#' 
#' expand_entry_columns()
#' 
#' @import magrittr
#' @import tidyverse
#' 
#' @export

expand_entry_columns  <- function(table_in){
  #If no index values are provided, just strip the field_index and return.
  if(all(is.na(table_in$field_idx))){return(select(table_in,-field_idx))}
  
  #If index values ARE provided, rbind a duplicate table for each possible set
  # value (if sets 1:3 are present, rbind 3 tables). This maintains each input
  # value. Next, pivot_wider() using the field index
  col_nms   <- colnames(table_in)[!colnames(table_in) %in% c("table","field","field_idx","alias","set_value")]
  lapply(unique(na.omit(table_in$field_idx)), function(x) {
    table_in %>% 
      filter(is.na(field_idx) | field_idx == x) %>%
      mutate(field_idx = x)}
    ) %>%
    do.call(rbind,.) %>%
    pivot_wider(id_cols =  c(table,field),
                names_from = field_idx,
                values_from = col_nms) %>%
    return()
}

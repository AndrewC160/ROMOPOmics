#' expand_entry_columns
#' 
#' Function is similar to dplyr::unnest() on all fields that are used more than
#' once (assigned a field_idx), but ensures that new columns also contain all 
#' common field entries (for instance, if the field 'value_as_number' is used 
#' twice, both indices are given a column, but both columns should feature 
#' "patient_name" and "gender_source_value".
#' 
#' @param table_in Table to be expanded, generally intermediate format within readInputFiles().
#' 
#' expand_entry_columns()
#' 
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
      dplyr::filter(is.na(field_idx) | field_idx == x) %>%
      dplyr::mutate(field_idx = x)}
    ) %>%
    do.call(rbind,.) %>%
    pivot_wider(id_cols =  c(table,field),
                names_from = field_idx,
                values_from = col_nms) %>%
    return()
}

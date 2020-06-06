#' expand_entry_columns
#' 
#' Function takes in a table with duplicated fields and a field_index column 
#' (the output of readInputFiles, effectively) and spreads them wider, i.e. 
#' one column per patient to one column per treatment. Probably more useful
#' when called by readInputFiles rather than by users.
#' 
#' @param table_in Table to be expanded, generally intermediate format within readInputFiles().
#' @param col_nms Names of columns to be "expanded".
#' 
#' expand_entry_columns()
#' 
#' @import magrittr
#' @import tidyverse
#' 
#' @export

expand_entry_columns  <- function(table_in = a,col_nms = c("brca_clinical2","brca_clinical3")){
  
  #If no index values are provided, just strip the field_index and return.
  if(all(is.na(table_in$set_value))){return(select(table_in,-field_idx))}
  
  #Base table: values with no index, meaning they should be common between all
  # other measurements (date of birth applies between all measurements).
  lapply(col_nms, function(x)
  { tb          <- select(table_in,table,field,field_idx,alias,!!as.name(x))
  base_table  <- filter(tb,is.na(field_idx)) %>% select(-field_idx,-alias)
  dupd_tabs   <- filter(tb,!is.na(field_idx)) %>%
    group_split(field_idx) %>%
    lapply(function(y) {
      cn  <- paste(x,y$field_idx[1],sep="_")
      select(y,table,field,x) %>%
        rbind(base_table,.) %>%
        rename(!!as.name(cn):=x)}) %>%
    Reduce(function(a,b) merge(a,b,all=TRUE),.)
  }) %>%
    Reduce(function(a,b) merge(a,b,all=TRUE),.) %>% as_tibble()
}
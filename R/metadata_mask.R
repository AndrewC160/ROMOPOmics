#' metadata_mask
#' 
#' Background function (not typically user-facing).
#' 
#' Function parses a metadata tibble into a mask format, including examples.
#' 
#' @param metadata_table Metadata table to be used.
#' @param examples Defaults to three; how many ";" separated examples from the data should be included?
#' 
#' metadata_mask()
#' 
#' @import tidyverse
#' 
metadata_mask   <- function(metadata_table,examples=3){
  metadata_table %>%
    summarize_all(list) %>%
    pivot_longer(cols=everything()) %>%
    rowwise() %>%
    mutate(na_count = sum(is.na(value)),
           value = list(unique(na.exclude(truncate_by_chars(value,max_char = 30)))),
           examples_from_data=list(unique(sample(value,size = 3,replace=TRUE))),
           examples_from_data=paste(examples_from_data,collapse=";")) %>%
    ungroup() %>%
    select(-value) %>%
    rename(alias=name) %>%
    mutate(table="",field="",field_idx="",set_value="") %>%
    select(alias,table,field,field_idx,everything()) %>%
    return()
}
  
  
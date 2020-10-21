#metadata_mask

#metadata_table <- sum_m_data
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
    mutate(table="",field="") %>%
    select(alias,table,field,everything()) %>%
    return()
}
  
  
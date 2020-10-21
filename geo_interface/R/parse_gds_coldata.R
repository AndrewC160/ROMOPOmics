#!/bin/Rscript
#Parse GDS coldata for all included samples.

parse_gds_coldata <- function(gds_in=NULL){
  if(is.null(gds_in)){return(NULL)}
  gds_in %>%
    Columns() %>%
    as_tibble() %>%
    rowwise() %>%
    mutate(description = 
             list(sapply(str_split(description,pattern=";",simplify = TRUE),trimws,USE.NAMES=FALSE))) %>%
    ungroup() %>%
    unnest(description) %>%
    #If no ":" present, use a generic title.
    group_by(sample) %>%
    mutate(description = ifelse(grepl(":",description),
                                description,
                                paste0("desc",row_number(),":",description))) %>%
    separate(description,into = c("desc_name","desc_value"),sep = ":") %>%
    mutate_at(vars(-group_cols()),trimws) %>%
    mutate(desc_name = gsub(" for GSM[0123456789]+","",desc_name)) %>%
    pivot_wider(names_from=desc_name,values_from=desc_value,values_fn = function(x) paste(x,collapse=";"))
}
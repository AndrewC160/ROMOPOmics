#' transpose_to_colwise
#' 
#' If an input data set is arranged in a rowwise fashion (one row per patient),
#' use transpose_to_colwise() transposes this data.
#' 
#' @param input_tibble Any tibble (no rownames, obviously).
#' 
#' @import tidyverse
#' 
#' @export

transpose_to_colwise  <- function(input_tibble){
  #class_vec <- sapply(colnames(input_tibble), function(x) class(select(input_tibble,x) %>% unlist()))
  input_tibble %>%
    mutate(rowname=paste0("V",row_number()+1)) %>%
    mutate_all(as.character) %>%
    pivot_longer(-rowname) %>%
    pivot_wider(names_from = rowname,values_from=value) %>%
    return()
}

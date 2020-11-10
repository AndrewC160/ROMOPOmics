#' transpose_to_colwise
#' 
#' If an input data set is arranged in a rowwise fashion (one row per patient),
#' use transpose_to_colwise() transposes this data.
#' 
#' @param input_tibble Any tibble (no rownames, obviously).
#' 
#' @import tidyr
#' @import dplyr
#' 
#' @export

transpose_to_colwise  <- function(input_tibble){
  input_tibble %>%
    dplyr::mutate(rowname=paste0("V",row_number()+1)) %>%
    tidyr::gather(V1,value,-rowname) %>%
    tidyr::pivot_wider(names_from = rowname,values_from=value) %>%
    return()
}

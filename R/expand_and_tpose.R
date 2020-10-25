#' expand_and_tpose
#' 
#' Background function (not user-facing).
#' 
#' Given a dataframe with at least two columns, transpose it using one column 
#' for names and another for values (defaults to 1 and 2, respectively) and 
#' duplicate into as many rows as needed.
#' 
#' @param input_frame Dataframe to be transposed.
#' @param rows_out Number of rows to expand by.
#' @param name_col Name of column containing transposed column names. Defaults to first column.
#' @param vals_col Name of column containing transposed column values. Defaults to second column.
#' 
#' @import tidyverse
#' 
#' expand_and_tpose()
#' 
#' @export

expand_and_tpose  <- function(input_frame, rows_out=10,name_col=NULL,vals_col=NULL){
  if(is.null(name_col)){name_col  <- names(input_frame)[1]}
  if(is.null(vals_col)){vals_col  <- names(input_frame)[2]}
  matrix(rep(input_frame[[vals_col]],rows_out),
         nrow=rows_out,byrow = TRUE,
         dimnames = list(NULL,input_frame[[name_col]])) %>%
    as_tibble() %>%
    return()
}

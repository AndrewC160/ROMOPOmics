#expand_and_tpose()
#Given a dataframe with at least two columns, transpose it using one column for
# names and another for values (defaults to 1 and 2, respectively) and 
# duplicate into as many rows as needed.
expand_and_tpose  <- function(input_frame, rows_out=10,name_col=NULL,vals_col=NULL){
  if(is.null(name_col)){name_col  <- names(input_frame)[1]}
  if(is.null(vals_col)){vals_col  <- names(input_frame)[2]}
  matrix(rep(input_frame[[vals_col]],rows_out),
         nrow=rows_out,byrow = TRUE,
         dimnames = list(NULL,input_frame[[name_col]])) %>%
    as_tibble() %>%
    return()
}

#' truncate_by_chars
#' 
#' Background function (not typically user-facing).
#' 
#' Convenience function for displaying things in human-readable tables. After a
#' given maximum number of characters, cut off the remainder and replace with
#' an ellipsis.
#' 
#' @param text_in Text string to be truncated.
#' @param max_char Maximum number of characters to display (including ellipses). Defaults to 80.
#' 
#' truncate_by_chars
#' 
#' @export
truncate_by_chars   <- function(text_in,max_char=80){
  return(ifelse(nchar(as.character(text_in)) <= max_char,
                      text_in,
                      paste0(substr(text_in,start = 1,stop = max_char - 3),"...")))
}

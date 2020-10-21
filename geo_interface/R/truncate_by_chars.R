#truncate_by_chars
#After a given maximum number of characters, cut off remainder and replace with
# ellipsis.

truncate_by_chars   <- function(text_in,max_char=80){
  return(ifelse(nchar(as.character(text_in)) <= max_char,
                      text_in,
                      paste0(substr(text_in,start = 1,stop = max_char - 3),"...")))
}

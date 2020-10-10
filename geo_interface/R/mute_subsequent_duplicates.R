#!/bin/Rscript
#For display table purposes; if subsequent entries are identical, blank them out.

#input_tibble  <- tibble(sample = c("apple","pear","pear","orange","orange","orange","apple"),
 #                       number = c(15,20,20,16,17,17,15),
  #                      letter = c("A","B","C","D","D","D","B"))

#input_tibble %>%
 # mutate_all(mute_duplicate_entries)

mute_subsequent_entries  <- function(vector_entries){
  a <- as.character(vector_entries)
  if(length(a) < 2) { return(a) }
  return(c(a[1],
           sapply(c(2:length(a)), function(i) ifelse(a[i] == a[i-1],"",a[i]))))
}

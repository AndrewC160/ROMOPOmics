#parse_geo_text_results
#GEO search results can be downloaded as a "text" format, and this function allows them to be parsed into a table.
parse_geo_text_results  <- function(text_file=file.path(data_dir,"ds_ids_kidney_seqencing.txt")){
  if(!file.exists(text_file)){stop(paste0("Text file specified doesn't exist:\n\t",text_file))}
  
  txt   <- scan(text_file,what=character(),sep="\n",strip.white = FALSE)
  hdrs  <- grep("^[0123456789]+\\. ",txt)
  tils  <- c(hdrs[-1]-1,length(txt))
  
  sapply(c(1:length(hdrs)), function(i){
    st  <- hdrs[i]
    en  <- tils[i]
    blk <- txt[st:en]
    return(
      c(
        dataset = str_match(blk,"Accession:[ \t]+([^ \t]+)")[,2] %>% na.omit(),
        title = unlist(str_match(blk[1],pattern="^[:digit:]+\\. (.+$)")[2]),
        description = blk[2],
        organism = str_match(blk,"Organism:[ \t]+(.+$)")[,2] %>% na.omit(),
        type = str_match(blk,"Type:[ \t]+(.+$)")[,2] %>% na.omit(),
        platform = str_extract_all(blk,"(GPL[:digit:]+)") %>% unlist() %>% paste(collapse=","),
        series = str_match(blk,"[^/](GSE[:digit:]+)")[,2] %>% na.omit(),
        #series= str_match(blk,"Series:[ \t]+([^ ]+)")[,2] %>% na.omit(),
        samples = str_match(blk,"([:digit:]+) Sample")[,2] %>% na.omit(),
        ftp = str_match(blk,"(ftp://.+$)")[,2] %>% na.omit(),
        id = str_match(blk,"ID:[ \t]+(.+)")[,2] %>% na.omit()
      ) #%>% enframe() %>% as.data.frame() %>% 
    )
  }) %>%
    as.data.frame() %>% t %>% as_tibble
}

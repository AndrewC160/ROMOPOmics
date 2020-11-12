#' parse_gse_metadata
#'
#' Background function (not typically user-facing).
#' 
#' Given a series list (GSE), parse each to generate metadata table, raw file
#' list, and retrieve the associated abstract.
#' 
#' @param gse_in GSE list, as returned by getGEO() (list of ExpressionSet S4 objects).
#' 
#' @import tidyverse
#' @import GEOquery
#' @importFrom stats setNames
#' 
#' @export

parse_gse_metadata  <- function(gse_in=NULL){
  if(is.null(gse_in)){return(NULL)}
  #Get metadata.
  ast<- abstract(gse_in)
  
  #Channels: Most series seem to have one channel.
  md  <- pData(gse_in) %>%
          as.data.frame(stringsAsFactors=FALSE) %>%
          as_tibble() %>% 
          mutate_if(is.factor,as.character) %>%
          select(-starts_with("characteristics"))
  
  #Split channel-specific details into separate frames and rbind them.
  ch_md <- md %>% 
            select(geo_accession,matches("ch[0123456789]+")) %>%
            pivot_longer(cols=!geo_accession,names_to = "detail") %>%
            mutate(channel = str_match(detail,"ch([:digit:]+)")[,2],
                   detail = gsub("[:_\\.]ch[0123456789]+","",detail)) %>% 
            pivot_wider(id_cols = c(geo_accession,channel),names_from=detail,values_from=value)
            #group_split(channel) %>%
            #lapply(function(x) pivot_wider(x,id_cols = c("geo_accession","channel"),names_from = "detail",values_from = "value")) %>%
            #do.call(rbind,.)
  #rbind one copy of each channel-independent entry per channel, then merge.
  md    <- lapply(unique(ch_md$channel), function(x) {
              md %>%
                select(!matches("ch[1234567890]+")) %>%
                mutate(channel=x)
            }) %>%
            do.call(rbind,.) %>%
            merge(ch_md) %>%
            as_tibble() %>%
  #Combine duplicated columns into one ";" separated list 
  # data_processing, data_processing.2, etc. -> data_processing
            pivot_longer(cols=!c(geo_accession,channel)) %>%
            mutate(dupe=str_match(name,"[\\._]([0123456789]+$)")[,2],
                   name=gsub("[\\._][0123456789]+$","",name)) %>%
            group_by(geo_accession,channel,name) %>%
            summarize(value = paste(value,collapse=";"),.groups="drop") %>%
            pivot_wider(id_cols = c("geo_accession","channel"),names_from=name,values_from=value) %>%
            rename_all(function(x) gsub(" ","_",x))
  r_f <- setNames(md$supplementary_file,nm=md$geo_accession)
  return(list(metadata=md,raw_files=r_f,abstract=ast))
}
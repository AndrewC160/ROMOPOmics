#' parse_geo_metadata
#' 
#' Background function (not typically user-facing).
#' 
#' Breaks metadata into a tibble of all values that apply accross all samples
#' ("all_samples"), i.e. all values that have one entry, and a tibble of all
#' metadata with multiple values ("other_values"). Also returns a text-based
#' summary of these "other values" as "other_values_txt".
#' 
#' @param geo_in GEO object as returned by getGEO() (GDS or GSE, generally).
#' 
#' @importFrom tibble rownames_to_column as_tibble 
#' @importFrom dplyr rename rowwise filter mutate ungroup select
#' @importFrom magrittr %>%
#' @importFrom GEOquery Meta
#' 
#' @export

parse_geo_metadata  <- function(geo_in=NULL){
  if(is.null(geo_in)){return(NULL)}
  #Get all metadata.
  values <- NULL
  md  <- as(Meta(geo_in),"matrix") %>%
          as.data.frame() %>%
          rownames_to_column("detail") %>%
          as_tibble() %>%
          rename(values=V1)
  #Basic metadata (one value per detail).
  md_basic  <- md %>% 
                rowwise() %>%
                filter(length(values) == 1) %>%
                mutate(values=unlist(values))
  #Complex metadata (multiple values per detail).
  md_complex<- md %>%
                rowwise() %>%
                filter(length(values) > 1)
  
  #Summary of other information
  #If < 15 entries are present in the value column, paste these into a basic
  # character string.
  len <- detail <- values <- NULL
  md_comp_text  <- md_complex %>%
                    rowwise() %>%
                    mutate(len=length(values)) %>%
                    mutate(text = ifelse(
                      len <= 15,
                      paste0("**",detail,"**\n",paste(values,collapse="\n")),
                      paste0("**",detail,"**\n",paste(head(values,3),collapse="\n"),
                             "\n[",prettyNum(len,big.mark=",")," values total]"))) %>%
                    ungroup() %>%
                    select(text) %>%
                    unlist(use.names=FALSE) %>%
                    paste(collapse="\n\n")
  metadata <- coldata <- other_values <- NULL
  if(is(geo_in,"GDS")){
    col_dat   <- parse_gds_coldata(geo_in)
    return(list(metadata= md_basic,
                coldata = col_dat,
                other_values=md_complex,
                other_values_txt=md_comp_text))
  }else{
    return(list(metadata= md_basic,
                other_values=md_complex,
                other_values_txt=md_comp_text))
  }
}

#' parse_gds_coldata
#' 
#' Background function (not typically user-facing).
#' 
#' Given a GDS object as returned from getGEO(), retrieves column data and 
#' formats for use with metadata tables, including parsing metadata values
#' based on semicolon-separated columns in the data (e.g. "source: cell type").
#' 
#' @param gds_in GDS object to be parsed, generally as returned by getGEO().
#' 
#' @importFrom GEOquery Columns
#' @importFrom tibble as_tibble
#' @importFrom dplyr rowwise mutate mutate_at ungroup group_by vars group_cols
#' @importFrom tidyr unnest separate pivot_wider
#' 
#' @export

parse_gds_coldata <- function(gds_in=NULL){
  if(is.null(gds_in)){return(NULL)}
  description <- NULL
  gds_in %>%
    Columns() %>%
    as_tibble() %>%
    rowwise() %>%
    mutate(description = 
             list(sapply(str_split(description,pattern=";",simplify = TRUE),trimws,USE.NAMES=FALSE))) %>%
    ungroup() %>%
    unnest(description) %>%
    #If no ":" present, use a generic title.
    group_by(sample) %>%
    mutate(description = ifelse(grepl(":",description),
                                description,
                                paste0("desc",row_number(),":",description))) %>%
    separate(description,into = c("desc_name","desc_value"),sep = ":") %>%
    mutate_at(vars(-group_cols()),trimws) %>%
    mutate(desc_name = gsub(" for GSM[0123456789]+","",desc_name)) %>%
    pivot_wider(names_from=desc_name,values_from=desc_value,values_fn = list(desc_value=function(x) paste(x,collapse=";")))
}
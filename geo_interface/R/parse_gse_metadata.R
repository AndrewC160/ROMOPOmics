#parse_gse_metadata

parse_gse_metadata  <- function(gse_in=NULL){
  if(is.null(gse_in)){return(NULL)}
  #Get metadata.
  ast<- abstract(gse_in)
  md <- otherInfo(experimentData(gse_in)) %>%
          enframe(name="detail",value = "values") %>%
          rowwise() %>%
          filter(length(values) == 1 & values != " ") %>%
          unnest(values)
  r_f<- as.character(gse_in$supplementary_file)
  names(r_f)  <- gse_in$geo_accession
  return(list(metadata=md,raw_files=r_f,abstract=ast))
}

#' parse_metadata
#' 
#' Background function (not typically user-facing).
#' 
#' Wrapper function for metadata parsing, since these differ between GDS/GPL 
#' and GSE types. Basically accepts either object type and passes it to the
#' appropriate function (parse_geo_metadata() vs. parse_gse_metadata()). Acts 
#' recursively if a list is provided.
#' 
#' @param object_in GEOquery object returned by getGEO() function.
#' 
#' @import GEOquery
#' 
#' @export

parse_metadata  <- function(object_in = NULL){
  #if(is.null(object_in)){return(NULL)}
  if(is(object_in,"GEOData")){
    obj_out   <- parse_geo_metadata(object_in)
  }else if(is(object_in,"ExpressionSet")){
    obj_out   <- parse_gse_metadata(object_in)
  }else if(is(object_in,"list")){
    #If a list of elements is provided, loop through recursively.
    obj_out   <- lapply(object_in,parse_metadata)
  }else{
    obj_out   <- NULL
  }
  return(obj_out)
}

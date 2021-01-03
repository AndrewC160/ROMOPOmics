#' check_geo_by_url
#' 
#' Background function (not user-facing).
#' 
#' Given a GSE or GDS ID, function builds a corresponding URL and tests it to 
#' ensure the ID is valid. Returns boolean results of "url.exists()" from RCURL
#' pacakge.
#' 
#' @param id_input Character string of GSE or GDS ID; i.e. "GSE15896".
#' 
#' @importFrom dplyr case_when
#' @importFrom RCurl url.exists
#' 
check_geo_by_url  <- function(id_input = "GSE15896"){
    url   <- case_when(
        grepl("^GSE",id_input) ~ 
            paste0("https://ftp.ncbi.nlm.nih.gov/geo/series/",
                   substr(id_input,1,nchar(id_input)-3),"nnn/GSE",
                   substr(id_input,4,stop = nchar(id_input))),
        grepl("^GDS",id_input) ~
            paste0("https://ftp.ncbi.nlm.nih.gov/geo/datasets/",
                   substr(id_input,1,nchar(id_input)-3),"nnn/GDS",
                   substr(id_input,4,stop = nchar(id_input)))
    )
    return(url.exists(url))
}

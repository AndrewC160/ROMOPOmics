#' interpret_class
#'
#' Given a character string from the default OMOP "type" column, convert that
#' to the tidyverse equivalent ("INTEGER" = "integer", "VARCHAR(x)" =
#' "character", etc.). As of now, there are no restrictions like character
#' character limits, etc.
#'
#' @param omop_def OMOP field definition to interpret.
#'
#' interpret_class()
#'
#' @import data.table
#' @import tidyverse
#'
#' @export

interpret_class     <- function(omop_def="VARCHAR(50)"){
  om_in   <- tolower(omop_def)
  case_when(grepl("^integer",om_in) ~ "integer",
            grepl("bigint",om_in) ~ "integer",
            #grepl("^date",om_in) ~ "date",
            grepl("fload",om_in) ~ "double",
            TRUE ~ "character")
}

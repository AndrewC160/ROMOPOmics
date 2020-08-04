#' buildSQLDBR
#'
#' Wrapper which uses dplyr's src_sqlite() function to create the SQLite 
#' database, and adds all OMOP-formatted tables (as produced by the function
#' combineInputTables()) to the database. Requires a list of formatted tables
#' and an output file name within which to store the SQL database.
#'
#' @param omop_tables Filesnames of all OMOP csv files to be incorporated into the database.
#' @param sql_db_file Filename under which to store the SQLite database file.
#'
#' @import tidyverse
#' @import DBI
#' @import RSQLite
#'
#' buildSQLDBR()
#'
#' @export

buildSQLDBR <- function(omop_tables,sql_db_file){
  db        <- DBI::dbConnect(RSQLite::SQLite(),sql_db_file)
  #Use na.omit() in case some NA tables get through.
  lapply(na.omit(names(omop_tables)), function(x) copy_to(db,omop_tables[[x]],name=x,overwrite = TRUE,temporary = FALSE))
  #Return the connection.
  return(db)
}


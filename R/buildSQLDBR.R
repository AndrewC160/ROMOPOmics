#' buildSQLDBR
#'
#' Wrapper which uses dplyr's src_sqlite() function to create the SQLite 
#' database, and adds all OMOP-formatted tables (as produced by the function
#' combineInputTables()) to the database. Requires a list of formatted tables.
#' If an an output file name is provided, the database file is saved in this 
#' location. Otherwise, the database file is stored in memory (equivalent to 
#' providing ":memory:" to dbConnect()).
#'
#' @param omop_tables Filesnames of all OMOP csv files to be incorporated into the database.
#' @param sql_db_file Filename under which to store the SQLite database file.
#'
#' @export
#'
#' @importFrom stats na.omit
#' @importFrom DBI dbConnect
#' @importFrom dplyr copy_to
#' @importFrom RSQLite SQLite


buildSQLDBR <- function(omop_tables,sql_db_file=":memory:"){
  db        <- dbConnect(SQLite(),sql_db_file)
  #Use na.omit() in case some NA tables get through.
  lapply(na.omit(names(omop_tables)), function(x) copy_to(db,omop_tables[[x]],name=x,overwrite = TRUE,temporary = FALSE))
  #Return the connection.
  return(db)
}


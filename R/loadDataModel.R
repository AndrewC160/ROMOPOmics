#' loadDataModel
#'
#' Function reads in a CSV file containing the definitions of a given data
#' model definitions and returns either as one table or as a list of tables. By
#' default, this function returns the OMOP data model 'OMOP_CDM_v6_0_custom.csv' 
#' included in the extdata folder of the installed ROMOPOmics package, 
#' but similarly formatted tables can be used as well as long as they are packaged as CSVs.
#'
#' @param master_table_file File containing the total data model used, including 
#' "field", "required", "type", "description", and "table" fields.
#' @param as_table_list If TRUE, return the data model split into a list of tables rather than as one solid table.
#'
#' loadDataModel
#'
#' @importFrom data.table fread
#' @import dplyr
#' @import magrittr
#'
#' @export

loadDataModel <- function(master_table_file,
                          as_table_list = FALSE){
  if(missing(master_table_file)){
    master_table_file <- system.file("extdata","OMOP_CDM_v6_0_custom.csv",package="ROMOPOmics",mustWork = TRUE)
  }
  #When reading the master table, ignore any field that is:
  # 1. A table ID.
  # 2. Ends with "_id" (these should be mapped, so maybe use them later).
  # 3. Has no alias.
  mst_tbl       <- master_table_file %>%
                    fread(header = TRUE,sep = ",") %>%
                    as_tibble()
  table_indices <- mst_tbl %>% select(table) %>% unlist(use.names=FALSE) %>% unique() %>% tolower() %>% paste0("_id")
  mst_tbl       <- mst_tbl %>%
                    mutate(table_index = field %in% table_indices)
  if(as_table_list){
    tbl_lst     <- mst_tbl %>%
                    group_by(table) %>%
                    group_split()
    names(tbl_lst)<- sapply(tbl_lst, function(x) toupper(x$table[1]))
    tbl_list    <- lapply(tbl_lst, function(x) select(x,-table))
    return(tbl_lst)
  }else{
    return(mst_tbl)
  }
}

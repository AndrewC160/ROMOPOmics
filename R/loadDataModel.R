#' Upload a common data model 
#'
#' \code{loadDataModel()} reads in a CSV file containing the definitions of a given data
#' model and returns either one table or a list of tables. By default, this function returns 
#' the OMOP data model 'OMOP_CDM_v6_0_custom.csv' at \link{https://github.com/OHDSI/CommonDataModel}.
#' We included in the extdata folder of the installed ROMOPOmics package, 
#' but similarly formatted tables can be used as well as long as they are packaged as CSVs.
#'
#' See the OMOP CDM document for more details creating a data model 
#' \link{https://github.com/OHDSI/CommonDataModel/blob/master/OMOP_CDM_v6_0.pdf}.
#' 
#' There are two requirements:
#' 1. The CDM file will have two fields 'field' and 'table'
#' 2. All entries are non-empty strings
#' 
#' Every table in the given CDM will have an associated id field 
#' where the id field is table_id, for example. It describes the unique entry in that table 
#' and serves as a foreign key to other tables. This id is created automatically within
#' the function. But, it should be included under the field 'field' so that
#' an index for this foreign key can be established. 
#' 
#' @param master_table_file File containing the total data model used, including 
#' "field", "required", "type", "description", and "table" fields.
#' @param as_table_list If TRUE, return the data model split into a list of tables 
#' rather than as one solid table.
#'
#' loadDataModel
#'
#' @importFrom data.table fread
#' @importFrom dplyr select mutate group_by group_split
#' @importFrom stringr str_to_upper
#' @importFrom tidyr as_tibble
#' @importFrom magrittr %>%
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
                    tidyr::as_tibble()
  table_indices <- mst_tbl %>% 
    dplyr::select(table) %>% unlist(use.names=FALSE) %>% unique() %>% tolower() %>% paste0("_id")
  mst_tbl       <- mst_tbl %>%
                    dplyr::mutate(table_index = field %in% table_indices)
  if(as_table_list){
    tbl_lst     <- mst_tbl %>%
                    dplyr::group_by(table) %>%
                    dplyr::group_split()
    names(tbl_lst)<- sapply(tbl_lst, function(x) stringr::str_to_upper(x$table[1]))
    tbl_list    <- lapply(tbl_lst, function(x) select(x,-table))
    return(tbl_lst)
  }else{
    return(mst_tbl)
  }
}

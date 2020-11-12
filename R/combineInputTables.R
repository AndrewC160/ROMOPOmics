#' combineInputTables
#'
#' Given a list of formatted input tables produced by readInputFiles(), this
#' function combines them into one set of data tables as specified by the data
#' model. Model tables with no entries included are dropped, and each table is
#' assigned an index based on all unique combinations of data in it. The output
#' tables are included in a named list, which is ready to be incorporated into
#' a SQLite databse.
#'
#' @param input_table_list List of tables for inclusion, typically from readInputFiles() with different masks but the same base data model.
#'
#' combineInputTables()
#'
#' @import data.table
#' @import tidyverse
#'
#' @export

combineInputTables  <- function(input_table_list){
  select <- dplyr::select
  filter <- dplyr::filter
  mutate <- dplyr::mutate
  
  #Check if only one table was included, and if so en-list it.
  if(!inherits(input_table_list,"list")){
    input_table_list<- list(input_table_list)
  }
  #Reference that includes ALL columns, including IDs and fields with identical names.
  full_tb   <- Reduce(function(x,y) merge(x,y,all=TRUE),input_table_list) %>%
                as_tibble() %>%
                dplyr::mutate(table_field = paste(table,field,sep="|")) %>%
                dplyr::select(table_field,everything())
  #Figure out used OMOP tables (those with any input fields).
  used_tbs  <- full_tb %>%
                dplyr::select(-field,-required,-type,-description,-table_index,-table_field) %>%
                dplyr::mutate(is_used=rowSums(!is.na(select(.,-table)))>0) %>%
                dplyr::filter(is_used) %>%
                dplyr::select(table) %>% unlist(use.names=FALSE) %>% unique()
  full_tb   <- dplyr::filter(full_tb,table %in% used_tbs)

  #Col_data contains all meta data for each field.
  col_data  <- dplyr::select(full_tb,table_field,field,table,required,type,description,table_index)

  #tb is a minimal tibble with a table|field column that indexes back to the full table.
  tb        <- dplyr::filter(full_tb,!table_index) %>%
                dplyr::select(table_field,
                       everything(),
                       -field,-table,-required,-type,-description,-table_index) #-set_value
  cn        <- tb$table_field
  tb        <- tb %>%
                dplyr::select(-table_field) %>%
                as.matrix() %>% t() %>%
                as_tibble(.name_repair = "minimal")
  colnames(tb)<- cn
  for(tb_name in rev(used_tbs)){
    idx_col   <- paste0(tb_name,"|",tolower(tb_name),"_id")
    flds      <- col_data %>% filter(table==tb_name,!table_index) %>% select(table_field) %>% unlist(use.names=FALSE)
    tb        <- tb %>%
      group_by_at(flds) %>%
      dplyr::mutate(!!as.name(idx_col):=cur_group_id()) %>%
      dplyr::select(!!as.name(idx_col),everything()) %>%
      ungroup()
  }

  #Return a list of formatted OMOP tables.
  tbl_lst      <- vector(mode = "list",length = length(used_tbs))
  names(tbl_lst) <- used_tbs
  for(tb_name in rev(used_tbs)){
    cd        <- filter(col_data,table==tb_name) %>%
                  arrange(!table_index)
    all_cols  <- filter(cd,!table_index) %>% select(table_field) %>% unlist(use.names=FALSE)
    idx_cols  <- cd %>% filter(table_index) %>% select(field) %>% unlist(use.names=FALSE)
    col_types <- interpret_class(cd$type)
    names(col_types)  <- cd$table_field
    tb_out    <- select(tb,ends_with(idx_cols),all_cols)
    x <- list()
    for(i in all_cols){
      #class(tb_out[[i]])<- interpret_class(filter(cd,table_field==i) %>% select(type) %>% unlist())
      x <-  c(x,interpret_class(filter(cd,table_field==i) %>% select(type) %>% unlist()))
    }
    tbl_lst[[tb_name]]  <- rename_all(tb_out,function(x) str_extract(x,"[^\\|]+$")) %>%
                            distinct()
  }
  return(tbl_lst)
}

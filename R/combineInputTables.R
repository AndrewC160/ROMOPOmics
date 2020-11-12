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
#' @importFrom data.table fread
#' @import dplyr
#' @import tidyr
#' @import stringr
#'
#' @export

combineInputTables  <- function(input_table_list){
  
  #Check if only one table was included, and if so en-list it.
  if(!inherits(input_table_list,"list")){
    input_table_list<- list(input_table_list)
  }
  #Reference that includes ALL columns, including IDs and fields with identical names.
  full_tb   <- Reduce(function(x,y) merge(x,y,all=TRUE),input_table_list) %>%
                as_tibble() %>%
                mutate(table_field = paste(table,field,sep="|")) %>%
                select(table_field,everything())
  #Figure out used OMOP tables (those with any input fields).
  used_tbs  <- full_tb %>%
                select(-field,-required,-type,-description,-table_index,-table_field) %>%
                mutate(is_used=rowSums(!is.na(select(.,-table)))>0) %>%
                filter(is_used) %>%
                select(table) %>% 
                unlist(use.names=FALSE) %>% 
                unique() %>%
                na.omit()
  full_tb   <- filter(full_tb,table %in% used_tbs)

  #col_data contains all meta data for each field.
  col_data  <- select(full_tb,table_field,field,table,required,type,description,table_index)

  #tb is a minimal tibble with a table|field column that indexes back to the full table.
  tb        <- filter(full_tb,!table_index) %>%
                select(-field,-table,-required,-type,-description,-table_index) %>%
                pivot_longer(cols = -table_field) %>%
                pivot_wider(id_cols=name,names_from = table_field,values_from=value)
  for(tb_name in rev(used_tbs)){
    idx_col   <- paste0(tb_name,"|",tolower(tb_name),"_id")
    flds      <- col_data %>% filter(table==tb_name,!table_index) %>% select(table_field) %>% unlist(use.names=FALSE)
    tb        <- tb %>%
      group_by_at(flds) %>%
      mutate(!!as.name(idx_col):=cur_group_id()) %>%
      select(!!as.name(idx_col),everything()) %>%
      ungroup()
  }
  
  tbl_lst       <- lapply(used_tbs, function(tb_nm){
    select(tb,starts_with(tb_nm)) %>%
      rename_all(function(x) str_extract(x,"[^\\|]+$")) %>%
      distinct()
  })
  names(tbl_lst)<- used_tbs
  return(tbl_lst)
}
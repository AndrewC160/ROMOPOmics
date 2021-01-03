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
#' @importFrom data.table fread merge.data.table
#' @importFrom dplyr select mutate mutate_at rename_all group_by group_by_at ungroup summarize filter arrange distinct cur_group_id vars
#' @importFrom tidyr as_tibble pivot_longer pivot_wider
#' @importFrom stringr str_extract str_to_lower
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
                pivot_longer(-table) %>%
                group_by(table) %>% 
                summarize(is_used = any(!is.na(value)),.groups="drop") %>%
                filter(is_used,!is.na(table)) %>%
                select(table) %>% 
                unlist(use.names=FALSE)
  full_tb   <- filter(full_tb,table %in% used_tbs)
  tb        <- full_tb %>%
                select(-field,-table,-required,-type,-description,-table_index) %>%
                pivot_longer(cols = -table_field) %>%
                pivot_wider(id_cols=name,names_from = table_field,values_from=value)
  #Group, sort, and index each table together.
  for(tab_nm in used_tbs){
    idx_nm  <- paste0(str_to_lower(tab_nm),"_id")
    idx_col <- paste0(tab_nm,"|",idx_nm)
    flds    <- select(tb,starts_with(tab_nm)) %>% colnames()
    tb      <- tb %>%
                group_by_at(flds) %>%
                mutate(!!as.name(idx_col):=cur_group_id()) %>%
                select(!!as.name(idx_col),everything()) %>%
                ungroup() %>%
                mutate_at(vars(ends_with(idx_nm)), function(x) unlist(select(.,idx_col))) %>%
                arrange(!!as.name(idx_col))
  }
  tbl_lst       <- lapply(used_tbs, function(tb_nm){
    select(tb,starts_with(tb_nm)) %>%
      rename_all(function(x) str_extract(x,"[^\\|]+$")) %>%
      distinct()
  })
  names(tbl_lst)<- used_tbs
  return(tbl_lst)
}

#' readInputFiles
#'
#' Given a TSV/CSV file containing a data set, that dataset's mask as formatted
#' by loadModelMask(), and the desired data model produced by loadDataModel(),
#' this function reads in that data table and funnels its fields into the 
#' appropriate tables and fields for the data model. All data tables are
#' included at this stage, including those with no entries, which allows any
#' data set produced by this function to be incorporated into the same database
#' as long as the same data model was used. As such, the output tables are
#' "exhaustive" in that no unused columns are dropped.
#'
#' @param input_file Name of a TSV file containing required alias column names.
#' @param data_model Data model being used, typically as a tibble returned by loadDataModel().
#' @param mask_table Mask contained in a tibble, typically as a tibble loaded by loadModelMask().
#'
#' readInputFiles
#'
#' @import tidyverse
#' @import data.table
#'
#' @export

readInputFiles    <- function(input_file,data_model,mask_table){
  #Get file names to append to each column.
  fl_nm   <- str_match(basename(input_file),"(.+)\\.[ct]sv$")[,2]
  #Merge input file into the full data model.
  in_tab  <- fread(input_file,header = FALSE,stringsAsFactors = FALSE) %>%
              rename_all(function(x) paste0("V",c(0:(length(x)-1)))) %>%
              rename(alias=V0) %>%
              merge(.,dplyr::select(mask_table,table,alias,field,field_idx,set_value),
                    by="alias",all.x = TRUE, all.y=TRUE) %>%
              drop_na(table) %>% 
              as_tibble() %>%
              rename_at(vars(starts_with("V")), function(x) gsub("V",fl_nm,x)) %>%
              dplyr::select(table,field,field_idx,alias,set_value,everything()) %>%
              mutate_all(function(x) ifelse(x=="",NA,x)) %>%
              select_if(function(x) !all(is.na(x)))

  #Sample column names contain the base file name as a prefix.
  col_nms <- colnames(in_tab)[grep(fl_nm,colnames(in_tab))]
  #If a set_value was provided, change all corresponding table values to that.
  set_vals<- in_tab %>% select(set_value) %>% unlist(use.names=FALSE)
  in_tab[which(!is.na(set_vals)),col_nms] <- set_vals[which(!is.na(set_vals))]

  #Expand duplicated entries into additional columns.
  out_tab   <- expand_entry_columns(table_in = in_tab)

  #The "standard table" is now the entire data model with mapped inputs, all
  # unspecified values as NA. Each individual entry is stored in unique column.
  data_model %>%
    select(table,field,required,type,description,table_index) %>% #Only keep standard cols.
    mutate(table=toupper(table)) %>%
    merge(out_tab,all=TRUE) %>%
    as_tibble() %>%
    distinct() %>%
    return()
}



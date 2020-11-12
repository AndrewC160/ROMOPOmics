#' readInputFile
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
#' @param transpose_input_table Boolean; defaults to FALSE. If TRUE, transpose tables with one row per treatment/sample to one per column.
#'
#' readInputFile
#'
#' @importFrom data.table fread
#' @import tidyverse
#'
#' @export

readInputFile <- function(input_file,data_model,mask_table,transpose_input_table=FALSE){
  #Get file names to append to each column.
  fl_nm   <- str_match(basename(input_file),"(.+)\\.[ct]sv$")[,2]
  #Merge input file into the full data model.
  if(transpose_input_table){
    in_tab<- fread(input_file,header = TRUE,stringsAsFactors = FALSE) %>%
              transpose_to_colwise()
  }else{
    in_tab<- fread(input_file,header = FALSE,stringsAsFactors = FALSE)
  }
  in_tab  <- in_tab %>%
              rename_all(function(x) paste0("V",c(0:(length(x)-1)))) %>%
              rename(alias=V0) %>%
              merge(.,select(mask_table,table,alias,field,field_idx,set_value),
                    by="alias",all.x = TRUE, all.y=TRUE) %>%
              drop_na(table) %>% 
              as_tibble() %>%
              rename_at(vars(starts_with("V")), function(x) gsub("V",fl_nm,x)) %>%
              select(table,field,field_idx,alias,set_value,everything()) %>%
              mutate_all(function(x) ifelse(x=="",NA,x)) %>%
              select_if(function(x) !all(is.na(x)))

  #Sample column names contain the base file name as a prefix.
  col_nms <- colnames(in_tab)[grep(fl_nm,colnames(in_tab))]
  
  #If a set_value was provided, change all corresponding table values to that.
  if("set_value" %in% colnames(in_tab)){
    set_vals<- in_tab %>% select(set_value) %>% unlist(use.names=FALSE)
    in_tab[which(!is.na(set_vals)),col_nms] <- set_vals[which(!is.na(set_vals))]
  }

  #Expand duplicated entries into additional columns.
  out_tab   <- expand_entry_columns(table_in = in_tab)
  out_tab$table <- out_tab$table %>% toupper()
  
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



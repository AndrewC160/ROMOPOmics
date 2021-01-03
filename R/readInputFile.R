#' expand_entry_columns
#' 
#' Function is similar to dplyr::unnest() on all fields that are used more than
#' once (assigned a field_idx), but ensures that new columns also contain all 
#' common field entries (for instance, if the field 'value_as_number' is used 
#' twice, both indices are given a column, but both columns should feature 
#' "patient_name" and "gender_source_value".
#' 
#' @param table_in Table to be expanded, generally intermediate format within readInputFiles().
#' 
#' expand_entry_columns()
#' 
#' @importFrom stats na.omit
#' @importFrom dplyr select filter mutate
#' @importFrom tidyr pivot_wider
#' @importFrom magrittr %>%
expand_entry_columns  <- function(table_in){
  table <- field <- field_idx <- NULL
  #If no index values are provided, just strip the field_index and return.
  if(all(is.na(table_in$field_idx))){return(select(table_in,-field_idx))}
  
  #If index values ARE provided, rbind a duplicate table for each possible set
  # value (if sets 1:3 are present, rbind 3 tables). This maintains each input
  # value. Next, pivot_wider() using the field index
  col_nms   <- colnames(table_in)[!colnames(table_in) %in% c("table","field","field_idx","alias","set_value")]
  lapply(unique(na.omit(table_in$field_idx)), 
         function(x) {
           table_in %>%
             filter(is.na(field_idx) | field_idx == x) %>%
             mutate(field_idx = x)}) %>%
    do.call(rbind,.) %>%
    pivot_wider(id_cols =  c(table,field),
                names_from = field_idx,
                values_from = col_nms) %>%
    return()
}


#' switch columns and rows of (transpose) data table
#' 
#' If an input data set is arranged in a rowwise fashion (one row per patient),
#' use \code{transpose_to_colwise()} transposes this data.
#' 
#' @param input_tibble Any tibble (no rownames, obviously).
#' 
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom dplyr mutate mutate_all
#' @importFrom magrittr %>%
transpose_to_colwise  <- function(input_tibble){
  input_tibble %>%
    mutate(rowname=paste0("V",row_number()+1)) %>%
    mutate_all(as.character) %>%
    pivot_longer(-rowname) %>%
    pivot_wider(names_from = rowname,values_from=value) %>%
    return()
}

#' Convert input data to OMOP formated data via CDM and mask
#'
#' \code{readInputFile()} takes a TSV/CSV file containing an input data set 
#' to be converted to the common data model format, that dataset's mask as formatted
#' by loadModelMask(), and the desired data model produced by loadDataModel().
#' This function reads in that data table and funnels its fields into the 
#' appropriate tables and fields for the data model. All data tables are
#' included at this stage, including those with no entries, which allows any
#' data set produced by this function to be incorporated into the same database
#' as long as the same data model was used. As such, the output tables are
#' "exhaustive" in that no unused columns are dropped.
#'
#' @param input_file Name of a TSV/CSV file containing required alias column names.
#' @param data_model Data model being used, typically as a tibble returned by loadDataModel().
#' @param mask_table Mask contained in a tibble, typically as a tibble loaded by loadModelMask().
#' @param transpose_input_table Boolean; defaults to FALSE. If TRUE, transpose tables with one row per treatment/sample to one per column.
#'
#' readInputFile()
#'
#' @importFrom data.table fread merge.data.table
#' @importFrom dplyr rename rename_all rename_at select_if select distinct
#' @importFrom tidyr drop_na as_tibble
#' @importFrom stringr str_match str_to_upper
#' @importFrom magrittr %>%
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
  table <- alias <- field <- field_idx <- set_value <- NULL
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
  out_tab$table <- out_tab$table %>% str_to_upper()
  
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



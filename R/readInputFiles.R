#' readInputFiles
#'
#' Function reads in TSV files designed with a given mask in mind, with rows
#' for each field and table combination and columns for input data entries.
#' Output is an "exhaustive" table including all fields and tables from the
#' specified data model, including unused tables and fields.
#'
#' @param input_file Name of a TSV file containing required alias column names.
#' @param data_model Data model being used, typically as a tibble returned by loadDataModel().
#' @param mask_table Mask contained in a tibble, typically as a tibble loaded by loadModelMask().
#'
#' readInputFiles
#'
#' @import tibble
#' @import data.table
#' @import magrittr
#'
#' @export

readInputFiles    <- function(input_file,data_model,mask_table){
  #Get file names to append to each column.
  fl_nm   <- str_match(basename(input_file),"(.+)\\.[ct]sv$")[,2]
  #Merge input file into the full data model.
  in_tab  <- fread(input_file,header = FALSE,stringsAsFactors = FALSE) %>%
              rename_all(function(x) paste0("V",c(0:(length(x)-1)))) %>%
              rename(alias=V0) %>%
              merge(.,select(mask_table,table,alias,field,field_idx,set_value),all.x = TRUE, all.y=TRUE) %>%
              as_tibble() %>%
              rename_at(vars(starts_with("V")), function(x) gsub("V",fl_nm,x)) %>%
              select(table,field,field_idx,alias,set_value,everything()) %>%
              mutate_all(function(x) ifelse(x=="",NA,x)) %>%
              select_if(function(x) !all(is.na(x)))

  #Sample column names contain the base file name as a prefix.
  col_nms <- colnames(in_tab)[grep(fl_nm,colnames(in_tab))]
  #If a set_value was provided, change all corresponding table values to that.
  set_vals<- in_tab %>% select(set_value) %>% unlist(use.names=FALSE)
  in_tab[which(!is.na(set_vals)),col_nms] <- set_vals[which(!is.na(set_vals))]

  #Expand duplicated entries into additional columns.
  out_tab   <- expand_entry_columns(table_in = in_tab)

  #The "standard table" now is the entire data model with mapped inputs, all
  # unspecified values as NA. Each individual entry is stored in unique column.
  data_model %>%
    select(table,field,required,type,description,table_index) %>% #Only keep standard cols.
    mutate(table=toupper(table)) %>%
    merge(out_tab,all=TRUE) %>%
    as_tibble() %>%
    distinct() %>%
    return()
}



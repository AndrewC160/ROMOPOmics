#!/bin/Rscript
#Convert column of lists into a drop-down box.


dropdown_table  <- function(table_in,input_prefix="sel",input_width = "500px",callback_text=FALSE){
#https://stackoverflow.com/questions/57215607/render-dropdown-for-single-column-in-dt-shiny
  #For now it looks like callback text needs to be included separately, so "callback_text=TRUE"
  # just returns the Java script for that.
  if(callback_text){
    return("table.rows().every(function(i, tab, row) {
             var $this = $(this.node());
             $this.attr('id', this.data()[0]);
             $this.addClass('shiny-input-container');
           });
           Shiny.unbindAll(table.table().node());
           Shiny.bindAll(table.table().node());")
  }
  tib   <- rowwise(table_in)
  list_cols   <- colnames(tib)[which(sapply(c(1:ncol(tib)), function(x) class(tib[[x]])) == "list")]
  
  for(col_nm in list_cols){
   tib  <- mutate(tib,!!as.name(col_nm) := as.character(
            selectInput(inputId = paste0(input_prefix,col_nm,"row",row_number()),
                        label=NULL,width=input_width,selected = 1,multiple = FALSE,
                        choices = !!as.name(col_nm))))
  }
  return(tib)
}

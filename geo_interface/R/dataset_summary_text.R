#dataset_summary_text
#Function returns a text blurb summarizing GEO objects (file names, sizes, 
# table dimensions, etc.) for datasets, their platform, and their samples.

dataset_summary_text  <- function(gds_acc = '',geo_data=NULL){
                                  #gds_obj = NULL,
                                  #gpl_obj = NULL,
                                  #gse_obj = NULL){
  separator <- paste(rep("-",30),collapse="")
  if(!is.null(geo_data$GDS$metadata)){
    geo_ttl     <- geo_data$GDS$GDS@header$title
    geo_fl_nm   <- Sys.glob(paste0(dirs$data,"/",gds_acc,".soft.gz"))
    geo_fl_sz   <- hsize(file.size(geo_fl_nm))
    geo_ob_sz   <- hsize(object.size(geo_data$GDS$GDS))
    geo_tbl_dim <- dim(Table(geo_data$GDS$GDS))
    
    paste(sep="\n",
      separator,
      paste("GEO Dataset"),
      separator,
      paste("Title:",geo_ttl),
      paste("Accession:",gds_acc),
      paste("File location:",geo_fl_nm),
      paste("File size:",geo_fl_sz),
      paste("Object size:",geo_ob_sz),
      paste("Data table dimensions:",
        paste(collapse=" x ",sapply(geo_tbl_dim,prettyNum,big.mark=",")))
    ) -> gds_txt
  }else{
    gds_txt <- NULL
  }
  if(!is.null(geo_data$GPL)){
    gpl_nm      <- geo_data$GPL$GPL@header$geo_accession
    gpl_fl_nm   <- Sys.glob(paste0(dirs$data,"/",geo_data$GPL$GPL@header$geo_accession,".soft"))
    gpl_fl_sz   <- hsize(file.size(gpl_fl_nm))
    gpl_ob_sz   <- hsize(object.size(geo_data$GPL$GPL))
    gpl_tbl_dim <- dim(Table(geo_data$GPL$GPL))
    
    paste(sep="\n",
      separator,
      paste("GEO Platform"),
      separator,
      paste("Title:",gpl_obj@header$title),
      paste("Accession: ",gpl_nm),
      paste("File location:",gpl_fl_nm),
      paste("File size:",gpl_fl_sz),
      paste("Object size:",gpl_ob_sz),
      paste("Data table dimensions:",
        paste(collapse=" x ",sapply(gpl_tbl_dim,prettyNum,big.mark=",")))
    ) -> gpl_txt
  }else{
    gpl_txt   <- NULL
  }
  if(!is.null(geo_data$GSE)){
    gse_txt   <- lapply(names(geo_data$GSE$metadata), function(nm) {
      x <- geo_data$GSE$GSE[[nm]]
      smps    <- ncol(exprs(x))
      ob_ttl  <- experimentData(x)@title
      fl_nm   <- paste0(dirs$data,"/",nm)
      fl_sz   <- hsize(file.size(fl_nm))
      ob_sz   <- hsize(object.size(x))
      tbl_dim <- dim(exprs(x))
      
      paste(sep="\n",
            nm,
            ob_ttl,
            paste("Samples:",prettyNum(smps,big.mark=",")),
            paste("File location:",fl_nm),
            paste("File size: ",fl_sz),
            paste("ES size: ",ob_sz),
            paste("Data table dimensions: ",paste(sapply(tbl_dim,prettyNum,big.mark=","),collapse=" x "))) %>%
        return()
    })
    gse_txt   <- paste0(separator,"\nGEO Series [x",length(gse_obj),"]\n",separator,"\n",paste(gse_txt,collapse="\n\n"))
  }else{
    gse_txt   <- NULL
  }
  return(paste(gds_txt,gpl_txt,gse_txt,sep="\n\n"))
}

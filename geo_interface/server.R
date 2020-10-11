server  <- function(input, output,session) {
  gds_nam <- reactiveVal("") #Name of DataSet (accession)
  geo_data<- reactiveVal(NULL)
  #gds_val <- reactiveVal(NULL) #DataSet object.
  #gpl_val <- reactiveVal(NULL) #Platform object.
  #gse_val <- reactiveVal(NULL) #Series object.
  #gsm_val <- reactiveVal(NULL) #Sample object.
  #gds_md_val  <- reactiveVal(NULL) #Metadata for dataset.
  #gpl_md_val  <- reactiveVal(NULL) #Metadata for platform.
  #gse_md_val  <- reactiveVal(NULL) #Metadata for series.
  #gsm_cl_val  <- reactiveVal(NULL) #Column information for sample summary.
  #cmp_md_tbl  <- reactiveVal(NULL) #Compiled sample table.
  
  observeEvent(input$txt_geo_id,
               handlerExpr = {
    #Enable/disable Fetch button if dataset value entered (GDSnnn) AND value is different from gds_nam().
    if(input$txt_geo_id != gds_nam() & str_detect(input$txt_geo_id,pattern = "^GDS[:digit:]{3}$")){
      enable("btn_geo_submit")
    }else{
      disable("btn_geo_submit")
    }
  })
  observeEvent(input$btn_geo_submit,
               handlerExpr = {
    #Clear current data entries.
    gds_nam("")
    geo_data(NULL)
    #gds_val(NULL)
    #gds_md_val(NULL)
    #gpl_val(NULL)
    #gpl_md_val(NULL)
    #gse_val(NULL)
    #gse_md_val(NULL)
    #gsm_cl_val(NULL)
    #cmp_md_tbl(NULL)
    
    #Purge dynamic stuff from output.
    del_idx <- names(output)
    del_idx <- del_idx[grep("^dyn",del_idx)]
    for(idx in del_idx){
      output[[idx]] <- NULL
    }
    html("datasetTitle",paste0("<h4></h4>"),add=FALSE)
    html("sampleTitle", paste0("<h4></h4>"),add=FALSE)
    html("platformTitle",paste0("<h4></h4>"),add=FALSE)
    
    #Make sure URL to dataset exists before using getGEO() (tryCatch seems to fail in Shiny...).
    # Append GDS to base URL so that URL fails without numeric component (GDSnnn/ ending returns a valid URL).
    gds_nam(input$txt_geo_id)
    url <- paste0("https://ftp.ncbi.nlm.nih.gov/geo/datasets/GDSnnn/GDS",
                  substr(gds_nam(),start = 4,stop = nchar(gds_nam())))
    if(!url.exists(url)){
      updateTextInput(session = session,inputId = "txt_geo_id",value = paste0(gds_nam()," [Not found]"))
    }else{
      geo_data(fetch_geo_dataset(geo_dataset_id = gds_nam()))
#gds_val(getGEO(gds_nam(),destdir=dirs$data))
#gpl_val(getGEO(Meta(gds_val())$platform,destdir=dirs$data))
#gse_val(getGEO(gds_val()@header$reference_series,destdir=dirs$data))
      
      #Generate tables.
      #gds_val(geo$GDS$GDS)
      #gpl_val(geo$GPL$GPL)
      #gse_val(geo$GSE$GSE)
      #gds_md_val(geo$GDS$metadata)
      #gpl_md_val(geo$GPL$metadata)
      #gse_md_val(geo$GSE$metadata)
      #gsm_cl_val(gds_md_val()$coldata)
      #cmp_md_tbl(composite_sample_data())
      
      #Update UI/output elements.
      if(!is.null(gds_val())){
        html("datasetTitle",paste0("<h4>",geo_data()$GDS$GDS@header$title,"</h4>"),add=FALSE)
        html("sampleTitle", paste0("<h4>Samples (",prettyNum(nrow(geo_data()$GDS$GDS@dataTable@columns),big.mark=","),")</h4>"),add=FALSE)
      }
      if(!is.null(gpl_val())){
        html("platformTitle",paste0("<h4>",geo_data()$GPL$GPL@header$title,"</h4>"),add=FALSE)
      }
      #Output elements for Series.
      for(nm in names(geo_data()$GSE$metadata)){
        abstrct   <- geo_data()$GSE$metadata[[nm]]$abstract
        md        <- geo_data()$GSE$metadata[[nm]]$metadata
        r_f       <- geo_data()$GSE$metadata[[nm]]$raw_files
        output[[paste0("dyn_txt_abs_",nm)]] <- renderText(paste(strwrap(abstrct),collapse = "\n"))
        output[[paste0("dyn_tbl_",nm)]]     <- renderDataTable(md,escape = FALSE, selection = 'none', server = FALSE,
                                                options = list(dom = 't', paging = FALSE, ordering = FALSE,scrollX=TRUE))
        output[[paste0("dyn_txt_",nm)]]     <- renderText(paste("Raw files:",paste(r_f,collapse="\n"),sep = "\n"))
      }
    }
  })
  output$txt_cache_summary<- renderText(expr={
    dataset_summary_text(gds_acc = gds_nam(),geo_data = geo_data())
  })
  output$tbl_gds_metadata <- renderDataTable(geo_data()$GDS$metadata$metadata,
                                             escape = FALSE, selection = 'none', server = FALSE,
                                             options = list(dom = 't',paging = FALSE,ordering = FALSE,scrollX=TRUE))
  output$txt_gds_metadata <- renderText(geo_data()$GDS$metadata$other_values_txt)
  output$tbl_gpl_metadata <- renderDataTable(geo_data()$GPL$metadata$metadata,
                                             escape = FALSE, selection = 'none', server = FALSE,
                                             options = list(dom = 't', paging = FALSE, 
                                                            ordering = FALSE, scrollX=TRUE,rownames=FALSE))
  output$txt_gpl_other  <- renderText(geo_data()$GPL$metadata$other_values_txt)
  output$uiSeriesTabs   <- renderUI({
    #Whenever gse_val() updates, change UI to reflect it.
    if(is.null(geo_data()$GSE)){
      return(NULL)
    }else{
      lapply(names(geo_data()$GSE$metadata), function(nm) {
        tabPanel(title = nm,
                 h3(nm),
                 h4("Abstract:"),
                 verbatimTextOutput(paste0("dyn_txt_abs_",nm)),
                 dataTableOutput(paste0("dyn_tbl_",nm)),
                 verbatimTextOutput(paste0("dyn_txt_",nm)))
      }) %>% do.call(tabsetPanel,.)
    }
  })
  output$tbl_gsm_coldata  <- renderDataTable(geo_data()$GDS$metadata$coldata,
                                             escape = FALSE, selection = 'none', server = FALSE,
                                             options = list(dom = 't', paging = FALSE, ordering = FALSE,scrollX=TRUE,rownames=FALSE))
}
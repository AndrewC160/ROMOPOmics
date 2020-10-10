server  <- function(input, output,session) {
  gds_nam <- reactiveVal("") #Name of DataSet (accession)
  gds_val <- reactiveVal(NULL) #DataSet object.
  gpl_val <- reactiveVal(NULL) #Platform object.
  gse_val <- reactiveVal(NULL) #Series object.
  gsm_val <- reactiveVal(NULL) #Sample object.
  gds_md_val  <- reactiveVal(NULL) #Metadata for dataset.
  gpl_md_val  <- reactiveVal(NULL) #Metadata for platform.
  gse_md_val  <- reactiveVal(NULL) #Metadata for series.
  gsm_cl_val  <- reactiveVal(NULL) #Column information for sample summary.
  cmp_md_tbl  <- reactiveVal(NULL) #Compiled sample table.
  
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
    gds_val(NULL)
    gds_md_val(NULL)
    gpl_val(NULL)
    gpl_md_val(NULL)
    gse_val(NULL)
    gse_md_val(NULL)
    gsm_cl_val(NULL)
    cmp_md_tbl(NULL)
    
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
      gds_val(getGEO(gds_nam(),destdir=dirs$data))
      gpl_val(getGEO(Meta(gds_val())$platform,destdir=dirs$data))
      gse_val(getGEO(gds_val()@header$reference_series,destdir=dirs$data))
      
      #Generate tables.
      gds_md_val(parse_metadata(gds_val()))
      gpl_md_val(parse_metadata(gpl_val()))
      gse_md_val(parse_metadata(gse_val()))
      gsm_cl_val(gds_md_val()$coldata)
      #cmp_md_tbl(composite_sample_data())
      
      #Update UI/output elements.
      if(!is.null(gds_val())){
        html("datasetTitle",paste0("<h4>",gds_val()@header$title,"</h4>"),add=FALSE)
        html("sampleTitle", paste0("<h4>Samples (",prettyNum(nrow(gds_val()@dataTable@columns),big.mark=","),")</h4>"),add=FALSE)
      }
      if(!is.null(gpl_val())){
        html("platformTitle",paste0("<h4>",gpl_val()@header$title,"</h4>"),add=FALSE)
      }
      #Output elements for Series.
      for(nm in names(gse_md_val())){
        abstrct   <- gse_md_val()[[nm]]$abstract
        md        <- gse_md_val()[[nm]]$metadata
        r_f       <- gse_md_val()[[nm]]$raw_files
        output[[paste0("dyn_txt_abs_",nm)]] <- renderText(paste(strwrap(abstrct),collapse = "\n"))
        output[[paste0("dyn_tbl_",nm)]]     <- renderDataTable(md,escape = FALSE, selection = 'none', server = FALSE,
                                                options = list(dom = 't', paging = FALSE, ordering = FALSE,scrollX=TRUE))
        output[[paste0("dyn_txt_",nm)]]     <- renderText(paste("Raw files:",paste(r_f,collapse="\n"),sep = "\n"))
      }
    }
  })
  output$txt_cache_summary<- renderText(expr={
    dataset_summary_text(gds_acc = gds_nam(),gds_obj = gds_val(),gpl_obj = gpl_val(),gse_obj = gse_val())
  })
  output$tbl_gds_metadata <- renderDataTable(gds_md_val()$metadata,
                                             escape = FALSE, selection = 'none', server = FALSE,
                                             options = list(dom = 't',paging = FALSE,ordering = FALSE,scrollX=TRUE))
  output$txt_gds_metadata <- renderText(gds_md_val()$other_values_txt)
  output$tbl_gpl_metadata <- renderDataTable(gpl_md_val()$metadata,
                                             escape = FALSE, selection = 'none', server = FALSE,
                                             options = list(dom = 't', paging = FALSE, 
                                                            ordering = FALSE, scrollX=TRUE,rownames=FALSE))
  output$txt_gpl_other  <- renderText(gpl_md_val()$other_values_txt)
  output$uiSeriesTabs   <- renderUI({
    #Whenever gse_val() updates, change UI to reflect it.
    if(is.null(gse_val())){
      return(NULL)
    }else{
      lapply(names(gse_val()), function(nm) {
        tabPanel(title = nm,
                 h3(nm),
                 h4("Abstract:"),
                 verbatimTextOutput(paste0("dyn_txt_abs_",nm)),
                 dataTableOutput(paste0("dyn_tbl_",nm)),
                 verbatimTextOutput(paste0("dyn_txt_",nm)))
      }) %>% do.call(tabsetPanel,.)
    }
  })
  output$tbl_gsm_coldata  <- renderDataTable(gsm_cl_val(),
                                             escape = FALSE, selection = 'none', server = FALSE,
                                             options = list(dom = 't', paging = FALSE, ordering = FALSE,scrollX=TRUE,rownames=FALSE))
}
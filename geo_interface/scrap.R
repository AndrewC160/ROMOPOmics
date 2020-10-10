#Scrap functions
output$tbl_geo_metadata <- renderDataTable(escape = FALSE, selection = 'none', server = FALSE,
                                           options= list(dom = 't', paging = FALSE, ordering = FALSE,scrollX=TRUE),
                                           expr = dropdown_table(table_in = 
                                                                   as(Meta(geo_val()),"matrix") %>% 
                                                                   as.data.frame() %>%
                                                                   rownames_to_column("detail") %>%
                                                                   as_tibble() %>%
                                                                   rename(Values = V1),input_prefix = "sel_meta"),
                                           callback = JS(dropdown_table(callback_text=TRUE)))


output$tbl_geo_coldata  <- renderDataTable(escape = FALSE, selection = 'none', server = FALSE,
                                           options = list(dom = 't', paging = FALSE, ordering = FALSE,scrollX=TRUE),
                                           expr = dropdown_table(table_in = get_geo_coldata(geo_val())),
                                           callback = 
                                             JS(dropdown_table(callback_text=TRUE)))




parse_gse_metadata  <- function(gse_in=NULL){
  if(is.null(gse_in)){return(NULL)}
  #Get metadata.
  lapply(gse_in, function(x){
    ast<- abstract(x)
    md <- otherInfo(experimentData(x)) %>%
      enframe(name="detail",value = "values") %>%
      rowwise() %>%
      filter(length(values) == 1 & values != " ") %>%
      unnest(values)
    r_f<- as.character(x$supplementary_file)
    names(r_f)  <- x$geo_accession
    return(list(all_samples=md,raw_files=r_f,abstract=ast))
  }) -> gse_out
  
  return(list(metadata = lapply(gse_out, function(x) x$all_samples),
              raw_files= lapply(gse_out, function(x) x$raw_files),
              abstracts= lapply(gse_out, function(x) x$abstract)))
}

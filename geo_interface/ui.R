ui <- fluidPage(
  useShinyjs(),  
  titlePanel("Gene Expression Omnibus importer"), 
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        column(8,textInput("txt_geo_id",label = "GEO DataSet ID (GDSnnn)",value = NULL,placeholder = "DataSets only, e.g. GDS507")),
        column(4,actionButton("btn_geo_submit",label = "Fetch",icon = icon(name="dog"),style = "margin-top: 25px;"))
      ),
      verbatimTextOutput("txt_cache_summary")
    ),
    mainPanel(
      tabsetPanel(
      #Dataset tab
        tabPanel("DataSet",icon = icon("hdd"),
          p(id = "datasetTitle",h4("")),
          dataTableOutput("tbl_gds_metadata")
        ),
      #Platform tab.
        tabPanel("Platform",icon=icon("microscope"),
          p(id = "platformTitle",h4("")),
          dataTableOutput("tbl_gpl_metadata"),
          h4("Other info"),
          verbatimTextOutput("txt_gpl_other")
        ),
      #Series tab.
        tabPanel("Series", icon =icon("box"),
          uiOutput("uiSeriesTabs")
        ),
      #Sample tab.
        tabPanel("Samples", icon=icon("vials"),
          p(id = "sampleTitle",h4("")),
          dataTableOutput("tbl_gsm_coldata")
        ),
      #Composite tab.
        tabPanel("Composite",icon=icon("object-group"),
          p(id = "compositeTitle",h4("")),
          dataTableOutput("tbl_meta_table")
        ),
      #Mask tab.
        tabPanel("Mask",icon=icon("mask"))
      )
    )
  )
)


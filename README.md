---
title: "ROMOPOmics - An OMOPOmics R package"
date: "13 December, 2020"
output:
  html_document:
    keep_md: yes
  github_document: default
---



# ROMOPOmics

## Installation


```r
devtools::install_github("AndrewC160/ROMOPomics",force=T) #for installation reference and not run
```

## Description

ROMOPOmics standardizes metadata of high throughput assays with associated patient clinical data. Our package ROMOPOmics provides a framework to standardize these datasets and a pipeline to convert this information into a SQL-friendly database that is easily accessed by users. After installation of our R package from the github repository, users specify a data directory and a mask file describing how to map their data's fields into a common data model. The resulting standardized data tables are then formatted into a SQLite database for easily interoperating and sharing the dataset.

<div class="figure" style="text-align: center">
<img src="man/figures/romopomics_code_flow.png" alt="Flow chart of essential functions for a basic ROMOPOmics implementation using two different input datasets." width="100%" />
<p class="caption">Flow chart of essential functions for a basic ROMOPOmics implementation using two different input datasets.</p>
</div>

## Package overview

See our vignette [ROMOPOmics](vignettes/ROMOPOmics.Rmd)

## Use Cases


```r
library(ROMOPOmics)
```

### TCGA data


```r
dirs          <- list()
dirs$base     <- file.path(rprojroot::find_root(criterion = rprojroot::criteria$is_r_package))
dirs$figs     <- file.path(dirs$base,"man/figures")
dirs$demo     <- file.path(dirs$base,"demo")
dirs$data     <- file.path(dirs$demo,"data")
dirs$masks    <- file.path(dirs$demo,"masks")
dm_file     <- system.file("extdata","OMOP_CDM_v6_0_custom.csv",package="ROMOPOmics",mustWork = TRUE)
dm          <- loadDataModel(master_table_file = dm_file)
tcga_files  <- list(brca_clinical=file.path(dirs$data,"brca_clinical.csv"),
                    brca_mutation=file.path(dirs$data,"brca_mutation.csv"))
msks        <- list(brca_clinical=loadModelMasks(file.path(dirs$masks,"brca_clinical_mask.tsv")),
                    brca_mutation=loadModelMasks(file.path(dirs$masks,"brca_mutation_mask.tsv")))
omop_inputs <- list(brca_clinical=readInputFile(input_file = tcga_files$brca_clinical,
                                                 data_model = dm,
                                                 mask_table = msks$brca_clinical),
                    brca_mutation=readInputFile(input_file = tcga_files$brca_mutation,
                                                 data_model = dm,
                                                 mask_table = msks$brca_mutation))
db_inputs   <- combineInputTables(input_table_list = omop_inputs)
omop_db     <- buildSQLDBR(omop_tables = db_inputs,file.path(dirs$data,"TCGA.sqlite"))
DBI::dbListTables(omop_db)
```

```
## [1] "COHORT"       "MEASUREMENT"  "OBSERVATION"  "PERSON"       "PROVIDER"    
## [6] "SEQUENCING"   "SPECIMEN"     "sqlite_stat1" "sqlite_stat4"
```

### ATAC-seq data


```r
dm_file     <- system.file("extdata","OMOP_CDM_v6_0_custom.csv",package="ROMOPOmics",mustWork = TRUE)
dm          <- loadDataModel(master_table_file = dm_file)

msk_file    <- file.path(dirs$masks,"GSE60682_standard_mask.tsv")
msks        <- loadModelMasks(msk_file)

in_file     <- file.path(dirs$data,"GSE60682_standard.tsv")
omop_inputs <- readInputFile(input_file=in_file,data_model=dm,mask_table=msks,transpose_input_table = TRUE)
db_inputs   <- combineInputTables(input_table_list = omop_inputs)
omop_db     <- buildSQLDBR(omop_tables = db_inputs, sql_db_file=file.path(dirs$data,"GSE60682_sqlDB.sqlite"))
DBI::dbListTables(omop_db)
```

```
## [1] "CONDITION_OCCURRENCE" "DRUG_EXPOSURE"        "PERSON"              
## [4] "PROVIDER"             "SEQUENCING"           "SPECIMEN"            
## [7] "sqlite_stat1"         "sqlite_stat4"
```

### GEO accessions from Stevens et al. 2013


```r
library(Biobase)

gse_ids <- c("GSE9006", "GSE26440", "GSE11504", "TABM666", "GSE6011", "GSE37721", "GSE20307", "GSE20436")

stevens_gse_lst <- fetch_geo_series(gse_ids,data_dir = "data/")

stevens_gse_lst$merged_metadata
```

```
## # A tibble: 683 x 96
##    sample gse_channel gse_channel_cou… gse_contact_add… gse_contact_city
##    <chr>  <chr>       <chr>            <chr>            <chr>           
##  1 GSM13… 1           1                Westplein 11     rotterdam       
##  2 GSM13… 1           1                Westplein 11     rotterdam       
##  3 GSM13… 1           1                Westplein 11     rotterdam       
##  4 GSM13… 1           1                Westplein 11     rotterdam       
##  5 GSM13… 1           1                Westplein 11     rotterdam       
##  6 GSM13… 1           1                Westplein 11     rotterdam       
##  7 GSM13… 1           1                Westplein 11     rotterdam       
##  8 GSM13… 1           1                Westplein 11     rotterdam       
##  9 GSM13… 1           1                Westplein 11     rotterdam       
## 10 GSM13… 1           1                Westplein 11     rotterdam       
## # … with 673 more rows, and 91 more variables: gse_contact_country <chr>,
## #   gse_contact_email <chr>, gse_contact_institute <chr>,
## #   gse_contact_name <chr>, `gse_contact_zip/postal_code` <chr>,
## #   gse_data_processing <chr>, gse_data_row_count <chr>, gse_description <chr>,
## #   gse_extract_protocol <chr>, gse_hyb_protocol <chr>, gse_label <chr>,
## #   gse_label_protocol <chr>, gse_last_update_date <chr>, gse_molecule <chr>,
## #   gse_organism <chr>, gse_platform_id <chr>, gse_scan_protocol <chr>,
## #   gse_source_name <chr>, gse_status <chr>, gse_submission_date <chr>,
## #   gse_supplementary_file <chr>, gse_taxid <chr>, gse_title <chr>,
## #   gse_type <chr>, gse_id <chr>, gpl_contact_address <chr>,
## #   gpl_contact_city <chr>, gpl_contact_country <chr>, gpl_contact_email <chr>,
## #   gpl_contact_institute <chr>, gpl_contact_name <chr>,
## #   gpl_contact_phone <chr>, gpl_contact_state <chr>,
## #   gpl_contact_web_link <chr>, `gpl_contact_zip/postal_code` <chr>,
## #   gpl_data_row_count <chr>, gpl_distribution <chr>, gpl_geo_accession <chr>,
## #   gpl_last_update_date <chr>, gpl_manufacturer <chr>, gpl_organism <chr>,
## #   gpl_status <chr>, gpl_submission_date <chr>, gpl_taxid <chr>,
## #   gpl_technology <chr>, gpl_title <chr>, gds_id <chr>,
## #   gse_contact_department <chr>, gse_contact_phone <chr>,
## #   gse_contact_laboratory <chr>, gse_tissue <chr>,
## #   gse_treatment_protocol <chr>, gse_age <chr>, gse_contact_state <chr>,
## #   gse_relation <chr>, gse_group <chr>, gse_sex <chr>, gse_Sex <chr>,
## #   gse_Age <chr>, gse_contact_fax <chr>, gse_Ethnicity <chr>,
## #   gse_Gender <chr>, gse_Illness <chr>,
## #   `gse_pH<7.30_at_time_of_diagnosis` <chr>, gse_Race <chr>,
## #   gse_Treatment <chr>, `gse_age_(years)` <chr>, gse_disease_state <chr>,
## #   gse_outcome <chr>, `gse_age_(in_years)` <chr>,
## #   gse_number_of_replicates <chr>, `gse_race/ethnicity` <chr>,
## #   gpl_manufacture_protocol <chr>, gpl_relation <chr>,
## #   gpl_supplementary_file <chr>, gse_age_at_onset <chr>, gse_cell_type <chr>,
## #   `gse_fstl-1_(ng/ml)` <chr>, gse_original_diagnosis <chr>,
## #   gse_prototype <chr>, gse_race <chr>, gse_ttf <chr>,
## #   gse_updated_diagnosis <chr>, gse_disease <chr>,
## #   gse_equivalent_who_simplified_trachoma_score <chr>, gse_ethnicity <chr>,
## #   gse_fpc_trachoma_score <chr>, gse_gender <chr>, gse_growth_protocol <chr>,
## #   gse_ompa_copies_per_swab <chr>, `gse_roche_ct/ng_pcr_amplicor_value` <chr>
```


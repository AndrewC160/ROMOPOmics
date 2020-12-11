---
title: "ROMOPOmics - An OMOPOmics R package"
date: "10 December, 2020"
output:
  html_document:
    toc: true
    keep_md: yes
    print_df: paged
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

```
## Setting options('download.file.method.GEOquery'='auto')
```

```
## Setting options('GEOquery.inmemory.gpl'=FALSE)
```

```
## Warning: replacing previous import 'RCurl::complete' by 'tidyr::complete' when
## loading 'ROMOPOmics'
```

```
## Warning: replacing previous import 'magrittr::extract' by 'tidyr::extract' when
## loading 'ROMOPOmics'
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
omop_db     <- buildSQLDBR(omop_tables = db_inputs,file.path(dirs$base,"TCGA.sqlite"))
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
omop_db     <- buildSQLDBR(omop_tables = db_inputs, sql_db_file=file.path(dirs$base,"GSE60682_sqlDB.sqlite"))
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
```

```
## Loading required package: BiocGenerics
```

```
## Loading required package: parallel
```

```
## 
## Attaching package: 'BiocGenerics'
```

```
## The following objects are masked from 'package:parallel':
## 
##     clusterApply, clusterApplyLB, clusterCall, clusterEvalQ,
##     clusterExport, clusterMap, parApply, parCapply, parLapply,
##     parLapplyLB, parRapply, parSapply, parSapplyLB
```

```
## The following objects are masked from 'package:stats':
## 
##     IQR, mad, sd, var, xtabs
```

```
## The following objects are masked from 'package:base':
## 
##     anyDuplicated, append, as.data.frame, basename, cbind, colnames,
##     dirname, do.call, duplicated, eval, evalq, Filter, Find, get, grep,
##     grepl, intersect, is.unsorted, lapply, Map, mapply, match, mget,
##     order, paste, pmax, pmax.int, pmin, pmin.int, Position, rank,
##     rbind, Reduce, rownames, sapply, setdiff, sort, table, tapply,
##     union, unique, unsplit, which, which.max, which.min
```

```
## Welcome to Bioconductor
## 
##     Vignettes contain introductory material; view with
##     'browseVignettes()'. To cite Bioconductor, see
##     'citation("Biobase")', and for packages 'citation("pkgname")'.
```

```r
gse_ids <- c("GSE9006", "GSE26440", "GSE11504", "TABM666", "GSE6011", "GSE37721", "GSE20307", "GSE20436")

stevens_gse_lst <- fetch_geo_series(gse_ids,data_dir = "data/")
```

```
## Found 2 file(s)
```

```
## GSE9006-GPL96_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE9006-GPL96_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL96 found here:
## data//GPL96.soft
```

```
## Warning: 68 parsing failures.
##   row     col           expected    actual         file
## 22216 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22217 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22218 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22219 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22220 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## GSE9006-GPL97_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE9006-GPL97_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL97 found here:
## data//GPL97.soft
```

```
## Warning: 68 parsing failures.
##   row     col           expected    actual         file
## 22578 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22579 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22580 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22581 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22582 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Using locally cached version of GPL96 found here:
## data//GPL96.soft
```

```
## Warning: 68 parsing failures.
##   row     col           expected    actual         file
## 22216 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22217 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22218 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22219 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22220 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Found 1 file(s)
```

```
## GSE26440_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE26440_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Found 1 file(s)
```

```
## GSE11504_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE11504_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Series ID should fit the format "GSEnnnnnn".
```

```
## Found 1 file(s)
```

```
## GSE6011_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE6011_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL96 found here:
## data//GPL96.soft
```

```
## Warning: 68 parsing failures.
##   row     col           expected    actual         file
## 22216 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22217 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22218 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22219 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22220 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Using locally cached version of GPL96 found here:
## data//GPL96.soft
```

```
## Warning: 68 parsing failures.
##   row     col           expected    actual         file
## 22216 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22217 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22218 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22219 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 22220 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Found 1 file(s)
```

```
## GSE37721_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE37721_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL6947 found here:
## data//GPL6947.soft 
## Using locally cached version of GPL6947 found here:
## data//GPL6947.soft
```

```
## Found 1 file(s)
```

```
## GSE20307_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE20307_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Found 1 file(s)
```

```
## GSE20436_series_matrix.txt.gz
```

```
## Using locally cached version: data//GSE20436_series_matrix.txt.gz
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   .default = col_double(),
##   ID_REF = col_character()
## )
## ℹ Use `spec()` for the full column specifications.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```
## Using locally cached version of GPL570 found here:
## data//GPL570.soft
```

```
## Warning: 62 parsing failures.
##   row     col           expected    actual         file
## 54614 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54615 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54616 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54617 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## 54618 SPOT_ID 1/0/T/F/TRUE/FALSE --Control literal data
## ..... ....... .................. ......... ............
## See problems(...) for more details.
```

```r
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


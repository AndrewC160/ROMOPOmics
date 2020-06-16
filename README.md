ROMOPOmics - An OMOPOmics R package
================
June 16, 2020

ROMOPOmics
==========

The purpose of ROMOPOmics is to incorporate the wide variety of sequencing-type data sets, including all pipeline by byproducts (alignment files, raw reads, readmes, etc.) as well as pipeline products of any type (gene counts, differential expression data, quality control analyses, etc.), into an SQL-friendly database that is easily accessed by users. The package should be a quick installation that allows users to specify a data directory and a mask file describing how to map that data's fields into the data model, and will return tables formatted for SQLite incorporation.

![ROMOPOmics diagram](/data/projects/andrew/ROMOPOmics/man/figures/romopomics_2.0.PNG)

Step 1: Load the OMOP data model.
=================================

This package has been designed with the OMOP [OMOP 6.0](https://github.com/OHDSI/CommonDataModel/blob/master/OMOP_CDM_v6_0.csv) framework in mind, though it should be compatible with custom models as well. Unless a custom data model is provided, the package defaults to opening a custom version of the OMOP 6.0 data model which is packaged with it in `extdata`.

``` r
dm      <- loadDataModel(as_table_list = FALSE)
```

This data model is a modified version of the OMOP model downloaded from the [OMOP 6.0 GitHub](https://github.com/OHDSI/CommonDataModel/blob/master/OMOP_CDM_v6_0.csv). This data model includes 448 fields distributed among 39 tables. Unique to this version of the data model is the inclusion of an `hla_source_value` field in the `PERSON` table. Second, our customized version includes a `SEQUENCING` table:

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
field
</th>
<th style="text-align:left;">
required
</th>
<th style="text-align:left;">
type
</th>
<th style="text-align:left;">
description
</th>
<th style="text-align:left;">
table
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
sequencing id
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
A unique identifier for each sequencing entry.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
person id
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
A foreign key identifier to the Person who is experiencing the condition. The demographic details of that Person are stored in the PERSON table.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
specimen id
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
A unique identifier for each specimen.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
library concept value
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Sequencing library type (text).
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
library source value
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Sequencing library source kit (text).
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
library paired end
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
Boolean; library is paired end.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
library cycles
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
Cycles per end; approximate number of base pairs sequenced per end of read.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
instrument source value
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Sequencing platform used (text).
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
reference genome value
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Reference genome used, if aligned (text).
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
metric source value
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Units of sequencing data (text); i.e. what was sequenced.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
sequencing pct alignment
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
Percent alignment, if available.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
sequencing min quality
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
INTEGER
</td>
<td style="text-align:left;">
Minimum quality score, if available.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
sequencing quality metric
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Quality score unit, if available.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
sequencing validation method
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(255)
</td>
<td style="text-align:left;">
Description of validation method, perhaps script or pseudocode.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
file type source value
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
File type (text).
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
sequencing file description
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(255)
</td>
<td style="text-align:left;">
File description (counts, normalization method, differential analysis, etc.).
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
file local source
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(255)
</td>
<td style="text-align:left;">
Local file location.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
file remote repo value
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Remote file repository.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
file remote repo id
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(50)
</td>
<td style="text-align:left;">
Remote file repository ID.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
<tr>
<td style="text-align:left;">
file remote source url
</td>
<td style="text-align:left;">
No
</td>
<td style="text-align:left;">
VARCHAR(255)
</td>
<td style="text-align:left;">
Remote file URL.
</td>
<td style="text-align:left;">
sequencing
</td>
</tr>
</tbody>
</table>
This table inherits from `PERSON` and `SPECIMEN`. The reasons for including this table are two fold: First, sequencing data is excedingly common in contemporary research, and is increasingly common in personalized medicine techniques. Second, to be truly useful "Sequencing" data should be able to incorporate the spectrum of products along the testing pipeline, from library preparation to sequencing to data analysis. This will allow for intermediate steps and files to be used (getting and using raw files rather than the gene counts, for example). But crucially, this will facilitate comparisons using data sets between different studies, which must account for differences in library preparation, quality control, alignment methods, reference data, etc. Including this data should make this easier, but incorporating this variety of variables is not intuitive in the existing OMOP model.

Step 2: Design and load input masks to translate database values into OMOP fields and tables.
=============================================================================================

``` r
msks  <- loadModelMasks(mask_file_directory = dirs$masks)
```

"Masks" are designed to streamline the addition of existing data sets to OMOP format, or at least to how the *admin* thinks these data sets should be incorporated. The mask file provides `table`, `alias`, and `field` columns, which describe each term's OMOP table, its name within the user's input file, and its name within the standard OMOP field, respectively. For instance, `patient_name` in the user's database will likely map to `person_source_value` in current OMOP parlance. Using multiple masks should streamline the use of multiple analysis types as well: the database administrators can develop and implement masks and users won't need to know that `patient_name` and `cell_line_name` are both synonymous with `person_source_value` in the OMOP framework, for instance. Thus "Sequencing" data can be added using the `sequencing` mask, while "HLA"" data can be incorporated using an `hla` mask. Here's an example of a mask formatted [TCGA](https://www.cancer.gov/about-nci/organization/ccg/research/structural-genomics/tcga) clinical data, provided to the `loadModelMasks()` function as a CSV:

#### **Column names**

-   **alias**: Field name for a value according to the input dataset.

-   **field**: Field name for a value according to the selected data model.

-   **table**: Table name for a value according to the selected data model.

-   **field\_idx**: Since OMOP format anticipates a one-column-per-treatment/observation/measurement format, appending a value here other than `NA` allows for new columns to be added for each such value. For instance, two inputs can be mapped to `value_as_number` by including a value here and causing each measurement to be added to a separate column. In effect, one column per measurement.

-   **set\_value**: Default value that is added to the given table and field regardless of input. Useful for specifying units, descriptions, etc. when facilitating the multiple-column transition.

Step 3: Use masks to translate the input dataset into OMOP format.
==================================================================

Using the `readInputFiles()` function, data table inputs are translated into the OMOP format according to the provided `mask` (in this case `brca_clinical` and `brca_mutation`). Tables in this format are "exhaustive" in that they include all possible fields and tables in the data model, including unused ones.

``` r
omop_inputs <- lapply(names(tcga_files), function(x) readInputFiles(input_file = tcga_files[[x]],
                                                                    mask_table = msks[[x]],
                                                                    data_model=dm))
```

Step 4: Combine all input tables into one set of OMOP tables.
=============================================================

Since tables read via `readInputFiles()` include all fields and tables from the data model, these tables can be combined regardless of input type or mask used using `combineInputTables()`. This function combines all data sets from all mask types, and filters out all OMOP tables from the data model that are unused (no entries in any of the associated fields). Tables are not "partially" used; if any field is included from that table, all fields from that table are included. The only exception to this is table indices: if a table inherits an index from an unused table, that index column is dropped.

Once data has been loaded into a single comprehensive table, an index column (`<table_name>_index`) is assigned for each permutation of all data sets included in each used table, and formats the `type` of each column based on the data model's specification (`VARCHAR(50)` is changed to "character", `INTEGER` is changed to "integer", etc.). Finally, this function returns each formatted OMOP table in a named list.

``` r
db_inputs   <- combineInputTables(input_table_list = omop_inputs)
```

In this example using these masks, the OMOP tables included are COHORT, MEASUREMENT, OBSERVATION, PERSON, PROVIDER, SEQUENCING, and SPECIMEN.

Step 6: Add OMOP-formatted tables to a database.
================================================

The tables compiled in `db_inputs` are now formatted for a SQLite database. `Dplyr` has built-in SQLite functionality, which is wrapped in the function `buildSQLDBR()`. However, building a database using any other package is amenable here.

``` r
omop_db     <- buildSQLDBR(db_inputs,sql_db_file = file.path(dirs$base,"sqlDB.sqlite"))

dbListTables(omop_db)
```

    ## [1] "COHORT"       "MEASUREMENT"  "OBSERVATION"  "PERSON"       "PROVIDER"    
    ## [6] "SEQUENCING"   "SPECIMEN"     "sqlite_stat1" "sqlite_stat4"

``` r
dbListFields(omop_db,"PERSON")
```

    ##  [1] "person_id"                   "provider_id"                
    ##  [3] "birth_datetime"              "day_of_birth"               
    ##  [5] "death_datetime"              "ethnicity_concept_id"       
    ##  [7] "ethnicity_source_concept_id" "ethnicity_source_value"     
    ##  [9] "gender_concept_id"           "gender_source_concept_id"   
    ## [11] "gender_source_value"         "hla_source_value"           
    ## [13] "month_of_birth"              "person_source_value"        
    ## [15] "race_concept_id"             "race_source_concept_id"     
    ## [17] "race_source_value"           "year_of_birth"

#### Raw SQLite query:

``` r
dbGetQuery(omop_db,
'SELECT person_source_value, person.person_id,file_remote_repo_id,file_remote_repo_value
 FROM person INNER JOIN sequencing 
 WHERE file_remote_repo_id IS NOT NULL and person_source_value is "tcga-3c-aaau" 
 ORDER BY "file_remote_repo_value"') %>%
  mutate_all(function(x) gsub("_"," ",x)) %>%
  kable() %>%
  kable_styling(full_width=FALSE) 
```

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
person\_source\_value
</th>
<th style="text-align:left;">
person\_id
</th>
<th style="text-align:left;">
file\_remote\_repo\_id
</th>
<th style="text-align:left;">
file\_remote\_repo\_value
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SB-10B-01D-A142-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SD-10A-01D-A110-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SE-10A-03D-A099-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SF-10B-01D-A142-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SG-10B-01D-A17G-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SH-10A-03D-A099-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SI-10B-01D-A142-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SJ-10A-02D-A099-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SK-10A-03D-A099-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SM-10A-02D-A10G-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SN-10B-01D-A142-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SP-10A-02D-A099-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SQ-10B-01W-A187-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04N-10A-01D-A110-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04P-10A-01W-A055-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04Q-10A-01W-A055-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04R-10B-01D-A10G-09
</td>
<td style="text-align:left;">
normal sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SB-01A-11D-A142-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SD-01A-11D-A10Y-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SE-01A-11D-A099-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SF-01A-11D-A142-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SG-01A-11D-A142-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SH-01A-11D-A099-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SI-01A-11D-A142-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SJ-01A-11D-A099-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SK-01A-12D-A099-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SM-01A-11D-A099-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SN-01A-11D-A142-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SP-01A-11D-A099-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A1-A0SQ-01A-21D-A142-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04N-01A-11D-A10Y-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04P-01A-31D-A128-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04Q-01A-21W-A050-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-3c-aaau
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
TCGA-A2-A04R-01A-41D-A117-09
</td>
<td style="text-align:left;">
tumor sample barcode
</td>
</tr>
</tbody>
</table>
#### DBplyr query:

``` r
inner_join(tbl(omop_db,"PERSON"),
           tbl(omop_db,"MEASUREMENT")) %>%
  select(person_source_value,
         birth_datetime,
         death_datetime,
         measurement_source_value,
         value_as_number,
         unit_source_value) %>%
  filter(charindex("lymph",measurement_source_value),
         !is.null(death_datetime)) %>%
  as_tibble() %>%
  mutate_all(function(x) gsub("_"," ",x)) %>%
  kable() %>%
  kable_styling(full_width=FALSE)
```

    ## Joining, by = c("person_id", "provider_id")

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
person\_source\_value
</th>
<th style="text-align:left;">
birth\_datetime
</th>
<th style="text-align:left;">
death\_datetime
</th>
<th style="text-align:left;">
measurement\_source\_value
</th>
<th style="text-align:left;">
value\_as\_number
</th>
<th style="text-align:left;">
unit\_source\_value
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
tcga-a1-a0sk
</td>
<td style="text-align:left;">
10/17/1956
</td>
<td style="text-align:left;">
5/1/2014
</td>
<td style="text-align:left;">
lymph nodes examined
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
nodes
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-a1-a0sk
</td>
<td style="text-align:left;">
10/17/1956
</td>
<td style="text-align:left;">
5/1/2014
</td>
<td style="text-align:left;">
lymph node he
</td>
<td style="text-align:left;">
0
</td>
<td style="text-align:left;">
nodes
</td>
</tr>
<tr>
<td style="text-align:left;">
tcga-a1-a0sk
</td>
<td style="text-align:left;">
10/17/1956
</td>
<td style="text-align:left;">
5/1/2014
</td>
<td style="text-align:left;">
lymph node ihc
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
nodes
</td>
</tr>
</tbody>
</table>
TL;DR:
======

    library(ROMOPOmics)
    dm_file     <- system.file("extdata","OMOP_CDM_v6_0_custom.csv",package="ROMOPOmics",mustWork = TRUE)
    dm          <- loadDataModel(master_table_file = dm_file)
    tcga_files  <- dir(dirs$data,full.names = TRUE)
    names(tcga_files) <- gsub(".csv","",basename(tcga_files))
    msks        <- loadModelMasks(mask_file_directory = dirs$masks)
    omop_inputs <- lapply(names(tcga_files), function(x) readInputFiles(tcga_files[[x]],data_model=dm,mask_table=msks[[x]]))
    db_inputs   <- combineInputTables(input_table_list = omop_inputs)
    omop_db     <- buildSQLDBR(db_inputs,sql_db_file = file.path(dirs$base,"sqlDB.sqlite"))

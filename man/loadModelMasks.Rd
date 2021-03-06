% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/loadModelMasks.R
\name{loadModelMasks}
\alias{loadModelMasks}
\title{Load the data dictionary for corresponding data fields to the CDM}
\usage{
loadModelMasks(mask_files)
}
\arguments{
\item{mask_files}{Either one or more file names of mask CSVs or TSVs, 
or a directory string containing the mask files.

loadModelMasks()}
}
\description{
\code{loadModelMasks} reads in all "mask" tables, which correspond the 
input data fields to the common data model fields and tables.
}
\details{
The function automatically adds essential columns table, alias, and field: 
'Alias' denotes the value being input, 'field' denotes the data model's 
equivalent field name, and 'table' denotes the data model table where that 
field resides. If multiple files are provided, they are returned in a list 
named from the basenames of the loaded files. If the list of mask files is 
already named, these names are used instead.
}

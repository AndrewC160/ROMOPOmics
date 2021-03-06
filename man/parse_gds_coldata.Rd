% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parse_gds_coldata.R
\name{parse_gds_coldata}
\alias{parse_gds_coldata}
\title{parse_gds_coldata}
\usage{
parse_gds_coldata(gds_in = NULL)
}
\arguments{
\item{gds_in}{GDS object to be parsed, generally as returned by getGEO().}
}
\description{
Background function (not typically user-facing).
}
\details{
Given a GDS object as returned from getGEO(), retrieves column data and 
formats for use with metadata tables, including parsing metadata values
based on semicolon-separated columns in the data (e.g. "source: cell type").
}

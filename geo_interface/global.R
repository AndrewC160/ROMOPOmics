#!/bin/Rscript
library(shiny)
library(shinyjs)
library(GEOquery)
library(tidyverse)
library(ROMOPOmics)
library(rprojroot)
library(RCurl)
library(DT)

dirs      <- list()
dirs$base <- file.path(find_root(criterion = criteria$is_r_package))
dirs$app  <- file.path(dirs$base,"geo_interface")
dirs$data <- file.path(dirs$app,"data")
dirs$src  <- file.path(dirs$app,"R")

lapply(dir(dirs$src,full.names = TRUE),source)

defaults  <- list(txt_geo_id="GDS509")

#Default functions
if(FALSE){
  gds_nam <- function(gds_default=defaults$txt_geo_id){
    return(gds_default)
  }
  gds_val <- function(default_gds=gds){
    return(default_gds)
  }
  gpl_val <- function(default_gpl=gpl){
    return(default_gpl)
  }
  gse_val <- function(default_gse=gse){
    return(default_gse)
  }
  gds_md_val  <- function(default_gds=gds_nam()){
    return()
  }
  
  geo_data <- function(default_geo_data=geo){
    return(default_geo_data)
  }
  #gsm_cl_val(gds_md_val()$coldata)
  geo <- fetch_geo_dataset(gds_nam())
  
  #gds <- getGEO(gds_nam(),destdir = dirs$data)
  #gpl <- getGEO(gds_val()@header$platform,destdir = dirs$data)
  #gse <- getGEO(gds_val()@header$reference_series,destdir=dirs$data)
  
  
#GEO GDS508
  gds <- getGEO("GDS508",destdir = dirs$data)
  md  <- parse_geo_metadata(gds)
  
  
}
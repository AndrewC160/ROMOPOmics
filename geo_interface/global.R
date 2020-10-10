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

defaults  <- list(txt_geo_id="GDS507")

#Debug functions
if(FALSE){
  #Gather these once.
  gds <- getGEO(gds_nam(),destdir = dirs$data)
  gpl <- getGEO(gds_val()@header$platform,destdir = dirs$data)
  gse <- getGEO(gds_val()@header$reference_series,destdir=dirs$data)
  
  #Pseudo reactiveValues().
  gds_nam   <- function(gds_default=defaults$txt_geo_id){
    return(gds_default)
  }
  gds_val   <- function(default_gds=gds){
    return(default_gds)
  }
  gpl_val   <- function(default_gpl=gpl){
    return(default_gpl)
  }
  gse_val   <- function(default_gse=gse){
    return(default_gse)
  }
  gds_md_val<- function(default_gds_val=gds_val()){
    return(parse_metadata(gds_val()))
  }
  gpl_md_val<- function(default_gpl_val=gpl_val()){
    return(parse_metadata(gpl_val()))
  }
  gse_md_val<- function(default_gse_val=gse_val()){
    return(parse_metadata(gse_val()))
  }
  gsm_cl_val<- function(defafult_gds_val=gds_val()){
    return(parse_metadata(gds_val())$coldata)
  }
}

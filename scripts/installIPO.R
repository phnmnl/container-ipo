#! /usr/bin/env Rscript

source("http://bioconductor.org/biocLite.R")

install.packages("devtools")
library("devtools")
install_github("sneumann/mzR")

biocLite("CAMERA")
biocLite("xcms")

install.packages("rsm") 
install.packages("optparse")


install_github("phnmnl/IPO")

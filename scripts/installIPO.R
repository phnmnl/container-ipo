#! /usr/bin/env Rscript

source("http://bioconductor.org/biocLite.R")

biocLite("CAMERA")
biocLite("xcms")

install.packages("rsm") 
install.packages("devtools")

library("devtools")
install_github("glibiseller/IPO")

#! /usr/bin/env Rscript

source("http://bioconductor.org/biocLite.R")

biocLite("CAMERA")
biocLite("xcms")

install.packages("rsm", , repos='http://mirrors.ebi.ac.uk/CRAN') 
install.packages("devtools",, repos='http://mirrors.ebi.ac.uk/CRAN')

library("devtools")
install_github("glibiseller/IPO")
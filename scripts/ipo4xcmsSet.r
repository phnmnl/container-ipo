#!/usr/bin/env Rscript
#Authors Gildas Le Corguille and Yann Guitton


# ----- LOG FILE -----
log_file=file("log.txt", open = "wt")
sink(log_file)
sink(log_file, type = "output")

# 
# ----- PACKAGE -----
options(bitmapType='cairo')
cat("\tPACKAGE INFO\n")
#pkgs=c("xcms","batch")
pkgs=c("parallel","BiocGenerics", "Biobase", "Rcpp", "mzR", "xcms","rsm","igraph","CAMERA","IPO","snow","batch")

for(pkg in pkgs) {
  print(pkg)
  cat(pkg,"\t",as.character(packageVersion(pkg)),"\n",sep="")
  suppressWarnings( suppressPackageStartupMessages( stopifnot( library(pkg, quietly=TRUE, logical.return=TRUE, character.only=TRUE))))
}
source_local <- function(fname){ argv <- commandArgs(trailingOnly = FALSE); base_dir <- dirname(substring(argv[grep("--file=", argv)], 8)); source(paste(base_dir, fname, sep="/")) }
cat("\n\n"); 





# ----- ARGUMENTS -----
cat("\tARGUMENTS INFO\n")
listArguments = parseCommandArgs(evaluate=FALSE) #interpretation of arguments given in command line as an R list of objects
write.table(as.matrix(listArguments), col.names=F, quote=F, sep='\t')

cat("\n\n");


# ----- ARGUMENTS PROCESSING -----
cat("\tINFILE PROCESSING INFO\n")


#Import the different functions
source_local("lib.r")

cat("\n\n")

#Import the different functions

# ----- PROCESSING INFILE -----
cat("\tARGUMENTS PROCESSING INFO\n")

optimResultsRdataOutput = paste("resultPeakpicking","RData",sep=".")
if (!is.null(listArguments[["optimResultsRdataOutput"]])){
  optimResultsRdataOutput = listArguments[["optimResultsRdataOutput"]]; listArguments[["optimResultsRdataOutput"]]=NULL
}

parametersOutput = "parametersOutput.tsv"
if (!is.null(listArguments[["parametersOutput"]])){
  parametersOutput = listArguments[["parametersOutput"]]; listArguments[["parametersOutput"]]=NULL
}

samplebyclass = 2
if (!is.null(listArguments[["samplebyclass"]])){
  samplebyclass = listArguments[["samplebyclass"]]; listArguments[["samplebyclass"]]=NULL
}

#necessary to unzip .zip file uploaded to Galaxy
#thanks to .zip file it's possible to upload many file as the same time conserving the tree hierarchy of directories


if (!is.null(listArguments[["zipfile"]])){
  zipfile= listArguments[["zipfile"]]; listArguments[["zipfile"]]=NULL
}


if (!is.null(listArguments[["singlefile_galaxyPath"]])){
  singlefile_galaxyPath = listArguments[["singlefile_galaxyPath"]]; listArguments[["singlefile_galaxyPath"]]=NULL
  singlefile_sampleName = listArguments[["singlefile_sampleName"]]; listArguments[["singlefile_sampleName"]]=NULL
}

# single file case
#@TODO: need to be refactoring
if(exists("singlefile_galaxyPath") && (singlefile_galaxyPath!="")) {
  print(singlefile_galaxyPath)
  if(!file.exists(singlefile_galaxyPath)){
    error_message=paste("Cannot access the sample:",singlefile_sampleName,"located:",singlefile_galaxyPath,". Please, contact your administrator ... if you have one!")
    print(error_message); stop(error_message)
  }
  
  cwd=getwd()
  dir.create("raw")
  setwd("raw")
  file.symlink(singlefile_galaxyPath, singlefile_sampleName)
  setwd(cwd)
  
  directory = "raw"
}

# We unzip automatically the chromatograms from the zip files.
if(exists("zipfile") && (zipfile!="")) {
  if(!file.exists(zipfile)){
    error_message=paste("Cannot access the Zip file:",zipfile,". Please, contact your administrator ... if you have one!")
    print(error_message)
    stop(error_message)
  }
  
  #list all file in the zip file
  #zip_files=unzip(zipfile,list=T)[,"Name"]
  
  # Because IPO only want raw data in its working directory
  dir.create("ipoworkingdir")
  setwd("ipoworkingdir")

  #unzip
  suppressWarnings(unzip(zipfile, unzip="internal"))
  
  #get the directory name
  filesInZip=unzip(zipfile, list=T);
  directories=unique(unlist(lapply(strsplit(filesInZip$Name,"/"), function(x) x[1])));
  directories=directories[!(directories %in% c("__MACOSX")) & file.info(directories)$isdir]
  directory = "."
  if (length(directories) == 1) directory = directories
  
  cat("files_root_directory\t",directory,"\n")
}

#addition of the directory to the list of arguments in the first position
checkXmlStructure(directory)
checkFilesCompatibilityWithXcms(directory)

cat("\n\n")


# ----- MAIN PROCESSING INFO -----

cat("\tMAIN PROCESSING INFO\n")

resultPeakpicking = ipo4xcmsSet(directory, parametersOutput, listArguments, samplebyclass)

#Important results
bestXset = resultPeakpicking$xset
bestXsetParams = resultPeakpicking$parameters
PPscore = resultPeakpicking$results[["PPS"]]
cat("\n\n")


# ----- EXPORT -----

cat("\tPEAK PICKING INFO\n")
print(resultPeakpicking)

# Keep results of the best xset
write.table(t(as.data.frame(resultPeakpicking)), file=parametersOutput,  sep="\t", row.names=T, col.names=F, quote=F)

#saving R data in .Rdata file to save the variables used in the present tool
objects2save = c("bestXset", "bestXsetParams", "PPscore", "zipfile")
save(list=objects2save[objects2save %in% ls()], file=optimResultsRdataOutput)

cat("\n\n")


cat("\tDONE\n")


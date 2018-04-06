#!/usr/bin/env Rscript
#Authors Gildas Le Corguille and Yann Guitton

# Setup R error handling to go to stderr for better error messages in Galaxy
options(show.error.messages=F, error=function(){cat(geterrmessage(),file=stderr());q("no",1,F)})

# ----- LOG FILE -----
log_file=file("log.txt", open = "wt")
sink(log_file)
sink(log_file, type = "output")


# ----- PACKAGE -----
options(bitmapType='cairo')
cat("\tPACKAGE INFO\n")
#pkgs=c("xcms","batch")
pkgs=c("parallel","BiocGenerics", "Biobase", "Rcpp", "mzR", "xcms","rsm","igraph","CAMERA","IPO","snow","batch")

for(pkg in pkgs) {
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

#image is an .RData file necessary to use xset variable given by previous tools
if (!is.null(listArguments[["image"]])){
  load(listArguments[["image"]]); listArguments[["image"]]=NULL
}

#Import the different functions
source_local("lib.r")

cat("\n\n")

# ----- PROCESSING INFILE -----
cat("\tARGUMENTS PROCESSING INFO\n")

optimResultsRdataOutput = paste("resultRetcorGroup","RData",sep=".")
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

    cwd=getwd()
    if(!dir.exists("raw"))
      dir.create("raw")
    setwd("raw")

    for (singlefile_galaxyPath_i in seq(1:length(singlefile_galaxyPath))) {
        if(!file.exists(singlefile_galaxyPath[singlefile_galaxyPath_i])){
            error_message=paste("Cannot access the sample:",singlefile_sampleName[singlefile_galaxyPath_i],"located:",singlefile_galaxyPath[singlefile_galaxyPath_i],". Please, contact your administrator ... if you have one!")
            print(error_message); stop(error_message)
        }
        if(!file.exists(singlefile_sampleName[singlefile_galaxyPath_i]))
          file.symlink(singlefile_galaxyPath[singlefile_galaxyPath_i],singlefile_sampleName[singlefile_galaxyPath_i])
    }

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
    if(!dir.exists("ipoworkingdir"))
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


resultRetcorGroup = ipo4retgroup(bestXset, directory, parametersOutput, listArguments, samplebyclass)

print(resultRetcorGroup)

cat("\n\n")


# ----- EXPORT -----

cat("\tEXPORTING INFO\n")

# Save current workspace
save("resultRetcorGroup", file=optimResultsRdataOutput)

cat("\n\n")


cat("\tDONE\n")

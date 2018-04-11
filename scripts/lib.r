##
## This function retrieves runinfos and instrument infos from
## mzfile given in argument
##
getInfos = function(mzdatafiles){
  
  # Get informations about instruments used and run
  file.format = c("mzData", "mzdata")
  if(tools::file_ext(mzdatafiles) %in% file.format){
    ms = openMSfile(mzdatafiles, backend="Ramp")
  } else {
    ms = openMSfile(mzdatafiles)
  }
  
  runInfo = t(sapply(runInfo(ms), function(x) x[1], USE.NAMES=TRUE))
  instrumentInfo = t(sapply(instrumentInfo(ms), function(x) x, USE.NAMES=TRUE))
  
  infos = list("runInfo" = runInfo, "instrumentInfo" = instrumentInfo)
  return (infos)
}


##
## This function launch IPO functions to get the best parameters for xcmsSet
## A sample among the whole dataset is used to save time
##
ipo4xcmsSet = function(directory, parametersOutput, listArguments, samplebyclass=4) {
  setwd(directory)
  
  files = list.files(".", recursive=T)  # "KO/ko15.CDF" "KO/ko16.CDF" "WT/wt15.CDF" "WT/wt16.CDF"
  files_classes = basename(dirname(files))    # "KO", "KO", "WT", "WT"
  
  mzmlfile = files
  if (samplebyclass > 0) {
    #random selection of N files for IPO in each class
    classes<-unique(basename(dirname(files)))
    mzmlfile = NULL
    for (class_i in classes){
      files_class_i = files[files_classes==class_i]
      if (samplebyclass > length(files_class_i)) {
        mzmlfile = c(mzmlfile, files_class_i)
      } else {
        mzmlfile = c(mzmlfile,sample(files_class_i,samplebyclass))
      }
    }
  }
  #@TODO: else, must we keep the RData to been use directly by group?
  
  cat("\t\tSamples used:\n")
  print(mzmlfile)
  
  peakpickingParameters = getDefaultXcmsSetStartingParams(listArguments[["method"]]) #get default parameters of IPO
  
  # filter listArguments to only get releavant parameters and complete with those that are not declared
  peakpickingParametersUser = c(listArguments[names(listArguments) %in% names(peakpickingParameters)], peakpickingParameters[!(names(peakpickingParameters) %in% names(listArguments))])
  peakpickingParametersUser$verbose.columns = TRUE
  
  # allow range for min and max peakwidth and ppm if given in arguments
  if (!is.null(listArguments[["minPeakWidth"]])){
    peakpickingParametersUser$min_peakwidth = as.vector(as.numeric(unlist(strsplit(listArguments[["minPeakWidth"]],split = ","))))
    listArguments[["minPeakWidth"]] = NULL
  }
  
  if (!is.null(listArguments[["maxPeakWidth"]])){
    peakpickingParametersUser$max_peakwidth = as.vector(as.numeric(unlist(strsplit(listArguments[["maxPeakWidth"]],split = ","))))
    listArguments[["maxPeakWidth"]] = NULL 
  }
  
  if (!is.null(listArguments[["ppm"]])){
    if(grepl(",", listArguments[["ppm"]]))
      peakpickingParametersUser$ppm = as.vector(as.numeric(unlist(strsplit(listArguments[["ppm"]],split = ","))))
    else
      peakpickingParametersUser$ppm = listArguments[["ppm"]]
    listArguments[["ppm"]] = NULL
  }
  
  # peakpickingParametersUser$profparam <- list(step=0.005) #not yet used by IPO have to think of it for futur improvement
  resultPeakpicking = optimizeXcmsSet(mzmlfile, peakpickingParametersUser, nSlaves=peakpickingParametersUser$nSlaves, subdir="../IPO_results") #some images generated by IPO
  
  # export results
  resultPeakpicking_best_settings_parameters = resultPeakpicking$best_settings$parameters[!(names(resultPeakpicking$best_settings$parameters) %in% c("nSlaves","verbose.columns"))]
  
  infos = getInfos(mzmlfile)
  # can be read by user
  write.table(cbind(mzmlfile, infos$instrumentInfo, infos$runInfo, t(as.matrix(resultPeakpicking_best_settings_parameters))), file=parametersOutput, sep="\t", row.names=F, col.names=T, quote=F)
  
  
  # Returns best settings containing among others:
  # - Best Xset (xcmsSet object)
  # - Best Xset parameters
  # - PeakPickingScore (PPS)
  return (resultPeakpicking)
}

##
## This function launch IPO functions to get the best parameters for group and retcor
##
ipo4retgroup = function(xset, directory, parametersOutput, listArguments, samplebyclass=4) {
  setwd(directory)
  
  files = list.files(".", recursive=T)  # "KO/ko15.CDF" "KO/ko16.CDF" "WT/wt15.CDF" "WT/wt16.CDF"
  files_classes = basename(dirname(files))    # "KO", "KO", "WT", "WT"
  
  retcorGroupParameters = getDefaultRetGroupStartingParams(listArguments[["retcorMethod"]]) #get default parameters of IPO
  print(retcorGroupParameters)
  # filter listArguments to only get releavant parameters and complete with those that are not declared
  retcorGroupParametersUser = c(listArguments[names(listArguments) %in% names(retcorGroupParameters)], retcorGroupParameters[!(names(retcorGroupParameters) %in% names(listArguments))])
  print("retcorGroupParametersUser")
  print(retcorGroupParametersUser)
  resultRetcorGroup = optimizeRetGroup(xset, retcorGroupParametersUser, nSlaves=listArguments[["nSlaves"]], subdir="../IPO_results") #some images generated by IPO
  
  # export  best retCor + grouping parameters
  write.table(t(as.data.frame(resultRetcorGroup$best_settings)), file=parametersOutput,  sep="\t", row.names=T, col.names=F, quote=F)  #can be read by user
}




##
## This function check if xcms will found all the files
##
#@author Gildas Le Corguille lecorguille@sb-roscoff.fr ABiMS TEAM
checkFilesCompatibilityWithXcms <- function(directory) {
  cat("Checking files filenames compatibilities with xmcs...\n")
  # WHAT XCMS WILL FIND
  filepattern <- c("[Cc][Dd][Ff]", "[Nn][Cc]", "([Mm][Zz])?[Xx][Mm][Ll]","[Mm][Zz][Dd][Aa][Tt][Aa]", "[Mm][Zz][Mm][Ll]")
  filepattern <- paste(paste("\\.", filepattern, "$", sep = ""),collapse = "|")
  info <- file.info(directory)
  listed <- list.files(directory[info$isdir], pattern = filepattern,recursive = TRUE, full.names = TRUE)
  files <- c(directory[!info$isdir], listed)
  files_abs <- file.path(getwd(), files)
  exists <- file.exists(files_abs)
  files[exists] <- files_abs[exists]
  files[exists] <- sub("//","/",files[exists])
  
  # WHAT IS ON THE FILESYSTEM
  filesystem_filepaths=system(paste("find $PWD/",directory," -not -name '\\.*' -not -path '*conda-env*' -type f -name \"*\"", sep=""), intern=T)
  filesystem_filepaths=filesystem_filepaths[grep(filepattern, filesystem_filepaths, perl=T)]
  
  # COMPARISON
  if (!is.na(table(filesystem_filepaths %in% files)["FALSE"])) {
    write("\n\nERROR: List of the files which will not be imported by xcmsSet",stderr())
    write(filesystem_filepaths[!(filesystem_filepaths %in% files)],stderr())
    stop("\n\nERROR: One or more of your files will not be import by xcmsSet. It may due to bad characters in their filenames.")
    
  }
}



##
## This function check if XML contains special caracters. It also checks integrity and completness.
##
#@author Misharl Monsoor misharl.monsoor@sb-roscoff.fr ABiMS TEAM
checkXmlStructure <- function (directory) {
  cat("Checking XML structure...\n")
  
  cmd=paste("IFS=$'\n'; for xml in $(find",directory,"-not -name '\\.*' -not -path '*conda-env*' -type f -iname '*.*ml*'); do if [ $(xmllint --nonet --noout \"$xml\" 2> /dev/null; echo $?) -gt 0 ]; then echo $xml;fi; done;")
  capture=system(cmd,intern=TRUE)
  
  if (length(capture)>0){
    #message=paste("The following mzXML or mzML file is incorrect, please check these files first:",capture)
    write("\n\nERROR: The following mzXML or mzML file(s) are incorrect, please check these files first:", stderr())
    write(capture, stderr())
    stop("ERROR: xcmsSet cannot continue with incorrect mzXML or mzML files")
  }
  
}

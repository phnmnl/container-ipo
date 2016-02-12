#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(IPO))

options_list<-list(
  make_option(c("--inputPaths","-i"),help="File with paths to mzML files"),
  make_option(c("--output","-o"),help="ouput full path name, directories and files will be created here"),
  make_option(c("--xcmsStartingMethod","-m"),
              default = "centWave",
              help="Method for starting XCMS parameters: centWave (default), matchedFilter or other accepted by IPO"),
  make_option(c("--minPeakWidth","-n"),default = "10,20",help = "Min peak width range, two integers separated by comma"),
  make_option(c("--maxPeakWidth","-x"),default = "26,42",help = "Max peak width range, two integers separated by comma"),
  make_option(c("--slaves","-s"),default = 4,help = "Integer for the number of slaves, default 4"),
  make_option(c("--retSteps","-r"),default = 1,help = "Integer for the number of steps for the retention time, default 1"),
  make_option(c("--ppm","-p"),default = 20,help = "PPM for peak picking parameters, default 20")
)

parser = OptionParser(option_list = options_list)
opt<-parse_args(parser,positional_arguments = FALSE)

if(!("inputPaths" %in% names(opt)) || !("output" %in% names(opt)) ) {
  print("no argument given!")
  print_help(parser)
  q(status = 1,save = "no")
}

peakpickingParameters<-getDefaultXcmsSetStartingParams(method = opt$xcmsStartingMethod)
peakpickingParameters$min_peakwidth <- as.vector(as.numeric(unlist(strsplit(opt$minPeakWidth,split = ","))))
peakpickingParameters$max_peakwidth <- as.vector(as.numeric(unlist(strsplit(opt$maxPeakWidth,split = ","))))
peakpickingParameters$ppm <- opt$ppm

filePaths<-scan(opt$inputPaths,what = "character")
resultPeakpicking <- optimizeXcmsSet(files=filePaths, 
                                     params=peakpickingParameters, nSlaves=opt$slaves, subdir=paste(opt$output,'rsmDirectory',sep = "/"))

optimizedXcmsSetObject <- resultPeakpicking$best_settings$xset

retcorGroupParameters <- getDefaultRetGroupStartingParams()
retcorGroupParameters$profStep <- 1
resultRetcorGroup <- optimizeRetGroup(xset=optimizedXcmsSetObject, params=retcorGroupParameters, 
                                      nSlaves=opt$slaves, subdir=paste(opt$output,'rsmDirectory',sep = "/"))

capture.output(
  writeRScript(resultPeakpicking$best_settings$parameters, resultRetcorGroup$best_settings, nSlaves=opt$slaves),
  file = paste(opt$ouput,"runXCMSWithArguments.R",sep="/"),type = "message")
save(resultPeakpicking,resultRetcorGroup,file = paste(opt$ouput,"optimizedParameters.RData",sep="/"))

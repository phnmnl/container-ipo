#!/bin/bash

# download test data file
# wget "https://raw.githubusercontent.com/workflow4metabolomics/ipo/master/galaxy/ipo/test-data/MM14.mzML" -O "/usr/local/bin/MM14.mzML"
wget "https://github.com/phnmnl/container-ipo/raw/develop/test/a_mtbls117_DIMS_POS_mass_spectrometry.zip" -O "/usr/local/bin/a_mtbls117_DIMS_POS_mass_spectrometry.zip"
wget "https://github.com/phnmnl/container-ipo/raw/develop/test/MTBLS117_POS_W4M_sampleMetadata.tsv" -O "/usr/local/bin/MTBLS117_POS_W4M_sampleMetadata.tsv"

# Peak picking first
#ipo4xcmsSet.r singlefile_galaxyPath /usr/local/bin/MM14.mzML singlefile_sampleName MM14.mzML parametersOutput MM14_IPO_parameters4xcmsSet.tsv nSlaves 4 minPeakWidth 3,9.5 maxPeakWidth 10,20 ppm 56
ipo4xcmsSet.r method centWave zipfile /usr/local/bin/a_mtbls117_DIMS_POS_mass_spectrometry.zip parametersOutput MTBLS117_IPO_parameters4xcmsSet.tsv nSlaves 4

# Then Grouping
# ipo4retgroup.r image best_xcmsSet.RData parametersOutput MM14_IPO_parameters4retcorGroup.tsv method density singlefile_galaxyPath /usr/local/bin/MM14.mzML singlefile_sampleName MM14.mzML retcorMethod obiwarp nSlaves 4
ipo4retgroup.r sampleMetadataFile /usr/local/bin/MTBLS117_POS_W4M_sampleMetadata.tsv image best_xcmsSet.RData parametersOutput MTBLS117_IPO_parameters4retcorGroup.tsv method density zipfile /usr/local/bin/a_mtbls117_DIMS_POS_mass_spectrometry.zip retcorMethod obiwarp nSlaves 4

# check that JPGs graphs have been created
# for index in `seq 1 3`; do
# if [ ! -s IPO_results/rsm_$index.jpg ]; then
#         echo "JPG graph rsm_$index.jpg not found or empty, failing test"
#         exit 1
# fi
# 
# if [ ! -s IPO_results/retgroup_rsm_$index.jpg ]; then
#         echo "JPG graph retgroup_rsm_$index.jpg not found or empty, failing test"
#         exit 1
# fi
# done


for index in `seq 1 3`; do
if [ ! -s IPO_results/rsm_$index.jpg ]; then
        echo "JPG graph rsm_$index.jpg not found or empty, failing test"
        exit 1
fi
done

for index in `seq 1 3`; do
if [ ! -s IPO_results/retgroup_rsm_$index.jpg ]; then
        echo "JPG graph retgroup_rsm_$index.jpg not found or empty, failing test"
        exit 1
fi
done


# check that RData files have been created
#if [ ! -s raw/resultPeakpicking.RData ] || [ ! -s best_xcmsSet.RData ]; then
#	echo "RData files are not found or empty, failing test"
#	exit 1
#fi

if [ ! -s ipoworkingdir/resultPeakpicking.RData ] || [ ! -s best_xcmsSet.RData ]; then
  echo "RData files are not found or empty, failing test"
  exit 1
fi

# check that tsv files have been created
#if [ ! -s raw/MM14_IPO_parameters4xcmsSet.tsv ] || [ ! -s raw/MM14_IPO_parameters4retcorGroup.tsv ] || [ ! -s run_instrument_infos.tsv ]; then
#	echo "tsv files are not found or empty, failing test"
#	exit 1
#fi

if [ ! -s ipoworkingdir/MTBLS117_IPO_parameters4xcmsSet.tsv ] || [ ! -s ipoworkingdir/MTBLS117_IPO_parameters4retcorGroup.tsv ]  || [ ! -s run_instrument_infos.tsv ]; then
  echo "tsv files are not found or empty, failing test"
  exit 1
fi

echo "massIPO runs with test data without error codes, all expected files created."

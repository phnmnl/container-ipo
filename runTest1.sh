#!/bin/bash
apt-get update -y && apt-get install -y --no-install-recommends wget ca-certificates

# download test data file
wget "https://raw.githubusercontent.com/workflow4metabolomics/ipo/master/galaxy/ipo/test-data/MM8.mzML" -O "/usr/local/bin/MM8.mzML"

# Peak picking first
ipo4xcmsSet.r singlefile_galaxyPath /usr/local/bin/MM8.mzML singlefile_sampleName MM8.mzML parametersOutput MM8_IPO_parameters4xcmsSet.tsv nSlaves 4

# Then Grouping
ipo4retgroup.r image raw/resultPeakpicking.RData parametersOutput MM8_IPO_parameters4retgroup.tsv method density singlefile_galaxyPath /usr/local/bin/MM8.mzML singlefile_sampleName MM8.mzML retcorMethod obiwarp nSlaves 4

# check that JPGs graphs have been created
for index in `seq 1 2`; do
	if [ ! -f IPO_results/rsm_$index.jpg ]; then
		echo "JPG graph rsm_$index.jpg not found, failing test"
		exit 1
	fi
	if [ ! -f IPO_results/retgroup_rsm_$index.jpg ]; then
		echo "JPG graph retgroup_rsm_$index.jpg not found, failing test"
		exit 1
	fi
done

# check that RData files have been created
if [ ! -f raw/resultPeakpicking.RData ] || [ ! -f raw/resultRetCor.RData ]; then
	echo "RData files not found, failing test"
	exit 1
fi

# check that tsv files have been created
if [ ! -f raw/MM8_IPO_parameters4xcmsSet.tsv ] || [ ! -f raw/MM8_IPO_parameters4retgroup.tsv ]; then
	echo "tsv files not found, failing test"
	exit 1
fi

echo "massIPO runs with test data without error codes, all expected files created."

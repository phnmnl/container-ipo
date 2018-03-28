#!/bin/bash
apt-get update -y && apt-get install -y --no-install-recommends wget ca-certificates

# download files path and data files
wget "https://drive.google.com/uc?export=download&id=0B7S2ZMhdzWwbMG5wOXpmU3Y1RWc" -O filesPaths_2_ms.txt
wget "https://drive.google.com/uc?export=download&id=0B7S2ZMhdzWwbUk9LdWl3SXFwQnc" -O MSpos-Ex1-Col0-48h-Ag-1_1-A,1_01_9818.mzData
wget "https://drive.google.com/uc?export=download&id=0B7S2ZMhdzWwbUk90c1Rva0Fibnc" -O MSpos-Ex1-Col0-48h-Ag-2_1-A,1_01_9820.mzData 
mkdir contTest

runIPO.R -i filesPaths_2_ms.txt -o contTest -s 2

# check that JPGs graphs have been created
for index in `seq 1 4`; do
	if [ ! -f contTest/rsm_$index.jpg ]; then
		echo "JPG graph rsm_$index.jpg not found, failing test"
		exit 1
	fi
done

echo "massIPO runs with test data without error codes, all expected files created."


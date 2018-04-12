# IPO
Version: 0.1.0

## Short Description

A Tool for automated Optimization of XCMS Parameters

## Description

Untargeted metabolomics generates a huge amount of data. Software packages for automated data processing are crucial to successfully process these data. A variety of such software packages exist, but the outcome of data processing strongly depends on algorithm parameter settings. If they are not carefully chosen, suboptimal parameter settings can easily lead to biased results. Therefore, parameter settings also require optimization. Several parameter optimization approaches have already been proposed, but a software package for parameter optimization which is free of intricate experimental labeling steps, fast and widely applicable is still missing.

The software package IPO (‘Isotopologue Parameter Optimization’)  is fast and free of labeling steps, and applicable to data from different kinds of samples and data from different methods of liquid chromatography - high resolution mass spectrometry and data from different instruments.

IPO optimizes XCMS peak picking parameters by using natural, stable 13C isotopic peaks to calculate a peak picking score. Retention time correction is optimized by minimizing relative retention time differences within peak groups. Grouping parameters are optimized by maximizing the number of peak groups that show one peak from each injection of a pooled sample. The different parameter settings are achieved by design of experiments, and the resulting scores are evaluated using response surface models. IPO was tested on three different data sets, each consisting of a training set and test set. IPO resulted in an increase of reliable groups (146% - 361%), a decrease of non-reliable groups (3% - 8%) and a decrease of the retention time deviation to one third.

IPO was successfully applied to data derived from liquid chromatography coupled to high resolution mass spectrometry from three studies with different sample types and different chromatographic methods and devices. We were also able to show the potential of IPO to increase the reliability of metabolomics data.

## Key features

- IPO optimizes XCMS peak picking parameters by using natural, stable 13C isotopic peaks to calculate a peak picking score
- Retention time correction is optimized by minimizing relative retention time differences within peak groups

## Functionality

- Optimization / Parameter Selection Optimization

## Approaches

- Metabolomics / Untargeted
  
## Instrument Data Types

- MS / LC-MS

## Tool Authors

- Gunnar Libiseller (Joanneum Research Forschungsgesellschaft m.b.H., HEALTH, Institute for Biomedicine and Health Sciences)
- Michaela Dvorzak (Joanneum Research Forschungsgesellschaft m.b.H., HEALTH, Institute for Biomedicine and Health Sciences)
- Ulrike Kleb (Joanneum Research Forschungsgesellschaft m.b.H., HEALTH, Institute for Biomedicine and Health Sciences)

## Container Contributors

- [Venkata Chandrasekhar Nainala](https://github.com/CS76) (EMBL-EBI)
- [Pablo Moreno](https://github.com/pcm32) (EMBL-EBI)
- [Philippe Rocca-Serra](https://github.com/proccaserra) (University of Oxford)
- [Gabriel Cretin](https://github.com/gabrielctn) (IPB Halle)

## Website

- https://github.com/rietho/IPO


## Git Repository

- https://github.com/phnmnl/container-ipo.git

## Usage Instructions


On the main directory, to build the image:
```
docker build -t ipo .
```

And then to run:

```
docker run ipo -i /complete/path/to/filesPaths -o /complete/path/to/out
```

On Mac OS X with docker-machine, because there is this intermediate VM, it is recommended to mount a high level directory on docker (as /Users, which will be already mounted on the docker-machine VM.

```
docker run -v /Users:/Users ipo -i /Users/yourUser/path/to/filesPaths -o /Users/yourUser/path/to/out
```

IPO has a number of options, which we have wrapped for you, to find them out please execute:

```
docker run ipo
```

## Publications

- Libiseller, G., Dvorzak, M., Kleb, U., Gander, E., Eisenberg, T., Madeo, F., ... & Magnes, C. (2015). IPO: a tool for automated optimization of XCMS parameters. BMC bioinformatics, 16(1), 1.

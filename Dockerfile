# PhenoMeNal H2020
# Microservices - IPO
# VERSION               0.1.1

FROM ubuntu:14.04

LABEL software=IPO
LABEL software.version=0.1.1
LABEL version=0.1

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

# Install R
RUN echo "deb http://mirrors.ebi.ac.uk/CRAN/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list && \
	gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
	gpg -a --export E084DAB9 | sudo apt-key add -

# R and Library Dependencies
RUN apt-get update && apt-get -y upgrade && apt-get install -y libcurl4-openssl-dev \
        libnetcdf-dev \
	libssl-dev \
	libssh2-1-dev \
	libxml2-dev \
	icu-devtools \
	netcdf-bin \
	r-base r-base-dev

# Add scripts folder to container
ADD scripts /scripts

# Add automatic repo finder for R:
RUN echo 'options("repos"="http://cran.rstudio.com")' >> /etc/R/Rprofile.site


# Install IPO
RUN Rscript /scripts/installIPO.R

# Clean up
RUN apt-get clean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

RUN chmod +x /scripts/runIPO.R

# Define Entry point script
#ENTRYPOINT ["/scripts/runIPO.R"]

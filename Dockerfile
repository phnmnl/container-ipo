# PhenoMeNal H2020
# Microservices - IPO
# VERSION               0.1

FROM ubuntu:14.04

MAINTAINER venkata chandrasekhar nainala (venkata@ebi.ac.uk / mailcs76@gmail.com)

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

# Add executable to run when container is spinned up
ADD entrypoint.sh /

# Add automatic repo finder for R:
RUN echo 'options("repos"="http://cran.rstudio.com")' >> /etc/R/Rprofile.site

# Install IPO
RUN Rscript /scripts/installIPO.R

# Define Entry point script
ENTRYPOINT ["/entrypoint.sh"]
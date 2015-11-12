# PhenoMeNal H2020
# Microservices - IPO
# VERSION               0.1

FROM ubuntu:14.04

MAINTAINER venkata chandrasekhar nainala (venkata@ebi.ac.uk / mailcs76@gmail.com)

# Install R
RUN echo "deb http://mirrors.ebi.ac.uk/CRAN/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list && \
	gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
	gpg -a --export E084DAB9 | sudo apt-key add -

# Upgrade R
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y r-base r-base-dev

# Library Dependencies
RUN apt-get install -y libnetcdf-dev && \
	apt-get install -y libcurl4-openssl-dev && \
	apt-get install -y libxml2-dev && \
	apt-get install -y libssl-dev && \
	apt-get install -y libssh2-1-dev

# Add scripts folder to container
ADD scripts /scripts

# Add executable to run when container is spinned up
ADD entrypoint.sh /

# Install IPO
RUN Rscript /scripts/installIPO.R

# Define Entry point script
ENTRYPOINT ["/entrypoint.sh"]
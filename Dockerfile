# PhenoMeNal H2020
# Microservices - IPO
FROM container-registry.phenomenal-h2020.eu/phnmnl/xcms

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL software=IPO
LABEL software.version=1.4.1
LABEL version=0.5
LABEL base.image="container-registry.phenomenal-h2020.eu/phnmnl/xcms"
LABEL description="A Tool for automated Optimization of XCMS Parameters"
LABEL website="https://github.com/phnmnl/container-ipo"
LABEL documentation="https://github.com/phnmnl/container-ipo"
LABEL license="https://github.com/phnmnl/container-ipo/blob/develop/LICENSE"
LABEL tags="Metabolomics"

# Add IPO scripts and W4M wrapper to path
ADD scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends libboost-dev libcurl4-openssl-dev libnetcdf-dev libssl-dev libssh2-1-dev libxml2-dev libxml2-utils icu-devtools netcdf-bin r-base r-base-dev && \
	echo 'options("repos"="http://cran.rstudio.com")' >> /etc/R/Rprofile.site && \
	R -e 'source("https://bioconductor.org/biocLite.R"); install.packages("devtools"); library("devtools"); install_github("sneumann/mzR"); install.packages("batch"); install.packages("rsm"); install.packages("optparse");' && \
    	R -e 'source("https://bioconductor.org/biocLite.R"); biocLite("IPO");' && \
	R -e 'remove.packages(c("devtools"))' && \
    	apt-get purge -y r-base-dev git libcurl4-openssl-dev libssl-dev libssh2-1-dev r-base-dev libboost-dev && \
	apt-get clean && apt-get autoremove -y && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Add testing to container
ADD runTest1.sh /usr/local/bin/runTest1.sh
RUN chmod +x /usr/local/bin/runTest1.sh

# Define Entry point script (Warning: may break Galaxy scripts!)
#ENTRYPOINT ["runIPO.R"]

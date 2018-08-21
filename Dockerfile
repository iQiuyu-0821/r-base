# This is a CENTOS container for Microsoft Open R with MKL 
# Using this container requires compliance with the Terms of Service
# of Microsoft R (Microsoft) and MKL (Intel)

# When building specify the version of R that you want
# Due to changes in the install script of MRO it is not advised
# to try versions much earlier than 3.3.1.

FROM centos:centos7

COPY . /app
WORKDIR /app

# Build instructions: 
# docker build -t centos7-mro . --build-arg R_VER=3.3.3
ARG R_VER
ENV R_VER=${R_VER:-3.3.3} 

# Setup EPEL && 
RUN yum -y install epel-release && yum -y update \
    && echo "LANG=en_US.utf8" >> /etc/locale.conf \
    && localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
    && export LC_ALL=en_US.UTF-8

# Install R dependencies
# this is a bit lazy right now, and should be thinned out a bit -jjl
RUN yum -y install wget make bzip2-devel gcc-c++ gcc-gfortran libX11-devel libicu-devel libxml2 \
  libxml2-devel openssl-devel pcre-devel pkgconfig tcl-devel texinfo-tex tk-devel tre-devel \
  xz-devel zlib-devel bzip2-libs cpp expat-devel fontconfig-devel freetype-devel \
  gcc glib2 glibc-devel glibc-headers kernel-headers libX11 libXau libXau-devel libXft-devel \
  libXrender-devel libffi libgcc libicu libmpc libquadmath-devel libselinux libsepol libstdc++ \
  libstdc++-devel libxcb libxcb-devel mpfr pcre perl perl-Data-Dumper perl-Text-Unidecode \
  libgfortran libgomp freetype fontconfig libXrender libpng pango-devel.x86_64 libXt-devel \
  cairo-devel.x86_64 NLopt-devel.x86_64 curl.x86_64 postgresql-devel \
  perl-libintl texinfo texlive-epsf xorg-x11-proto-devel xz-libs zlib which \
  && yum groupinstall X11 -y \
  && yum clean all


# get MRO
RUN wget https://mran.blob.core.windows.net/install/mro/${R_VER}/microsoft-r-open-${R_VER}.tar.gz \
    && tar -xf microsoft-r-open-${R_VER}.tar.gz \
    && ./microsoft-r-open/install.sh -u -a

# install need packages
RUN R -e "install.packages(c('littler','stringr','acepack','adabag','amap','arules','arulesSequences','assertthat','backports','base','base64enc','BH','bindr','bindrcpp','bit','bit64','bitops','blob','bnlearn','boot','Cairo','car','caret','checkmate','chron','class','cluster','codetools','coin','colorspace','combinat','compiler','config','crayon','crosstalk','curl','CVST','datasets','data.table','DBI','ddalpha','debugme','DEoptimR','diagram','dichromat','digest','dimRed','diptest','DistributionUtils','dplyr','DRR','dtw','dygraphs','e1071','evaluate','expm','fArma','fBasics','flexmix','fmsb','FNN','foreach','forecast','foreign','Formula','fpc','fracdiff','fUnitRoots','futile.logger','futile.options','gbm','GeneralizedHyperbolic','ggfortify','ggplot2','glmnet','glue','gower','graphics','grDevices','grid','gridExtra','gss','gsubfn','gtable','hexbin','highr','Hmisc','htmlTable','htmltools','htmlwidgets','httpuv','httr','igraph','ipred','irlba','iterators','jiebaR','jiebaRD','jsonlite','keras','kernlab','KernSmooth','kknn','klaR','knitr','ks','labeling','lambda.r','lattice','latticeExtra','lava','lazyeval','lda','leaps','lme4','lmtest','locfit','log4r','lubridate','magrittr','markdown','MASS','Matrix','MatrixModels','mclust','memoise','methods','mgcv','mime','minqa','misc3d','mlbench','ModelMetrics','modeltools','multcomp','multicool','munsell','mvtnorm','nlme','nloptr','NLP','nnet','nortest','numDeriv','openssl','parallel','party','pbkrtest','pkgconfig','plogr','plotly','plotrix','pls','plspm','plyr','prabclus','pracma','pROC','processx','prodlim','proto','proxy','purrr','qcc','quadprog','quantmod','quantreg','R2HTML','R6','randomForest','RColorBrewer','Rcpp','RcppArmadillo','RcppArmadillo-bak','RcppEigen','RcppRoll','RCurl','recipes','recommenderlab','registry','reshape','reshape2','reticulate','rgl','ridge','rJava','RJDBC','rlang','RMySQL','RMySQL-bak','robustbase','rpart','RPostgreSQL','Rserve','RSNNS','Rsolnp','RSQLite','rstudioapi','rugarch','RUnit','Rwordseg','sandwich','scales','shape','shiny','showtext','showtextdb','SkewHyperbolic','slam','SnowballC','sourcetools','SparseM','spatial','spd','splines','splitstackshape','sqldf','stabledist','stats','stats4','stringi','stringr','strucchange','survival','sysfonts','tcltk','tensorflow','tester','tfruns','TH.data','tibble','tidyr','tidyselect','timeDate','timeSeries','tm','tmcn','tools','topicmodels','tree','trimcluster','truncnorm','TSA','tseries','TTR','turner','urca','utils','viridis','viridisLite','visNetwork','whisker','withr','xtable','xts','YaleToolkit','yaml','zoo'), repos='https://mirrors.tuna.tsinghua.edu.cn/CRAN/')"

# using a symlink to get around the lack of dynamic variables in docker
# this is a slightly better way to handle setting up littler than editing 
# the text files through sed.
ENV LIBLOC /usr/lib64/R/library
RUN mkdir -p /usr/lib64/R/library

# handle litter
RUN echo ln -s /usr/lib64/microsoft-r/`ls /usr/lib64/microsoft-r/`/lib64/R/library/littler/examples/install.r /usr/local/bin/install.r > /install-littler.sh \
    && echo ln -s /usr/lib64/microsoft-r/`ls /usr/lib64/microsoft-r/`/lib64/R/library/littler/examples/install2.r /usr/local/bin/install2.r >> /install-littler.sh \
    && echo ln -s /usr/lib64/microsoft-r/`ls /usr/lib64/microsoft-r/`/lib64/R/library/littler/examples/installGithub.r /usr/local/bin/installGithub.r >> /install-littler.sh \
    && echo ln -s /usr/lib64/microsoft-r/`ls /usr/lib64/microsoft-r/`/lib64/R/library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r >> /install-littler.sh \
    && echo ln -s /usr/lib64/microsoft-r/`ls /usr/lib64/microsoft-r/`/lib64/R/library/littler/bin/r /usr/local/bin/r >> /install-littler.sh \
    && echo ln -s /usr/lib64/microsoft-r/`ls /usr/lib64/microsoft-r/`/lib64/R/library /usr/lib64/R/library  >> /install-littler.sh

RUN  bash /install-littler.sh && install.r docopt 

# Clean UP
RUN rm -rf /tmp/* \
    && rm -rf microsoft-r-open-${R_VER}.tar.gz \
    && rm -rf microsoft-r-open \
    && rm -rf install-littler.sh 

ADD start.sh /usr/local/bin/start.sh
RUN chmod 777 /usr/local/bin/start.sh
CMD /usr/local/bin/start.sh

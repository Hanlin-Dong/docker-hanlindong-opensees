FROM alpine:3.12
ENV TAG v3.2.0
RUN apk update && apk upgrade && \
    apk add sed wget bash make git gcc g++ gfortran tcl=8.6.10-r0 tcl-dev=8.6.10-r0 && \
    mkdir /home/ops && \
    cd /home/ops && \
    mkdir OpenSees bin lib && \
    cd OpenSees && \
    git init && \
    git remote add origin https://github.com/OpenSees/OpenSees.git && \
    git config core.sparsecheckout true && \
    echo "/SRC" >> .git/info/sparse-checkout && \
    echo "/OTHER" >> .git/info/sparse-checkout && \
    echo "/Makefile" >> .git/info/sparse-checkout && \
    echo "/MAKES/Makefile.def.EC2-UBUNTU" >> .git/info/sparse-checkout && \
    echo "/DEVELOPER" >> .git/info/sparse-checkout && \
    git pull origin master --tags && \
    git checkout $TAG && \
    cp MAKES/Makefile.def.EC2-UBUNTU Makefile.def && \
    sed -i 's#INTERPRETER_LANGUAGE = PYTHON#INTERPRETER_LANGUAGE = TCL#' Makefile.def && \
    sed -i 's#HOME\t\t= ./home#HOME\t\t= /home/ops#' Makefile.def && \
    sed -i 's#/usr/lib/x86_64-linux-gnu/libtcl8.6.so#/usr/lib/libtcl8.6.so#' Makefile.def && \
    make
WORKDIR /data
ENV PATH $PATH:/home/ops/bin
VOLUME ["/data"]
CMD ["OpenSees"]

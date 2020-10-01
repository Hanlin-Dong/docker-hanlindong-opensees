FROM jupyter/datascience-notebook:latest
ENV TAG v3.2.0
USER root
RUN cd /home && \
    wget --no-check-certificate https://downloads.sourceforge.net/project/tcl/Tcl/8.6.10/tcl8.6.10-src.tar.gz && \
    tar -xzvf tcl8.6.10-src.tar.gz && \
    cd /home/tcl8.6.10/unix && \
    ./configure && \
    make && \
    make install && \
    cd /home && \
    mkdir OpenSees bin lib && \
    cd OpenSees && \
    git init && \
    git remote add origin https://github.com/OpenSees/OpenSees.git && \
    git pull origin master --tags && \
    git checkout $TAG && \
    cp MAKES/Makefile.def.EC2-UBUNTU Makefile.def && \
    sed -i 's#INTERPRETER_LANGUAGE = PYTHON#INTERPRETER_LANGUAGE = TCL#' Makefile.def && \
    sed -i 's#HOME\t\t= ./home#HOME\t\t= /home#' Makefile.def && \
    sed -i 's#/usr/lib/x86_64-linux-gnu/libtcl8.6.so#/usr/local/lib/libtcl8.6.so#' Makefile.def && \
    make && \
    cd /home && \
    rm tcl8.6.10-src.tar.gz && \
    rm -r tcl8.6.10/
USER jovyan
ENV PATH $PATH:/home/bin

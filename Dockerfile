FROM alpine:3.11
RUN apk update && \
    apk add sed wget bash make git gcc g++ gfortran && \
    cd /home && \
    wget --no-check-certificate https://downloads.sourceforge.net/project/tcl/Tcl/8.6.10/tcl8.6.10-src.tar.gz && \
    tar -xzvf tcl8.5.18-src.tar.gz && \
    cd /home/tcl8.5.18/unix && \
    ./configure && \
    make && \
    make install && \
    cd /home && \
    mkdir OpenSees bin lib && \
    cd OpenSees && \
    git init && \
    git remote add origin https://github.com/OpenSees/OpenSees.git && \
    git config core.sparsecheckout true && \
    echo "/SRC" >> .git/info/sparse-checkout && \
    echo "/OTHER" >> .git/info/sparse-checkout && \
    echo "/Makefile" >> .git/info/sparse-checkout && \
    echo "/MAKES/Makefile.def.EC2-UBUNTU" >> .git/info/sparse-checkout && \
    git pull --depth 1 origin master && \
    cp /MAKES/Makefile.def.EC2-UBUNTU /Makefile.def && \
    sed -i 's#INTERPRETER_LANGUAGE = PYTHON#INTERPRETER_LANGUAGE = TCL' Makefile.def && \
    sed -i 's#HOME\t\t= ./home#HOME\t\t= /home#' Makefile.def && \
    sed -i 's#/usr/lib/x86_64-linux-gnu/libtcl8.6.so#/usr/local/lib/libtcl8.6.so#' Makefile.def && \
    make && \
    cd /home && \
    rm tcl8.6.10-src.tar.gz && \
    rm -r OpenSees/ && \
    rm -r tcl8.6.10/ && \
    rm -r lib/ && \
    apk del git make wget sed
WORKDIR /data
ENV PATH $PATH:/home/bin
VOLUME ["/data"]
CMD ["OpenSees"]

FROM alpine:3.7
MAINTAINER Hanlin Dong <https://github.com/Hanlin-Dong>
ENV REVISION 6258
RUN apk update && \
apk add sed wget bash make subversion gcc g++ gfortran && \
cd /home && \
mkdir OpenSees bin lib && \
svn co -r $REVISION svn://peera.berkeley.edu/usr/local/svn/OpenSees/trunk/SRC OpenSees/SRC && \
svn co -r $REVISION svn://peera.berkeley.edu/usr/local/svn/OpenSees/trunk/OTHER OpenSees/OTHER && \
svn cat -r $REVISION svn://peera.berkeley.edu/usr/local/svn/OpenSees/trunk/Makefile > OpenSees/Makefile && \
svn cat -r $REVISION svn://peera.berkeley.edu/usr/local/svn/OpenSees/trunk/MAKES/Makefile.def.EC2-UBUNTU > OpenSees/Makefile.def && \
sed -i 's#HOME\t\t= /home/ubuntu#HOME\t\t= /home#' OpenSees/Makefile.def && \
sed -i 's#/usr/lib/libtcl8.5.so#/usr/local/lib/libtcl8.5.so#' OpenSees/Makefile.def && \
wget --no-check-certificate https://sourceforge.net/projects/tcl/files/Tcl/8.5.18/tcl8.5.18-src.tar.gz && \
tar -xzvf tcl8.5.18-src.tar.gz && \
cd /home/tcl8.5.18/unix && \
./configure && \
make && \
make install && \
cd /home/OpenSees && \
make && \
cd /home && \
rm tcl8.5.18-src.tar.gz && \
rm -r OpenSees/ && \
rm -r tcl8.5.18/ && \
rm -r lib/ && \
apk del subversion make wget sed
WORKDIR /data
ENV PATH $PATH:/home/bin
VOLUME ["/data"]
CMD ["OpenSees"]

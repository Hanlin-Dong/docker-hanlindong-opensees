FROM hanlindong/opensees:developer
COPY ./doweltype-sourcecode/. /home/ops/OpenSees/DEVELOPER/material/doweltype/
RUN cd /home/ops/OpenSees/DEVELOPER/material/doweltype && make
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/home/ops/OpenSees/DEVELOPER/material/doweltype
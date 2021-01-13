FROM alpine:edge
WORKDIR /data
COPY ./OpenSees /bin/OpenSees
RUN apk update && apk upgrade && \
    apk add bash libstdc++ libgfortran tcl tcl-dev && \
    apk add build-base python3 py3-pip python3-dev py3-numpy py3-matplotlib py3-pandas libffi-dev zeromq-dev freetype-dev libpng-dev && \
    pip install jupyter && \
    adduser -h /data -D -s /bin/bash opsuser
EXPOSE 8888
USER opsuser
VOLUME ["/data"]
CMD ["jupyter", "notebook", "--no-browser", "--ip=*"]

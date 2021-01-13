FROM alpine:3.12
WORKDIR /data
COPY ./OpenSees /bin/OpenSees
RUN apk update && apk upgrade && \
    apk add --no-cache bash libstdc++ libgfortran tcl=8.6.10-r0 tcl-dev=8.6.10-r0
VOLUME ["/data"]
CMD ["OpenSees"]

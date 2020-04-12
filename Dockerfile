FROM hanlindong/opensees:fat
WORKDIR /data
RUN apk add py3-gevent && \
    pip install pyyaml flask flask-cors gunicorn
COPY . .
EXPOSE 80
CMD ["gunicorn", "app:app", "-c", "./gunicorn.conf.py"]

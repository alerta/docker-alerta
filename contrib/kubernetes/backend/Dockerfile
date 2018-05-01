FROM python:3.6.5
ENV PYTHONUNBUFFERED 1

ARG VERSION

RUN apt-get update && apt-get install -y \
    mongodb-clients \
    postgresql-client \
    gettext

RUN pip install uwsgi alerta alerta-server==$VERSION

WORKDIR /app

COPY wsgi.py /app/wsgi.py
COPY uwsgi.ini.template /app/uwsgi.ini.template

ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE /app/alerta.conf
ENV ALERTA_WEB_CONF_FILE /web/config.js

ENV BASE_URL /
ENV INSTALL_PLUGINS ""

EXPOSE 8080

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["uwsgi", "--ini", "/app/uwsgi.ini"]

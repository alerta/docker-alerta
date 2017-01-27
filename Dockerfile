
FROM ubuntu:latest
MAINTAINER Nick Satterly <nick.satterly@theguardian.com>

RUN apt-get update && apt-get install -y \
    build-essential \
    cron \
    git \
    libffi-dev \
    mongodb-clients \
    nginx \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    wget

RUN set -x && \
  pip install pip --upgrade && \
  pip install uwsgi supervisor alerta-server alerta

RUN wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
RUN set -x && \
  mv alerta-angular-alerta-webui-*/app /app && \
  rm -Rf /alerta-angular-alerta-webui-* && \
  mv /app/config.js /app/config.js.orig

ENV ALERTA_SVR_CONF_FILE /etc/alertad.conf
ENV ALERTA_WEB_CONF_FILE /app/config.js
ENV ALERTA_CONF_FILE /root/alerta.conf

ENV BASE_URL /api
ENV PROVIDER basic
ENV CLIENT_ID not-set
ENV CLIENT_SECRET not-set

RUN echo "from alerta.app import app" >/wsgi.py
ADD uwsgi.ini /uwsgi.ini
ADD nginx.conf /nginx.conf
ADD housekeepingAlerts.js /housekeepingAlerts.js
ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

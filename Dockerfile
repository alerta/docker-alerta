FROM python:3
ENV PYTHONUNBUFFERED 1

LABEL maintainer="Nick Satterly <nick.satterly@gmail.com>"
LABEL version="5.0.11"
LABEL url="https://alerta.io"
LABEL vcs-url="https://github.com/alerta/docker-alerta"

RUN groupadd -r alerta && useradd --no-log-init -r -g alerta alerta

RUN apt-get update && apt-get install -y \
    git \
    libffi-dev \
    libpq-dev \
    mongodb-clients \
    nginx \
    postgresql-client \
    postgresql-client-common \
    python3-dev \
    supervisor \
    wget

RUN pip install --no-cache-dir virtualenv && \
    virtualenv --python=python3 /venv && \
    /venv/bin/pip install uwsgi alerta alerta-server
ENV PATH $PATH:/venv/bin

ADD https://github.com/alerta/angular-alerta-webui/archive/master.tar.gz /tmp/web.tar.gz
RUN tar zxvf /tmp/web.tar.gz -C /tmp && \
    mv /tmp/angular-alerta-webui-master/app /web && \
    mv /web/config.js /web/config.js.orig

COPY wsgi.py /app/wsgi.py
COPY uwsgi.ini /app/uwsgi.ini

COPY nginx.conf /app/nginx.conf
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

RUN chown -R alerta:alerta /app /venv /web
USER alerta:alerta

ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE /app/alerta.conf
ENV ALERTA_WEB_CONF_FILE /web/config.js

ENV BASE_URL /api
ENV PROVIDER basic
ENV INSTALL_PLUGINS ""

EXPOSE 80

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY supervisord.conf /app/supervisord.conf
CMD ["supervisord", "-c", "/app/supervisord.conf"]

FROM node:14 AS gr-main

ARG WEBUI_SHA
WORKDIR /tmp
RUN curl -Ls -O https://github.com/g-research/alerta-webui/archive/$WEBUI_SHA.zip \
  && unzip $WEBUI_SHA.zip \
  && rm $WEBUI_SHA.zip \
  && cd alerta-webui-$WEBUI_SHA \
  && npm install \
  && npm run build

FROM python:3.8-slim-buster

ENV PYTHONUNBUFFERED 1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

ARG WEBUI_SHA

ENV SERVER_VERSION=8.7.0
ENV CLIENT_VERSION=8.5.1
ENV WEBUI_SHA=$WEBUI_SHA

ENV NGINX_WORKER_PROCESSES=1
ENV NGINX_WORKER_CONNECTIONS=1024

ENV UWSGI_PROCESSES=5
ENV UWSGI_LISTEN=100
ENV UWSGI_BUFFER_SIZE=8192

ENV HEARTBEAT_SEVERITY=major
ENV HK_EXPIRED_DELETE_HRS=2
ENV HK_INFO_DELETE_HRS=12

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    gnupg2 \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    postgresql-client \
    python3-dev \
    supervisor \
    xmlsec1 && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    echo "deb https://nginx.org/packages/debian/ buster nginx" | tee /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3008
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - && \
    echo "deb https://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    mongodb-org-shell && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY requirements*.txt /app/
# hadolint ignore=DL3013
RUN pip install --no-cache-dir pip virtualenv jinja2 && \
    python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade setuptools && \
    /venv/bin/pip install --no-cache-dir --requirement /app/requirements.txt && \
    /venv/bin/pip install --no-cache-dir --requirement /app/requirements-docker.txt
ENV PATH $PATH:/venv/bin

RUN /venv/bin/pip install alerta==${CLIENT_VERSION} alerta-server==${SERVER_VERSION}
COPY install-plugins.sh /app/install-plugins.sh
COPY plugins.txt /app/plugins.txt
RUN /app/install-plugins.sh

COPY --from=gr-main /tmp/alerta-webui-$WEBUI_SHA/dist /web

ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE /app/alerta.conf
ENV ALERTA_WEB_CONF_FILE /web/config.json

COPY config/templates/app/ /app
COPY config/templates/web/ /web

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN chgrp -R 0 /app /venv /web && \
    chmod -R g=u /app /venv /web && \
    useradd -u 1001 -g 0 -d /app alerta

USER 1001

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 1717
CMD ["supervisord", "-c", "/app/supervisord.conf"]

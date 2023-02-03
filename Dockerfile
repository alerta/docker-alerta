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

ARG WEBUI_SHA
ARG CONTRIB_SHA

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    SERVER_VERSION=8.7.0 \
    CLIENT_VERSION=8.5.1 \
    WEBUI_SHA=$WEBUI_SHA \
    CONTRIB_SHA=$CONTRIB_SHA \
    NGINX_WORKER_PROCESSES=1 \
    NGINX_WORKER_CONNECTIONS=1024 \
    UWSGI_PROCESSES=5 \
    UWSGI_LISTEN=100 \
    UWSGI_BUFFER_SIZE=8192 \
    HEARTBEAT_SEVERITY=major \
    HK_EXPIRED_DELETE_HRS=2 \
    HK_INFO_DELETE_HRS=12

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
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    curl -fsSL https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - && \
    echo "deb https://nginx.org/packages/debian/ buster nginx" | tee /etc/apt/sources.list.d/nginx.list && \
    # hadolint ignore=DL3008
    echo "deb https://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nginx mongodb-org-shell && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY requirements*.txt install-plugins.sh plugins.txt /app/ 
# hadolint ignore=DL3013
RUN pip install --no-cache-dir pip virtualenv jinja2 && \
    python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade setuptools && \
    /venv/bin/pip install --no-cache-dir --requirement /app/requirements.txt && \
    /venv/bin/pip install --no-cache-dir --requirement /app/requirements-docker.txt
ENV PATH $PATH:/venv/bin

RUN /venv/bin/pip install alerta==${CLIENT_VERSION} alerta-server==${SERVER_VERSION} && \
    sed -i "s/gr-main/$CONTRIB_SHA/g" /app/plugins.txt && \
    bash -x /app/install-plugins.sh

COPY --from=gr-main /tmp/alerta-webui-$WEBUI_SHA/dist /web

ENV ALERTA_SVR_CONF_FILE=/app/alertad.conf \
    ALERTA_CONF_FILE=/app/alerta.conf \
    ALERTA_WEB_CONF_FILE=/web/config.json

COPY config/templates/app/ /app
COPY config/templates/web/ /web

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log && \
    chgrp -R 0 /app /venv /web && \
    chmod -R g=u /app /venv /web && \
    useradd -u 1001 -g 0 -d /app alerta

USER 1001

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 1717
CMD ["supervisord", "-c", "/app/supervisord.conf"]

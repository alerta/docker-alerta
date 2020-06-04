FROM python:3.7

ENV PYTHONUNBUFFERED 1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

LABEL maintainer="Nick Satterly <nick.satterly@gmail.com>"

ARG BUILD_DATE=now
ARG VCS_REF
ARG VERSION

ARG SERVER_VERSION=${VERSION}
ARG CLIENT_VERSION=7.5.1
ARG WEBUI_VERSION=7.5.1

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.url="https://alerta.io" \
      org.label-schema.vcs-url="https://github.com/alerta/docker-alerta" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0.0-rc.1"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - && \
    echo "deb https://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gettext-base \
    libffi-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    nginx-light \
    postgresql-client \
    python3-dev \
    supervisor \
    wget \
    mongodb-org-shell && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
# hadolint ignore=DL3013
RUN pip install pip virtualenv && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade setuptools && \
    /venv/bin/pip install -r /app/requirements.txt
ENV PATH $PATH:/venv/bin

RUN /venv/bin/pip install alerta==${CLIENT_VERSION} alerta-server==${SERVER_VERSION}
COPY install-plugins.sh /app/install-plugins.sh
COPY plugins.txt /app/plugins.txt
RUN /app/install-plugins.sh

COPY install-webhooks.sh /app/install-webhooks.sh
COPY webhooks.txt /app/webhooks.txt
RUN /app/install-webhooks.sh

ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE /app/alerta.conf

ADD https://github.com/alerta/alerta-webui/releases/download/v${WEBUI_VERSION}/alerta-webui.tar.gz /tmp/webui.tar.gz
RUN tar zxvf /tmp/webui.tar.gz -C /tmp && \
    mv /tmp/dist /web
COPY config.json /web/config.json

COPY wsgi.py /app/wsgi.py
COPY uwsgi.ini /app/uwsgi.ini
COPY nginx.conf /app/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN chgrp -R 0 /app /venv /web && \
    chmod -R g=u /app /venv /web && \
    useradd -u 1001 -g 0 alerta

USER 1001

ENV HEARTBEAT_SEVERITY major

COPY docker-entrypoint.sh /usr/local/bin/
COPY supervisord.conf /app/supervisord.conf

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080
CMD ["supervisord", "-c", "/app/supervisord.conf"]

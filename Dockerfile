FROM python:3.6
ENV PYTHONUNBUFFERED 1

LABEL maintainer="Nick Satterly <nick.satterly@gmail.com>"

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.url="https://alerta.io" \
      org.label-schema.vcs-url="https://github.com/alerta/docker-alerta" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0.0-rc.1"

RUN apt-get update && apt-get install -y \
    gettext-base \
    git \
    libffi-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    mongodb-clients \
    nginx \
    postgresql-client \
    postgresql-client-common \
    python3-dev \
    supervisor \
    wget

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir virtualenv && \
    virtualenv --python=python3 /venv && \
    /venv/bin/pip install -r /app/requirements.txt
ENV PATH $PATH:/venv/bin

RUN /venv/bin/pip install alerta alerta-server==$VERSION
COPY install-plugins.sh /app/install-plugins.sh
COPY plugins.txt /app/plugins.txt
RUN /app/install-plugins.sh

ADD https://github.com/alerta/alerta-webui/releases/download/v${VERSION}/alerta-webui.tar.gz /tmp/webui.tar.gz
RUN tar zxvf /tmp/webui.tar.gz -C /tmp && \
    mv /tmp/dist /web
COPY config.json.template /web/config.json.template

COPY wsgi.py /app/wsgi.py
COPY uwsgi.ini /app/uwsgi.ini
COPY nginx.conf /app/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stdout /var/log/nginx/error.log
RUN chgrp -R 0 /app /venv /web && \
    chmod -R g=u /app /venv /web && \
    useradd -u 1001 -g 0 alerta

USER 1001

ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE /app/alerta.conf
ENV ALERTA_WEB_CONF_FILE /web/config.json
ENV HEARTBEAT_SEVERITY major

ENV BASE_URL /api

EXPOSE 8080

COPY docker-entrypoint.sh /
COPY supervisord.conf /app/supervisord.conf

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/app/supervisord.conf"]

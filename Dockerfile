FROM python:3.6-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="Nick Satterly <nick.satterly@gmail.com>" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.url="https://alerta.io" \
      org.label-schema.vcs-url="https://github.com/alerta/docker-alerta" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.version=${VERSION} \
      org.label-schema.schema-version="1.0.0-rc.1"

ENV PATH ${PATH}:/venv/bin \
    ALERTA_SVR_CONF_FILE /app/alertad.conf \
    ALERTA_CONF_FILE     /app/alerta.conf \
    ALERTA_WEB_CONF_FILE /web/config.json \
    BASE_URL             /api \
    INSTALL_PLUGINS      "" \
    PYTHONUNBUFFERED     1

RUN apk --no-cache add \
      bash \
      gettext \
      mongodb-tools\
      nginx \
      postgresql-client \
      supervisor \
      wget \
      libuuid \
      git \
 && apk --no-cache add --virtual .build-deps \
      build-base \
      cyrus-sasl-dev \
      gcc \
      libffi-dev \
      linux-headers \
      openldap-dev \
      postgresql-dev \
      python3-dev \
    && pip install --no-cache-dir virtualenv \
    && virtualenv --python=python3 /venv \
    && /venv/bin/pip install uwsgi alerta alerta-server==${VERSION} \
    && apk del .build-deps

RUN wget -q -O - "https://github.com/alerta/angular-alerta-webui/archive/v${VERSION}.tar.gz" |  tar xzf - -C /tmp/  \
 && mv /tmp/angular-alerta-webui-${VERSION}/app /web \
 && mv /web/config.json /web/config.json.orig \
 && rm -fr /tmp/angular-alerta-webui-${VERSION}

COPY slash/ /

RUN adduser -S -h /app -u 1001 -g 0 alerta \
 && chgrp -R 0 /app /venv /web \
 && chmod -R g=u /app /venv /web

USER 1001
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/app/supervisord.conf"]

FROM python:3.6

LABEL maintainer="Nick Satterly <nick.satterly@gmail.com>" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.url="https://alerta.io" \
      org.label-schema.vcs-url="https://github.com/alerta/docker-alerta" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.version=${VERSION} \
      org.label-schema.schema-version="1.0.0-rc.1"

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV PATH ${PATH}:/venv/bin
ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE     /app/alerta.conf
ENV ALERTA_WEB_CONF_FILE /web/config.json
ENV BASE_URL             /api
ENV INSTALL_PLUGINS      ""
ENV PYTHONUNBUFFERED     1
ENV HEARTBEAT_ALERT_SEVERITY major

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gettext-base \
      libffi-dev \
      libldap2-dev \
      libpq-dev \
      libsasl2-dev \
      mongodb-clients \
      nginx-light \
      postgresql-client \
      python3-dev \
      supervisor \
      wget \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir virtualenv \
 && virtualenv --python=python3 /venv \
 && /venv/bin/pip install uwsgi alerta alerta-server==${VERSION}

RUN wget -q -O - "https://github.com/alerta/angular-alerta-webui/archive/v${VERSION}.tar.gz" |  tar xzf - -C /tmp/  \
 && mv /tmp/angular-alerta-webui-${VERSION}/app /web \
 && mv /web/config.json /web/config.json.orig \
 && rm -fr /tmp/angular-alerta-webui-${VERSION}

COPY slash/ /

RUN chgrp -R 0 /app /venv /web \
 && chmod -R g=u /app /venv /web \
 && useradd -r -d /app -u 1001 -g 0 alerta

USER 1001
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/app/supervisord.conf"]

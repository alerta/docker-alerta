FROM alerta/alerta-web

USER root
RUN apt-get install -y \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev
USER 1001

RUN /venv/bin/pip install python-ldap

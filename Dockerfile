
FROM ubuntu:latest
MAINTAINER Nick Satterly <nick.satterly@theguardian.com>

RUN apt-get update && apt-get install -y git wget build-essential python python-setuptools python-pip python-dev libffi-dev nginx

RUN pip install --upgrade pip
RUN pip install uwsgi supervisor
RUN pip install alerta-server alerta

RUN wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
RUN mv alerta-angular-alerta-webui-*/app /app

ENV ALERTA_SVR_CONF_FILE /alertad.conf
ENV BASE_URL /api
ENV AUTH_REQUIRED False
ENV ADMIN_USERS not-set
ENV CUSTOMER_VIEWS False
ENV PROVIDER basic
ENV CLIENT_ID not-set
ENV CLIENT_SECRET not-set
ENV ALLOWED_EMAIL_DOMAIN *
ENV ALLOWED_GITHUB_ORGS *
ENV GITLAB_URL not-set
ENV ALLOWED_GITLAB_GROUPS *
ENV PLUGINS reject
ENV ORIGIN_BLACKLIST not-set
ENV ALLOWED_ENVIRONMENTS Production,Development

ADD config.js.sh /config.js.sh
ADD alertad.conf.sh /alertad.conf.sh
RUN echo "from alerta.app import app" >/wsgi.py
ADD uwsgi.ini /uwsgi.ini
ADD nginx.conf /nginx.conf
ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80
CMD /config.js.sh && /alertad.conf.sh && supervisord -c /etc/supervisord.conf

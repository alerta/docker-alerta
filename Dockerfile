
FROM ubuntu:latest
MAINTAINER Nick Satterly <nick.satterly@theguardian.com>

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git wget build-essential python python-setuptools python-pip python-dev nginx

RUN wget -q -O - https://github.com/guardian/alerta/tarball/release/3.2 | tar zxf -
RUN mv guardian-alerta-* /api
RUN pip install -r /api/requirements.txt
RUN pip install gunicorn supervisor


RUN wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
RUN mv alerta-angular-alerta-webui-*/app /app

ADD nginx.conf /nginx.conf

ADD config.js.sh /config.js.sh
ADD settings.py.sh /settings.py.sh

ENV AUTH_REQUIRED False
ENV CLIENT_ID not-set
ENV REDIRECT_URL not-set
ENV ALLOWED_EMAIL_DOMAIN *

ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80
CMD /config.js.sh && /settings.py.sh && supervisord -n


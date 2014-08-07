
FROM ubuntu:latest
MAINTAINER Nick Satterly <nick.satterly@theguardian.com>

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git wget build-essential python python-setuptools python-pip python-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 libapache2-mod-wsgi

RUN wget -q -O - https://github.com/guardian/alerta/tarball/release/3.2 | tar zxf -
RUN mv guardian-alerta-* /api
RUN pip install -r /api/requirements.txt

RUN echo "#!/usr/bin/env python"                      >/api/alerta/app/app.wsgi
RUN echo "import sys ; sys.path.insert(0, '/api')"   >>/api/alerta/app/app.wsgi
RUN echo "from alerta.app import app as application" >>/api/alerta/app/app.wsgi

RUN wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
RUN mv alerta-angular-alerta-webui-*/app /app

COPY alerta.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir /logs && chmod 777 /logs

ADD config.js.sh /config.js.sh
ADD settings.py.sh /settings.py.sh
ADD start.sh /start.sh

ENV AUTH_REQUIRED False
ENV CLIENT_ID not-set
ENV REDIRECT_URL not-set
ENV ALLOWED_EMAIL_DOMAIN *

EXPOSE 80
CMD /config.js.sh && /settings.py.sh && /start.sh


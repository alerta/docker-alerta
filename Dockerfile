
FROM ubuntu:latest
MAINTAINER Nick Satterly <nick.satterly@theguardian.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

RUN apt-get update
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git wget build-essential python python-setuptools python-pip python-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 libapache2-mod-wsgi mongodb-org openssh-server supervisor

RUN mkdir -p /data/db
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd

RUN wget -q -O - https://github.com/guardian/alerta/tarball/release/3.2 | tar zxf -
RUN mv guardian-alerta-* /api
RUN pip install -r /api/requirements.txt

RUN echo "#!/usr/bin/env python"                    >/api/alerta/app/app.wsgi
RUN echo "import sys ; sys.path.insert(0, '/api')" >>/api/alerta/app/app.wsgi
RUN echo "from alerta.app import app as application"   >>/api/alerta/app/app.wsgi

RUN wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
RUN mv alerta-angular-alerta-webui-*/app /app

RUN echo "ServerName localhost" >>/etc/apache2/apache2.conf
COPY alerta.conf /etc/apache2/sites-available/000-default.conf

ENV CLIENT_ID google-oauth-client-id
ENV REDIRECT_URL http://www.example.com/callback.html

COPY settings.py /api/alerta/settings.py
RUN echo "LOG_FILE = None"                        >/api/alerta/settings.py
RUN echo "USE_SYSLOG = False"                    >>/api/alerta/settings.py
RUN echo "GOOGLE_OAUTH_CLIENT_ID = '$CLIENT_ID'" >>/api/alerta/settings.py
RUN echo "ALLOWED_EMAIL_DOMAINS = ['gmail.com']" >>/api/alerta/settings.py

RUN sed -i -e s,CLIENT_ID,$CLIENT_ID, \
           -e s,REDIRECT_URL,$REDIRECT_URL, \
           /app/config.js

EXPOSE 22 80
CMD ["/usr/bin/supervisord", "-n"]

FROM ubuntu

RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    snmptrapd \
    snmp \
    snmp-mibs-downloader

ENV MIBS +ALL

ADD snmptrapd.conf.sh /snmptrapd.conf.sh
RUN /snmptrapd.conf.sh

RUN pip3 install git+https://github.com/alerta/alerta-contrib.git#subdirectory=integrations/snmptrap

EXPOSE 162/udp

CMD ["snmptrapd", "-f", "-Lo", "-n", "-m+ALL", "-Dtrap"]

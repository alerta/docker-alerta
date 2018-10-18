FROM nginx:1.13

ADD https://github.com/alerta/angular-alerta-webui/archive/master.tar.gz /tmp/web.tar.gz
RUN tar zxvf /tmp/web.tar.gz -C /tmp && \
    rm -rf /usr/share/nginx/html && \
    mv /tmp/angular-alerta-webui-master/app /usr/share/nginx/html && \
    mv /usr/share/nginx/html/config.json /usr/share/nginx/html/config.json.orig


ENV ALERTA_API_SERVER 'http://alerta:8080/'

COPY config.json.template /usr/share/nginx/html/config.json.template
COPY alerta-frontend-entrypoint.sh /alerta-frontend-entrypoint.sh

ENTRYPOINT ["/alerta-frontend-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

FROM nginx:1.13

ADD https://github.com/alerta/angular-alerta-webui/archive/master.tar.gz /tmp/web.tar.gz
RUN tar zxvf /tmp/web.tar.gz -C /tmp && \
    rm -rf /usr/share/nginx/html && \
    mv /tmp/angular-alerta-webui-master/app /usr/share/nginx/html && \
    mv /usr/share/nginx/html/config.js /usr/share/nginx/html/config.js.orig


ENV ALERTA_API_SERVER '"http://"+window.location.hostname+":8080"'
ENV AUTH_PROVIDER basic
ENV CLIENT_ID "INSERT-CLIENT-ID-HERE"
ENV GITHUB_URL ""
ENV GITLAB_URL "https://gitlab.com"
ENV KEYCLOAK_URL "https://keycloak.example.org"
ENV KEYCLOAK_REALM "master"
ENV PINGFEDERATE_URL "https://pingfederate.example.org"
ENV COLORS {}
ENV SEVERITY {}
ENV AUDIO {}
ENV TRACKING_ID ""

COPY config.js.template /usr/share/nginx/html/config.js.template
COPY alerta-frontend-entrypoint.sh /alerta-frontend-entrypoint.sh

ENTRYPOINT ["/alerta-frontend-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

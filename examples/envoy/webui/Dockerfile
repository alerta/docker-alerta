# build stage
FROM node:14-alpine as build-stage
RUN apk add --no-cache python3 py3-pip make g++
RUN apk add --no-cache git
WORKDIR /app
ADD https://github.com/alerta/alerta-webui/archive/master.tar.gz /tmp/webui.tar.gz
RUN tar zxvf /tmp/webui.tar.gz -C /app --strip-components=1
RUN npm install
COPY .env .
RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /app/dist /app
COPY config.json /app/config.json
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

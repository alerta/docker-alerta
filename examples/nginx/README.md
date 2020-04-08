# NGINX Reverse Proxy Example

This is an example configuration to demonstrate how to proxy
the web UI and Alerta API on a non-root URL sub-path.

## Containers

- nginx reverse proxy
- webui (custom built image)
- api (using official docker image)
- db (postgres image)

## Run

    $ cd examples/nginx
    $ docker-compose build
    $ docker-compose up

## Endpoints

- web UI => http://local.alerta.io/alerta/ui 
- API    => http://local.alerta.io/alerta/api

## References

https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/

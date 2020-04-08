# Apache Reverse Proxy Example

This is an example configuration to demonstrate how to proxy
the web UI and Alerta API on a non-root URL sub-path using Apache.

## Containers

- apache httpd as reverse proxy
- webui (custom built image)
- api (using official docker image)
- db (postgres image)

## Run

    $ cd examples/apache
    $ docker-compose build
    $ docker-compose up -d
    $ docker-compose up -d --scale webui=2
    $ docker-compose up -d --scale api=3

## Endpoints

- web UI => <http://local.alerta.io:8000/web>
- API    => <http://local.alerta.io:8000/api>

## References

<https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html>

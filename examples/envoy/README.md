# Envoy Proxy Example

This is an example configuration to demonstrate how to proxy
the web UI and Alerta API on a non-root URL sub-path using Envoy.

## Containers

- envoy proxy
- webui (custom built image)
- api (using official docker image)
- db (postgres image)

## Run

    $ cd examples/envoy
    $ docker-compose build
    $ docker-compose up -d
    $ docker-compose up -d --scale webui=2
    $ docker-compose up -d --scale api=3

## Endpoints

- web UI => <http://local.alerta.io:8000/alerta/ui>
- API    => <http://proxy.local.alerta.io:8000/alerta/api/>

## References

<https://www.envoyproxy.io/learn/on-your-laptop>

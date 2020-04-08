# Traefik Reverse Proxy Example

This is an example configuration to demonstrate how to proxy
the web UI and Alerta API on a non-root URL sub-path using Traefik.

## Containers

- traefik reverse proxy
- webui (custom built image)
- api (using official docker image)
- db (postgres image)

## Run

    $ cd examples/nginx
    $ docker-compose build
    $ docker-compose up -d
    $ docker-compose up -d --scale webui=2
    $ docker-compose up -d --scale api=3

## Endpoints

- web UI => <http://local.alerta.io:8000/web>
- API    => <http://api.local.alerta.io:8000>
- Traefik => <http://traefik.local.alerta.io:8080>

## References

<https://docs.traefik.io/getting-started/quick-start/>
<https://docs.traefik.io/v2.0/middlewares/addprefix/>
<https://docs.traefik.io/v2.0/middlewares/stripprefix/>


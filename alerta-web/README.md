
Usage
-----

    $ docker run --name alerta-db -d mongo
    $ docker run --name alerta-web --link alerta-db:mongo -d -P alerta/web


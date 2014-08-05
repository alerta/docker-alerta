
alerta
======

Alerta monitoring tool for consolidation of alerts.

Usage
-----

To use this image run a mongo container first:

    $ docker run --name alerta-db -d mongo

Then link to the mongo container when running the alerta container:

    $ docker run --name alerta-web --link alerta-db:mongo -d -P alerta/alerta-web    


License
-------

Copyright (c) 2014 Nick Satterly. Available under the MIT License.


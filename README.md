
alerta
======

Alerta monitoring tool for consolidated view of alerts

Installation
------------

To use this image run a `mongo` container first:

    $ docker run --name alerta-db -d mongo

Update to the latest image:

    $ docker pull alerta/alerta-web

Then link to the `mongo` container when running the alerta container:

    $ docker run --name alerta-web --link alerta-db:mongo -d -p <port>:80 alerta/alerta-web

The API endpoint is at:

    http://<docker>:<port>/api

Browse to the alerta console at:

    http://<docker>:<port>/

To check running processes and tail the application and web server logs:

    $ docker top alerta-web
    $ docker logs -f alerta-web

Configuration
-------------

To make it easy to get going with alerta on docker quickly, the default image
will use Basic Auth for user logins.

To allow users to login using Google OAuth, go to the [Google Developer Console][1]
and create a new client ID for a web application. Then set the `CLIENT_ID`
and `CLIENT_SECRET` environment variables on the command line to `docker run`
as follows:

    $ export CLIENT_ID=379647311730-6tfdcopl5fodke08el52nnoj3x8mpl3.apps.googleusercontent.com
    $ export CLIENT_SECRET=UpJxs02c_bx9GlI3X8MPL3-p

Now pass in the defined environment variables to the `docker run` command:

    $ docker run --link alerta-db:mongo -e PROVIDER=google -e CLIENT_ID=$CLIENT_ID -e CLIENT_SECRET=$CLIENT_SECRET -d -p <port>:80 alerta/alerta-web

This will allow users to login but will only make it optional. To enforce
users to login additionally set the `AUTH_REQUIRED` environment variable to
`True` when starting the docker image:

    $ docker run --link alerta-db:mongo -e AUTH_REQUIRED=True -e ...

To restrict logins to a certain email domain set the `ALLOWED_EMAIL_DOMAIN`
environment variable as follows:

    $ docker run --link alerta-db:mongo -e ALLOWED_EMAIL_DOMAIN=example.com ...

GitHub and GitLab can also be used as the OAuth2 providers by setting the
`PROVIDER` environment variable to `github` and `gitlab` respectively.

Docker Compose
--------------

Use `docker-compose` to create and start Alerta and MongoDB with
one command:

    $ docker-compose up

**Example Docker Compose File**

```yaml
version: '2.1'
services:
  web:
    build: .
    ports:
      - "8181:80"
    depends_on:
      - db
    environment:
      - AUTH_REQUIRED=${AUTH_REQUIRED:-False}
      - ADMIN_USERS=${ADMIN_USERS:-not-set}
      - CUSTOMER_VIEWS=${CUSTOMER_VIEWS:-False}
      - PROVIDER=${PROVIDER:-basic}
      - CLIENT_ID=${CLIENT_ID:-not-set}
      - CLIENT_SECRET=${CLIENT_SECRET:-not-set}
      - ALLOWED_EMAIL_DOMAIN=${ALLOWED_EMAIL_DOMAIN:-*}
      - ALLOWED_GITHUB_ORGS=${ALLOWED_GITHUB_ORGS:-*}
      - GITLAB_URL=${GITLAB_URL:-not-set}
      - ALLOWED_GITLAB_GROUPS=${ALLOWED_GITLAB_GROUPS:-*}
      - PLUGINS=${PLUGINS:-reject}
      - ORIGIN_BLACKLIST=${ORIGIN_BLACKLIST:-not-set}
      - ALLOWED_ENVIRONMENTS=${ALLOWED_ENVIRONMENTS:-Production,Development}
      - MONGO_URI=mongodb://db:27017/monitoring
    restart: always
  db:
    image: mongo
    volumes:
      - ./mongodb:/data/db
    restart: always
```

Command-line Tool
-----------------

A command-line tool for alerta is available. To install it run:

    $ pip install alerta

Configuration file `$HOME/.alerta.conf`:

    [DEFAULT]
    endpoint = http://<docker>:<port>/api

If authentication is enabled (ie. `AUTH_REQUIRED` is `True`), then create
a new API key in the alerta console and add the key to the configuration
file. For example:

    [DEFAULT]
    endpoint = ...
    key = 4nHAAslsGjLQ9P0QxmAlKIapLTSDfEfMDSy8BT+0

Further Reading
---------------

More information about alerta can be found at http://docs.alerta.io

License
-------

Copyright (c) 2014-2016 Nick Satterly. Available under the MIT License.

[1]: <https://console.developers.google.com> "Google Developer Console"

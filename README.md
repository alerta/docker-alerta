What is Alerta?
===============

???

How to use this image
=====================

To use this image run a `mongo` container first:

    $ docker run --name alerta-db -d mongo

Then link to the `mongo` container when running the `alerta-web` container:

    $ docker run --name alerta-web --link alerta-db:mongo -d -p <port>:80 alerta/alerta-web

The API endpoint is at:

    http://<docker>:<port>/api

Browse to the alerta console at:

    http://<docker>:<port>/

To check running processes and tail the application and web server logs:

    $ docker top alerta-web
    $ docker logs -f alerta-web

Environment Variables
---------------------

The following environment variables are also honoured for configuring
the `alerta-web` container:

`DEBUG`

`BASE_URL`

`SECRET_KEY`

`MONGO_URI`

`AUTH_REQUIRED`

`ADMIN_USERS`

`CUSTOMER_VIEWS`

`OAUTH2_CLIENT_ID`

`OAUTH2_CLIENT_SECRET`

`ALLOWED_EMAIL_DOMAINS`

`GITHUB_URL`

`ALLOWED_GITHUB_ORGS`

`GITLAB_URL`

`ALLOWED_GITLAB_GROUPS`

`CORS_ORIGINS`

`MAIL_FROM`

`SMTP_PASSWORD`

`PLUGINS`

Configuration Files
-------------------

To use configuration files instead of environment variables ...

    $ docker run -v $PWD/config/alertad.conf:/etc/alertad.conf --network dbnet -p 8181:80 48e84ce69d3a

Installing Plugins
------------------

Plugins listed in the `PLUGINS` environment variable or in the `PLUGINS`
server configuration file setting will be installed automatically at
start time.

Alternatively, install them as an additional image layer.

Authentication
--------------

To make it easy to get going with alerta on docker quickly, the default image
will use Basic Auth for user logins and login will be optional.

To allow users to login using Google OAuth, go to the [Google Developer Console][1]
and create a new client ID for a web application. Then set the `CLIENT_ID`
and `CLIENT_SECRET` environment variables on the command line as follows:

    $ export CLIENT_ID=379647311730-6tfdcopl5fodke08el52nnoj3x8mpl3.apps.googleusercontent.com
    $ export CLIENT_SECRET=UpJxs02c_bx9GlI3X8MPL3-p

Now pass in the defined environment variables to the `docker run` command:

    $ docker run --name alerta-web  -e PROVIDER=google -e CLIENT_ID=$CLIENT_ID \
    -e CLIENT_SECRET=$CLIENT_SECRET -d -p <port>:80 alerta/alerta-web

This will allow users to login but will only make it optional. To enforce
users to login you must also set the `AUTH_REQUIRED` environment variable to
`True` when starting the docker image:

    $ docker run --name alerta-web -e AUTH_REQUIRED=True -e ...

To restrict logins to a certain email domain set the `ALLOWED_EMAIL_DOMAIN`
environment variable as follows:

    $ docker run --name alerta-web -e ALLOWED_EMAIL_DOMAIN=example.com ...

GitHub and GitLab can also be used as the OAuth2 providers by setting the
`PROVIDER` environment variable to `github` and `gitlab` respectively. For
more information on using GitHub, GitHub Enterprise or GitLab as th OAuth2
provider see http://docs.alerta.io

Docker Compose
--------------

Use `docker-compose` to create and start Alerta and MongoDB with
one command:

    $ docker-compose up

**Example Docker Compose File**

```yaml
version: '2.1'
services:
  alerta-web:
    image: alerta/alerta-web
    ports:
      - "8181:80"
    depends_on:
      - alerta-db
    environment:
      - MONGO_URI=mongodb://alerta-db:27017/monitoring
    restart: always
  alerta-db:
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
a new API key in the Alerta console and add the key to the configuration
file. For example:

    [DEFAULT]
    endpoint = ...
    key = 4nHAAslsGjLQ9P0QxmAlKIapLTSDfEfMDSy8BT+0

Further Reading
---------------

More information about Alerta can be found at http://docs.alerta.io

License
-------

Copyright (c) 2014-2017 Nick Satterly. Available under the MIT License.

[1]: <https://console.developers.google.com> "Google Developer Console"

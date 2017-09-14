What is Alerta?
===============

The alerta monitoring system is a tool used to consolidate and
de-duplicate alerts from multiple sources for quick ‘at-a-glance’
visualisation. With just one system you can monitor alerts from
many other monitoring tools on a single screen.

How to use this image
=====================

To use this image run a `mongo` container first:

    $ docker run --name alerta-db -d mongo

Then link to the `mongo` container when running the `alerta-web` container:

    $ export MONGO_URI=mongodb://db:27017/monitoring
    $ docker run --name alerta-web -e MONGO_URI=$MONGO_URI --link alerta-db:db \
    -d -p <port>:80 alerta/alerta-web

The API endpoint is at:

    http://<docker>:<port>/api

Browse to the alerta console at:

    http://<docker>:<port>/

Environment Variables
---------------------

The following environment variables are supported for configuring
the `alerta-web` container:

`DEBUG`
    - debug mode. Set to ``True`` for increased logging.

`BASE_URL`
    - used to fix relative links. (default: `/api`)

`SECRET_KEY`
    - a unique, randomly generated sequence of ASCII characters.

`MONGO_URI`
    - MongoDB connection URI string.

`AUTH_REQUIRED`
    - require users to authenticate when using web UI or `alerta` CLI.

`ADMIN_USERS`
    - list of logins that should be granted "admin" role.

`ADMIN_KEY`
    - set an "admin" API key for use by the `alerta` CLI

`CUSTOMER_VIEWS`
    - enable alert views partitioned by customer. (default:``False``)

`OAUTH2_CLIENT_ID`
    - client ID required by OAuth2 provider

`OAUTH2_CLIENT_SECRET`
    - client secret required by OAuth2 provider

`ALLOWED_EMAIL_DOMAINS`
    - list of authorised email domains when using Google

`GITHUB_URL`
    - GitHub Enteprise URL for privately run GitHub server

`ALLOWED_GITHUB_ORGS`
    - list of authorised GitHub organisations when using GitHub

`GITLAB_URL`
    - GitLab website URL for public or privately run GitLab server

`ALLOWED_GITLAB_GROUPS`
    - list of authorised GitLab groups when using GitLab

`CORS_ORIGINS`
    - list of URL origins that can access the API

`MAIL_FROM`
    - valid email address from which verification emails are sent

`SMTP_PASSWORD`
    - password for ``MAIL_FROM`` email account

`PLUGINS`
    - list of plugins to enable.

`INSTALL_PLUGINS`
    - list of plugins to automatically install.

Configuration Files
-------------------

To set configuration settings not supported by environment variable use
configuration files instead. For example:

    $ docker run -v $PWD/config/alertad.conf:/etc/alertad.conf \
      -v $PWD/config/config.js:/app/config.js \
      -p 80 alerta/alerta-web

Installing Plugins
------------------

Plugins listed in the `PLUGINS` environment variable or in the `PLUGINS`
server configuration file setting will be installed automatically at
container start time.

Alternatively, install all wanted plugins as an additional image layer.

Authentication
--------------

To make it easy to get going with Alerta on docker quickly, the default image
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

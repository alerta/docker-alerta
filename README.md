What is Alerta?
===============

The alerta monitoring system is a tool used to consolidate and
de-duplicate alerts from multiple sources for quick ‘at-a-glance’
visualisation. With just one system you can monitor alerts from
many other monitoring tools on a single screen.

How to use this image
=====================

To use this image run either a `mongo` or `postgres` container first:

    $ docker run --name alerta-db -d mongo

Then link to the database container when running the `alerta-web` container:

    $ export DATABASE_URL=mongodb://db:27017/monitoring
    $ docker run --name alerta-web -e DATABASE_URL=$DATABASE_URL --link alerta-db:db \
    -d -p <port>:8080 alerta/alerta-web

The API endpoint is at:

    http://<docker>:<port>/api

Browse to the alerta console at:

    http://<docker>:<port>/

Environment Variables
---------------------

The following environment variables are supported for configuring
the `alerta-web` container specifically for Docker deployments:

`ADMIN_PASSWORD`
    - sets the password of all admins. Should be changed at first login. default: alerta

`ADMIN_KEY`
    - sets an admin API key.

`ADMIN_KEY_MAXAGE`
    - sets the duration of the admin key (seconds) default: 10 years

`HEARTBEAT_SEVERITY`
    - severity used to create alerts for stale heartbeats

The following environment variables are supported by the Alerta
API to ease deployment more generally:

`DEBUG`
    - debug mode for increased logging. equivalent of setting `LOG_LEVEL=debug` (eg. `DEBUG=1`)

`LOG_LEVEL`
    - log level of Alerta application and nginx (default:`warn`)

`SUPERVISORD_LOG_LEVEL`
    - log level of supervisord, must be `debug` or lower to see appliation logs (default:`debug`)

`SECRET_KEY`
    - a unique, randomly generated sequence of ASCII characters.

`DATABASE_URL`
    - database connection URI string. Only MongoDB and Postgres allowed.

`DATABASE_NAME`
    - used to override database name in `DATABASE_URL`.

`AUTH_REQUIRED`
    - require users to authenticate when using web UI or `alerta` CLI.

`AUTH_PROVIDER`
    - authentication provider eg. basic, ldap, openid, saml2, keycloak

`ADMIN_USERS`
    - comma-separated list of logins that will be created with "admin" role.

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

`KEYCLOAK_URL`
    - Keycloak URL

`KEYCLOAK_REALM`
    - Keycloak realm

`ALLOWED_KEYCLOAK_ROLES`
    - Keycloak roles

`CORS_ORIGINS`
    - list of URL origins that can access the API

`MAIL_FROM`
    - valid email address from which verification emails are sent

`SMTP_PASSWORD`
    - password for ``MAIL_FROM`` email account

`PLUGINS`
    - list of plugins to enable.

`NGINX_WORKER_PROCESSES`
    - number of worker processes (default:`1`)

`NGINX_WORKER_CONNECTIONS`
    - maximum number of simultaneous connections that can be opened by a worker process (default:`1024`)

`UWSGI_PROCESSES`
    - number of processes for uWSGI (default:`5`)

`UWSGI_LISTEN`
    - max number of concurrent connections (default:`100`)

`UWSGI_BUFFER_SIZE`
    - size of the unix socket buffer (default:`8192`)

`UWSGI_MAX_WORKER_LIFETIME`
    - reload worker after this many seconds (default:`30`)

`UWSGI_WORKER_LIFETIME_DELTA`
    - time in seconds to stagger UWSGI worker respawns (default:`3`)

Configuration Files
-------------------

To set configuration settings not supported by environment variables use
configuration files instead. For example:

    $ docker run -v $PWD/config/alertad.conf:/app/alertad.conf \
      -v $PWD/config/config.json:/web/config.json \
      -p <port>:8080 alerta/alerta-web

For a full list of server configuration options see https://docs.alerta.io.

Plugins
-------

All built-in and contributed plugins are installed at image build time. Only
plugins listed in `PLUGINS` environment variabled will be enabled.

In the example below, of all the plugins installed only those listed will
be enabled at container start time:

    PLUGINS=remote_ip,reject,heartbeat,blackout,slack,prometheus

Custom plugins should be installed as an additional image layer.

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

    $ docker run --name alerta-web  -e AUTH_PROVIDER=google -e CLIENT_ID=$CLIENT_ID \
    -e CLIENT_SECRET=$CLIENT_SECRET -d -p <port>:8080 alerta/alerta-web

This will allow users to login but will only make it optional. To enforce
users to login you must also set the `AUTH_REQUIRED` environment variable to
`True` when starting the docker image:

    $ docker run --name alerta-web -e AUTH_REQUIRED=True -e ...

To restrict logins to a certain email domain set the `ALLOWED_EMAIL_DOMAIN`
environment variable as follows:

    $ docker run --name alerta-web -e ALLOWED_EMAIL_DOMAIN=example.com ...

GitHub and GitLab can also be used as the OAuth2 providers by setting the
`AUTH_PROVIDER` environment variable to `github` and `gitlab` respectively. For
more information on using GitHub, GitHub Enterprise or GitLab as th OAuth2
provider see https://docs.alerta.io

Docker Compose
--------------

Use `docker-compose` to create and start Alerta and Postgres with
one command:

    $ docker-compose up

**Example Docker Compose File**

```yaml
version: '2.1'
services:
  web:
    image: alerta/alerta-web
    ports:
      - "8080:8080"
    depends_on:
      - db
    environment:
      - DEBUG=1  # remove this line to turn DEBUG off
      - DATABASE_URL=postgres://postgres:postgres@db:5432/monitoring
      - AUTH_REQUIRED=True
      - ADMIN_USERS=admin@alerta.io,devops@alerta.io #default password: alerta
      - ADMIN_KEY=demo-key
      - PLUGINS=reject,blackout,normalise,enhance
    restart: always
  db:
    image: postgres
    volumes:
      - ./pg-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: monitoring
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
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

Copyright (c) 2014-2020 Nick Satterly. Available under the MIT License.

[1]: <https://console.developers.google.com> "Google Developer Console"

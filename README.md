
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

    $ docker run --name alerta-web --link alerta-db:mongo -d -p 8080:80 alerta/alerta-web

The API endpoint is at:

    http://<docker>:8080/api

Browse to the alerta console at:

    http://<docker>:8080/

To check running processes and tail the application and web server logs:

    $ docker top alerta-web
    $ docker logs -f alerta-web

Configuration
-------------

To make it easy to get going with alerta on docker quickly, the default image will **not** require users to login. However, if logins aren't enabled then certain features in the web console are not available, such as:

  * watching alerts
  * creating API keys
  * adding users to whitelist

To allow users to login, go to the [Google Developer Console][1] and create a new client ID for a web application. Then set the `CLIENT_ID` and `REDIRECT_URL` environment variables on the command line to `docker run` as follows:

    $ export CLIENT_ID=988466068957-example-client-id.apps.googleusercontent.com
    $ export REDIRECT_URL=http://<docker>:8080/oauth2callback.html

Important: The Redirect URL can not be an IP address.

Now pass in the defined environment variables to the `docker run` command:

    $ docker run --link alerta-db:mongo -e CLIENT_ID=$CLIENT_ID -e REDIRECT_URL=$REDIRECT_URL -d -p 8080:80 alerta/alerta-web

This will allow users to login but will only make it optional. To enforce users to login set the `AUTH_REQUIRED` environment variable to `True` as follows:

    $ export AUTH_REQUIRED=True
    $ docker run --link alerta-db:mongo -e AUTH_REQUIRED=$AUTH_REQUIRED -e CLIENT_ID=$CLIENT_ID -e REDIRECT_URL=$REDIRECT_URL -d -p 8080:80 alerta/alerta-web

To restrict logins to a certain email domain set the `ALLOWED_EMAIL_DOMAIN` environment variable as follows:

    $ export ALLOWED_EMAIL_DOMAIN=example.com
    $ docker run --link alerta-db:mongo -e AUTH_REQUIRED=$AUTH_REQUIRED -e CLIENT_ID=$CLIENT_ID -e REDIRECT_URL=$REDIRECT_URL -e ALLOWED_EMAIL_DOMAIN=$ALLOWED_EMAIL_DOMAIN -d -p 8080:80 alerta/alerta-web

Individual users whose email domains do not match the `ALLOWED_EMAIL_DOMAIN` setting can be added to a user whitelist in the console under the `Configuration / Users` menu option.

Command-line Tool
-----------------

A command-line tool for alerta is available. To install it run:

    $ pip install alerta

Configuration file `$HOME/.alerta.conf`:

    [DEFAULT]
    endpoint = http://<docker>:8080

If authentication is enabled (ie. `AUTH_REQUIRED` is `True`), then create a new API key in the alerta console and add the key to the configuration file. For example:

    [DEFAULT]
    endpoint = ...
    key = 4nHAAslsGjLQ9P0QxmAlKIapLTSDfEfMDSy8BT+0

Further Reading
---------------

More information about alerta can be found at http://docs.alerta.io

License
-------

Copyright (c) 2014 Nick Satterly. Available under the MIT License.

[1]: <https://console.developers.google.com> "Google Developer Console"

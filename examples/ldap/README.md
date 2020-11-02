# Alerta with LDAP auth

## Run

Note: Add the following entry to `/etc/hosts`:

    127.0.0.1 host.docker.internal

To launch Alerta and LDAP containers:

    $ docker-compose up
    => http://local.alerta.io:8000/login  # leela/leela

## References

https://hub.docker.com/r/rroemhild/test-openldap

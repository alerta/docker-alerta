# Alerta with Keycloak Auth

Containers
----------

* Alerta web
* Postgres database for Alerta
* [Keycloak](https://hub.docker.com/r/jboss/keycloak/)

## Configuration

Step 1. 
The hostname "host.docker.internal" must resolve to "127.0.0.12".

**Example /etc/hosts file**

```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost host.docker.internal
255.255.255.255 broadcasthost
::1             localhost
```

Step 3. Launch services

    $ docker-compose up

Step 3. Login to Alerta Web UI

Using credentials "alice" / "alice" login to Alerta web UI

## Troubleshooting

OpenID Connect Wellknown  http://host.docker.internal:8080/auth/realms/demo/.well-known/openid-configuration

## References

* Keycloak Docker Compose Example - https://github.com/jboss-dockerfiles/keycloak/blob/master/docker-compose-examples/keycloak-postgres.yml

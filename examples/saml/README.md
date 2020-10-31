# Alerta with SAML2 IdP Example

## IMPORTANT

NOTE: You must add the following entry to /etc/hosts for this to work:

    127.0.0.1 host.docker.internal

## Run

    $ docker-compose up

    => http://local.alerta.io:8080/login   user1/user1pass

### Example auth data

```
{
    "Attributes": {
        "uid": [
            "2"
        ],
        "first_name": [
            "User"
        ],
        "last_name": [
            "Two"
        ],
        "email": [
            "user_2@example.com"
        ]
    },
    "Authority": "example-userpass",
    "AuthnInstant": 1604355254,
    "Expire": 1604384054
}
```

## References

https://hub.docker.com/r/jamedjo/test-saml-idp/

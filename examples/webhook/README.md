# Custom Webhook Example

This is an example configuration to demonstrate how to extend
the "official" base image to add a custom webhook or plugin.

## Containers

- custom image using "official" image as base

## Run

    $ cd examples/webhook
    $ docker-compose build
    $ docker-compose up

## Test

List all webhooks:

    $ curl http://localhost:9000/api/

Send test webhook payload:

    $ curl -XPOST http://localhost:9000/api/webhooks/msteams \
    -H 'Content-Type: application/json' \
    -H 'X-API-Key: demo-key' \
    -d '{"action":"ack","alert_id":"da9b3d24-3ee3-4cdc-8a58-a6533c9e9af9"}'

## Endpoints

- web UI => <http://localhost:9000/>
- API    => <http://localhost:9000/api>

## References

<https://docs.alerta.io/en/latest/gettingstarted/tutorial-10-docker.html>

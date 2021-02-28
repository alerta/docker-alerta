# Federated Alerta Example

This is an example configuration to demonstrate how to forward
alerts between Alerta servers to create a highly-available
cluster of monitoring servers.

## Containers

- MoM (Manager-of-Mangers, aka. top-level manager) x 2
- MLM (Mid-Level Manager, aka. regional manager) x 2

## Run

    $ cd examples/federated
    $ docker-compose up -d

## Endpoints

TBC

## References

https://prometheus.io/docs/prometheus/latest/federation/

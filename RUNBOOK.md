Docker 
======

Building
--------

    $ docker-compose -f docker-compose.yml -f docker-compose.mongo.yml build


Testing
-------

MongoDB Replica Set

Run an interactive shell in one of the mongoDB containers:

    $ docker ps -a  # <= get container ID
    $ docker exec -ti CONTAINER_ID bash
    root:/# mongo

At the `mongo` prompt ">" run:

```
rs.initiate(
    {
        _id: "rs0",
        version: 1,
        members: [
            { _id: 0, host : "db:27017" },
            { _id: 1, host : "db1:27017" },
            { _id: 2, host : "db2:27017" }
        ]
    }
)
```

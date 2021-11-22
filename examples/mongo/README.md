# Alerta with MongoDB Replica Set Example

Once the mongo containers have started, run an interactive shell in one of the mongoDB containers, like so:

    $ docker exec -ti mongo_db0_1 mongo

To initiate the replicaset, at the `mongo` prompt ">" run:

```
rs.initiate(
    {
        _id: "rs0",
        version: 1,
        members: [
            { _id: 0, host : "db0:27017" },
            { _id: 1, host : "db1:27017" },
            { _id: 2, host : "db2:27017" }
        ]
    }
)
```

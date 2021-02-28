#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE mom1;
    CREATE DATABASE mom2;
    CREATE DATABASE mlm1;
    CREATE DATABASE mlm2;
EOSQL

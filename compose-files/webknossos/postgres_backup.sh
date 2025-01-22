#!/bin/bash
# create postgres dump
docker exec -it --user root webknossos_postgres_1 bash -c \
	'pg_dumpall --username "postgres" --no-password >/pg_dumps/backup'

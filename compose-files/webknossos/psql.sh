#!/bin/bash
# start interactive psql shell on webknossos
docker exec -it --user root webknossos_postgres_1 /usr/local/bin/psql \
	--username "postgres" --no-password --db webknossos

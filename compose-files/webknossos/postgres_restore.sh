#!/bin/bash
# restore postgres db from backup, ie after updating the pg version

# note, because of the use of docker-compose down there will be downtime
# with this method, something more advanced but perhaps more fragile would
# run two containers for postgres simultaneously and then replace the old one
# with the new one, which would result in almost no downtime

# stop currently running containers
docker-compose down

# move db
mkdir -p ./persistent/old
chown webknossos:webknossos ./persistent/old
rm -rf ./persistent/old/postgres
mv ./persistent/postgres ./persistent/old/
mkdir ./persistent/postgres
chown webknossos:webknossos ./persistent/postgres

# start only postgres
docker-compose up -d postgres

# wait a bit
sleep 5

# restore from dump
docker exec -it --user root webknossos_postgres_1 bash -c \
	'psql --username "postgres" --no-password -f /pg_dumps/backup'

# wait a bit
sleep 5

# start the rest
docker-compose up -d

# done
echo "the following backups are still present, to remove them use:"
echo "rm ./persistent/pg_dumps/backup"
echo "rm -r ./persistent/old/postgres"

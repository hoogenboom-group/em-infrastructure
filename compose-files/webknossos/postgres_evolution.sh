#!/bin/bash

# apply a postgres evolution to the webknossos postgres database
# see here for the current list of migrations and versions:
# https://github.com/scalableminds/webknossos/blob/master/MIGRATIONS.released.md
function get_version () {
  rx=' schemaversion 
---------------
 *([0-9]+)
\(1 row\)
'
  if ! version=$(docker exec -it webknossos_postgres_1 /usr/local/bin/psql \
      -v ON_ERROR_STOP=1 --username "postgres" --no-password \
      --db "webknossos" -c "select schemaversion from webknossos.releaseInformation")
  then
    echo "could not get version from container" >&2
    exit 3
  fi
  [[ $version =~ $rx ]]
  echo "${BASH_REMATCH[1]}"
}

database_file=$1
before=$(get_version) || exit 3
if [[ ! $database_file ]]; then
  echo "database evolution file is required" >&2
  echo "usage: $0 [path to file]"
  echo "the current schemaversion is $before"
  exit 2
fi

cd "${BASH_SOURCE%/*}/" || exit 2
if [[ $database_file =~ ^https?:// ]]; then
  if [[ $database_file =~ (^https?://github.com/[^/]*/[^/]*/)blob(/.*) ]]; then
    database_file="${BASH_REMATCH[1]}raw${BASH_REMATCH[2]}"
  fi
  if ! curl -L "$database_file" -o ./persistent/postgres/evolution.sql; then
    echo "failed to download file" >&2
    exit 1
  fi
elif ! cp "$database_file" ./persistent/postgres/evolution.sql; then
  echo "failed to copy file" >&2
  exit 1
fi

docker exec -it webknossos_postgres_1 /usr/local/bin/psql \
    -v ON_ERROR_STOP=1 --username "postgres" --no-password \
    --db "webknossos" -f "/var/lib/postgresql/data/evolution.sql"
e=$?
rm "./persistent/postgres/evolution.sql"
after=$(get_version) || exit 3
echo "resulting schemaversion: from $before to $after"
exit $e

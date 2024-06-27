function exec_psql ()
{
  local a=()
  while [[ $1 ]]; do
    a+=("-c" "$1")
    shift
  done
  docker exec webknossos_postgres_1 /usr/local/bin/psql \
      -v ON_ERROR_STOP=1 --username "postgres" --no-password \
      --db "webknossos" "${a[@]}"
}

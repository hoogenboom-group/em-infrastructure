#!/bin/bash

# rename a dataset from the webknossos postgres database
# needs jq
old=$1
new=$2
if [[ ! ( $old || $new ) ]]; then
  echo "an old and new name are required" >&2
  echo "usage: $0 [old name] [new name]"
  exit 2
fi
location="/long_term_storage/webknossos/binaryData/hoogenboom-group"
path="$location/$old"
if [[ ! -d $path ]]; then
  echo "$path is not a directory" >&2
  exit 3
fi

cd "${BASH_SOURCE%/*}/" || exit 2

# shellcheck disable=SC1091
source exec_psql.sh

result=$(exec_psql "\\t on" \
    "select _id, _datastore from webknossos.datasets where name = '$old'")
# line endings have CR!
rx='^ ([0-9a-z]+) \| (.+)
$'
[[ $result =~ $rx ]]
id=${BASH_REMATCH[1]}
store=${BASH_REMATCH[2]}
if [[ ! $id ]]; then
  echo "$old was not found in the database" >&2
  exit 1
fi
if [[ $store != localhost ]]; then
  echo "$old does not have the localhost datastore type but $store!" >&2
  exit 1
fi
echo "are you sure you want to rename $old (id $id) to $new? (^C exits)"
read -r

exec_psql "update webknossos.datasets set name = '$new' where _id = '$id'"
json_path="$path/datasource-properties.json"
if ! json=$(jq '.id += {"name": "'"$new"'"}' "$json_path"); then
  echo "error reading $json_path" >&2
  exec_psql "update webknossos.datasets set name = '$old' where _id = '$id'"
  exit 1
fi
if ! echo "$json" >"$json_path"; then
  echo "error writing $json_path" >&2
  exec_psql "update webknossos.datasets set name = '$old' where _id = '$id'"
  exit 1
fi
mv "$path" -T "$location/$new" || echo "dir was not renamed!"

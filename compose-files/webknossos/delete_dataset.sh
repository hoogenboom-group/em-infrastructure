#!/bin/bash

# delete a dataset and its annotations from the webknossos postgres database
name=$1
if [[ ! $name ]]; then
  echo "a name is required" >&2
  echo "usage: $0 [name]"
  exit 2
fi
path="/long_term_storage/webknossos/binaryData/hoogenboom-group/$name"
if [[ ! -d $path ]]; then
  echo "$path is not a directory" >&2
fi
cd "${BASH_SOURCE%/*}/" || exit 2

# shellcheck disable=SC1091
source exec_psql.sh

result=$(exec_psql "\\t on" \
    "select _id from webknossos.datasets where name = '$name'")
[[ $result =~ [0-9a-z]+ ]]
id=${BASH_REMATCH[0]}
if [[ ! $id ]]; then
  echo "$name was not found in the database;" >&2
  exit 1
fi
amount=$(exec_psql "\\t on" \
    "select _id from webknossos.annotations where _dataset = '$id'" \
  | wc -l)
if [[ $amount == 1 ]]; then
  echo "$id has no annotations"
else
  echo "$id has $(( amount - 1 )) annotations by the following users:"
  exec_psql "select _user, email, firstname, lastname from webknossos.userinfos where _user in (
          select _user from webknossos.annotations where _dataset = '$id'
  )"
fi
echo "are you sure you want to delete this? (^C exits)"
read -r

exec_psql "delete from webknossos.annotations where _dataset = '$id'" \
    "delete from webknossos.datasets where _id = '$id'"
rm "$path" -r || echo "failed to delete $path"

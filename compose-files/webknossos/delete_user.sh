#!/bin/bash

# delete a user from the webknossos postgres database
userid=$1
if [[ ! $userid ]]; then
  echo "user id to delete is required" >&2
  echo "usage: $0 [user id]"
  exit 2
fi
cd "${BASH_SOURCE%/*}/" || exit 2

# shellcheck disable=SC1091
source exec_psql.sh

if [[ $userid =~ @ ]]; then
  email=$userid
  unset userid
  exec_psql "select _user, email, firstname, lastname from webknossos.userinfos where email = '$email'"
else
  exec_psql "select _user, email, firstname, lastname from webknossos.userinfos where _user = '$userid'"
fi
echo "are you sure you want to delete this? (^C exits)"
read -r

if [[ $email ]]; then
  result=$(exec_psql '\pset format csv' "select _user from webknossos.userinfos where email = '$email'")
  rx='Output format is csv.
_user
([a-z0-9]{24})'
  if [[ ! $result =~ $rx ]]; then
    echo "could not find id of user with email $email" >&2
    exit 4
  fi
  userid=${BASH_REMATCH[1]}
fi

result=$(exec_psql '\pset format csv' "select _multiuser from webknossos.users where _id = '$userid'")
rx='Output format is csv.
_multiuser
([a-z0-9]{24})'
if [[ ! $result =~ $rx ]]; then
  echo "user was not found, no changes were made" >&2
  exit 3
fi
multiuserid=${BASH_REMATCH[1]}

exec_psql "delete from webknossos.multiusers where _id = '$multiuserid'" && \
  exec_psql "delete from webknossos.users where _id = '$userid'"

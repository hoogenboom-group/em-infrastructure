#!/bin/bash

# find new users in the webknossos postgres database and send email using sendmail
# related systemd serivice and timer: webknossos_accounts_waiting_for_activation_check
counter_file="/tmp/webknossos_accounts_waiting_for_activation"
cd "${BASH_SOURCE%/*}/" || exit 2

# shellcheck disable=SC1091
source exec_psql.sh

result=$(exec_psql '\pset format csv' "select _user, firstname, lastname, lastactivity, email from webknossos.userinfos where isdeactivated = true")

rx='([a-z0-9]{24}),([^,]*),([^,]*),([^,+]*)\+00,(.*)'
i=0
list=""
{
  read -r
  read -r
  while read -r; do
    if [[ ! $REPLY =~ $rx ]]; then
      echo "unexpected entry $REPLY" >&2
      exit 3
    fi
    id=${BASH_REMATCH[1]}
    name="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
    date=${BASH_REMATCH[4]}
    email=${BASH_REMATCH[5]}
    list+="id $id registered $date: $name <$email> 
"
    ((++i))
  done
} <<<"$result"
if [[ $i == 0 ]]; then
  rm -f "$counter_file"
  exit 0
fi
declare -i last_count
{ last_count=$(<"$counter_file"); } 2>/dev/null
if [[ $last_count == "$i" ]]; then
  exit 0
fi
echo "$i" >"$counter_file"
is=is
if [[ $i != 1 ]]; then
  s=s
  is=are
fi
echo "There $is $i account$s waiting for activation in the webknossos database (was $last_count)"
echo "Go to https://webknossos.tnw.tudelft.nl/users to manage accounts"
{ 
  echo "SUBJECT: $i new webknossos user$s"
  echo
  echo "There $is $i new webknossos account$s waiting to be activated:"
  echo "$list"
  echo "Go to https://webknossos.tnw.tudelft.nl/users to manage accounts"
} | /usr/sbin/sendmail -f "root <root@$(</etc/hostname)>" "$(</etc/contact)"

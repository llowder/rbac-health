#!/bin/bash

declare -r PROGNAME=${0##*/}
declare -r -i E_OK=0
declare -r -i E_GENERIC_FALIURE=1
#declare -r -i E_NO_POSTGRESQL=2
declare -r SHORT_OPTSTRING="u:h"
declare -r LONG_OPTSTRING="user:,help"

function usage {
  local msg="\n ${PROGNAME} [-h] [-u user]"
  msg+="\n"
  msg+="\nwhere:"
  msg+="\n- -h or --help"
  msg+="\n  - Description: Outputs usage information"
  msg+="\n- -u or --user"
  msg+="\n  - Default: pe-postgres"
  msg+="\n  - Description: The user to run the pgsql commands as"
  msg+="\n"
  echo -e "${msg}"
  return ${E_OK}
}

#utility function to make failing easier.
function fail_sauce {
  echo -e "$*"
  exit $(E_GENERIC_ERROR)
  return $(E_OK)
}

declare pg_user='pe-postgres'

ARGS=$(getopt -s bash -o ${SHORT_OPTSTRING} -l ${LONG_OPTSTRING} -n ${PROGNAME} -- "$@")

eval set -- "$ARGS"

while true; do
  case "$1" in
    -h|--help)
      usage
      ;;
    -u|--user)
      pg_user="$2"
      ;;
    --) shift; break ;;
  esac
done

#locate postgresql
if [ -x /opt/puppet/bin/psql ]; then
  declare -r PG_COMMAND="/opt/puppet/bin/psql";
else
  declare -r PG_COMMAND=$(sudo -u ${pg_user} which pgsql)
  [ $? -eq 0 ] || fail_sauce "Can't find pgsql."
fi

declare -r RET_VAL_PG=$(sudo -u ${pg_user} ${PG_COMMAND} -d pe-rbac -c "SELECT row_to_json(row) FROM ( SELECT id,display_name,help_link,type,hostname,port,ssl,login,connect_timeout,base_dn,user_rdn,user_display_name_attr,user_email_attr,user_lookup_attr,group_rdn,group_object_class,group_name_attr,group_member_attr,group_lookup_attr FROM directory_settings) row" | grep -E '{([^{]*?)}')
declare -r HOSTNAME=$(echo ${RET_VAL_PG} |  cut -f3 -d'"')
declare -r PORT=$(echo ${RET_VAL_PG} | cut -f6  -d',' | cut -f3 -d'"' | cut -f2 -d':')
declare -r SSL=$(echo ${RET_VAL_PG} | cut -f7 -d',' | cut -f3 -d'"' | cut -f2 -d':')
declare -r BASE_DN=$(echo ${RET_VAL_PG} |  cut -f3 -d'"')
declare -r USER_RDN=$(echo ${RET_VAL_PG} |  cut -f3 -d'"')
declare -r GROUP_RDN=$(echo ${RET_VAL_PG} |  cut -f3 -d'"')

echo "Hostname: ${HOSTNAME}"
echo "Port: ${PORT}"
echo "SSL: ${SSL}"
echo "base_dn: ${BASE_DN}"
echo "user_rdn: ${USER_RDN}"
echo "group_rdn: ${GROUP_RDN}"


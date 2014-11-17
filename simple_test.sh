#!/bin/bash
ret_val_pg=`sudo -u pe-postgres /opt/puppet/bin/psql -d pe-rbac -c "SELECT row_to_json(row) FROM ( SELECT id,display_name,help_link,type,hostname,port,ssl,login,connect_timeout,base_dn,user_rdn,user_display_name_attr,user_email_attr,user_lookup_attr,group_rdn,group_object_class,group_name_attr,group_member_attr,group_lookup_attr FROM directory_settings) row" | grep -E '{([^{]*?)}'`
hostname=`echo ${ret_val_pg} | grep -Po 'hostname":"(.*)","p' | cut -f3 -d'"'`
port=`echo ${ret_val_pg} | grep -Po 'port":"(.*)","s' | cut -f3 -d'"'`
echo $hostname
echo $port

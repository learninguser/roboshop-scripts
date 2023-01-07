#!/bin/bash
log_file="/tmp/shipping.log"
current_dir=$(pwd)
source common.sh

if [ -z $mysql_root_password ]; then
  echo "Variable mysql_root_password is missing"
  exit
fi

component="shipping"
schema="true"
schema_type="mysql"
MAVEN
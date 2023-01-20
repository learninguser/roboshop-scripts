#!/bin/bash
log_file="/tmp/dispatch.log"
current_dir=$(pwd)
source common.sh

if [ -z "$roboshop_rabbitmq_password" ]; then
  echo "Variable roboshop_rabbitmq_password is missing"
  exit
fi

component="dispatch"
schema="true"
GOLANG
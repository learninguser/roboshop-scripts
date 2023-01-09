#!/bin/bash
log_file="/tmp/mysql.log"
current_dir=$(pwd)
source common.sh

if [ -z $roboshop_rabbitmq_password ]; then
  echo "Variable roboshop_rabbitmq_password is missing"
  exit
fi

print_message "Configuring YUM repos for erlang"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>> $log_file
status_check

print_message "Configuring YUM repos for RabbitMQ"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> $log_file
status_check

print_message "Installing erlang and rabbitmq server"
yum install erlang rabbitmq-server -y &>> $log_file
status_check

print_message "Enabling rabbitmq server"
systemctl enable rabbitmq-server &>> $log_file
status_check

print_message "Starting rabbitmq server"
systemctl start rabbitmq-server &>> $log_file
status_check

print_message "Adding roboshop user"
rabbitmqctl list_users | grep roboshop &>> $log_file
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop $roboshop_rabbitmq_password &>> $log_file
fi
status_check

print_message "Adding tags for roboshop user"
rabbitmqctl set_user_tags roboshop administrator &>> $log_file
status_check

print_message "Setting permissions for roboshop user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
status_check
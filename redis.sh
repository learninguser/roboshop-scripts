#!/bin/bash
log_file="/tmp/redis.log"
source common.sh

print_message "Installing remi"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $log_file
status_check

print_message "Enabling redis 6.2"
dnf module enable redis:remi-6.2 -y &>> $log_file
status_check

print_message "Installing redis"
yum install redis -y &>> $log_file
status_check

print_message "Updating listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf
status_check

print_message "Enabling Redis service"
systemctl enable redis &>> $log_file
status_check

print_message "Starting redis"
systemctl start redis &>> $log_file
status_check
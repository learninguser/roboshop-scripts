#!/bin/bash
log_file="/tmp/mysql.log"
current_dir=$(pwd)
source common.sh

if [ -z $mysql_root_password ]; then
  echo "MySQL root password is missing"
  exit
fi

print_message "Disabling default MySQL version and enabling v5.7"
dnf module disable mysql -y
status_check

print_message "Copy repo file"
cp $current_dir/files/mysql.repo /etc/yum.repos.d/mysql.repo
status_check

print_message "Installing MySQL server"
yum install mysql-community-server -y
status_check

print_message "Start MySQL service"
systemctl enable mysqld
systemctl start mysqld
status_check

print_message "Changing default MySQL Root password"
mysql_secure_installation --set-root-pass $mysql_root_password
status_check

print_message "Checking if the set password is working or not"
mysql -uroot -p$mysql_root_password
status_check
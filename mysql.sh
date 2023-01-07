#!/bin/bash
log_file="/tmp/mysql.log"
current_dir=$(pwd)
source common.sh

if [ -z $mysql_root_password ]; then
  echo "Variable mysql_root_password is missing"
  exit
fi

print_message "Disabling default MySQL version and enabling v5.7"
dnf module disable mysql -y &>> $log_file
status_check $log_file

print_message "Copy repo file"
cp $current_dir/files/mysql.repo /etc/yum.repos.d/mysql.repo &>> $log_file
status_check $log_file

print_message "Installing MySQL server"
yum install mysql-community-server -y &>> $log_file
status_check $log_file

print_message "Start MySQL service"
systemctl enable mysqld &>> $log_file
systemctl start mysqld &>> $log_file
status_check $log_file

echo "show databases;" | mysql -uroot -p${mysql_root_password} &>> $log_file
if [ $? -ne 0 ]
  print_message "Changing default MySQL Root password"
  mysql_secure_installation --set-root-pass $mysql_root_password &>> $log_file
  status_check $log_file
fi

print_message "Checking if the set password is working or not"
mysql -uroot -p$mysql_root_password &>> $log_file
status_check $log_file
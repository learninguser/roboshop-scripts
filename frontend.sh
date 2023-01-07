#!/bin/bash
log_file="/tmp/frontend.log"
current_dir=$(pwd)
source common.sh

print_message "Installing Nginx"
yum install nginx -y &>> $log_file
status_check $log_file

print_message "Removing existing files"
rm -rf /usr/share/nginx/html/* &>> $log_file
status_check $log_file

print_message "Fetching frontend scrips"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> $log_file
status_check $log_file

print_message "Extracting frontend scripts"
cd /usr/share/nginx/html 
unzip -o /tmp/frontend.zip &>> $log_file
status_check $log_file

print_message "Copying Roboshop conf to /etc/nginx/default.d location"
cp $current_dir/files/roboshop.conf /etc/nginx/default.d/roboshop.conf
status_check $log_file

print_message "Renaming each service with its Address"
for component in catalogue user cart shipping payment; do
  sed -i -e "/$component/ s/localhost/$component-dev.learninguser.online/" /etc/nginx/default.d/roboshop.conf
done
status_check $log_file

print_message "Starting nginx service"
systemctl enable nginx &>> $log_file
systemctl restart nginx &>> $log_file
status_check $log_file
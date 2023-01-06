#!/bin/bash
log_file="/tmp/catalogue.log"
current_dir=$(pwd)
source common.sh

print_message "Setup NodeJS repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $log_file
status_check $log_file

print_message "Install NodeJS"
yum install nodejs -y &>> $log_file
status_check $log_file

print_message "adding roboshop user"
useradd roboshop &>> $log_file
status_check $log_file

print_message "Downloading and extracting application code"
mkdir -p /app
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> $log_file
cd /app 
unzip -o /tmp/catalogue.zip &>> $log_file
status_check $log_file

print_message "Downloading and installing dependencies"
cd /app 
npm install &>> $log_file

cp $current_dir/files/catalogue.service /etc/systemd/system/catalogue.service
status_check $log_file

print_message "Load catalogue service"
systemctl daemon-reload &>> $log_file
status_check $log_file

print_message "Starting catalogue service"
systemctl enable catalogue &>> $log_file
systemctl restart catalogue &>> $log_file
status_check $log_file

cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
print_message "Installing mongodb"
yum install mongodb-org-shell -y &>> $log_file
status_check $log_file

print_message "Load schema"
mongo --host mongodb-dev.learninguser.online </app/schema/catalogue.js &>> $log_file
status_check $log_file
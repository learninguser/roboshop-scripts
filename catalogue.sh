#!/bin/bash
log_file="/tmp/catalogue.log"
current_dir=$(pwd)

echo "Setup NodeJS repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $log_file

echo "Install NodeJS"
yum install nodejs -y &>> $log_file

echo "adding roboshop user"
useradd roboshop &>> $log_file

echo "Downloading and extracting application code"
mkdir /app
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> $log_file
cd /app 
unzip /tmp/catalogue.zip &>> $log_file

echo "Downloading and installing dependencies"
cd /app 
npm install &>> $log_file

cp $current_dir/files/catalogue.service /etc/systemd/system/catalogue.service

echo "Load catalogue service"
systemctl daemon-reload &>> $log_file

echo "Starting catalogue service"
systemctl enable catalogue &>> $log_file
systemctl restart catalogue &>> $log_file

cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
echo "Installing mongodb"
yum install mongodb-org-shell -y &>> $log_file

echo "Load schema"
mongo --host mongodb.learninguser.online </app/schema/catalogue.js &>> $log_file
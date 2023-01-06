#!/bin/bash
log_file="/tmp/catalogue.log"
current_dir=$(pwd)

echo -e "\e[35mSetup NodeJS repos\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $log_file

echo -e "\e[35mInstall NodeJS\e[0m"
yum install nodejs -y &>> $log_file

echo -e "\e[35madding roboshop user\e[0m"
useradd roboshop &>> $log_file

echo -e "\e[35mDownloading and extracting application code\e[0m"
mkdir -p /app
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> $log_file
cd /app 
unzip -o /tmp/catalogue.zip &>> $log_file

echo -e "\e[35mDownloading and installing dependencies\e[0m"
cd /app 
npm install &>> $log_file

cp $current_dir/files/catalogue.service /etc/systemd/system/catalogue.service

echo -e "\e[35mLoad catalogue service\e[0m"
systemctl daemon-reload &>> $log_file

echo -e "\e[35mStarting catalogue service\e[0m"
systemctl enable catalogue &>> $log_file
systemctl restart catalogue &>> $log_file

cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
echo -e "\e[35mInstalling mongodb\e[0m"
yum install mongodb-org-shell -y &>> $log_file

echo -e "\e[35mLoad schema\e[0m"
mongo --host mongodb.learninguser.online </app/schema/catalogue.js &>> $log_file
#!/bin/bash
log_file="/tmp/frontend.log"
current_dir=$(pwd)

echo "Installing Nginx"
yum install nginx -y &>> $log_file

echo "Removing existing files"
rm -rf /usr/share/nginx/html/* &>> $log_file

echo "Fetching frontend scrips"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> $log_file

echo "Extracting frontend scripts"
cd /usr/share/nginx/html 
unzip -o /tmp/frontend.zip

echo "Copying Roboshop conf to /etc/nginx/default.d location"
cp $current_dir/files/roboshop.conf /etc/nginx/default.d/roboshop.conf

echo "Renaming each service with its Address"
sed -i -e "/catalogue/ s/localhost/catalogue.learninguser.online" /etc/nginx/default.d/roboshop.conf

echo "Starting nginx service"
systemctl enable nginx &>> $log_file
systemctl restart nginx &>> $log_file
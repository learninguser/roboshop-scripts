#!/bin/bash
log_file="/tmp/frontend.log"
current_dir=$(pwd)
source common.sh

echo -e "\e[35mInstalling Nginx\e[0m"
yum install nginx -y &>> $log_file
status_check $log_file

echo -e "\e[35mRemoving existing files\e[0m"
rm -rf /usr/share/nginx/html/* &>> $log_file
status_check $log_file

echo -e "\e[35mFetching frontend scrips\e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> $log_file
status_check $log_file

echo -e "\e[35mExtracting frontend scripts\e[0m"
cd /usr/share/nginx/html 
unzip -o /tmp/frontend.zip
status_check $log_file

echo -e "\e[35mCopying Roboshop conf to /etc/nginx/default.d location\e[0m"
cp $current_dir/files/roboshop.conf /etc/nginx/default.d/roboshop.conf
status_check $log_file

echo -e "\e[35mRenaming each service with its Address\e[0m"
sed -i -e "/catalogue/ s/localhost/catalogue-dev.learninguser.online/" /etc/nginx/default.d/roboshop.conf
sed -i -e "/user/ s/localhost/user-dev.learninguser.online/" /etc/nginx/default.d/roboshop.conf
sed -i -e "/cart/ s/localhost/cart-dev.learninguser.online/" /etc/nginx/default.d/roboshop.conf
sed -i -e "/shipping/ s/localhost/shipping-dev.learninguser.online/" /etc/nginx/default.d/roboshop.conf
sed -i -e "/payment/ s/localhost/payment-dev.learninguser.online/" /etc/nginx/default.d/roboshop.conf

status_check $log_file

echo -e "\e[35mStarting nginx service\e[0m"
systemctl enable nginx &>> $log_file
systemctl restart nginx &>> $log_file
status_check $log_file
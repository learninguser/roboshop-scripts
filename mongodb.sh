log_file="/tmp/mongo.log"
current_dir=$(pwd)
source common.sh

print_message "Installing MongoDB"
cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
yum install mongodb-org -y &>> $log_file
status_check $log_file

print_message "Updating listen address from 127.0.0.1 to 0.0.0.0"
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf
status_check $log_file

print_message "Starting MongoDB service"
systemctl enable mongod &>> $log_file
systemctl restart mongod &>> $log_file
status_check $log_file
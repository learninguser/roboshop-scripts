log_file="/tmp/mongo.log"
current_dir=$(pwd)

echo "Installing MongoDB"
cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
yum install mongodb-org -y &>> $log_file

echo "Updating listen address from 127.0.0.1 to 0.0.0.0"
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongo.conf

echo "Starting MongoDB service"
systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
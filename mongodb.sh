log_file="/tmp/mongo.log"
current_dir=$(pwd)

echo -e "\e[35mInstalling MongoDB\e[0m"
cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
yum install mongodb-org -y &>> $log_file
if[ $? -eq 0 ]; then
    echo "\e[32mSuccess\e[0m"
else
    echo "\e[31mFailure\e[0m"
fi

echo -e "\e[35mUpdating listen address from 127.0.0.1 to 0.0.0.0\e[0m"
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf
if[ $? -eq 0 ]; then
    echo "\e[32mSuccess\e[0m"
else
    echo "\e[31mFailure\e[0m"
fi

echo -e "\e[35mStarting MongoDB service\e[0m"
systemctl enable mongod &>> $log_file
systemctl restart mongod &>> $log_file
if[ $? -eq 0 ]; then
    echo "\e[32mSuccess\e[0m"
else
    echo "\e[31mFailure\e[0m"
fi
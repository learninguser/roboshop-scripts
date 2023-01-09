status_check(){
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32mSuccess\e[0m"
    else
        echo -e "\e[1;31mFailure\e[0m"
        echo "Refer Log file ($1) for more information, "
        exit 1
    fi
}

print_message(){
    echo -e "\e[1m$1\e[0m"
}

APP_PREREQ(){
  print_message "adding roboshop user"
  id roboshop &>> $log_file
  if [ $? -ne 0 ]; then
      useradd roboshop &>> $log_file
  fi
  status_check $log_file

  print_message "Downloading and extracting application code"
  mkdir -p /app
  curl -L -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>> $log_file
  cd /app
  unzip -o /tmp/$component.zip &>> $log_file
  status_check $log_file
}

SYSTEMD_SETUP(){
    print_message "Configuring ${component} Service File"
    cp $current_dir/files/$component.service /etc/systemd/system/$component.service
    status_check $log_file

    print_message "Load $component service"
    systemctl daemon-reload &>> $log_file
    status_check $log_file

    print_message "Starting $component service"
    systemctl enable $component &>> $log_file
    systemctl restart $component &>> $log_file
    status_check $log_file
}

LOAD_SCHEMA(){
  if [ $schema == "true" ]; then
    if [ $schema_type == "mongo" ]; then
      cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
      print_message "Installing mongodb"
      yum install mongodb-org-shell -y &>> $log_file
      status_check $log_file

      print_message "Load schema"
      mongo --host mongodb-dev.learninguser.online </app/schema/$component.js &>> $log_file
      status_check $log_file
    fi
    if [ $schema_type == "mysql" ]; then
      print_message "Installing MySQL client"
      yum install mysql -y &>> $log_file
      status_check $log_file

      print_message "Loading $component schema"
      mysql -h mysql-dev.learninguser.online -uroot -p$mysql_root_password < /app/schema/shipping.sql &>> $log_file
      status_check $log_file
    fi
  fi
}

NODEJS(){
  print_message "Setup NodeJS repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $log_file
  status_check $log_file

  print_message "Install NodeJS"
  yum install nodejs -y &>> $log_file
  status_check $log_file

  APP_PREREQ

  print_message "Downloading and installing dependencies"
  cd /app
  npm install &>> $log_file
  status_check $log_file

  SYSTEMD_SETUP
  LOAD_SCHEMA
}

MAVEN(){
  print_message "Installing Maven"
  yum install maven -y &>> $log_file
  status_check $log_file

  APP_PREREQ

  print_message "Download the dependencies & build the application"
  mvn clean package &>> $log_file
  status_check $log_file

  print_message "Copy App file to App Location"
  mv target/$component-1.0.jar $component.jar
  status_check $log_file

  SYSTEMD_SETUP
  LOAD_SCHEMA
}

PYTHON(){
  print_message "Install Python"
  yum install python36 gcc python3-devel -y &>> $log_file
  APP_PREREQ

  print_message "Downloading and installing dependencies"
  cd /app
  pip3.6 install -r requirements.txt &>> $log_file
  status_check $log_file

  sed -i -e "s/roboshop_rabbitmq_password/$roboshop_rabbitmq_password" $current_dir/files/payment.service

  SYSTEMD_SETUP
}
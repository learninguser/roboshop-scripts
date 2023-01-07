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

LOAD_SCHEMA(){
  if [ $schema == "true" ]; then
    cp $current_dir/files/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
    print_message "Installing mongodb"
    yum install mongodb-org-shell -y &>> $log_file
    status_check $log_file

    print_message "Load schema"
    mongo --host mongodb-dev.learninguser.online </app/schema/$component.js &>> $log_file
    status_check $log_file
  fi
}

NODEJS(){
  print_message "Setup NodeJS repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $log_file
  status_check $log_file

  print_message "Install NodeJS"
  yum install nodejs -y &>> $log_file
  status_check $log_file

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

  print_message "Downloading and installing dependencies"
  cd /app
  npm install &>> $log_file

  cp $current_dir/files/$component.service /etc/systemd/system/$component.service
  status_check $log_file

  print_message "Load $component service"
  systemctl daemon-reload &>> $log_file
  status_check $log_file

  print_message "Starting $component service"
  systemctl enable $component &>> $log_file
  systemctl restart $component &>> $log_file
  status_check $log_file

  LOAD_SCHEMA
}
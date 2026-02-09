#!/bin/bash

source ./common.sh

check_root


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Install mysql"

systemctl enable mysqld
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Password set"

print_total_time
#!/bin/bash

source ./common.sh
app_name=frontend

check_root

dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "insatll Nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarted Nginx"

print_total_time
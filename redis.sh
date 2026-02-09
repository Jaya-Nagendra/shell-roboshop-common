#!/bin/bash

source ./common.sh
app_name=redis
check_root

dnf module disable redis -y &>>$LOG_FILE
dnf module enable redis:7 -y
VALIDATE $? "Enabling redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
sed -i '/protected-mode/c\protected-mode no' /etc/redis/redis.conf
#or -- sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf /  -e for extra comands 

VALIDATE $? "Allowing remote access"

systemctl enable redis 
systemctl start redis &>>$LOG_FILE

VALIDATE $? "Start redis"

print_total_time



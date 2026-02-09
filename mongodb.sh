#!/bin/bash

source ./common.sh
check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo.repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongodb"

systemctl start mongod 
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connection"

systemctl restart mongod 
VALIDATE $? "restarting mongod"

print_total_time
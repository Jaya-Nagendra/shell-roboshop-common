#!/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Install rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server
VALIDATE $? "Start rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "created user and gien permissions"

print_total_time
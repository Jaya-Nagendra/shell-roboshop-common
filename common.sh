#!/bin/bash

LOG_FOLDER="/var/log/roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"

N="\e[0m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"

SCRIPT_DIR=$PWD 
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.ljnag.space
MSQL_HOST=mysql.ljnag.space

mkdir -p $LOG_FOLDER

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

USER_ID=$(id -u)

check_root(){
if [ $USER_ID -ne 0 ]; then
echo -e "$R Run this script with Root account $N" | tee -a $LOG_FILE
exit 1
fi
}

VALIDATE(){
    if [ $1 -eq 0 ]; then
        echo -e "$(date "+%Y-%m-%d  %H:%M:%S") | $2 ....$G SUCCESS $N" | tee -a $LOG_FILE
        else
        echo -e "$2 .... $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    fi
}

app_setup(){
    id roboshop
    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "User creation"
    else
    echo "User allready exist"
    fi

    mkdir -p /app 

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
    VALIDATE $? "Download $app_name"

    cd /app 

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unziped the file"
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs 20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Install nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "npm install"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Install maven"

    cd /app 
    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "maven clean $app_name"
    mv target/$app_name-1.0.jar $app_name.jar  &>>$LOG_FILE
    VALIDATE $? "moving and renaming $app_name"
}

python_sepup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Install python"

    cd /app 
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "install dependencies"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Service file copy"

    systemctl daemon-reload
    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "$app_name start"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=(( $END_TIME - $START_TIME  ))
    echo -e "$(date "+%Y-%m-%d  %H:%M:%S") | Script executed in: $G $TOTAL_TIME seconds $N"
}
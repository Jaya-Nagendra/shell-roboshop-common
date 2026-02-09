#!/bin/bash

source ./common.sh
app_name=shipping

check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "install mysqql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

mysql -h $MSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
VALIDATE $? "load schema"

mysql -h $MSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
VALIDATE $? "load user"

mysql -h $MSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
VALIDATE $? "load data"

else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

app_restart

print_total_time
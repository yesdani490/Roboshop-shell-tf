#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGDIR=/tmp
LOGFILE=$LOGDIR/$SCRIPT_NAME-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m" 
#Y="\e[33m"

if [ $USERID -ne 0 ];

then 
  echo -e " $R Error::: Please run the script with root access $N "
  exit 1

fi

VALIDATE(){
   if [ "$1" -ne 0 ];
      then
        echo -e " $2....$R Failure $N"
        exit 1
      else 
      echo -e "   $2 .... $G Success $N"
   fi
}

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE
VALIDATE $? 'Downloading repo'

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE
VALIDATE $? 'Downloading rabbitmq '

yum install rabbitmq-server -y &>>$LOGFILE
VALIDATE $? 'Installing rabbitmq'

systemctl enable rabbitmq-server &>>$LOGFILE
VALIDATE $? 'Enabling rabbitmq'


systemctl start rabbitmq-server &>>$LOGFILE
VALIDATE $? 'Starting rabbitmq'

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE
VALIDATE $? 'adding user'

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE
VALIDATE $? 'setting permission'

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copied MongoDB Repo into yum.repos.d"

yum install mongodb-org -y &>>$LOGFILE

VALIDATE $? "Installation of MongoDB"

systemctl enable mongod &>>$LOGFILE

VALIDATE $? "Enabled MongoDB"

systemctl start mongod &>>$LOGFILE

VALIDATE $? "Started MongoDB"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf  &>>$LOGFILE
VALIDATE $? "Edited Mongodb conf"

systemctl restart mongod &>>$LOGFILE
VALIDATE $? "Restarted MongoDB"
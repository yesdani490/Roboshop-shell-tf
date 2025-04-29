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

yum module disable mysql -y &>>$LOGFILE
 VALIDATE $? 'Disabling mysql'

 cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOGFILE
 VALIDATE $? 'creating mysql.repo'

 yum install mysql-community-server -y &>>$LOGFILE

 VALIDATE $? 'Installing mysql'

 systemctl enable mysqld &>>$LOGFILE
VALIDATE $? 'Enabling mysql'
 
 systemctl start mysqld &>>$LOGFILE
 VALIDATE $? 'Starting mysql'

 mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE
VALIDATE $? 'Setting up root password'

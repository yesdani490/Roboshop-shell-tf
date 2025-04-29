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
yum install maven -y

VALIDATE $? 'Installing maven'

echo "Please enter username"
read roboshop

id "$roboshop" 
if [ $? -eq 0 ]; then
  echo "User '$roboshop' exists."
  exit 1
else
  echo "User '$roboshop' does not exist so adding user."
  sudo useradd $roboshop
fi
echo "username added is:"$USERNAME

echo "Enter Directory name"
read directory
# Check if the directory already exists
if [ -d "$directory" ]; then
  echo "The directory '$directory' already exists."
 
else
  # If it doesn't exist, create the directory
  sudo mkdir -p "$directory"

  echo "Directory created: $directory"
 
fi
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? 'Downloading shipping'

cd /app || exit &>>$LOGFILE

VALIDATE $? 'moving to /app'

unzip /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? 'Unzipping shipping file'

mvn clean package &>>$LOGFILE

VALIDATE $? 'package shipping app'

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE

VALIDATE $? 'Renaming shipping.jar'

cp /home/centos/roboshop-shell/shipping.service  /etc/systemd/system/shipping.service

VALIDATE $? 'Copying shipping service'

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? 'Daemon reload'

systemctl enable shipping &>>$LOGFILE
VALIDATE $? 'Shipping enable'

systemctl start shipping &>>$LOGFILE
VALIDATE $? 'starting shipping'

yum install mysql -y &>>$LOGFILE

VALIDATE $? 'Installing mysql'


mysql -h mysql.joindevops.top -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? 'Loading countires and cities information'

systemctl restart shipping &>>$LOGFILE
VALIDATE $? 'Restarting shipping'


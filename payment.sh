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

yum install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? 'Installing Python3
'
echo "Please enter username"
read roboshop

id "$roboshop" 
if [ $? -eq 0 ]; then
  echo "User '$roboshop' exists."
  
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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? 'Downloading payment artifact'

cd /app || exit &>>$LOGFILE
VALIDATE $? 'Moving to app directory'

unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? 'Unzipping payiment.ziip'

cd /app || exit &>>$LOGFILE
VALIDATE $? 'Moving to app directory'

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? 'Installing dependencies'

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? 'Copying payment service'

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? 'Daemon reload'

systemctl unmask payment &>>$LOGFILE
VALIDATE $? 'Unmasking payment service'

systemctl enable payment &>>$LOGFILE
VALIDATE $? 'Enabling payment'

systemctl start payment &>>$LOGFILE
VALIDATE $? 'starting payment'

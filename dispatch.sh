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
yum install golang -y 

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

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
VALIDATE $? 'Downloading dispatch artifact'

cd /app ||exit &>>$LOGFILE
VALIDATE $? 'moving to /app dir'
unzip /tmp/dispatch.zip &>>$LOGFILE
VALIDATE $? 'Unzipping dispatch'
cd /app ||exit &>>$LOGFILE
VALIDATE $? 'moving to /app dir'
go mod init dispatch &>>$LOGFILE
VALIDATE $? 'executing go init'
go get  &>>$LOGFILE
VALIDATE $? 'executing go get'
go build &>>$LOGFILE
VALIDATE $? 'build command'
cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE
VALIDATE $? 'copying dispatch service'
systemctl daemon-reload &>>$LOGFILE
VALIDATE $? 'Daemon reload'
systemctl enable dispatch &>>$LOGFILE
VALIDATE $? 'Enabling dispatch'
systemctl start dispatch &>>$LOGFILE
VALIDATE $? 'starting dispatch'
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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? 'Setting up Nodesource'

yum install nodejs -y &>>$LOGFILE

VALIDATE $? 'Installig NodeJS'

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


curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? 'Downloading user Artifact'

cd /app || exit &>>$LOGFILE

VALIDATE $? 'moving to /app directory'

unzip /tmp/user.zip &>>$LOGFILE

VALIDATE $? 'Unzipping user'

npm install &>>$LOGFILE

VALIDATE $? 'Installing dependencies'

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? 'copying user.service'

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? 'daemon reloading'

systemctl enable user &>>$LOGFILE

VALIDATE $? 'enabling user'

systemctl start user &>>$LOGFILE

VALIDATE $? 'enabling user'

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? 'copying mongorepo'

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? 'Installing mongo client'


mongo --host mongodb.joindevops.top </app/schema/user.js &>>$LOGFILE

VALIDATE $? 'Loading user data.'
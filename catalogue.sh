#bin/bash

USERID=$(id -u)
LOGS_FOLDER="var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executed at:$(date) | tee -a $LOG_FILE
if [ $USERID -eq 0 ]
then
    echo "run this script with no problem" | tee -a $LOG_FILE
else  
    echo "error:please run this script with root access" | tee -a $LOG_FILE
    exit 1
fi
#passing aruguments for validate function $1 and $2

VALIDATE(){ 
if [ $1 -eq 0 ]
then
   echo "$2 is success" | tee -a $LOG_FILE
else
   echo "$2 is not success" | tee -A $LOG_FILE
   exit 1
fi
}
dnf module list nodejs
VALIDATE $? "list"

dnf module disable nodejs
VALIDATE $? "disable"

dnf module enable nodejs:20 -y
VALIDATE $? "enable"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "useradd"

mkdir -p /app
VALIDATE $? "directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading"

cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping"

cd /app 
npm install 
VALIDATE $? "npm"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying"

systemctl daemon-reload
VALIDATE $? "reload"

systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "enable"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "mongo"

dnf install mongodb-mongosh -y
VALIDATE $? "install"

mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
VALIDATE $? "host"

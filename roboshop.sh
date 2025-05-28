#!bin/bash


USERID=$(id -u)
LOGS_FOLDER="var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo "script started executing at:$(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo "please run the script with root access" | tee -a $LOG_FILE
    exit 1
else
    echo "running with root access" | tee -a $LOG_FILE
fi

VALIDATE(){
if [ $1 -eq 0 ]
then 
   echo  "$2 is success..." | tee -a $LOG_FILE
else
   echo "$2  is not success..." | tee -a $LOG_FILE
   exit 1
fi
}

cp mongo.repo /etc/yum.repos.d/mongod.repo 
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "mongod"

systemctl enable mongod  &>>$LOG_FILE
VALIDATE $? "enable"

systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "settings"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarted"
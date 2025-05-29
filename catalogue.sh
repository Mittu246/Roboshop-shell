#bin/bash

USERID=$(id -u)

if [ $USERID -eq 0 ]
then
    echo "run this script with no problem"
else  
    echo "error:please run this script with root access"
    exit 1
fi
#passing aruguments for validate function $1 and $2

VALIDATE(){ 
if [ $1 -eq 0 ]
then
   echo "$2 is success"
else
   echo "$2 is not success"
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


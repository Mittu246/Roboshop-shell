#!bin/bash


USERID=$(id -u)
 
if [ $USERID -ne 0 ]
then
    echo "please run the script with root access"
    exit 1
else
    echo "running with root access" 
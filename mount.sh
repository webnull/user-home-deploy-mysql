#!/bin/bash
if ! [ "$1" ];
then
    echo "Mounts a MySQL server data from image from user's home directory. Could be used to encrypt MySQL data with eCryptFS if user has an encrypted home directory" 
    echo "Usage: [user login]"
    exit
fi

if ! grep -q "$1:" /etc/passwd ;
then
    echo "User $1 not found in the system"
    exit
fi

if ! [ -e "/home/$1/.mysql-deployment/image.img" ]
then
    echo "/home/$1/.mysql-deployment/image.img does not exists, did you run ./deploy.sh $1 [parition size in gigabytes here]? eg. ./deploy.sh damian 35"
    exit
fi

MySQLDir="/var/lib/mysql"

if [ "$2" == "tmp" ]
then
    MySQLDir="/mnt/mysql-tmp"
    mkdir /mnt/mysql-tmp
fi

mkdir /var/lib/mysql -p
mount "/home/$1/.mysql-deployment/image.img" "$MySQLDir" -o barrier=0,noatime,discard

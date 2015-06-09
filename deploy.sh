#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if ! [ "$1" ];
then
    echo "Creates a virtual partition in user's home directory and puts MySQL data. Could be used to encrypt MySQL data with eCryptFS if user has an encrypted home directory" 
    echo "Usage: [user login] [partition image size, eg. 50 - in gigabytes]"
    exit
fi

if ! whoami |grep root ;
then
    echo "You need to be a root to use this tool"
    exit
fi

if ! grep -q "$1:" /etc/passwd ;
then
    echo "User $1 not found in the system"
    exit
fi

if ! [ "$2" ];
then
    echo "Please specify partition size as secondary argument, eg. 50G"
    exit
fi

if ! [ -e "/home/$1/.mysql-deployment/" ]
then
    mkdir "/home/$1/.mysql-deployment/"
fi

#if [ -e "/home/$1/.mysql-deployment/image.img" ]
#then
#    echo "/home/$1/.mysql-deployment/image.img already exists, it seems that you already have deployed MySQL server on this account, remember - if its mounted on /var/lib/mysql then removing this file will cause loss of data in /var/lib/mysql"
#    exit
#fi

if [ -e /etc/init.d/mysql ] ;
then
    /etc/init.d/mysql stop
fi

size=$(($2*1024*1024))

echo "Creating a image of $2 size ($size kilobytes)" 
#dd if=/dev/zero of="/home/$1/.mysql-deployment/image.img" bs=1k count=$size

echo "Creating ext4 filesystem"
#mkfs.ext4 "/home/$1/.mysql-deployment/image.img"

echo "Moving /var/lib/mysql content to image"
"$DIR/mount.sh" "$1" tmp
cp -p /var/lib/mysql/* /mnt/mysql-tmp/ -R
mv /var/lib/mysql /var/lib/mysql-backup
umount "/mnt/mysql-tmp"
rmdir "/mnt/mysql-tmp"
echo "Your /var/lib/mysql was copied, the backup is in /var/lib/mysql-backup if the operation was successful you could remove backup files"

echo "Mounting image using mount.sh tool"
"$DIR/mount.sh" "$1"

echo "Image /home/$1/.mysql-deployment/image.img is ready"

echo "Adding entry to sudoers"
echo "$1 localhost = (root) NOPASSWD: $DIR/mount.sh" > "/etc/sudoers.d/user-home-deploy-mysql-by-$1"
chmod 0440 "/etc/sudoers.d/user-home-deploy-mysql-by-$1"

echo "[Desktop Entry]
Comment[pl]=
Comment=
Exec=sudo $DIR/mount.sh
GenericName=user-home-deploy-mysql
Icon=system-run
MimeType=
Name=user-home-deploy-mysql
Path=
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-KDE-SubstituteUID=false
X-KDE-Username=" > "/home/$1/.config/autostart/user-home-deploy-mysql.desktop"

chown "$1":"$1" "/home/$1/.config/autostart/user-home-deploy-mysql.desktop"
chmod 775 "/home/$1/.config/autostart/user-home-deploy-mysql.desktop"

if [ -e /etc/init.d/mysql ] ;
then
    /etc/init.d/mysql start
fi

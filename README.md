# user-home-deploy-mysql
Deploy MySQL data to user's /home directory and mount to /var/lib/mysql

Tips to speedup SSD write performance:
```bash
sudo echo "deadline" > /sys/block/sda/queue/scheduler
```
## How to install
```bash
sudo su
cd /usr/share
git clone https://github.com/webnull/user-home-deploy-mysql
cd user-home-deploy-mysql
```

## Move MySQL to user directory
```bash
sudo su
cd /usr/share/user-home-deploy-mysql
./deploy.sh YOUR-USER-LOGIN 35 # where 35 is 35 GIGABYTES SPACE FOR MYSQL IMAGE
```

## Everytime you want to run MySQL
```bash
sudo /usr/share/user-home-deploy-mysql/mount.sh YOUR-USER-LOGIN
```

The script also created a startup entry in KDE4, and a sudoers entry.

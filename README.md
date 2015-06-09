# user-home-deploy-mysql
Deploy MySQL data to user's /home directory and mount to /var/lib/mysql

Tips to speedup SSD write performance:
```bash
sudo echo "deadline" > /sys/block/sda/queue/scheduler
```

#!/bin/bash

s3_bucket="upgrad-pankaj"
myname="pankaj"

sudo apt update -y

dpkg -l aws
aws_exitcode=$(echo $?)

if [ $aws_exitcode -ne 0 ]
then
        sudo apt install -y awscli
else
        echo "AWS CLI is already  installed"
fi

dpkg -l apache2
apache_exitcode=$(echo $?)

if [ $apache_exitcode -ne 0 ]
then
	sudo apt install -y apache2
else
	echo "Apache2 is already  installed"
fi

status=`ps -eaf | grep -i apache2 | sed '/^$/d' | wc -l`

if [[ $status -gt 1 ]]
then
	echo "Apache2 service is running"
else
	sudo systemctl start apache2 && echo "Apache2 service started"
	sudo systemctl enable apache2 && echo "Apache2 service enabled"
fi

LogTypes="httpd-logs"
Type="tar"
timestamp=$(date "+%d.%m.%Y-%H.%M.%S")

sudo tar -cvf /tmp/$myname-$LogTypes-$timestamp.$Type /var/log/apache2/*.log
sudo aws s3 cp /tmp/$myname-$LogTypes-$timestamp.$Type s3://$s3_bucket

Size=$(du -h /tmp/$myname-$LogTypes-$timestamp.$Type | awk {'print $1'})

if [[ -f "/var/www/html/inventory.html" ]]
then
    echo "Inventory.HTML file exists on your filesystem."
else
	echo "Log Type		Time Created			Type		Size" >> /var/www/html/inventory.html

fi

echo -e "$LogTypes		$timestamp		$Type		$Size" >> /var/www/html/inventory.html

if [[ -f "/etc/cron.d/automation" ]]
then
    echo "Cron Job file exists on your filesystem."
else
       echo "* 23 * * * root /root/Automation_Project/automation.sh >> /root/Automation_Project/automation.logs" >> /etc/cron.d/automation
       echo "Cron Job created sucessfully"
fi

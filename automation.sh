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

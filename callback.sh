#!/bin/bash
## This certainly needs to be modified to work for the user that is going to execute everything, but we can consider it for root. This is POC
## But it works

## Check if the file exists and only then continuer. This prevents the service from dying if started before nginx has created neccessary files

while [ ! -f /var/log/nginx/access.log ]
do
  sleep 5
  echo "Waiting for NGINX access.log to be created"
done


tail -fn0 /var/log/nginx/access.log | \
while read line ; do
        echo "$line" | grep "pop=yes"
        if [ $? = 0 ]
        then
                echo "Got PoP Register request"
		ipaddr=`echo $line | cut -d" " -f1`
		echo "IP Address is: $ipaddr"
		if grep -Fxq $ipaddr /var/log/nginx/insights-proxy.log
			then
				echo "IP address exists: $ipaddr"
			else
				echo $ipaddr >> /var/log/nginx/insights-proxy.log
				## let's add the fingerprint to unblock passwordless SSH
				#ssh-keyscan -H $ipaddr >> ~/.ssh/known_hosts
			fi
	else
		echo "Wrong request" >> /var/log/nginx/insights-proxy.log
        fi
done

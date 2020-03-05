#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage : $0 HOSTNAME/IP"
    exit 1
fi

address=$1

# Check if hostname or IP is reachable
ping -c 2 $address > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "IP/Host not reachable"
	exit 1
else
	# Remove Old entry from known_hosts
	ssh-keygen -R $address > /dev/null 2>&1
	# ADD  HOSTS/ IP to known_hosts
	ssh-keyscan -H $address >> ~/.ssh/known_hosts
fi

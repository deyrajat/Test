#!/bin/bash

if [ -z $1 ]; then
    echo "Enter the Minion Password :"
    exit;
fi

minionPwd=$1

installSshPass=$(apt-get install sshpass)
nodeCnt=$(kubectl get nodes -o wide | grep -v NAME | grep -v master | wc -l)
nodeIpStr=$(kubectl get nodes -o wide | grep -v NAME | grep -v master | awk '{print $6}')
nodeIpList=($nodeIpStr)

for nodeIp in ${nodeIpList[*]}; do
    echo $(sshpass -p $minionPwd ssh-copy-id -o StrictHostKeyChecking=no root@$nodeIp)
    sleep 10
done

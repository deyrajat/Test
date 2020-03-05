#!/bin/bash
if [ -z $1 ]; then
    echo "LB01 IP not provided"
    exit;
fi
if [ -z $2 ]; then
    passwd=Starent@123
else
    passwd=$2
fi
lbIp=$1
offset=`ntpdate -q ${1} | awk 'FNR == 1 {print $8}'`
offsetLimit=0.3
osversion=0
if [ $( cat /etc/os-release | grep CentOS | wc -l ) -gt 0 ]; then
  osversion=1
fi
if [ $( cat /etc/os-release | grep Ubuntu | wc -l ) -gt 0 ]; then
  osversion=2
fi
if (( $(echo "$offset < $offsetLimit" |bc -l) )); then
   echo "The offset is within limit"
else
   echo "The offset is not within limit"
   if [ $osversion -eq 1 ]; then
     service ntpd stop
   fi
   if [ $osversion -eq 2 ]; then
     service ntp stop
   fi
   sleep 3
   ntpdate -s 1.ntp.esl.cisco.com
   sleep 3
   timedatectl set-ntp no
   sleep 3
   if [ $osversion -eq 1 ]; then
     service ntpd start
   fi
   if [ $osversion -eq 2 ]; then
     service ntp start
   fi
   sleep 3
   timedatectl set-ntp yes
   sleep 3
   if [ $osversion -eq 1 ]; then
     service ntpd start
   fi
   sleep 60
   offset=`ntpdate -q $lbIp | awk 'FNR == 1 {print $8}'`
   echo "ofset is $offset"
   if (( $(echo "$offset < $offsetLimit" |bc -l) )); then
      echo "The offset is within limit"
   else
      echo "The offset is not within limit"
   fi
fi
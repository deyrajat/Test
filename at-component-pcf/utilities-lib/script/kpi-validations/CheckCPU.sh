#!/bin/bash
if [ "$1" -eq 0 ]; then
    echo "Current CPU Idle is zero"
    exit;
fi

if [ "$2" -eq 0 ]; then
    echo "Configured CPU Idle threshold is zero"
    exit;
fi


if [ $2 -le $1 ]; 
   then
     echo "Avg CPU is less than configured CPU value" 
    exit;       
else
     echo "Avg CPU is exceeding configured CPU Value"
     exit;
fi

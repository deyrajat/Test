#!/bin/bash
if [ "$1" -eq 0 ]; then
    echo "Benchmark Ratio is zero"
    exit;
fi
if [ "$2" -eq 0 ]; then
    echo "Current Ratio is zero"
    exit;
fi

if [ $1 -le $2 ]; 
   then
     echo "Ratio's are within limits" 
    exit;       
else
     echo "Ratio's check is failing"
     exit;
fi

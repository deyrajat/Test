#!/bin/bash

if [ -z $1 ]; then
    echo "Enter the total succesful TPS value :"
    exit;
fi
if [ "$1" -eq 0 ]; then
    echo "Total TPS is zero"
    exit;
fi

if [ -z $2 ]; then
    echo "Enter the total successful LDAP TPS value :"
    #exit;
fi
if [ -z $3 ]; then
    echo "Enter the error count for the specified period:"
    #exit;
fi
if [ -z $4 ]; then
    echo "Enter the time duration in seconds:"
    exit;
fi
ivalue=`echo $4 `
fvalue=`echo $3 `

TotTPSValue=`expr $1 + $2`
TotalSec=`expr $4 \* $TotTPSValue`
echo "scale=2; $fvalue*100/$TotalSec" |bc

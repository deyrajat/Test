#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the benchmark value of site1: "
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the benchmark value of site2:"
    exit;
fi
if [ -z $4 ]; then
    echo "Enter the deviation percentage value :"
    exit;
fi
if [ -z $3 ]; then
    echo "Enter the Current TPS value :"
    exit;
fi

ivalue=`echo $1`
fvalue=`echo $2`
kvalue=`echo $4`
NEWTPS=`echo $3`

#if both the benchmark and iteration TPS value is less than the deviation threshold percentage
#we are marking the test as passed
if [ $ivalue -lt $kvalue -a $NEWTPS -lt $kvalue ]
then
    echo "Current Value is within threshold"
    exit;
fi

ADDVAL=$(expr "$ivalue" + "$fvalue")

FINALVAL=`echo "scale=2; ($ADDVAL-($kvalue*$ADDVAL)/100)" |bc`
if ((`bc <<< "$NEWTPS>=$FINALVAL"`))
   then
     echo "Current Value is within threshold" 
    exit;
else
     echo "Current Value exceeds threshold"
     exit;
fi


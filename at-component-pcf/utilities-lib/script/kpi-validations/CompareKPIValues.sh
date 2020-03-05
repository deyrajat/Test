#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the benchmark value: "
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the Current value :"
    exit;
fi
if [ -z $3 ]; then
    echo "Enter the deviation percentage value :"
    exit;
fi
ivalue=`echo $1`
fvalue=`echo $2`
kvalue=`echo $3`

perval=`echo "scale=2; (($kvalue*$ivalue)/100)+$ivalue" |bc`
#echo $perval
#echo $fvalue
if ((`bc <<< "$fvalue<=$perval"`))
   then
     echo "Current Value is within threshold" 
    exit;
else
     echo "Current Value exceeds threshold"
     exit;
fi


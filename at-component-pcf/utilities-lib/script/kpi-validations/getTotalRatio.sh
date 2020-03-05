#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the total successful TPS value of site1:"
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the total successful TPS value of site2:"
    exit;
fi
ivalue=`echo $1 `
fvalue=`echo $2 `


ratioval=$(( ($ivalue ) + $fvalue ))
finalval=$((ratioval/2))
if [ $finalval == 0 ]; then
     finalval=1
fi
echo $finalval
exit;

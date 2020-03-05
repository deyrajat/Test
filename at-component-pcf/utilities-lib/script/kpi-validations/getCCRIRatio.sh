#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the total successful TPS value :"
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the CCR I Total successful TPS value :"
    exit;
fi
ivalue=`echo $1 `
fvalue=`echo $2 `


ratioval=$(( ($ivalue ) / $fvalue ))
if [ $ratioval == 0 ]; then
     ratioval=1
fi
echo $ratioval
exit;

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


ratioval=`echo "scale=6 ; ($ivalue/$fvalue)" | bc`
echo $ratioval
exit;
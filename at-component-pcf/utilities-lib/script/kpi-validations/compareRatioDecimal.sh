#!/bin/bash
if [ -z $1 ]; then
    echo "Benchmark Ratio is required"
    exit;
fi
if [ -z $2 ]; then
    echo "Iteration ratio is required"
    exit;
fi
if [ -z $3 ]; then
    echo "Provide deviation"
    exit;
fi
tenp=`echo $3 | cut -d'.' -f2 | wc -c`
tenp=`echo " 10^$tenp " | bc`

actdev=`echo "$3 * $tenp" | bc`
actdev=`echo ${actdev%.*}`
actrdiff=`echo "scale=6 ; ($1-$2)" | bc`
actrdiff=`echo $actrdiff | tr -d '-'`
actrdiff=`echo "$actrdiff * $tenp" | bc`
actrdiff=`echo ${actrdiff%.*}`
if [ -z $actrdiff ]; then
    actrdiff=0
fi

if [ $actrdiff -le $actdev ];
   then
     echo "Ratio's are within limits"
    exit;
else
     echo "Ratio's check is failing"
     exit;
fi
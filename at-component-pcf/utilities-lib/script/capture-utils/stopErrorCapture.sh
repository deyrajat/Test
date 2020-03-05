#!/bin/bash
kill -9 $(ps -aef | grep "tail -f /var/log/broadhop/consolidated-qns.log" | grep -v grep | awk '{print $2}')
totalException=`grep ERROR $1 | wc -l`
echo "total Excetion: $totalException"

errorType=`grep "ERROR" $1 | awk -F "ERROR" '{print $NF}' | sort -u  | awk -F "-" '{print $1}' | sort -u`
for error in $errorType
do 
	uniqCount=`grep $error $1 | wc -l`
	lastUniqLine=`grep $error $1 | tail -1`
	echo "$lastUniqLine, Total Count=$uniqCount" >> tmp_Error
done
>$1
cp tmp_Error $1
rm -f tmp_Error
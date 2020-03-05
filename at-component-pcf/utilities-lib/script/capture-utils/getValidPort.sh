#!/bin/bash
if [ -z $1 ]; then
        echo "starting port number is missing"
        exit;
fi
testPort=$1
result=1
while [ $result -ne 0 ]; do
    result=$(ss -ln src :$testPort | grep -Ec -e "$testPort")
    if [ $result -gt 0 ]; then
       testPort=$(($testPort + 1))
    fi
done
echo $testPort

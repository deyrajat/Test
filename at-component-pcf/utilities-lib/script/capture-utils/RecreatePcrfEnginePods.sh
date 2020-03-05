#!/bin/bash

if [ -z $1 ]; then
    echo "Enter the deployement namespace value :"
    exit;
fi
if [ -z $1 ]; then
    echo "Enter the Engine Prefix value :"
    exit;
fi
nameSpace=$1
enginePrefix=$2
waititrcnt=20
cntr=1

nodeCnt=$(kubectl get pods -n $nameSpace | grep --color=never $enginePrefix | wc -l)
nodeStr=$(kubectl get pods -n $nameSpace | grep --color=never $enginePrefix | awk '{print $1}')
nodeList=($nodeStr)
for n in ${nodeList[*]}; do
    echo $(kubectl delete pod $n -n $nameSpace)
    sleep 30
done

totalinst=$(kubectl get pods -n $nameSpace | grep --color=never $enginePrefix | awk 'NR == 1 {print $2}'  | cut -d'/' -f 2 )
checkCntr=0
while [ $cntr -le $waititrcnt ]; do
    transCnt=$(kubectl get pods -n $nameSpace | grep --color=never $enginePrefix | grep -v Running | wc -l)
    if [ $transCnt -eq 0 ]; then
       break
    fi
    sleep 30
done

totalinst=$(kubectl get pods -n $nameSpace | grep --color=never $enginePrefix | awk 'NR == 1 {print $2}'  | cut -d'/' -f 2 )
testStr=`echo $totalinst/$totalinst`
echo "Expect status is $testStr"
nodeStr=$(kubectl get pods -n $nameSpace | grep --color=never $enginePrefix | awk '{print $1}')
nodeList=($nodeStr)
while [ $cntr -le $waititrcnt ]; do
    sleep 15
    checkCntr=0
    for n in ${nodeList[*]}; do
        podStatus=$(kubectl get pods -n $nameSpace | grep --color=never $n | awk '{print $2}')
        echo "==========================="
        echo "Check for $n"
        echo "Status is $podStatus"
        if [ "$podStatus" = "$testStr" ]; then
            checkCntr=$((checkCntr + 1))
        fi
    done
    echo "==========================="
    if [ $checkCntr -eq $nodeCnt ]; then
        echo "All the PcrfEngine Pods are ready"
        break
    fi
done
if [ $checkCntr -ne $nodeCnt ]; then
    checkCntr=0
    for n in ${nodeList[*]}; do
        podStatus=$(kubectl get pods -n $nameSpace | grep --color=never $n | awk '{print $2}')
        if [ "$podStatus" != "$testStr" ]; then
            echo "The status of the pod $n is $podStatus"
        fi
    done
fi
#!/bin/bash
if [ -z $1 ]; then
    nodeNum=1
else
    nodeNum=$1
fi
minionName=""
patsNode=$(kubectl get pod -n pats -o wide | grep --color=never patsexecutor | awk '{print $7}')
node_name_str=$(kubectl get node | grep --color=never -v NAME | grep -v master | awk '{print $1}')
node_name_list=($node_name_str)
node_name_list=( $(printf '%s\n' "${node_name_list[@]}" | sort -u))
counter=1
for nodeName in ${node_name_list[*]};
do
    if [ "$nodeName" == "$patsNode" ]; then
        continue
    else
        if [ $counter -eq $nodeNum ]; then
            minionName=$nodeName
            break
        else
            counter=`expr $counter + 1`
        fi
    fi
done
if [ $minionName = "" ]; then
    echo "No monion matching the condition present"
else
    minionIP=$(kubectl describe node $minionName | grep InternalIP | awk '{print $2}' )
    echo "The minion IP to use is $minionIP"
fi
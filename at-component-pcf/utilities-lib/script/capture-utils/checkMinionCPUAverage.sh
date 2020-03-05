#!/bin/bash
if [ -z $1 ]; then
    echo "Please provide the key file name with path"
    exit
fi

keyfilepath=${1}

node_name_str=$(kubectl get node | grep --color=never -v NAME | grep -v master | awk '{print $1}')
node_name_list=($node_name_str)
node_name_list=( $(printf '%s\n' "${node_name_list[@]}" | sort -u))
node_ip_str=$(kubectl get node -o wide | grep --color=never -v NAME | grep -v master | awk '{print $6}')
node_ip_list=($node_ip_str)
node_ip_list=( $(printf '%s\n' "${node_ip_list[@]}" | sort -u))
counter=0
for nodeName in ${node_name_list[*]};
do
    if [[ $nodeName =~ .*oam.* ]] ; then
        counter=$(( $counter + 1))
        continue
    fi
    nodeIp=${node_ip_list[$counter]}
    echo "nodeIp is $nodeIp"
    vCPU=`ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
    echo "vCPUs are $vCPU"
    loadAvg=`ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp uptime | awk '{print $(NF-1)}' | tr "," " "`
    echo "loadAvg is $loadAvg"
    if (( $(echo "$loadAvg $vCPU" | awk '{print ($1 <= $2)}') )); then
       echo "Load Average is less for $nodeName"
    else
       echo "Load Average is more for $nodeName value is $loadAvg"
    fi
    counter=$(( $counter + 1))
done
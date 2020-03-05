#!/bin/bash
if [ -z $1 ]; then
    echo "Please provide the key file name with path"
    exit
fi

keyfilepath=${1}

echo "===== Show the load average information fr all the nodes ======"
all_node_name_str=$(kubectl get node --show-labels | grep --color=never -v NAME  | awk '{print $1}')
all_node_name_list=($all_node_name_str)
all_node_name_list=( $(printf '%s\n' "${all_node_name_list[@]}" | sort -u))
all_node_ip_str=$( kubectl get node --show-labels -o wide | grep --color=never -v NAME | awk '{print $6}' )
all_node_ip_list=($all_node_ip_str)
all_node_ip_list=( $(printf '%s\n' "${all_node_ip_list[@]}" | sort -u))
all_counter=0
for nodeName in ${node_name_list[*]};
do
    nodeIp=${all_node_ip_list[$all_counter]}
    nodeName=${all_node_name_list[$all_counter]}
    echo "For node $nodeName"
    vCPU=`ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
    echo "vCPUs are $vCPU"
    loadAvg=`ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp uptime | awk '{print $(NF-1)}' | tr "," " "`
    echo "loadAvg is $loadAvg"
    all_counter=$(( $all_counter + 1))    
done 


node_name_str=$( kubectl get node --show-labels | grep =service | grep --color=never -v NAME | grep -v master | awk '{print $1}')
node_name_list=($node_name_str)
node_name_list=( $(printf '%s\n' "${node_name_list[@]}" | sort -u))
node_ip_str=$( kubectl get node --show-labels -o wide | grep =service | grep --color=never -v NAME | grep -v master | awk '{print $6}' )
node_ip_list=($node_ip_str)
node_ip_list=( $(printf '%s\n' "${node_ip_list[@]}" | sort -u))
counter=0
vmCount=0
for nodeName in ${node_name_list[*]};
do
    nodeIp=${node_ip_list[$counter]}
    echo "nodeIp is $nodeIp"
    vCPU=`ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
    echo "vCPUs are $vCPU"
    loadAvg=`ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp uptime | awk '{print $(NF-1)}' | tr "," " "`
    echo "loadAvg is $loadAvg"
    if (( $(echo "$loadAvg $vCPU" | awk '{print ($1 > $2)}') )); then
	   vmCount=$(( $vmCount + 1))
    fi
    counter=$(( $counter + 1))    
done 

if [ $counter -eq $vmCount ]; then
    echo "System is stressed"
else
    echo "System is not Stressed"
fi    

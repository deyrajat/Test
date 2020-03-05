#!/bin/bash

function usage_cpu() {
        local node_count=0
        local readonly nodes=$@
        local match_count=0

        for n in $nodes; do
                nodeIp=`kubectl get nodes -o wide | grep $n | awk '{print $6}'`
                percent_cpu=$(ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp /usr/bin/top -b | head -3 | tail -1 | awk '{print $8}' | cut -d'.' -f 1)
                percent_cpu=$(( 100 - $percent_cpu ))
                echo "$n: ${percent_cpu}% CPU"
                node_count=$((node_count + 1))
                if [ $percent_cpu -ge $limit ]; then
                    echo "For Minion $n CPU Used is > $limit%"
                else
                    match_count=$((match_count + 1))
                fi
        done
        if [ $match_count -eq $node_count ]; then
            echo "For all Minions CPU Used is < $limit%"
        fi
}

function usage_memory() {
        local node_count=0
        local total_percent_mem=0
        local readonly nodes=$@
        local match_count=0

        for n in $nodes; do
                nodeIp=`kubectl get nodes -o wide | grep $n | awk '{print $6}'`
                percent_mem=$(ssh -o StrictHostKeyChecking=no -i ${keyfilepath} $nodeIp free -t | awk 'NR == 2 {print $3/$2*100}' | cut -d'.' -f 1)
                echo "$n: ${percent_mem}% memory"
                node_count=$((node_count + 1))
                if [ $percent_mem -ge $limit ]; then
                    echo "For Minion $n Memory is used > $limit%"
                else
                    match_count=$((match_count + 1))
                fi
        done
        if [ $match_count -eq $node_count ]; then
            echo "For all Minions Memory is used < $limit%"
        fi
}

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 usage_cpu/usage_memory key-file-path limit(optional)"
    exit 1
fi

if [ -z $3 ]; then
    limit=80
else
    limit=`echo ${3} | tr -d % | tr -d ' '`
fi

keyfilepath=${2}

set -e

NODES=$(kubectl get nodes -l '!node-role.kubernetes.io/master' --no-headers -o custom-columns=NAME:.metadata.name)

if [ $1 == 'usage_cpu' ]; then
    usage_cpu $NODES
elif [ $1 == 'usage_memory' ]; then
    usage_memory $NODES
else
    echo "Only usage_cpu/usage_memory allowed"
    exit 1
fi

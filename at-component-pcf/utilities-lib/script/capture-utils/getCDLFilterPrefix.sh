#!/bin/bash

if [  $# -le 1 ]; then
   echo "Two or more Calipers file not provided"
   exit
fi
args=("$@")
counter=0
prefixLength=10
for supiId in "${args[@]}"
do
    if [ $counter -eq 0 ]; then
       filterPrefix=`echo $supiId | head -c $prefixLength`
    else
       while [ $prefixLength -gt 1 ];
       do
          matchPrefix=`echo $supiId | head -c $prefixLength`
          if [ "$filterPrefix" = "$matchPrefix" ]; then
             break
          else
             prefixLength=$(( $prefixLength - 1 ))
             filterPrefix=` echo $filterPrefix | head -c $prefixLength`
          fi
       done
    fi
    counter=$(( $counter + 1 ))
done

echo $filterPrefix

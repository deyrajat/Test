#!/bin/bash

namespaces=(`kubectl get ns | grep -v NAME | awk '{print $1}'`)
counter=0
for ns in "${namespaces[@]}"
do
   numpods=`kubectl get pod -n $ns | awk '{split($0,a," ");split(a[2],b,"/"); print b[1]-b[2]}' | grep -v 0 | wc -l`
   if [ $numpods -eq 0 ]; then
      counter=$(($counter+1))
   fi
done
if [ "${#namespaces[@]}" -eq "$counter" ]; then
    echo "Setup is 100% deployed"
else
    echo "Setup is not 100% deployed"
fi

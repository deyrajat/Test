#!/bin/bash
if [ "$1" -eq 0 ]; then
    echo "Total TPS is zero"
    #exit;
fi
if [ "$2" -eq 0 ]; then
    echo "Total LDAP TPS is zero"
    #exit;
fi
if [ "$3" -eq 0 ]; then
    echo "Minimum Expected TPS is zero"
    exit;
fi
TotTPSValue=`expr $1 + $2`


if [ $3 -le $TotTPSValue ]; 
   then
     echo "Avg TPS matches expected TPS value" 
    exit;       
else
     echo "Avg TPS is less than expected TPS"
     exit;
fi

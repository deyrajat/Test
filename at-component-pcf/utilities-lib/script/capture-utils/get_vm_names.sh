#!/bin/bash
if [ -z $1 ]; then
        echo "host file name is missing"
        exit;
fi
if [ -z $2 ]; then
        echo "vm Type (lb/pcrf/qns/sm) is missing"
        exit;
fi

hostfileName=$1
vmType=$2

#######  For LB hostname ######
if [ "$vmType" = "lb" ]; then
    lbHostName=`grep lb01 $hostfileName | head -n 1 | awk  '{print $3}'`
    STRLENGTH=$(echo -n $lbHostName | wc -m)
    STRLENGTH=`expr $STRLENGTH - 2`
    lbHostName=${lbHostName:0:$STRLENGTH}
    echo $lbHostName
fi

#######  For pcrf hostname ######
if [ "$vmType" = "pcrf" ]; then
    pcrfHostName=`grep pcrfclient01 $hostfileName | head -n 1 | awk  '{print $3}'`
    STRLENGTH=$(echo -n $pcrfHostName | wc -m)
    STRLENGTH=`expr $STRLENGTH - 2`
    pcrfHostName=${pcrfHostName:0:$STRLENGTH}
    echo $pcrfHostName
fi

#######  For QNS  hostname ######
if [ "$vmType" = "qns" ]; then
    qnsHostName=`grep qns01 $hostfileName | head -n 1 | awk  '{print $3}'`
    STRLENGTH=$(echo -n $qnsHostName | wc -m)
    STRLENGTH=`expr $STRLENGTH - 2`
    qnsHostName=${qnsHostName:0:$STRLENGTH}
    echo $qnsHostName
fi

#######  For SM hostname ######
if [ "$vmType" = "sm" ]; then
    smHostName=`grep sessionmgr01 $hostfileName | head -n 1 | awk  '{print $3}'`
    STRLENGTH=$(echo -n $smHostName | wc -m)
    STRLENGTH=`expr $STRLENGTH - 2`
    smHostName=${smHostName:0:$STRLENGTH}
    echo $smHostName
fi


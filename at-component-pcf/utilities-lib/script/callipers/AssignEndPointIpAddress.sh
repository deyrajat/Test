#!/bin/bash

help_function()
{
    echo "======================================"
    echo "parameters"
    echo "-f Input file"
    echo "-c call rate"
    echo "-L Local IP"
    echo "-G N7 Remote IP"
    echo "-N N28 Remote IP"
    echo "-R Rx Remote IP"
    echo "-Y Sy Remote IP"
    echo "-D Sd Remote IP"
    echo "-H Sh Remote IP"
    echo "-p NRFServPort1"
    echo "-q NRFServPort2"
    echo "-r NRFServPort3"
    echo "-b Brigde Port"  
    echo "-s NRFServIP1"
    echo "-t NRFServIP2"
    echo "-u NRFServIP3"    
    echo "======================================"
    exit
}


while getopts ":f:c:L:G:N:R:D:H:Y:p:q:r:b:s:t:u:" option; do
  case $option in
    f) fName=${OPTARG};;
    c) callRate=${OPTARG};;
    L) Local_IP=${OPTARG};;
    G) N7Remote_IP=${OPTARG};;
    N) N28Remote_IP=${OPTARG};;
    R) RxRemote_IP=${OPTARG};;
    D) SdRemote_IP=${OPTARG};;
    H) ShRemote_IP=${OPTARG};;
    Y) SyRemote_IP=${OPTARG};;
    p) NRFServPort1=${OPTARG};;
    q) NRFServPort2=${OPTARG};;
    r) NRFServPort3=${OPTARG};;
    b) bridgePort=${OPTARG};;
    s) NRFServIP1=${OPTARG};;
    t) NRFServIP2=${OPTARG};;
    u) NRFServIP3=${OPTARG};;
    \?) echo "Invalid option -$OPTARG" >&8
        help_function
    ;;
  esac
done

if [ -z $fName ]; then
   echo " file name is needed "
   exit;
fi

if [ ! -z $callRate ]; then
   sed -i -e 's/CallRate/'${callRate}'/g' $fName
fi
if [ ! -z $Local_IP ]; then
   sed -i -e 's/LocalIP/'${Local_IP}'/g' $fName
fi
if [ ! -z $N7Remote_IP ]; then
   sed -i -e 's/N7RemoteIP/'${N7Remote_IP}'/g' $fName
fi
if [ ! -z $N28Remote_IP ]; then
   sed -i -e 's/N28RemoteIP/'${N28Remote_IP}'/g' $fName
fi
if [ ! -z $RxRemote_IP ]; then
   sed -i -e 's/RxRemoteIP/'${RxRemote_IP}'/g' $fName
fi
if [ ! -z $SdRemote_IP ]; then
   sed -i -e 's/SdRemoteIP/'${SdRemote_IP}'/g' $fName
fi
if [ ! -z $ShRemote_IP ]; then
   sed -i -e 's/ShRemoteIP/'${ShRemote_IP}'/g' $fName
fi
if [ ! -z $SyRemote_IP ]; then
   sed -i -e 's/SyRemoteIP/'${SyRemote_IP}'/g' $fName
fi
if [ ! -z $NRFServPort1 ]; then
   sed -i -e 's/NRFServPort1/'${NRFServPort1}'/g' $fName
fi
if [ ! -z $NRFServPort2 ]; then
   sed -i -e 's/NRFServPort2/'${NRFServPort2}'/g' $fName
fi
if [ ! -z $NRFServPort3 ]; then
   sed -i -e 's/NRFServPort3/'${NRFServPort3}'/g' $fName
fi
if [ ! -z $NRFServIP1 ]; then
   sed -i -e 's/NRFServIP1/'${NRFServIP1}'/g' $fName
fi
if [ ! -z $NRFServIP2 ]; then
   sed -i -e 's/NRFServIP2/'${NRFServIP2}'/g' $fName
fi
if [ ! -z $NRFServIP3 ]; then
   sed -i -e 's/NRFServIP3/'${NRFServIP3}'/g' $fName
fi
if [ ! -z $bridgePort ]; then
   bpList=($(echo $bridgePort | tr "," "\n"))
   for bpPort in "${bpList[@]}"; do
       echo $bpPort
       sed -i -e '0,/BridgePort/{s/BridgePort/'${bpPort}'/}' $fName
   done
fi

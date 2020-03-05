#!/bin/bash

help_function()
{
    echo "======================================"
    echo "parameters"
    echo "-f Input file"
    echo "-S SUPI Start value"
    echo "-G GPSI Start value"
    echo "-P PEI Start value"
    echo "-i IPv4 Start value"
    echo "-s IPv6 Start value" 
    echo "-c CHF Location value"
    echo "======================================"
    exit
}


while getopts ":f:S:G:P:i:s:c:" option; do
  case $option in
    f) fName=${OPTARG};;
    S) supiInit=${OPTARG};;
    G) gpsiInit=${OPTARG};;
    P) peiInit=${OPTARG};;
    i) ipv4Init=${OPTARG};;
    s) ipv6Init=${OPTARG};;
    c) chfloc=${OPTARG};;
    \?) echo "Invalid option -$OPTARG" >&8
        help_function
    ;;
  esac
done

if [ -z $fName ]; then
   echo " file name is needed "
   exit;
fi

if [ ! -z $supiInit ]; then
   sed -i -e 's/SUPIValue/'${supiInit}'/g' $fName
fi
if [ ! -z $gpsiInit ]; then
   sed -i -e 's/GPSIValue/'${gpsiInit}'/g' $fName
fi
if [ ! -z $peiInit ]; then
   sed -i -e 's/PEIValue/'${peiInit}'/g' $fName
fi
if [ ! -z $ipv4Init ]; then
   sed -i -e 's~IPv4Value~'${ipv4Init}'~g' $fName
fi
if [ ! -z $ipv6Init ]; then
   sed -i -e 's~IPv6Value~'${ipv6Init}'~g' $fName
fi
if [ ! -z $chfloc ]; then
   sed -i -e 's/CHFLOC/'${chfloc}'/g' $fName
fi

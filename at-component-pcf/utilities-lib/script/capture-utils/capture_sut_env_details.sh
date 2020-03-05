#!/bin/bash
if [ -z $1 ]
then
        echo "Provide IP address of pcrfclient01/pcrfclient02."
        exit
fi

if [ -z $2 ]
then
        echo "Provide the name of the feature file."
        exit
fi
if [ -z $3 ]
then
        password="Starent@123"
else
        password="${3}"
fi

ip_addr="${1}"
ffname="${2}"
#echo "IP address is ${ip_addr}"
#echo $ffname

rm -f output.txt
#echo $password | ssh root@$ip_addr /var/qps/bin/support/env/capture_env.sh > output.txt
sshpass -p "${password}" ssh root@${ip_addr} /var/qps/bin/support/env/capture_env.sh > output.txt

fspec=`sed -n '$ p' output.txt | sed 's/^The CPS environment information has been exported to \(.*\)$/\1/'`

#echo $fspec

name="${fspec##*/}"
#echo $name

path="${fspec%/*}"
#echo $path

outputfile=$path/${ffname}_${name}
#echo "The archive name is $outputfile"
#echo $password | ssh root@$ip_addr mv $fspec $outputfile
sshpass -p "${password}" ssh root@${ip_addr} mv $fspec $outputfile
echo "$outputfile"
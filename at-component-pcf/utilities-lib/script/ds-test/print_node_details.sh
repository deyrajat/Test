#!/bin/bash
if [ -z $1 ]
then
    echo "dstest IP needed "
    exit
fi
dsClientPath=`find / -name dsClient | awk 'NR==1{print $1}'`
echo $dsClientPath
nodesstr=`/usr/local/devsol/bin/dsClient -d 10.122.122.64 -c "nodes"`
nodeslist=($nodesstr)
nodeslistLen=${#nodeslist[@]}
nodesnum=` expr $nodeslistLen / 2`
for ((number=0;number < $nodesnum;number++))
do
    arrindex=` expr 2 \* $number`
    elementtypename=${nodeslist[$arrindex]}
    echo $elementtypename
    elementindex=`expr $arrindex + 1`
    elementname=${nodeslist[$elementindex]}
    elementname=`echo $elementname | cut -d'=' -f 2 | cut -d"'" -f 2`
    echo $elementname 
    if [ $elementtypename == "pcef" ] ; then
        datastr=`echo $elementtypename':'$elementname 'gx om'`
        echo $datastr
        $dsClientPath -d $1 -c "$datastr"
    fi
    if [ $elementtypename == "hss" ] ; then
        datastr=`echo $elementtypename':'$elementname 'sh om'`
        echo $datastr
        $dsClientPath -d $1 -c "$datastr"
    fi
    if [ $elementtypename == "ocs" ] ; then
        datastr=`echo $elementtypename':'$elementname 'sy om'`
        echo $datastr
        $dsClientPath -d $1 -c "$datastr"
    fi
    if [ $elementtypename == "cscf" ] ; then
        datastr=`echo $elementtypename':'$elementname 'rx om'`
        echo $datastr
        $dsClientPath -d $1 -c "$datastr"
    fi
done

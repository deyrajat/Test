#!/bin/bash
help_function() {
echo "Mandatory"
echo "======================================"
echo "-i ip address of pcrfclient01"
echo "-p pcrfcleint01 PASSWORD"
echo "-o output directory(should be same as tet output directory)"
echo "OPtional"
echo "======================================"
echo "-e allowed error count"
echo ""
echo "Usage: ./checkSpike.sh -i 10.225.115.150 -p cisco123 -o /root/tet/"
exit
}

while getopts ":i:o:u:p:" opt; do
  case $opt in
    i) ip="$OPTARG"
    ;;
    o) outputPath="$OPTARG"
    ;;
    u) user="$OPTARG"
    ;;
    p) passwd="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        help_function
    ;;
  esac
done
if [ -z $ip ]; then
   help_function
fi
if [ -z $outputPath ]; then
   help_function
fi
if [ -z $passwd ]; then
   help_function
fi

cpuSpikeCounter () {
    echo "######### Get CPU Spike Count#######"
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        if [ "$host" != "installer" ] ; then
            acthostname=`sshpass -p $passwd ssh $ip ssh $host hostname | tr -d '\n'`
            acthostnameL=`echo $acthostname|wc -c`
            if [ $acthostnameL -lt 2 ]
            then
                continue
            fi
            lowestIdleStr=`grep -A 3 $acthostname $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $6}' | sort -nrk1,1`
            lowestIdleList=($lowestIdleStr)
            listSize=${#lowestIdleList[*]}
            lastIndex=`expr $listSize - 1`
            numSpike=0
            for negativeindex in $(seq 0 $lastIndex)
            do
                currentPos=`expr $lastIndex - $negativeindex`
                lowestIdle=${lowestIdleList[$currentPos]}
                if [ $( echo "$lowestIdle < 20"  | bc ) -ne 0 ] ; then
                    numSpike=`expr $numSpike + 1`
                else
                    echo "number of spike for " $host " is " $numSpike
                    break
                fi
            done
        fi
    done
}
function waitCheck()
{
    echo "######### I/O wait Spike Count #######"
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        if [ "$host" != "installer" ] ; then
            acthostname=`sshpass -p $passwd ssh $ip ssh $host hostname | tr -d '\n'`
            acthostnameL=`echo $acthostname|wc -c`
            if [ $acthostnameL -lt 2 ]
            then
                continue
            fi
            maxIOwait=`grep -A 3 $acthostname $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $4}' | sort -rk1 `
            lowestIdleList=($maxIOwait)            
            listSize=${#lowestIdleList[*]}
            lastIndex=`expr $listSize - 1`
            numSpike=0
            for listindex in $(seq 0 $lastIndex)
            do
                lowestIdle=${lowestIdleList[$listindex]}
                if [ $( echo "$lowestIdle > 20"  | bc ) -ne 0 ] ; then
                    numSpike=`expr $numSpike + 1`
                else
                    echo "number of I/O Wait spike for " $host " is " $numSpike
                    break
                fi
            done
        fi
    done
}

function stealCheck()
{
    echo "######### Steal Spike Counter #######"
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        if [ "$host" != "installer" ] ; then
            acthostname=`sshpass -p $passwd ssh $ip ssh $host hostname | tr -d '\n'`
            acthostnameL=`echo $acthostname|wc -c`
            if [ $acthostnameL -lt 2 ]
            then
                continue
            fi
            maxSteal=`grep -A 3 $acthostname $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $5}' | sort -rk1`
            lowestIdleList=($maxSteal)
            listSize=${#lowestIdleList[*]}
            lastIndex=`expr $listSize - 1`
            numSpike=0
            for listindex in $(seq 0 $lastIndex)
            do
                lowestIdle=${lowestIdleList[$listindex]}
                if [ $( echo "$lowestIdle > 20"  | bc ) -ne 0 ] ; then
                    numSpike=`expr $numSpike + 1`
                else
                    echo "number of Steal spike for " $host " is " $numSpike
                    break
                fi
            done
        fi
    done
}

if  ls -l $outputPath/iostat* > /dev/null 2>&1 ;  then
        cpuSpikeCounter $passwd $ip
	waitCheck $passwd $ip
        stealCheck $passwd $ip
else
        echo "TET output of IOStat not present"
fi


#!/bin/bash
help_function() {
echo "Mandatory"
echo "======================================"
echo "-i ip address of pcrfclient01"
echo "-p pcrfcleint01 PASSWORD"
echo "-o output directory(should be same as tet output directory)"
echo ""
echo "Usage: ./tetValidation.sh -i 10.225.115.150 -p cisco123 -o /root/tet/"
exit
}

memoryValidation () {
echo "######### Memory Check #######"
while read line
do
        #echo $line
        vm=`echo $line | awk '{print $1}'`
        numRec=`grep $vm $outputPath/vmstat_* | wc -l`
        sumSeris=`grep $vm $outputPath/vmstat_* | awk '{ sum += $4 } END {print sum}'`
        #echo " sum is " $sumSeris "NR is " $numRec
        avgMem=`expr "$sumSeris" / "$numRec"`
        #echo $avgMem
        totalMem=`grep $vm $outputPath/final.txt | awk '{print $3}' | rev | cut -c 2- | rev`
        #echo "$avgMem $totalMem "
        perMemUsed=$((100 * $avgMem / $totalMem))
        #echo "$vm:  $perMemUsed"
        if [ $perMemUsed -lt 80 ] ; then
                echo "$vm: Memory is used > 80%"
                #return
        else
		echo "$vm: Memory is used < 80%"
	fi
done < $outputPath/final.txt

}
cpuValidatiion () {
    echo "######### CPU Check #######"
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList 
    do
        if [ "$host" != "installer" ] ; then  
            #echo $host
            lowestIdle=`grep -A 3 $host $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $6}' | sort -rk1 | tail -1`
            if [ $( echo "$lowestIdle < 20"  | bc ) -ne 0 ] ; then
            #if [ $lowestIdle -lt 20 ] ; then
                echo "$host: Max CPU Used is > 80%"
            else 
                echo "$host: Max CPU Used is < 80%"
            fi
			
        fi
    done
}
function waitCheck()
{
    echo "######### I/O wait Check #######"
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        if [ "$host" != "installer" ] ; then
#            echo $host
            maxIOwait=`grep -A 3 $host $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $4}' | sort -rk1 | head -1`
            if [ $( echo "$maxIOwait < 20"  | bc ) -ne 0 ] ; then
#           if [ $lowestIdle -lt 20 ] ; then
                echo "$host: Max IO Wait < 20%"
            else
                echo "$host: Max IO Wait is > 20%"
            fi

        fi
    done
}

function stealCheck()
{
    echo "######### I/O wait Check #######"
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        if [ "$host" != "installer" ] ; then
#            echo $host
            maxSteal=`grep -A 3 $host $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $5}' | sort -rk1 | head -1`
#           echo $lowestIOwait
            if [ $( echo "$maxSteal < 20"  | bc ) -ne 0 ] ; then
#           if [ $lowestIdle -lt 20 ] ; then
                echo "$host: Max Steal time < 20%"
            else
                echo "$host: Max Steal time > 20%"
            fi

        fi
    done
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
rm -f $outputPath/final.txt
sshpass -p $passwd scp $ip:/root/outputkpi/* $outputPath
for file in $outputPath/* 
do
	if [ $(echo $file | grep outputkpi) ] ; then 
		#echo $file
		vm=`echo $file | awk -F"/" '{print $NF}' | awk -F"_" '{print $NF}'`
                #echo $vm
		echo "$vm Mem:" $(cat $outputPath/outputkpi_$vm | grep Mem: | awk '{print $2}' | sort -u) ", Swap:"  $(cat $outputPath/outputkpi_$vm | grep Swap: | awk '{print $2}' | sort -u) >> $outputPath/final.txt
	fi
done
if  ls -l $outputPath/vmstat* > /dev/null 2>&1 ;  then 
	memoryValidation $outputPath
else
	echo "TET output of VMStat not present"
fi
if  ls -l $outputPath/iostat* > /dev/null 2>&1 ;  then
	cpuValidatiion $passwd $ip
	waitCheck $passwd $ip
	stealCheck $passwd $ip
else
	echo "TET output of IOStat not present"
fi

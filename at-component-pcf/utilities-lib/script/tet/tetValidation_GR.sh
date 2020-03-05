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
echo "-c Max CPU Usage"
echo "-m Max Memory Usage"
echo "-w Max IOTime"
echo "-s Max StealTime"
echo ""
echo "Usage: ./tetValidation.sh -i 10.225.115.150 -p cisco123 -o /root/tet/ -e 2 -c 80% -m 95% -w 20% -s 20%"
exit
}

memoryValidation () {
    echo "######### Memory Check #######"
    memoryFree=`echo $memoryFree | cut -d'%' -f 1`
    memoryFree=$((100-$memoryFree))

#whi#le IFS=$'\r' read -r line
#do
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        #vm=`echo $line | awk '{print $1}'`
        echo $host
        vm=$host
        test_vm=`sshpass -p $passwd ssh -n $ip ping $vm -c 1 | grep icmp_seq`
        if [[ $test_vm != *"ttl"* ]] ; then
            echo "$vm is not pingable"
            continue
        fi
        #### PcrfClient check commented as per CDET CSCvm33547   #####
        #if [[ $vm =~ pcrfclient.*|lwr.*|udc.* ]]; then #-o $vm =~ lwr.* -o $vm =~ udc.* ]] ; then
        if [[ $vm =~ pcrfclient.*|installer ]]; then
            echo "skip check for $vm"
            continue
        fi
        vmNewName=`sshpass -p $passwd ssh -n $ip ssh $vm hostname | tr -d '\n'`
        numRec=`grep $vmNewName $outputPath/vmstat_* | wc -l`
        sumSeris=`grep $vmNewName $outputPath/vmstat_* | awk '{ sum += $4+$5+$6 } END {print sum}'`
        avgMem=`expr "$sumSeris" / "$numRec"`
        #totalMem=`grep $vm $outputPath/final.txt | awk '{print $3}' | rev | cut -c 1- | rev`
        totalMem=`sshpass -p $passwd ssh -n $ip ssh $vm free | grep Mem: | awk '{print $2}'`
        perMemFree=$((100 * $avgMem / $totalMem))
        echo "perMemFree = $perMemFree"
        if [ $perMemFree -lt $memoryFree ] ; then
            echo "$vm: Memory is used > $((100-$memoryFree))%"
            echo "Free Memory = $avgMem"
            echo "totalMem = $totalMem"
        else
            echo "$vm: Memory is used < $((100-$memoryFree))%"
        fi
    done
#done < "$outputPath/final.txt"
}
cpuValidatiion () {
    echo "######### CPU Check #######"
    
	cpuIdle=`echo $cpuIdle | cut -d'%' -f 1`
	cpuIdle=$((100-$cpuIdle))
    
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList 
    do
        #if [[ $host =~ lwr.*|udc.* ]] ; then
        #     echo "skip check for $host"
        #     continue
        #fi

        if [ "$host" != "installer" ]; then  
            test_vm=`sshpass -p $passwd ssh $ip ping $host -c 1 | grep icmp_seq`
            if [[ $test_vm != *"ttl"* ]] ; then
                echo "$host is not pingable"
                continue
            fi
            acthostname=`sshpass -p $passwd ssh $ip ssh $host hostname | tr -d '\n'`
            lowestIdleStr=`grep -A 3 $acthostname $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $6}' | sort -nrk1,1`
            lowestIdleList=($lowestIdleStr)
            listSize=${#lowestIdleList[*]}
            changePos=`expr $listSize - $allowedErrorCnt`
            lowestIdle=${lowestIdleList[$changePos]}
            echo "lowestIdle :" $lowestIdle
            if [ $( echo "$lowestIdle < $cpuIdle"  | bc ) -ne 0 ] ; then
            #if [ $lowestIdle -lt 20 ] ; then
                echo "$host: Max CPU Used is > $((100-$cpuIdle))%"
            else 
                echo "$host: Max CPU Used is < $((100-$cpuIdle))%"
            fi
			
        fi
    done
}
function waitCheck()
{
    echo "######### I/O wait Check #######"
    
    maxWait=`echo $maxWait | cut -d'%' -f 1`
    
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        #if [[ $host =~ lwr.*|udc.* ]] ; then
        #    echo "skip check for $host"
        #    continue
        #fi
        if [ "$host" != "installer" ] ; then
            test_vm=`sshpass -p $passwd ssh $ip ping $host -c 1 | grep icmp_seq`
            if [[ $test_vm != *"ttl"* ]] ; then
                echo "$host is not pingable"
                continue
            fi
            acthostname=`sshpass -p $passwd ssh $ip ssh $host hostname | tr -d '\n'`
            maxIOwait=`grep -A 3 $acthostname $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $4}' | sort -rk1 | head -1`
            if [ $( echo "$maxIOwait < $maxWait"  | bc ) -ne 0 ] ; then
#           if [ $lowestIdle -lt 20 ] ; then
                echo "$host: Max IO Wait < $maxWait%"
            else
                echo "$host: Max IO Wait is > $maxWait%"
            fi

        fi
    done
}

function stealCheck()
{
    echo "######### Steal Check #######"
    
    maxCPUSteal=`echo $maxCPUSteal | cut -d'%' -f 1`
    
    hostList=`sshpass -p $passwd ssh $ip hosts-all.sh`
    for host in $hostList
    do
        #echo "Host name is $host"
        #if [[ $host =~ lwr.*|udc.* ]] ; then
        #    echo "skip check for $host"
        #    continue
        #fi
        #echo "Host is not lwr or udc"
        if [ "$host" != "installer" ] ; then
            test_vm=`sshpass -p $passwd ssh $ip ping $host -c 1 | grep icmp_seq`
            if [[ $test_vm != *"ttl"* ]] ; then
                echo "$host is not pingable"
                continue
            fi
            acthostname=`sshpass -p $passwd ssh $ip ssh $host hostname | tr -d '\n'`
            maxSteal=`grep -A 3 $acthostname $outputPath/iostat_* | grep -v "HOSTNAME\|OUTPUT\|TIMESTAMP\|=\|Linux\|avg-cpu\|^$\|--" | awk '{print $5}' | sort -rk1 | head -1`
#           echo $lowestIOwait
            if [ $( echo "$maxSteal < $maxCPUSteal"  | bc ) -ne 0 ] ; then
#           if [ $lowestIdle -lt 20 ] ; then
                echo "$host: Max Steal time < $maxCPUSteal%"
            else
                echo "$host: Max Steal time > $maxCPUSteal%"
            fi

        fi
    done
}

echo " starting validation"
while getopts ":i:o:u:p:e:c:m:w:s:" opt; do
  case $opt in
    i) ip="$OPTARG"
    ;;
    o) outputPath="$OPTARG"
    ;;
    e) allowedErrorCnt="$OPTARG"
    ;;
    u) user="$OPTARG"
    ;;
    p) passwd="$OPTARG"
    ;;
    c) cpuIdle="$OPTARG"
    ;;
    m) memoryFree="$OPTARG"
    ;;
    w) maxWait="$OPTARG"
    ;;
    s) maxCPUSteal="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&3
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
if [ -z $allowedErrorCnt ] || [ $allowedErrorCnt -lt 1 ]; then
   allowedErrorCnt=1
fi
if [ -z $cpuIdle ]; then
   cpuIdle="80%"
fi
if [ -z $memoryFree ]; then
   memoryFree="80%"
fi
if [ -z $maxIOWait ]; then
   maxIOWait="20%"
fi
if [ -z $maxSteal ]; then
   maxSteal="20%"
fi

rm -f $outputPath/final.txt
sshpass -p $passwd scp $ip:/root/outputkpi/* $outputPath
for file in $outputPath/* 
do
	if [ $(echo $file | grep outputkpi) ] ; then 
		#echo $file
		vm=`echo $file | awk -F"/" '{print $NF}' | awk -F"_" '{print $NF}'`
                #echo $vm
                memValue=$(cat $outputPath/outputkpi_$vm | grep Mem: | awk '{print $2}' | sort -u)
                swapValue=$(cat $outputPath/outputkpi_$vm | grep Swap: | awk '{print $2}' | sort -u)
                echo -e "$vm Mem: $memValue , Swap: $swapValue \r" >> $outputPath/final.txt
		#echo "$vm Mem:" $(cat $outputPath/outputkpi_$vm | grep Mem: | awk '{print $2}' | sort -u) ", Swap:"  $(cat $outputPath/outputkpi_$vm | grep Swap: | awk '{print $2}' | sort -u) >> $outputPath/final.txt
	fi
done
chmod 755 $outputPath/final.txt
if  ls -l $outputPath/vmstat* > /dev/null 2>&1 ;  then 
	echo "$outputPath"
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
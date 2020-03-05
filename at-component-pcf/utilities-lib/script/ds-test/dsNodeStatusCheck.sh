#!/bin/bash
help_function()
{
        echo "Mandatory"
        echo "======================================"
        echo "-I ip address of dsTest"
        echo ""
	echo "Optional"
	echo "======================================"
        echo "-F file name of the dsTest configuration"
	echo "-C Retry count (Defaule 5)"
	echo "-S Interval time between two retry (Default 30 sec)"
        echo "Usage: ./dsNodeStatusCheck.sh -I 10.225.115.224 -F Solution2_2nd.xml -C 4 -S 10"
        exit
}
while getopts ":I:F:C:S:" opt; do
  case $opt in
    I) dsTestIP="$OPTARG"
    ;;
    F) dsTestConfigFileName="$OPTARG"
    ;;
    C) loopCount="$OPTARG"
    ;;
    S) loopSleep="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        help_function
    ;;
  esac
done
if [ -z $loopSleep ] ; then
	loopSleep=30
fi
if [ -z $loopCount ] ; then
	loopCount=5
fi
if [ -z $dsTestIP ] ; then
	help_function
fi
if [ -z $dsTestConfigFileName ] ; then
	echo "WARNING: You did not provide dsTest config file, so it will check all unwated node also"
#	help_function
fi

loop=0
while [ $loop -lt $loopCount ]
do
	noodeStatus=0
        loop=`expr $loop + 1`
        echo "Trycount: $loop"
        /usr/local/devsol/bin/dsClient -d $dsTestIP -c "nodes status" > tmp.txt
	nodePresents=`grep "name=" tmp.txt | wc -l`
	if [ $nodePresents -eq 0 ]; then
		echo "No nodes is created"
		exit
	fi	
        nodeList=`grep -A 3 "name=" tmp.txt | grep -v "status\|started\|--\|deny" | awk '{print $2}' | sed 'N;s/\n/ /' | awk '{if($2 != "contents:true") print $1}' |  sed "s/' /\"/"`
        for node in $nodeList
        do
                nodeName=`echo $node | awk -F= '{print $2}' | tr -d \'  `
		if [ -z $dsTestConfigFileName ] ; then 
			echo "$nodeName is not in the ready state"
                        noodeStatus=1
		else
			findCount=`grep "name=\"$nodeName\"" $dsTestConfigFileName | wc -l`
			if [ $findCount -gt 0 ] ; then
				echo "$nodeName is not in the ready state"
                		noodeStatus=1
			fi
		fi
        done

        sleep $loopSleep
done
if [ $noodeStatus -ne 1 ] ; then
        echo "All nodes are in the ready state"
fi
#rm -f tmp.txt

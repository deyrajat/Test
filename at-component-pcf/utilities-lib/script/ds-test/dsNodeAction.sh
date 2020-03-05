#!/bin/bash
function help_function
{
	echo "Mandatory"
	echo "======================================"
	echo "-i ip address of dsTest"
	echo "-f file name of the dsTest configuration"
	echo "-a action need to be perform. stop/start/delete"
	echo ""
	echo "Optional"
	echo "======================================"
	echo "-N Node Type (hss cscf ....)"
	echo "-n Node name (TEJAS_Solution2_OCS_3 TEJAS_Solution2_PCEF_4)"
	echo ""
	echo "Usage: ./dsNodeAction.sh -i 10.225.115.224 -f Solution2_2nd.xml -n \"TEJAS_Solution2_DB_TDF_1 TEJAS_Solution2_CSCF_1\" -a \"stop\""
	echo "Usage: ./dsNodeAction.sh -i 10.225.115.224 -f Solution2_2nd.xml -N \"hss cscf\" -a \"stop\""
	exit
}
function nodeAction 
{
	for nodeType in $nodeTypeList
	do
		for node in $nodeList
                do
                        if [ $( echo $node | grep $nodeType) ]
                        then
        #                       echo "$action taken on $node $dsTestIP"
                                /usr/local/devsol/bin/dsClient -d $dsTestIP -c "$node $action"
                        fi
                done
	done
	exit
}
function nodeNameAction 
{
	#echo $nodeList
	for nodeName in $nodeNameList
	do 
		for node in $nodeList
		do 
			if [ $( echo $node | grep $nodeName) ]
			then
	#			echo "$action taken on $node $dsTestIP"
				/usr/local/devsol/bin/dsClient -d $dsTestIP -c "$node $action"
			fi
		done
	done
	exit
}
while getopts ":i:f:N:n:a:" opt; do
  case $opt in
    a) action="$OPTARG"
    ;;
    i) dsTestIP="$OPTARG"
    ;;
    f) dsTestConfigFileName="$OPTARG"
    ;;
    N) nodeTypeList="$OPTARG"
    ;;
    n) nodeNameList="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        help_function
    ;;
  esac
done
if [ -z $dsTestIP ] ; then
	help_function
fi
if [ -z $dsTestConfigFileName ] ; then
	help_function
fi
if [ -z $action ] ; then
    help_function
fi

#nodeList=`grep name= $dsTestConfigFileName | grep "hss\|ocs\|cscf\|pcef\|tdf\|spr\|pcrf\|mme\|as\|cscf" | awk -F "name=\"" '{print $1":"$2}' | rev | cut -c 3- | rev | sed -e "s/ //g" | cut -c 2- | grep -Ev 'subscriber|SmartProfile|SmartEvents|start|subscription|access_profile'`
nodeList=`grep name= $dsTestConfigFileName | grep "hss\|ocs\|cscf\|pcef\|tdf\|spr\|pcrf\|mme\|as\|cscf\|agw\|aaa" | awk -F "name=\"" '{print $1":"$2}' | rev | cut -c 3- | rev | sed -e "s/ //g" | cut -c 2- | grep -Ev 'subscriber|SmartProfile|SmartEvents|start|subscription|access_profile|diameter|avp' | awk -F "\"" '{print $1}' | sort -u`
if [ "$nodeTypeList" != "" ] ; then
        nodeAction $nodeTypeList $action
fi
if [ "$nodeNameList" != "" ] ; then
        nodeNameAction $nodeNameList $action $nodeList
fi

for node in $nodeList
do
#        echo "deleting $node"
#        echo "/usr/local/devsol/bin/dsClient -d $dsTestIP -c \"$node $action\""
        /usr/local/devsol/bin/dsClient -d $dsTestIP -c "$node $action"
done

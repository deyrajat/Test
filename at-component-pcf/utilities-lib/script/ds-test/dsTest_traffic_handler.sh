#!/bin/bash
#########################################################################################
#       Filename : dsTest_traffic_handler.sh
#       Author   : Abhijit Bote
#       Project  : GR Automation
#       About    : This bash script can handle(stop/start) traffic of dsTest nodes based on input xml file
#       Version  : 1 [Date: 31-Mar-18] [Initial Version]
##########################################################################################


Search_Site()
{
  grep name= $XmlFileName | grep "hss\|ocs\|cscf\|pcef\|spr\|pcrf\|mme\|as\|cscf\|agw\|aaa" | awk -F "name=\"" '{print $1":"$2}' | rev | cut -c 3- | rev | sed -e "s/ //g" | cut -c 2- | grep -Ev 'subscriber|SmartProfile|SmartEvents|start|subscription|access_profile|diameter' | grep -v "avp:"| awk -F "\"" '{print $1}' | sort -u > /root/dsTest_nodes_list.txt

	if [ $RecoveringSiteId == "site2"  ]
		then grep -i $RecoveringSiteId /root/dsTest_nodes_list.txt | grep cscf > /root/cscf_nodes.txt
		     grep -i $RecoveringSiteId /root/dsTest_nodes_list.txt | grep pcef > /root/pcef_nodes.txt	
	#	then nodeList=`grep -i $RecoveringSiteId /root//root/dsTest_nodes_list.txt`
	else 	 grep -iv site2 /root/dsTest_nodes_list.txt | grep pcef > /root/pcef_nodes.txt
		grep -iv site2 /root/dsTest_nodes_list.txt | grep cscf > /root/cscf_nodes.txt
	#	nodeList=`grep -iv $RecoveringSiteId /root/dsTest_nodes_list.txt`
	fi
for cmd in `cat /root/cscf_nodes.txt`
	do
		arr_site_csef[$i]="dsClient -c \"$cmd $Rx_SOCKET_NAME stop\""
		let "i++"
done	      

for cmd in `cat /root/pcef_nodes.txt`
	do
		arr_site_pcef[$j]="dsClient -c \"$cmd $Gx_SOCKET_NAME stop\""
      		let "j++"
  	done
}

cscf_Display ()
{
  for cscf in "${arr_site_csef[@]}"
  do
    echo "$cscf"
  done
} > /root/dsNodes_stop.sh

pcef_Display ()
{
  for pcef in "${arr_site_pcef[@]}"
  do
    echo "$pcef"
  done
echo "sleep 60"
} >> /root/dsNodes_stop.sh

dsTest_cmd ()
{
chmod 777 /root/dsNodes_stop.sh
ssh root@$dsTestIp "sh /root/dsNodes_stop.sh"
sleep 5
sed 's/stop/status/' /root/dsNodes_stop.sh > /root/dsNodes_status.sh
chmod 777 /root/dsNodes_status.sh
sh /root/dsNodes_status.sh > /root/nodeStatus.txt
cnt=`grep "Idle" /root/nodeStatus.txt | wc -l`
	if [ $cnt -eq 0 ]
		then echo "Diameter links towards recovering site are still Connected"
	else	echo "Diameter links towards recovering site have been disconnected"

fi

}


Traffic_stop ()
{
        Search_Site $XmlFileName $RecoveringSiteId
	cscf_Display
	pcef_Display 
#       Site1_Display
        dsTest_cmd $dsTestIp

}

Traffic_start ()
{
sed  's/stop/start/' /root/dsNodes_stop.sh > /root/dsNodes_start.sh
chmod 777 /root/dsNodes_start.sh
ssh root@$dsTestIp "sh /root/dsNodes_start.sh"
sleep 5
sh /root/dsNodes_status.sh > /root/nodeStatus.txt
cnt=`grep "Connected" /root/nodeStatus.txt | wc -l`
if [ $cnt -eq 0 ]
        then echo "Traffic towards recovering site hsa NOT started"
else echo "Traffic towards recovering site has been started"
fi

}

help()
{
        echo "Mandatory"
        echo "======================================"
        echo "======================================"
        echo "Site id of a recovery site"
        echo "Xml file name of dsTest make break file "
        echo "daTest endpoint ip addresess"
	echo "function Name"
        echo "======================================"
        echo "Please follow given below sequence to execute the script"
        echo "<dsTest_traffic_handler.sh> <recoverySiteId> <xml dsTest file name> <dsTest endpintIpAddress> <function name>"
        echo "Usage: ./dsTest_traffic_handler.sh site2 MakebreakFile.xml 172.18.19.20 Traffic_stop"
}


i=0
j=0
arr_site_csef=[]
arr_site_pcef=[]
RecoveringSiteId=$1
Gx_SOCKET_NAME=$2
Rx_SOCKET_NAME=$3
XmlFileName=$4
dsTestIp=$5
User_input=$6
case $User_input in
    "Traffic_stop")
            Traffic_stop $RecoveringSiteId $XmlFileName $dsTestIp
            ;;
    "Traffic_start")
            Traffic_start $dsTestIp
            ;;
    *)
        echo "Please enter valid option"
        help
       ;;
esac


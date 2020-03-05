#!/bin/bash
#########################################################################################
#       Filename : Mongo_db_action.sh 
#       Author   : Abhijit Bote
#       Project  : GR Automation
#       About    : This bash script has capability to find primary members and make them down and up based on requirement.
#       Version  : 1 [Date: 28-Nov-17] [Initial Version]
#		   2 [Date: 15-Feb-18] Modularize script
#
##########################################################################################



SearchIpAndPort ()
{

	diagnostics.sh --get_replica $TRIGGRED_SITEID | grep $PORT_ID |grep -v "ARBITER" | grep "PRIMARY" | awk -F':' '{print $2}' | awk -F'-' '{print $1}'  > /root/ip_$TRIGGRED_SITEID.txt
	sed -i $'s/[^[:print:]\t]//g' /root/ip_$TRIGGRED_SITEID.txt;sed  -i 's/\[42G//' /root/ip_$TRIGGRED_SITEID.txt;sed  -i 's/\[49G//' /root/ip_$TRIGGRED_SITEID.txt;sed -i 's/ //g' /root/ip_$TRIGGRED_SITEID.txt	
}


MongoDbStop ()
{
ssh `cat /root/ip_$TRIGGRED_SITEID.txt` monit stop aido_client
sleep 5
echo "/etc/init.d/sessionmgr-$PORT_ID" > /root/ipportfinal.txt
paste /root/ip_$TRIGGRED_SITEID.txt /root/ipportfinal.txt > /root/temp1
sed -e 's/^/ssh /'  /root/temp1 > /root/temp2
sed  's/$/ stop/' /root/temp2 > /root/final_$TRIGGRED_SITEID.sh
chmod 777 /root/final_$TRIGGRED_SITEID.sh
sh /root/final_$TRIGGRED_SITEID.sh > /root/output_mongo_stop_$TRIGGRED_SITEID.txt
sleep 5
SUCCESS=`cat /root/output_mongo_stop_$TRIGGRED_SITEID.txt | egrep "stopped successfully|OK"| wc -l`
if [[ $SUCCESS -eq "1" ]]; then echo "Mongo process stopped"
        else echo "Mongo proces not stopped"
fi

rm -rf /root/temp1
rm -rf /root/temp2

}

MongoDbStart ()
{
sed  's/stop/start/' /root/final_$TRIGGRED_SITEID.sh > /root/final_start_$TRIGGRED_SITEID.sh
chmod 777 /root/final_start_$TRIGGRED_SITEID.sh
sh /root/final_start_$TRIGGRED_SITEID.sh > /root/output_mongo_start_$TRIGGRED_SITEID.txt
sleep 5
SUCCESSCOUNT2=`cat /root/output_mongo_start_$TRIGGRED_SITEID.txt | egrep "started successfully|OK"| wc -l`
if [[ $SUCCESSCOUNT2 -eq "1" ]]; then echo "Mongo process started"
        else echo "Mongo proces not started"
fi

ssh `cat /root/ip_$TRIGGRED_SITEID.txt` monit start aido_client
sleep 5

rm -rf /root/final_start_$TRIGGRED_SITEID.sh /root/ip_$TRIGGRED_SITEID.txt /root/output_mongo_start_$TRIGGRED_SITEID.txt /root/ipportfinal.txt /root/ip_$TRIGGRED_SITEID.txt /root/output_mongo_stop_$TRIGGRED_SITEID.txt

}



DB_STOP ()
{

	SearchIpAndPort $TRIGGRED_SITEID $PORT_ID
	MongoDbStop $PORT_ID

}

DB_START ()
{

	MongoDbStart $TRIGGRED_SITEID

}


help()
{
        echo "Mandatory"
        echo "======================================"
        echo "======================================"
        echo "Triggered site id"
        echo "Function name"
        echo ""
        echo "======================================"
        echo "Please follow given below sequence to execute the script"
        echo "<Mongo_db_action.sh> <Triggered site id> DB_STOP "
        echo "Usage: ./Mongo_db_action.sh site1 DB_STOP"
	echo "Usage: ./Mongo_db_action.sh site1 DB_START"
}



TRIGGRED_SITEID=$1
PORT_ID=$2
User_input=$3
case $User_input in
    "DB_STOP")
	    DB_STOP $TRIGGRED_SITEID $PORT_ID 
            ;;
    "DB_START")
            DB_START $TRIGGRED_SITEID $PORT_ID
            ;;
    *)	 
        echo "Please enter valid option"
        help
       ;;	
esac


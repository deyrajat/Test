#!/bin/bash

usage() {
        echo "Usage: `basename $0` [s <no. of shards: default to 4>|S <no. of shards: default to 4>|b|h]"
        echo "       s => create session shards without backup db."
        echo "       S => create session shards with last session db in list as backup db."
        echo "       b => create balance shards."
        echo "       a => S+b: create balance and session shards with backup."
        echo "       h => Help."
        exit 1
}
create_session_shards() {
        filename=/tmp/replicaSets.txt
        diagnostics.sh --get_rep > $filename
        db_name='SESSION'
        filename=/tmp/replicaSets.txt
        dbCount=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|wc -l`
        shardCount=`session_cache_ops.sh --count|grep session_cache|wc -l`
        let chk=$dbCount*$2
        if [ $shardCount -eq $chk ]
        then
                echo "Session Shards Alreday Exists"
                return
        fi

        count=1
        myF=/tmp/inputFile.txt
        while [ $count -le $dbCount ]
        do
                rm -f $myF >/dev/null
                d_port=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|awk -F"-" '{print $3}'|cut -d':' -f1|egrep -o '[0-9]{5}'|head -$count|tail -1`
                d_primary_ipaddr=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|awk -F"-" '{print $5}'|egrep -o "[a-z]+[0-9]+"|head -$count|tail -1`
                d_secondary_ipaddr=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep SECONDARY|awk -F"-" '{print $5}'|egrep -o "[a-z]+[0-9]+"|head -$count|tail -1`
                x=`echo $d_primary_ipaddr:$d_secondary_ipaddr:$d_port`
                if [ $count -eq $dbCount -a $1 -eq 1 ]
                then
                        echo BACKUP
                        echo n > $myF
                        echo >> $myF
                fi
                echo y >> $myF
                echo $x >> $myF
                echo $2 >> $myF
                let count=$count+1
                #cat $mF
                #session_cache_ops.sh --add-shard < $myF
		session_cache_ops.sh --add-shard < $myF > tempOut&
		sleep 20
		shardProcessID=`ps -aef | grep session_cache_ops.sh | grep -v grep | awk '{print $2}'`		
		if [ $(grep "Invalid sessionmgr pair" tempOut | wc -l) -gt 0 ]
		then
			kill -9 $(ps -aef | grep session_cache_ops.sh | grep -v grep | awk '{print $2}')
			echo "\"Invalid sessionmgr pair\".... Shard creation failed... Please check manually"
			exit
		fi
		while [[ ! -z $shardProcessID ]]
        	do
			sleep 30
			shardProcessID=`ps -aef | grep session_cache_ops.sh | grep -v grep | awk '{print $2}'`
			if [ -z $shardProcessID ] 
			then
				break
			fi
		done
			
                echo "##############################ANKIT#####################"
        done
}
create_balance_shards() {
        shard_count=`cat /etc/broadhop/pcrf/qns.conf |grep Dcom.cisco.balance.dbs|cut -d'=' -f2`
        if [ ! -z $shard_count ]
        then
                printf "\nrebalanceBalanceShard $shard_count\ndisconnect\nyes\n" | nc qns01 9091
                echo
        fi
}

################### MAIN ########################
n="${2:-4}"
echo "No. of shards=$n"

case $1 in
        s)
                create_session_shards 0 $n
                ;;
        S)
                create_session_shards 1 $n
                ;;
        b)
                create_balance_shards
                ;;
        a)
                create_balance_shards
                create_session_shards 1 $n
                ;;
        h)
                usage
                ;;
        *)
                echo "Invalid option."
                usage
                exit 0
                ;;
esac



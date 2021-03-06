#!/bin/bash

params=$(getopt -o "" -al "u:,p:,authenticationDatabase:" --name "$0"  -- "$@")
eval set -- "$params"
while true;
do
    case "$1" in
        --u)
            mongo_user=$2
            shift 2
            ;;
        --p)
            mongo_pwd=$2
            shift 2
            ;;
        --authenticationDatabase)
            authDB=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Main" "Invalid option is provided: $1" >&2
            exit 1
            ;;
    esac
done

/var/qps/bin/diag/diagnostics.sh --get_replica > /tmp/.diag.txt

db_name=SPR
echo "use spr" > /tmp/.spr_cmd
echo "db.subscriber.remove({})" >> /tmp/.spr_cmd

filename=/tmp/.diag.txt
dbCount=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|wc -l`
count=0
while [ $count -lt $dbCount ]
do
        let count=$count+1
        d_port=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|awk -F"-" '{print $3}'|cut -d':' -f1|egrep -o '[0-9]{5}'|head -$count|tail -1`
        d_ipaddr=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|awk -F"-" '{print $3}'|cut -d':' -f2|egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'|head -$count|tail -1`
        x=`echo $d_ipaddr:$d_port|wc -c`
        d_primary_host=`ssh $d_ipaddr hostname`
        if [ $x -le 1 ]
        then
                continue
        fi
        echo "spr"
        mongo_cmd="mongo --host $d_primary_host --port $d_port --ipv6"
        if [[ -z "${mongo_user// }" ]]
        then
            echo "Mongo auth info not provided!!!"
        else
            mongo_cmd="${mongo_cmd} -u ${mongo_user} -p ${mongo_pwd} --authenticationDatabase ${authDB}"
        fi
        echo "$mongo_cmd"
        ${mongo_cmd} < /tmp/.spr_cmd
done

db_name=BALANCE

echo "show dbs" > /tmp/.bal_cmd

dbCount=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|wc -l`
count=0
while [ $count -lt $dbCount ]
do
        let count=$count+1
        cat /dev/null  > /tmp/.bal_cmd_1
        d_port=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|awk -F"-" '{print $3}'|cut -d':' -f1|egrep -o '[0-9]{5}'|head -$count|tail -1`
        d_ipaddr=`awk ' /'"$db_name"'/ {flag=1;next} /set/{flag=0} flag {print }' $filename|grep PRIMARY|awk -F"-" '{print $3}'|cut -d':' -f2|egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'|head -$count|tail -1`
        x=`echo $d_ipaddr:$d_port|wc -c`
        d_primary_host=`ssh $d_ipaddr hostname`
        if [ $x -le 1 ]
        then
                continue
        fi
        echo "balance"
        mongo_cmd="mongo --host $d_primary_host --port $d_port --ipv6"
        if [[ -z "${mongo_user// }" ]]
        then
            echo "Mongo auth info not provided!!!"
        else
            mongo_cmd="${mongo_cmd} -u ${mongo_user} -p ${mongo_pwd} --authenticationDatabase ${authDB}"
        fi
        #mongo --host $d_ipaddr:$d_port < /tmp/.bal_cmd |grep balance_mgmt|awk '{print "use " $1}' >> /tmp/.bal_cmd_1
        $mongo_cmd < /tmp/.bal_cmd |grep balance_mgmt|awk '{print "use " $1}' >> /tmp/.bal_cmd_1
        for db in `cat /tmp/.bal_cmd_1`
        do
                echo "use $db" > /tmp/.bal_cmd_2
                echo "use $db" 
                echo "db.account.remove({})" >> /tmp/.bal_cmd_2
                #mongo --host $d_ipaddr:$d_port < /tmp/.bal_cmd_2
                echo "$mongo_cmd"
                $mongo_cmd < /tmp/.bal_cmd_2
        done
done
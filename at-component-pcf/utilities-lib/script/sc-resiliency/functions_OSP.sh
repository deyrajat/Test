#!/bin/bash
USER="root"
OUT_FILE=/tmp/output.log
TMP_DB=/tmp/db.log
OUT2_FILE=/tmp/output2.log
ERR_FILE=/tmp/error.log
keystoneCmd='source /root/keystonerc_core'
CFG=test.setup
SUCCESS=0
FAILURE=1
OUT3_FILE=/tmp/output3.log
VMIP_FILE=/root/VMip.txt

function log_trace
{
        if [ $LEVEL -le 0 ]
        then
                echo "`date` TRACE $*"
        fi
}

function log_debug
{
        if [ $LEVEL -le 1 ]
        then
                echo "`date` DEBUG $*"
        fi
}

function log_info
{
        if [ $LEVEL -le 2 ]
        then
                echo "`date` INFO $*"
        fi
}

function _ssh_command
{
        node=$1
        shift
        > $OUT_FILE
        log_trace "Executing $* ON $node"
        sshpass -p $PASSWORD ssh ${USER}@${node} $* > $OUT_FILE 2>$ERR_FILE
        status=$?
        if [ -z $ERR_FILE -o $status != $SUCCESS ]
        then
                return $FAILURE
        fi
        return $SUCCESS
}

function _ssh_command_ret
{
    node=$1
    shift
    > $OUT_FILE
    log_trace "Executing $* ON $node"
    sshpass -p $PASSWORD ssh ${USER}@${node} $* > $OUT_FILE 2>$ERR_FILE
    RET_VAL=`cat $OUT_FILE`
}

function _ssh_vm_command_ret
{
    node=$1
    shift
    > $OUT_FILE
    log_trace "Executing $* ON $node"
    ssh -i $KeyFileLoc ${NodeUser}@${node} $* > $OUT_FILE 2>$ERR_FILE
    RET_VAL=`cat $OUT_FILE`
}
##############################NATE START

function _get_vm_list
{
    node=$1
    > $OUT_FILE
    log_info "Getting VM list from $node"
    _ssh_command_ret $node "$keystoneCmd ; nova list | sed 's/ //g'| cut -d'|' -f 2,3,4"
}

function _get_all_vm_list
{
    echo "" > $OUT2_FILE
    for node in `grep ^BLADE $CFG | cut -f2 -d=`
    do
        cinderListCnt=`sshpass -p $PASSWORD ssh ${USER}@${node} "service neutron-server status | wc -l"`
        if [ $cinderListCnt -gt 20 ]
        then
            _get_vm_list $node
            OSP_Control_Blade_IP=$node
            vmBladeDetails=$(cat $OUT_FILE|tr "\n" " ")
            vmBladeDetailList=($vmBladeDetails)
            for name in ${vmBladeDetailList[*]};
            do
                echo "$node|$name" >> $OUT2_FILE
            done
        fi
    done
}

function _vm_power_state
{
    node=$1
    vmid=$2
    powerstatus=status
    _ssh_command_ret $node "$keystoneCmd ; nova show $vmid | grep $powerstatus"
    RET_VAL=`echo $RET_VAL | awk 'BEGIN {FS="|"} {print $3}' | tr -d ' '`
    log_info "Power state of $node($vmid) is $RET_VAL"
}

function _power_off
{
    OSP_BLADE_IP=$1
    VM_NAME=$2
    VM_ID=$3
    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Shutting down VM $VM_NAME{$VM_ID} ($RET_VAL) on OSP $OSP_BLADE_IP"
    _ssh_command_ret $OSP_BLADE_IP "$keystoneCmd ; nova stop $VM_ID"
    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Shutdown VM $VM_NAME{$VM_ID} ($RET_VAL) on OSP $OSP_BLADE_IP"
}

function _power_on
{
    OSP_BLADE_IP=$1
    VM_NAME=$2
    VM_ID=$3

    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Starting VM $VM_NAME ($RET_VAL) on OSP $OSP_BLADE_IP"
    _ssh_command_ret $OSP_BLADE_IP "$keystoneCmd ; nova start $VM_ID"
    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Started VM $VM_NAME ($RET_VAL) on OSP $OSP_BLADE_IP"
}

function _reboot
{
    OSP_BLADE_IP=$1
    VM_NAME=$2
    VM_ID=$3

    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Starting VM $VM_NAME ($RET_VAL) on OSP $OSP_BLADE_IP"
    nova reboot $VM_ID
    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Started VM $VM_NAME ($RET_VAL) on OSP $OSP_BLADE_IP"
}

function _hard_reboot
{
    OSP_BLADE_IP=$1
    VM_NAME=$2
    VM_ID=$3
    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Starting VM $VM_NAME ($RET_VAL) on OSP $OSP_BLADE_IP"
    nova reboot --hard $VM_ID
    _vm_power_state $OSP_BLADE_IP $VM_ID
    log_info "Started VM $VM_NAME ($RET_VAL) on OSP $OSP_BLADE_IP"
}


function _get_db_status
{
    node=$1
    port=$2
    RET_VAL=""
    for kills in `grep "$node" $TMP_DB`
    do
        OSP_BLADE_IP=`echo $kills | cut -f1 -d#`
        VM_NAME=`echo $kills | cut -f3 -d#`
        VM_ID=`echo $kills | cut -f2 -d#`

        #_ssh_command_ret $OSP_BLADE_IP "vim-cmd vmsvc/get.guest $VM_ID | grep ipAdd | sed -n 1p | cut -d '\"' -f 2"
        VM_IP=`nova show ${VM_ID} | grep ${INTERNAL_NET_NAME} | awk 'BEGIN {FS="|"} {print $3}' | tr -d ' '`

        _ssh_vm_command_ret $VM_IP "mongo --port $port --eval \"printjson(rs.isMaster())\""
        TMP_VAL=`echo $RET_VAL | cut -f3 -d, | grep ismaster | cut -f2 -d: | cut -c2-`
        RET_VAL="UNKNOWN"
        if [ "$TMP_VAL" == "false" ]
        then
            RET_VAL="SECONDARY"
        fi
        if [ "$TMP_VAL" == "true" ]
        then
            RET_VAL="PRIMARY"
        fi
        RET_VAL="$RET_VAL:$OSP_BLADE_IP:$VM_ID"
        return
    done
}

function _get_members
{
    type=$1
    STR=""
    for lines in `grep "^$type" $CFG | cut -f2 -d=`
    do
        port=`echo $lines | cut -f2 -d,`
        for node in `echo $lines | cut -f1 -d, | tr ":" " "`
        do
            _get_db_status $node $port
            STR="$STR $node:$port:$RET_VAL"
        done
    done
    RET_VAL=$STR
}


function _restart_sm
{
    type=$1
    dbType=$2
    sleepTime=$3
    _get_members $type
    for node in $RET_VAL
    do
        log_info "$node"
        DB_TYPE=`echo $node | cut -f3 -d:`
        VM_IP=`echo $node | cut -f1 -d:`
        OSP_BLADE_IP=`echo $node | cut -f4 -d:`
        VM_ID=`echo $node | cut -f5 -d:`
        if [ "$DB_TYPE" == "$dbType" ]
        then
            log_info "Shutting database $type dbType: $DB_TYPE blade: $OSP_BLADE_IP  vmId: $VM_ID"
            _power_off $OSP_BLADE_IP "SM_${VM_IP}" $VM_ID
            sleep $sleepTime
            log_info "Statring database $type dbType: $DB_TYPE blade: $OSP_BLADE_IP  vmId: $VM_ID"
            _power_on $OSP_BLADE_IP "SM_${VM_IP}" $VM_ID
            return
        fi
    done
    log_info "Restart fail down Type: $type dbType: $dbType failed"
}

function _network
{
    node=$1
    interface=$2
    state=$3
    RET_VAL=""
    INTERNAL_NET_NAME=Internal
    vmBladeDetails=$(cat $TMP_DB|tr "\n" " ")
    vmBladeDetailList=($vmBladeDetails)
    for kills in ${vmBladeDetailList[*]};
        do
        if [[ "$kills" =~ "$node" ]]; then
            OSP_BLADE_IP=`echo $kills | cut -f1 -d'|'`
            VM_NAME=`echo $kills | cut -f3 -d'|'`
            VM_ID=`echo $kills | cut -f2 -d'|'`
        fi
    done        
    _ssh_command_ret $OSP_BLADE_IP "$keystoneCmd ; nova show $VM_ID | grep $INTERNAL_NET_NAME"
    VM_IP=`echo $RET_VAL |  awk 'BEGIN {FS="|"} {print $3}' | tr -d ' '`         
    _ssh_vm_command_ret $VM_IP "netstat -i | egrep -v \"lo|Iface|Kernel\" |  cut -f1 -d' '"
    log_info "State: $state before VM: $VM_NAME  IP: $VM_IP Interfaces: `echo $RET_VAL`"
    for iface in `echo $interface|tr "," " "`
    do
            _ssh_vm_command_ret $VM_IP "ifconfig $iface $state"
    done
    _ssh_vm_command_ret $VM_IP "netstat -i | egrep -v \"lo|Iface|Kernel\" |  cut -f1 -d' '"
    log_info "State: $state After VM: $VM_NAME  IP: $VM_IP Interfaces: `echo $RET_VAL`"
}

function network_down
{
    node=$1
    interface=$2
    _network $node $interface "down"
}

function network_up
{
    node=$1
    interface=$2
    _network $node $interface "up"
}

function restart_blade_network
{
    node=$1
    _get_aggr_host_for_vm $node    
    _ssh_command_ret $OSP_Control_Blade_IP "ssh $aggr_host_name hostname -i"
    compute_blade_IP=$RET_VAL
    _ssh_command_ret $compute_blade_IP "service network restart"
}

function _get_vms_vlan_port_id
{
    node=$1
    interface=$2
    RET_VAL=""
    port_cmd="neutron port-list"
    for kills in `grep "$node" $TMP_DB`
    do
        VM_NAME=`echo $kills | cut -f3 -d '|'`
        VM_ID=`echo $kills | cut -f2 -d '|'`
        _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; nova show ${VM_ID} | grep ${2} | awk 'BEGIN {FS=\"|\"} {print \$3}' | tr -d ' '"
        VM_IP=`echo $RET_VAL`
        if [ -z $VM_IP ]; then
                continue
        fi
        _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; $port_cmd | grep ${VM_IP}| cut -d '|' -f2"
        IDS=`echo $RET_VAL`
        echo $IDS
    done

}

function _port_change
{
    node=$1
    interface=$2
    state=$3
    _get_vms_vlan_port_id $node $interface
    port_id=$IDS
    if [ "$port_id" != "" ]; then
         _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; neutron port-update ${port_id} --admin-state-up $state"
        if [ $? -eq 0 ]; then
            log_info "Moved ip '$VM_IP' port:'$port_id' on node '$VM_NAME' to $state"
        fi
    fi
}

function port_down
{
    node=$1
    interface=$2
    log_info "Moving VM: $node interface: $interface to down"
    _port_change $node $interface "False"
}

function port_up
{
    node=$1
    interface=$2
    log_info "Moving VM: $node interface: $interface to up"
    _port_change $node $interface "True"
}


function power_off_vm
{
    kill_node=$1
    vmBladeDetails=$(cat $TMP_DB|tr "\n" " ")
    vmBladeDetailList=($vmBladeDetails)
    for kills in ${vmBladeDetailList[*]};
    do
        if [[ "$kills" =~ "$kill_node" ]]; then
           OSP_BLADE_IP=`echo $kills | cut -f1 -d'|'`
           VM_NAME=`echo $kills | cut -f3 -d'|'`
           VM_ID=`echo $kills | cut -f2 -d'|'`
        fi
    done
    _power_off $OSP_BLADE_IP $VM_NAME $VM_ID
}

function power_on_vm
{
    kill_node=$1
    vmBladeDetails=$(cat $TMP_DB|tr "\n" " ")
    vmBladeDetailList=($vmBladeDetails)
    for kills in ${vmBladeDetailList[*]};
        do
        if [[ "$kills" =~ "$kill_node" ]]; then
            OSP_BLADE_IP=`echo $kills | cut -f1 -d'|'`
            VM_NAME=`echo $kills | cut -f3 -d'|'`
            VM_ID=`echo $kills | cut -f2 -d'|'`
        fi
        done
    _power_on $OSP_BLADE_IP $VM_NAME $VM_ID

}

function reboot_vm
{
    kill_node=$1
    for kills in `grep $kill_node $TMP_DB`
    do
        OSP_BLADE_IP=`echo $kills | cut -f1 -d#`
        VM_NAME=`echo $kills | cut -f3 -d#`
        VM_ID=`echo $kills | cut -f2 -d#`
        _reboot $OSP_BLADE_IP $VM_NAME $VM_ID
    done

}

function hard_reboot_vm
{
    kill_node=$1
    for kills in `grep $kill_node $TMP_DB`
    do
        OSP_BLADE_IP=`echo $kills | cut -f1 -d#`
        VM_NAME=`echo $kills | cut -f3 -d#`
        VM_ID=`echo $kills | cut -f2 -d#`
        _hard_reboot $OSP_BLADE_IP $VM_NAME $VM_ID
    done

}


function reboot_blade
{
    blade=$1
    _ssh_command_ret $blade "reboot -f" >/dev/null &
}


function all_blades_reboot
{
    all_blades_list=`grep ^BLADE $CFG | cut -f2 -d=`
    for blade in $all_blades_list
    do
        reboot_blade $blade
    done
}


function check_vm_state
{   
    VM_NAME=$1
    ESC_OPER_DONE=$2
    VM_IP=`ping $VM_NAME -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
    test_vm=`ping $VM_NAME -c 1 | grep icmp_seq`
    echo "=================================================="
    echo "Debug logs for " $VM_NAME " is " $test_vm
    echo "=================================================="
    if [ $ESC_OPER_DONE == "oper_vm_down" ]; then
        if [[ $test_vm = *"ttl"* ]] ; then
                log_info "VM is not in Shutdown state as expected"
        else
                log_info "VM in Shutdown state as expected"            
        fi
    elif [ $ESC_OPER_DONE == "oper_vm_up" ] ; then        
        if [[ $test_vm = *"ttl"* ]] ; then
            log_info "VM in Active state as expected"
        else
            log_info "VM is not in Active state as expected"
        fi
    else      
        echo "VM in unknown state"
    fi
}

function restart_pri_sm
{
    type=$1
    sleepTime=$2
    _restart_sm $type "PRIMARY" $sleepTime

}

function restart_non_pri_sm
{
    type=$1
    sleepTime=$2
    _restart_sm $type "SECONDARY" $sleepTime
}

function kill_memcached_on_node
{
    log_info "Kill -9 memcached on node $1"
    _ssh_command $1 "killall -9 memcached "
}

function kill_java_on_node
{
    _ssh_command $1 "killall -9 java "
}

function _get_aggr_host_for_vm
{
    vmHostName=$1
    VM_Desc_str=$(cat $TMP_DB |tr "\n" " ")
    VM_Desc_list=($VM_Desc_str)
    for VM_Desc in ${VM_Desc_list[*]};
    do
        if [[ "$VM_Desc" =~ "$vmHostName" ]] ; then
            vmID=`echo $VM_Desc | cut -d'|' -f 2`
            _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; nova show $vmID | grep hypervisor_hostname | cut -d '|' -f 3"
            aggr_host_name=`echo $RET_VAL | tr -d ' '`
            break
        fi
    done
}

function get_all_vm_aggr_host
{
    aggr_hostname=$1
    aggr_vm_name_str=""
    vm_detail_str=$(cat $TMP_DB |tr "\n" " ")
    vm_detail_list=($vm_detail_str)
    for vm_detail in ${vm_detail_list[*]};
    do
        vmID=`echo $vm_detail | cut -d'|' -f 2`
        vm_name=`echo $vm_detail | cut -d'|' -f 3`
        _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; nova show $vmID | grep hypervisor_hostname | cut -d '|' -f 3"
        aggr_hst_name=`echo $RET_VAL | tr -d ' '`
        if [ "$aggr_hst_name" = "$aggr_hostname" ] ; then
            aggr_vm_name_str=` echo $aggr_vm_name_str " " $vm_name`
        fi
    done
} 


function get_blade_ip_for_vm
{
    node=$1
    _get_aggr_host_for_vm $node
    blade_name=$aggr_host_name
    #_ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; nova hypervisor-show $blade_name | grep host_ip | awk '{print \$4}'"
	#_ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ;  nova list --field name,host | egrep -i 'lb|pcrfclient' | awk '{print \$6}' | sort | uniq"
	#echo $RET_VAL=$qnsBladeIp 
	#echo $qnsBladeIp
	_ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ;  openstack hypervisor show $blade_name | grep host_ip | awk '{print \$4}'"
        BladeIP=`echo $RET_VAL` 
}

function get_blade_ip_for_qns_vm
{
    node=$1
    _get_aggr_host_for_vm $node
    blade_name=$aggr_host_name
	_ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ;  openstack hypervisor show $blade_name | grep host_ip | awk '{print \$4}'"
    BladeIP=`echo $RET_VAL`
	non_qns_blade_ip_list
}


function non_qns_blade_ip_list
{

    _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ;  nova list --field name,host | egrep -i 'lb|pcrfclient' | awk '{print \$6}' | sort | uniq"
    PcrfLbBladeIp=`echo $RET_VAL`
    echo $PcrfLbBladeIp
    for NonQnsBladeIp in $PcrfLbBladeIp
    do
        _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ;  openstack hypervisor show $NonQnsBladeIp | grep host_ip | awk '{print \$4}'"
        echo $RET_VAL >> /root/NonQNSBladeIP.txt
    done
    NonQnsBladeIp=`cat /root/NonQNSBladeIP.txt | sort | uniq`
    echo $NonQnsBladeIp
}

function blade_power_off
{
    vmHostName=$1
    _get_aggr_host_for_vm $vmHostName
    get_all_vm_aggr_host $aggr_host_name
    aggr_vm_name_list=($aggr_vm_name_str)
    for vmName in ${aggr_vm_name_list[*]};
    do 
        power_off_vm $vmName
    done
}

function blade_power_on
{
    vmHostName=$1
    _get_aggr_host_for_vm $vmHostName
    get_all_vm_aggr_host $aggr_host_name
    aggr_vm_name_list=($aggr_vm_name_str)
    for vmName in ${aggr_vm_name_list[*]};
    do 
        power_on_vm $vmName
    done
       sleep 600
       printf '\n' | for NH in `hosts.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
       printf '\n' | for NH in `hosts-sessionmgr.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
       printf 'y\n' | /var/qps/bin/support/sync_times.sh ha
    for vmName in ${aggr_vm_name_list[*]};
    do
        check_vm_state $vmName "oper_vm_up"
    done

}
    

function get_appltcation_blade_sm
{
    VM_prefix=$1
    Num_Sessionmgr=$2
    allowedSessionmgr=1
    if [ $VM_prefix = "null" ] ; then
          hostoptlist=(`awk /SESSION-SET/,/-END/ /etc/broadhop/mongoConfig.cfg | grep -v "^#" | grep -w "ARBITER" |awk -F'=' '{print $2}'|awk -F':' '{print $2}'`)
    fi
    > $OUT3_FILE
    for mongoport in ${hostoptlist[*]}
    do
        hostName=(`mongo --port $mongoport --host $MongoHost_Name --eval 'printjson(rs.isMaster())' | grep primary | awk '{split($0,a,":"); print a[2]}' | cut -c 3-`)
        echo $hostName >> $OUT3_FILE
    done
    host_name_str=$(cat $OUT3_FILE |tr "\n" " ")
    host_name_list=($host_name_str)
    for vmHostName in ${host_name_list[*]};
    do
        echo "check for vm : "$vmHostName
        _get_aggr_host_for_vm $vmHostName
        get_all_vm_aggr_host $aggr_host_name
        takehost=0
        qnscnt=0
        if [[ $aggr_vm_name_str =~ .*lb.* || $aggr_vm_name_str =~ .*PD.* ]] ; then
            takehost=0
            break
        fi
        if [[ $aggr_vm_name_str =~ .*pcrfclient.* || $aggr_vm_name_str =~ .*OA.* ]] ; then
            takehost=0
            break
        fi
        if [[ $aggr_vm_name_str =~ .*installer.* || $aggr_vm_name_str =~ .*CM.* || $aggr_vm_name_str =~ .*cluman.* ]] ; then
            takehost=0
            break
        fi
        if [[ $aggr_vm_name_str =~ .*qns.* || $aggr_vm_name_str =~ .*PS.* ]] ; then
            qnscnt=1
        fi
        takehost=1
        if [ $takehost -eq 1 ] ; then
            if [ $allowedSessionmgr -eq $Num_Sessionmgr ] ; then
                echo "The Sessionmgr to be used is "$vmHostName
                break
            else
                allowedSessionmgr=`expr $allowedSessionmgr + 1`
            fi
        fi
    done
}

function _get_vm_list_for_VLAN
{
    vlan=$1
    string=""
    cps_vm_list=`hosts-all.sh`
    for vm in $cps_vm_list
        do
                VM_IP=`ping $vm -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
                _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; nova list | grep $vlan | grep $VM_IP | awk '{print \$4}'"
                string=`echo $string" "$RET_VAL`
        done
    echo $string
}

function check_vlan_status
{
        vlan_name=$1
        status=$2
        flag=0
        vms_list=$(_get_vm_list_for_VLAN $vlan_name)
        for vm in $vms_list
        do
               portID=$(_get_vms_vlan_port_id $vm $vlan_name)
               _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; neutron port-show $portID | grep admin_state_up | awk '{print \$4}'"
               portState=`echo $RET_VAL`
                if [ "$portState" != "True" ]
                then
                        if [ "$status" = "up" ]; then
                                echo "$vlan_name VLAN is not UP successfully"
                                flag=1
                                break
                        else
                                continue                 
                        fi
                elif [ "$portState" != "False" ]
                then
                        if [ "$status" = "down" ]; then
                                echo "$vlan_name VLAN is not down successfully"
                                flag=1
                                break
                        else
                                continue
                        fi

                fi
        done
        if [ $flag -ne 1 ]; then
                if [ "$status" = "up" ]; then
                        echo "$vlan_name VLAN is restored successfully"
                elif [ "$status" = "down" ]; then
                        echo "$vlan_name VLAN is down successfully"
                fi
        fi
       
}

function down_vlan_interface
{
        interface=$1
        vms_list=$(_get_vm_list_for_VLAN $interface)
        for vm in $vms_list
        do
                port_down $vm $interface
        done
}

function up_vlan_interface
{
        interface=$1
        vms_list=$(_get_vm_list_for_VLAN $interface)
        for vm in $vms_list
        do
                port_up $vm $interface
        done
}

function get_shard_list
{
        echo "" > $VMIP_FILE
        site_id=$1
        session_port=$2
        if [ "$site_id" = "site1" ]
        then
                set="PRI-"
                SITE="SITE1"
        else
                set="SEC-"
                SITE="SITE2"
        fi
        diagnostics.sh --get_replica $SITE | grep $session_port |grep -v "ARBITER" | grep -i $set | awk -F':' '{print $2}' | awk -F'-' '{print $1}' >$VMIP_FILE
        sed -i $'s/[^[:print:]\t]//g' $VMIP_FILE
        sed  -i 's/\[42G//' $VMIP_FILE
	sed  -i 's/\[49G//' $VMIP_FILE
	for ip in `cat $VMIP_FILE`
        do
                _ssh_command_ret $OSP_Control_Blade_IP "$keystoneCmd ; nova list | grep $ip | awk '{print \$4}'"
		hostname=`echo $RET_VAL`
                vm_list+=$hostname" "
        done
        echo $vm_list

	

}

function session_shards_power_off
{
        site_id=$1
        mongo_port=$2
        SessionVM_list=$(get_shard_list $site_id $mongo_port)
        for vm in $SessionVM_list
                do
                power_off_vm $vm
                done

}

function session_shards_power_on
{
        site_id=$1
        mongo_port=$2
        SessionVM_list=$(get_shard_list $site_id $mongo_port)
        for vm in $SessionVM_list
                do
                power_on_vm $vm
                done
        sleep 180
        for vm in $SessionVM_list
        do
               check_vm_state $vm "oper_vm_up" 
        done

}



#Cache list of vms
_get_all_vm_list
mv $OUT2_FILE $TMP_DB
log_info $TMP_DB

#esxcli network ip interface set -e false -i vmk0; esxcli network ip interface set -e true -i vmk0






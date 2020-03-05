#!/bin/bash
USER="root"
OUT_FILE=/tmp/output.log
TMP_DB=/tmp/db.log
TMP_NETWORK=/tmp/network.log
OUT2_FILE=/tmp/output2.log
OUT3_FILE=/tmp/output3.log      #Blade network detail
ERR_FILE=/tmp/error.log
CFG=test.setup
SUCCESS=0
FAILURE=1
VMIP_FILE=/root/VMip.txt
SVM_FILE=/root/sessionvm.txt

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

function _get_vm_list
{
        node=$1
        > $OUT_FILE
        log_info "Getting VM list from $node"
        _ssh_command $node "vim-cmd vmsvc/getallvms | awk '{print \"#\"\$1\"#\"\$2\"#\"\$3\"#\"\$4\"#\"\$5\"#\"\$6\"#\"}'" 
        return $?
        cat $OUT_FILE
}

function _get_all_vm_list
{
        echo "" > $OUT2_FILE
        echo "" > $OUT3_FILE
        for node in `grep ^BLADE $CFG | cut -f2 -d=`
        do
                _get_vm_list $node
                for name in `cat $OUT_FILE`
                do
                        echo "$node$name" >> $OUT2_FILE
                done
                _get_blade_network_list $node
                for name in `cat $OUT_FILE`
                do
                        echo "$node$name" >> $OUT3_FILE
                done
        done
}

function _vm_power_state
{
        node=$1
        vmid=$2
        _ssh_command $node "vim-cmd vmsvc/power.getstate $vmid"
        RET_VAL=`grep -i Power $OUT_FILE`
}

function _power_off
{
        ESXI_BLADE_IP=$1
        VM_NAME=$2
        VM_ID=$3
        _vm_power_state $ESXI_BLADE_IP $VM_ID
        log_info "Shutting down VM $VM_NAME{$VM_ID} ($RET_VAL) on ESXI $ESXI_BLADE_IP"
        _ssh_command $ESXI_BLADE_IP "vim-cmd vmsvc/power.off $VM_ID"
        _vm_power_state $ESXI_BLADE_IP $VM_ID
        log_info "Shutdown VM $VM_NAME{$VM_ID} ($RET_VAL) on ESXI $ESXI_BLADE_IP"

}

function _power_on
{
        ESXI_BLADE_IP=$1
        VM_NAME=$2
        VM_ID=$3

        _vm_power_state $ESXI_BLADE_IP $VM_ID
        log_info "Starting VM $VM_NAME ($RET_VAL) on ESXI $ESXI_BLADE_IP"
        _ssh_command $ESXI_BLADE_IP "vim-cmd vmsvc/power.on $VM_ID"
        _vm_power_state $ESXI_BLADE_IP $VM_ID
        log_info "Started VM $VM_NAME ($RET_VAL) on ESXI $ESXI_BLADE_IP"

}

function _get_db_status
{
        node=$1
        port=$2
        RET_VAL=""
        for kills in `grep "$node" $TMP_DB`
        do
                ESXI_BLADE_IP=`echo $kills | cut -f1 -d#`
                VM_NAME=`echo $kills | cut -f3 -d#`
                VM_ID=`echo $kills | cut -f2 -d#`

                _ssh_command_ret $ESXI_BLADE_IP "vim-cmd vmsvc/get.guest $VM_ID | grep ipAdd | sed -n 1p | cut -d '\"' -f 2"
                VM_IP=$RET_VAL

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
                RET_VAL="$RET_VAL:$ESXI_BLADE_IP:$VM_ID"
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
                DB_TYPE=`echo $node | cut -f3 -d:`
                VM_IP=`echo $node | cut -f1 -d:`
                ESXI_BLADE_IP=`echo $node | cut -f4 -d:`
                VM_ID=`echo $node | cut -f5 -d:`
                if [ "$DB_TYPE" == "$dbType" ]
                then
                        log_info "Shutting database $type dbType: $DB_TYPE blade: $ESXI_BLADE_IP  vmId: $VM_ID"
                        #_power_off $ESXI_BLADE_IP "SM_${VM_IP}" $VM_ID

                        sleep $sleepTime

                        log_info "Statring database $type dbType: $DB_TYPE blade: $ESXI_BLADE_IP  vmId: $VM_ID"
                        #_power_on $ESXI_BLADE_IP "SM_${VM_IP}" $VM_ID
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
    for kills in `grep "$node" $TMP_DB`
    do
        ESXI_BLADE_IP=`echo $kills | cut -f1 -d#`
        VM_NAME=`echo $kills | cut -f3 -d#`
        VM_ID=`echo $kills | cut -f2 -d#`
        _ssh_command_ret $ESXI_BLADE_IP "vim-cmd vmsvc/get.guest $VM_ID | grep ipAdd | sed -n 1p | cut -d '\"' -f 2"
        VM_IP=$RET_VAL
        _ssh_vm_command_ret $VM_IP "netstat -i | egrep -v \"lo|Iface|Kernel\" |  cut -f1 -d' '"
        log_info "State: $state before VM: $VM_NAME  IP: $VM_IP Interfaces: `echo $RET_VAL`"
        for iface in `echo $interface|tr "," " "`
        do
            log_info "Interface : $iface"
            _ssh_vm_command_ret $VM_IP "ifconfig $iface $state"
        done
        _ssh_vm_command_ret $VM_IP "netstat -i | egrep -v \"lo|Iface|Kernel\" |  cut -f1 -d' '"
        log_info "State: $state After VM: $VM_NAME  IP: $VM_IP Interfaces: `echo $RET_VAL`"
    done
}

function _get_blade_network_list
{
    node=$1
    > $OUT_FILE
    log_info "Getting Blade network list from $node"
    _ssh_command $node "esxcli network ip interface ipv4 get | awk '{print \"#\"\$1\"#\"\$2\"#\"\$3\"#\"\$4\"#\"\$5\"#\"\$6\"#\"}' | grep vmk"
    return $?
    cat $OUT_FILE
}

function restart_blade_network
{
    node=$1
    sleepTime=$2
    get_blade_ip_for_vm $node
    for nw_line in `grep $BladeIP $TMP_NETWORK`
    do
        blade=`echo $nw_line | cut -f1 -d#`
        nw=`echo $nw_line | cut -f2 -d#`
        log_info "Restarting network $nw on $BladeIP"
        _ssh_command $BladeIP "esxcli network ip interface set -e false -i $nw; sleep $sleepTime; esxcli network ip interface set -e true -i $nw"
        _ssh_command_ret $BladeIP "esxcli network ip interface ipv4 get | awk '{print \"#\"\$1\"#\"\$2\"#\"\$3\"#\"\$4\"#\"\$5\"#\"\$6\"#\"}'|grep vmk"
        log_info "Restarted network $nw on $BladeIP [$RET_VAL]" 
    done
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

function power_off_vm
{
    kill_node=$1
    for kills in `grep -i $kill_node $TMP_DB`
    do
        ESXI_BLADE_IP=`echo $kills | cut -f1 -d#`
        VM_NAME=`echo $kills | cut -f3 -d#`
        VM_ID=`echo $kills | cut -f2 -d#`
        _power_off $ESXI_BLADE_IP $VM_NAME $VM_ID
    done
}

function power_on_vm
{
    kill_node=$1
    for kills in `grep -i $kill_node $TMP_DB`
    do
        ESXI_BLADE_IP=`echo $kills | cut -f1 -d#`
        VM_NAME=`echo $kills | cut -f3 -d#`
        VM_ID=`echo $kills | cut -f2 -d#`
        _power_on $ESXI_BLADE_IP $VM_NAME $VM_ID
    done
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

function network_service_restart
{
        node=$1
        VM_IP=`ssh $node hostname -i`   
        RET_VAL=_ssh_command $VM_IP $PASSWORD_VM "service network restart"
        if [ $RET_VAL -eq $SUCCESS ];
        then 
            log_info "Network service restart on $VM_NAME SUCCESS"
        else
            log_info "Network service restart on $VM_NAME FAIL"
        fi
}

#### New function to restart blade network #############
function restart_blade_real_network
{
    node=$1
    nic=$2
    sleepTime=$3
    for nw_line in `grep $node $TMP_NETWORK2 | grep "$nic#"`
    do
        blade=`echo $nw_line | cut -f1 -d#`
        nw=`echo $nw_line | cut -f2 -d#`
        log_info "Restarting network $nw on $node"
        _ssh_command $node "esxcli network nic down -n $nw; sleep $sleepTime; esxcli network nic up -n $nw"
        _ssh_command_ret $node "esxcfg-nics -l | grep $nic | awk '{print \$1, \$4}'"
        log_info "Restarted network $nw on $node [$RET_VAL]"
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
function get_blade_ip_for_vm
{
    vmHostName=$1
    vmIP=`grep $vmHostName /etc/hosts |awk -F" " '{print $1}' `
    BladeIP=`grep $vmHostName /var/qps/config/deploy/csv/Hosts.csv |awk -F"," '{print $1}'`
}

function get_blade_ip_for_qns_vm
{
    vmHostName=$1
    vmIP=`grep $vmHostName /etc/hosts |awk -F" " '{print $1}' `
    NonQnsBladeIp=`egrep  'pcrfclient|lb'  /var/qps/config/deploy/csv/Hosts.csv | awk -F, '{print $1}' | sort| uniq`
    BladeIP=`grep $vmHostName /var/qps/config/deploy/csv/Hosts.csv |awk -F"," '{print $1}'`
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
            get_blade_ip_for_vm $vmHostName
        _ssh_command_ret $BladeIP "vim-cmd vmsvc/getallvms | grep -v Name | cut -d ' ' -f 1"
      vmIdList=(`cat $OUT_FILE`)
      takehost=0
            qnscnt=0
      for vmID in ${vmIdList[*]};
      do 
          vmHostFrmBlade=''
            _ssh_command_ret $BladeIP vim-cmd vmsvc/get.guest $vmID
            vmHostFrmBlade=`grep hostName $OUT_FILE | tr -d "\n" | cut -d',' -f 1 | cut -d'"' -f 2`
                  if [[ $vmHostFrmBlade =~ .*lb.* || $vmHostFrmBlade =~ .*PD.* ]] ; then
                        takehost=0
                        break
                  fi
                  if [[ $vmHostFrmBlade =~ .*pcrfclient.* || $vmHostFrmBlade =~ .*OA.* ]] ; then
                        takehost=0
                        break
                  fi               
                  if [[ $vmHostFrmBlade =~ .*installer.* || $vmHostFrmBlade =~ .*CM.* ]] ; then
                        takehost=0
                        break
                  fi
                  if [[ $vmHostFrmBlade =~ .*qns.* || $vmHostFrmBlade =~ .*PS.* ]] ; then
                        qnscnt=` expr $qnscnt + 1`
                  fi
                  takehost=1             
      done                   
            if [ $takehost -eq 1 ] ; then
                  if [ $qnscnt -gt 0 ] ; then
                        if [ $allowedSessionmgr -eq $Num_Sessionmgr ] ; then
                              echo "The Sessionmgr to be used is "$vmHostName
                        break
                       else
                             allowedSessionmgr=`expr $allowedSessionmgr + 1`
                       fi
                fi
            fi   
    done   
}


function blade_power_off
{
        vmHostName=$1
        get_blade_ip_for_vm $vmHostName
        _ssh_command_ret $BladeIP "vim-cmd vmsvc/getallvms | grep -v Name | cut -d ' ' -f 1"
        vmIdList=(`cat $OUT_FILE`)
        for vmID in ${vmIdList[*]};
          do 
            vmHostFrmBlade=''
            _ssh_command_ret $BladeIP vim-cmd vmsvc/get.guest $vmID
            vmHostFrmBlade=`grep hostName $OUT_FILE | tr -d "\n" | cut -d',' -f 1 | cut -d'"' -f 2`
            power_off_vm $vmHostFrmBlade
          done
}

function blade_power_on
{
        vmHostName=$1
        get_blade_ip_for_vm $vmHostName
        vmHostList=`grep $BladeIP /var/qps/config/deploy/csv/Hosts.csv |awk -F"," '{print $2}'`
        for vmHostFrmBlade in ${vmHostList[*]};
        do 
            power_on_vm $vmHostFrmBlade
        done
        sleep 600
        printf '\n' | for NH in `hosts.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
        printf '\n' | for NH in `hosts-sessionmgr.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
        printf 'y\n' | /var/qps/bin/support/sync_times.sh ha
        for vmHostFrmBlade in ${vmHostList[*]};
        do
        check_vm_state $vmHostFrmBlade "oper_vm_up"
        done
}

    
function get_shard_list
{
        echo "" > $VMIP_FILE
        echo "" > $SVM_FILE
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
        diagnostics.sh --get_replica $SITE | grep $session_port |grep -v "ARBITER" | grep -i $set | awk -F':' '{print $2}' | awk -F'-' '{print $1}' > $VMIP_FILE
        sed -i $'s/[^[:print:]\t]//g' $VMIP_FILE
        sed  -i 's/\[49G//' $VMIP_FILE
        for ip in `cat $VMIP_FILE`
        do
                _ssh_vm_command_ret $ip "hostname"
                hostname=`echo $RET_VAL`
                vm_list+=$hostname" "
        done
        echo $vm_list > $SVM_FILE
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
        SessionVM_list=`cat $SVM_FILE`
        for vm in $SessionVM_list
                do
                power_on_vm $vm
                done
        sleep 60
        for vm in $SessionVM_list
                do
                check_vm_state $vm "oper_vm_up"
                done

}

function reboot_blade
{
        blade=$1
	_ssh_command_ret $blade "reboot -f"&
        sleep 3
}

function all_blades_reboot
{
        all_blades_list=`grep ^BLADE $CFG | cut -f2 -d=`
        for blade in $all_blades_list
        do
                reboot_blade $blade
        done
}

function check_vlan_status
{
        vlan=$1
        status=$2
        flag=0
        network_portgroup=`cat /var/qps/config/deploy/csv/VLANs.csv | grep $vlan | awk -F, '{print $2}'`
        blade_list=`cat /var/qps/config/deploy/csv/Hosts.csv | grep -v  Hypervisor | awk -F, '{print $1}' | sort | uniq`
        for ip in $blade_list
        do
                _ssh_command_ret $ip  "esxcfg-vswitch --list | grep $network_portgroup | awk  '{print \$2}'"
                vlan_status=`echo $RET_VAL`
                if [ $vlan_status -eq 0 ]
                then
                        if [ "$status" = "up" ]; then
                                echo "$vlan VLAN is not UP successfully"
                                flag=1
                                break
                        else
                                continue
                        fi
                elif [ $vlan_status -ne 0 ]
                then
                        if [ "$status" = "down" ]; then
                                echo "$vlan VLAN is not down successfully"
                                flag=1
                                break
                        else
                                continue
                        fi

                fi
        done
        if [ $flag -ne 1 ]; then
                if [ "$status" = "up" ]; then
                        echo "$vlan VLAN is restored successfully"
                elif [ "$status" = "down" ]; then
                        echo "$vlan VLAN is down successfully"
                fi
        fi
}

function down_vlan_interface
{
       vlan_name=$1
       network_portgroup=`cat /var/qps/config/deploy/csv/VLANs.csv | grep $vlan_name | awk -F, '{print $2}'`
       blade_list=`cat /var/qps/config/deploy/csv/Hosts.csv | grep -v  Hypervisor | awk -F, '{print $1}' | sort | uniq`
       for ip in $blade_list
       do
       _ssh_command_ret $ip  "esxcli network vswitch standard portgroup set -p $network_portgroup -v 0"&
       done
}

function up_vlan_interface
{
        vlan_name=$1
        network_portgroup=`cat /var/qps/config/deploy/csv/VLANs.csv | grep $vlan_name | awk -F, '{print $2}'`
        vlan_id=`echo $network_portgroup | sed 's/[^0-9]*//g'`
        blade_list=`cat /var/qps/config/deploy/csv/Hosts.csv | grep -v  Hypervisor | awk -F, '{print $1}' | sort | uniq`
        for ip in $blade_list
        do
        _ssh_command_ret $ip  "esxcli network vswitch standard portgroup set -p $network_portgroup -v $vlan_id"&
        done

}

function osp_network_restart
{
    node=$1
    RET_VAL=""
    VM_IP=`ping $node -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
    _ssh_vm_command_ret $VM_IP "lshw -class network | grep -A 1 'bus info' | grep name | awk -F':' '{print \$2}'"
    for iface in ${RET_VAL[@]}
    do  
        _ssh_vm_command_ret $VM_IP "ifconfig $iface down && sleep 15 &&  ifconfig $iface up"
        RET_VAL=""
        _ssh_vm_command_ret $VM_IP "cat /sys/class/net/$iface/operstate"
        if [[ $RET_VAL = "up" ]];
        then 
            log_trace "State after: VM: $node  IP: $VM_IP Interfaces: $iface : UP"
            log_info "Interface Is UP"
        else
            log_trace "State after: VM: $node  IP: $VM_IP Interfaces: $iface  : DOWN"
            log_info "Interface Is Down"
        fi
    done
}

function reboot_vm
{
        VM_TO_START=$1
        VM_IP=`ping $VM_TO_START -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
        _ssh_vm_command_ret $VM_IP "sudo reboot"
        
}

#Cache list of vms

_get_all_vm_list
mv $OUT2_FILE $TMP_DB
mv $OUT3_FILE $TMP_NETWORK

#esxcli network ip interface set -e false -i vmk0; esxcli network ip interface set -e true -i vmk0




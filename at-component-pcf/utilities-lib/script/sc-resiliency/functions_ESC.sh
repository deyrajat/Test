#!/bin/bash
VM_OSPD_USER="root"
ESC_USER="admin"
OUT_FILE=/tmp/output.log
TMP_DB=/tmp/db.log
TMP_NETWORK=/tmp/network.log
ERR_FILE=/tmp/error.log
SUCCESS=0
FAILURE=1
ESC_CLI_CMD="/opt/cisco/esc/esc-confd/esc-cli/esc_nc_cli"
keyStoneFile="/home/stack/esc-cpsrc-Pcrf"
keyStoneFileBlade="/home/stack/stackrc"
OUT2_FILE=/tmp/output2.log
OUT3_FILE="/tmp/output3.log"
VMIP_FILE=/root/VMip.txt
Hostname_File=/root/hostname.txt

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
        PASSWORD=$1
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
        PASSWORD=$1
        shift
        log_trace "Executing $* ON $node"
    RET_VAL=`sshpass -p $PASSWORD ssh ${VM_OSPD_USER}@${node} " $* "` 
}

function _ssh_esc_command_ret
{
    esc_node=$1
    shift
    ESC_PASSWD=$1
    shift
    log_trace "Executing $* ON $esc_node"
    RET_VAL=`sshpass -p $ESC_PASSWD ssh ${ESC_USER}@${esc_node} " $* "`
}

function _ssh_vm_command_ret
{
        node=$1
        shift
        > $OUT_FILE
        log_trace "Executing $* ON $node"
        sshpass -p $PASSWORD_VM ssh ${VM_OSPD_USER}@${node} $* > $OUT_FILE 2>$ERR_FILE
        RET_VAL=`cat $OUT_FILE`
}



##############################NATE START

function _vm_power_state
{
    ospdIP=$1
    vmid=$2
    powerstatus="status"
    RET_VAL=""
    _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova show $vmid | grep $powerstatus | cut -d'|' -f3 | tr -d ' '"
    log_info "Power state of $node($vmid) is $RET_VAL"
    RET_VAL=""
    _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $vmid | cut -d'|' -f4 | tr -d ' '"
    log_info "State of $node($vmid) is $RET_VAL"
}

function change_vm_state
{
    VM_NAME=$1
    NEW_VM_STATE=$2
    VM_IP=`ping $VM_NAME -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
    _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_IP | cut -d'|' -f 2 | cut -d' ' -f 2"
    VM_ID=$RET_VAL  
    _vm_power_state $OSPD_IP_Address $VM_ID
    _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_IP | cut -d'|' -f 3 | cut -d' ' -f 2"
    VM_DEP_ID=$RET_VAL
        log_info "Shutting down / Start up / Reboot VM $VM_NAME $RET_VAL on ESC $OSPD_IP_Address"
        #if [ "$NEW_VM_STATE" == "STOP" ]; then
        #       _ssh_esc_command_ret $ESC_IP_Address $ESC_password "$ESC_CLI_CMD vm-action DISABLE_MONITOR $VM_DEP_ID"
        #       echo "disable monitor"
        #else
        #       _ssh_esc_command_ret $ESC_IP_Address $ESC_password "$ESC_CLI_CMD vm-action ENABLE_MONITOR $VM_DEP_ID"
        #       echo "enable monitor"
        #fi
        #sleep 60
        _ssh_esc_command_ret $ESC_IP_Address $ESC_password "$ESC_CLI_CMD vm-action $NEW_VM_STATE $VM_DEP_ID"
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

function _get_vm_blade_name
{
        VM_NAME_CHECK=$1
        VM_IP_ADDR=`ping $VM_NAME_CHECK -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_IP_ADDR | cut -d '|' -f2 | tr -d ' '"
        VM_ID_CHECK=$RET_VAL
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova show $VM_ID_CHECK | grep 'OS-EXT-SRV-ATTR:hypervisor_hostname' | cut -d'|' -f 3 | tr -d ' ' | tr -d '\n'"
        BLADE_HOSTNAME=$RET_VAL 
}

function get_blade_ip_for_vm
{
    nodes=$1
    _get_vm_blade_name $nodes
    bladeName=`echo $BLADE_HOSTNAME | cut -d'.' -f 1`
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFileBlade ; nova list | grep -w $bladeName | cut -d'|' -f 7 |  cut -d'=' -f 2"
        BladeIP=$RET_VAL
}
    
function _get_vms_on_blade
{   
    BLADE_HOST_NAME=$1
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | awk 'NR>3' | head -n-1 | cut -d '|' -f 3 | tr -d ' '"
        VM_ID_LIST=$RET_VAL
        echo "" > $OUT2_FILE
        NUM_VM_BLADE=0
        for vm_node in $VM_ID_LIST
        do              
                _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova show $vm_node | grep 'OS-EXT-SRV-ATTR:hypervisor_hostname' | cut -d '|' -f 3 | tr -d ' '"
                BLADE_TMP_HOSTNAME=$RET_VAL
                if [ $BLADE_TMP_HOSTNAME = $BLADE_HOST_NAME ]; then
                    NUM_VM_BLADE=`expr $NUM_VM_BLADE + 1`
                        echo "$vm_node" >> $OUT2_FILE
                fi
        done
        sed -i '/^$/d' $OUT2_FILE
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
            change_vm_state $OSP_BLADE_IP "SM_${VM_IP}" $VM_ID
            sleep $sleepTime
            log_info "Starting database $type dbType: $DB_TYPE blade: $OSP_BLADE_IP  vmId: $VM_ID"
            change_vm_state $OSP_BLADE_IP "SM_${VM_IP}" $VM_ID
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
        VM_IP=`ping $node -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
        for iface in `echo $interface|tr "," " "`
        do      
                _ssh_command_ret $VM_IP $PASSWORD_VM "ifconfig $interface"
        if [[ $RET_VAL = *"RUNNING"* ]];
                then 
                        log_info "State before: VM: $VM_NAME  IP: $VM_IP Interfaces: UP"
            else
                log_info "State before: VM: $VM_NAME  IP: $VM_IP Interfaces: DOWN"      
            fi
            RET_VAL=""  
                _ssh_command_ret $VM_IP $PASSWORD_VM "ifconfig $iface $state"
                RET_VAL=""
                _ssh_command_ret $VM_IP $PASSWORD_VM "ifconfig $interface"
                if [ $RET_VAL =~ "RUNNING" ];
                then 
                        log_info "State after: VM: $VM_NAME  IP: $VM_IP Interfaces: UP"
            else
                log_info "State after: VM: $VM_NAME  IP: $VM_IP Interfaces: DOWN"
            fi      
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

function network_service_restart
{
        node=$1
        VM_IP=`ping $node -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
        _ssh_command_ret $VM_IP $PASSWORD "service network restart"
    echo $RET_VAL
        if [ $RET_VAL -eq $SUCCESS ];
        then 
                log_info "Network service restart on $VM_NAME SUCCESS"
        else
                log_info "Network service restart on $VM_NAME FAIL"
        fi
}

function _get_vms_vlan_port_id
{
        VM_NAME=$1
        interface=$2
        RET_VAL=""
        port_cmd="neutron port-list"
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_NAME | cut -d'|' -f 2 | cut -d' ' -f 2"
        VM_ID=$RET_VAL
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova show ${VM_ID} | grep ${2} | awk 'BEGIN {FS=\"|\"} {print \$3}' | tr -d ' '"
        VM_IP=`echo $RET_VAL`
        if [ -z $VM_IP ]; then
               continue
        fi
                _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; $port_cmd | grep ${VM_IP}| cut -d '|' -f2"
                IDS=`echo $RET_VAL`
                echo $IDS
}

function _port_change
{
        node=$1
        interface=$2
        state=$3
        _get_vms_vlan_port_id $node $interface
        port_id=$IDS
        if [ "$port_id" != "" ]; then
                 _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; neutron port-update ${port_id} --admin-state-up $state"
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
        VM_TO_STOP=$1
        echo "VM_TO_STOP : " $VM_TO_STOP
        change_vm_state $VM_TO_STOP STOP
}

function power_on_vm
{
        VM_TO_START=$1
        change_vm_state $VM_TO_START START
}

function reboot_vm
{
        VM_TO_START=$1
        change_vm_state $VM_TO_REBOOT REBOOT
}

function check_vm_state
{   
    VM_NAME=$1
    ESC_OPER_DONE=$2
    VM_IP=`ping $VM_NAME -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
    test_vm=`ping $VM_NAME -c 1 | grep icmp_seq`
    echo "=================================================="
    echo "Debug logs : " $test_vm
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
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_IP"
        VM_ID=$RET_VAL  
        _vm_power_state $OSPD_IP_Address $VM_ID
    fi
}

function blade_vm_operation
{
        VM_NAME=$1
        OPERATION=$2
        _get_vm_blade_name $VM_NAME
        _get_vms_on_blade $BLADE_HOSTNAME       
        vm_name_str=$(cat $OUT2_FILE |tr "\n" " ")
    vm_name_list=($vm_name_str)
        for VM_Full_Name in ${vm_name_list[*]};
        do
        RET_VAL=""
        _ssh_esc_command_ret $ESC_IP_Address $ESC_password "$ESC_CLI_CMD vm-action $OPERATION $VM_Full_Name"
        #RET_VAL="`ssh $ESC_USER@$ESC_IP_Address $ESC_CLI_CMD vm-action $OPERATION $VM_Full_Name`"
    done
}       

function disable_monitor_on_blade
{
        VM_TO_ACT=$1
        blade_vm_operation $VM_TO_ACT DISABLE_MONITOR
}

function enable_monitor_on_blade
{
        VM_TO_ACT=$1
        blade_vm_operation $VM_TO_ACT ENABLE_MONITOR
}

function reboot_VM_on_blade
{
        VM_NAME=$1
        _get_vm_blade_name $VM_NAME
        _get_vms_on_blade $BLADE_HOSTNAME
        vm_name_str=$(cat $OUT2_FILE |tr "\n" " ")
        vm_name_list=($vm_name_str)
        
        for VM_Full_Name in ${vm_name_list[*]};
        do
        RET_VAL=""
                _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova reboot --hard $VM_Full_Name"
        done
}

function check_vm_blade
{
        VM_NAME=$1
        _get_vm_blade_name $VM_NAME
        echo "BLADE_HOSTNAME :" $BLADE_HOSTNAME
        _get_vms_on_blade $BLADE_HOSTNAME
        VUP=0
        VDN=0
        VERR=0
        vm_name_str=$(cat $OUT2_FILE |tr "\n" " ")
        vm_name_list=($vm_name_str)     
        for VM_Full_Name in ${vm_name_list[*]};
        do
            RET_VAL=""
            _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_Full_Name | cut -d'|' -f 4"
            VM_STATUS=$RET_VAL  
            RET_VAL=""
            _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $VM_Full_Name | cut -d'|' -f 6"
            VM_POWER_STATUS=$RET_VAL    
            if [ $VM_STATUS = "ACTIVE" -a $VM_POWER_STATUS = "Running" ]; then
                VUP=`expr $VUP + 1`
            elif [ $VM_STATUS = "SHUTOFF" -a $VM_POWER_STATUS = "Shutdown" ]; then
                VDN=`expr $VDN + 1`
            else
                VERR=`expr $VERR + 1`
            fi
         done
         
         if [ $VUP -eq $NUM_VM_BLADE ]; then
                echo "All VMs are in Active State"
         elif [ $VDN -eq $NUM_VM_BLADE ]; then
                echo "All VMs are in Shutdown State"
         else
                echo "Some VMs are in Error State"
         fi         
}  

function change_blade_state
{
        VM_IN_BLADE=$1
        BLADE_OPERATION=$2
        _get_vm_blade_name $VM_IN_BLADE
        BLADE_HOSTNAME_Prefix=`echo $BLADE_HOSTNAME | cut -d'.' -f 1`
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFileBlade ; nova list | grep -w $BLADE_HOSTNAME_Prefix |  cut -d '|' -f 2"
        BLADE_ID=$RET_VAL
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFileBlade ; openstack baremetal node list | grep $BLADE_ID |  cut -d '|' -f 2"
        BLADE_UUID=$RET_VAL
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFileBlade ; openstack baremetal node power $BLADE_OPERATION $BLADE_UUID"
}   

function blade_power_off
{
        VM_IN_BLADE=$1
        change_blade_state $VM_IN_BLADE off
}

function blade_power_on
{
        VM_IN_BLADE=$1
        change_blade_state $VM_IN_BLADE on
}

function get_appltcation_blade_sm
{
    echo "" > $Hostname_File
    VM_prefix=$1
    Num_Sessionmgr=$2
    allowedSessionmgr=1
    hostoptstr=`awk /SESSION-SET/,/-END/ /etc/broadhop/mongoConfig.cfg | grep -v "^#" |  grep -e $MongoHost_Name | awk -F'=' '{print $2}' | awk -F':' '{print $2}' | tr '\r\n' ' '`
    hostoptlist=($hostoptstr)
    > $OUT3_FILE
    for mongoport in ${hostoptlist[*]}
    do
        diagnostics.sh --get_rep | grep $mongoport | awk -F'ARBITER' 'NR==1 {print $2}' | cut -d '-' -f 2 > $Hostname_File
        sed -i $'s/[^[:print:]\t]//g' $Hostname_File
        sed  -i 's/\[61G//' $Hostname_File
        sed  -i 's/\[92G//' $Hostname_File
        MongoHost=`cat $Hostname_File`   
        hostName=`mongo --port $mongoport --host $MongoHost --eval 'printjson(rs.isMaster())' | grep primary | awk '{split($0,a,":"); print a[2]}' | cut -c 3-`
        if [ $VM_prefix = "null" ] ; then
            echo $hostName >> $OUT3_FILE
        else
            if [[ $hostName =~ $VM_prefix ]] ; then 
                echo $hostName >> $OUT3_FILE
            fi
        fi
    done
    host_name_str=$(cat $OUT3_FILE |tr "\n" " ")
    host_name_list=($host_name_str)
    host_name_list=( $(printf '%s\n' "${host_name_list[@]}" | sort -u))
    for vmHostName in ${host_name_list[*]};
    do  
        _get_vm_blade_name $vmHostName
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list --host $BLADE_HOSTNAME | grep Internal | cut -d '|' -f 7 | cut -d ';' -f 2 | cut -d '=' -f 2"
        VM_IP_LIST=$RET_VAL
        takehost=0
        qnscnt=0
        for vm_ip in $VM_IP_LIST
        do
            vmHstNme=`ssh $vm_ip hostname`
            if [[ $vmHstNme =~ .*lb.* || $vmHstNme =~ .*PD.* ]] ; then 
                takehost=0
                break
            fi 
            if [[ $vmHstNme =~ .*pcrfclient.* || $vmHstNme =~ .*OA.* ]] ; then 
                takehost=0
                break
            fi                  
            if [[ $vmHstNme =~ .*installer.* || $vmHstNme =~ .*CM.* ]] ; then 
                takehost=0
                break
            fi 
            if [[ $vmHstNme =~ .*qns.* || $vmHstNme =~ .*PS.* ]] ; then 
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

function restart_blade_network
{
        VM_IN_BLADE=$1
        _get_vm_blade_name $VM_IN_BLADE
        echo $BLADE_HOSTNAME
        BLADE_HOSTNAME=`echo $BLADE_HOSTNAME | cut -d'.' -f 1`
        echo "BLADE_HOSTNAME " $BLADE_HOSTNAME
        echo "keyStoneFileBlade " $keyStoneFileBlade
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFileBlade ; nova list | grep $BLADE_HOSTNAME | cut -d '|' -f 7 | cut -d'=' -f 2"
        echo $RET_VAL
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "cd /home/stack; sudo -u stack -i ssh heat-admin@$RET_VAL sudo service network restart ; echo \r"
        echo "=================================================================================="
        echo $RET_VAL
        echo "=================================================================================="
}


function check_network_on_blade
{
        VM_IN_BLADE=$1
        _get_vm_blade_name $VM_IN_BLADE
        BLADE_HOSTNAME=`echo $BLADE_HOSTNAME | cut -d'.' -f 1`
        echo "BLADE_HOSTNAME " $BLADE_HOSTNAME
        echo "keyStoneFileBlade " $keyStoneFileBlade
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFileBlade ; nova list | grep $BLADE_HOSTNAME | cut -d '|' -f 7 | cut -d'=' -f 2"
        echo $RET_VAL
        _ssh_command_ret $OSPD_IP_Address $PASSWORD "cd /home/stack; sudo -u stack -i ssh heat-admin@$RET_VAL sudo systemctl status neutron-openvswitch-agent"
        if [[ $RET_VAL =~ .*active.* || $vmHstNme =~ .*running.* ]] ; then 
                echo "Network service Up on Blade"
        else
                echo "Network service Down on Blade"
        fi
}

function _get_vm_list_for_VLAN
{
    vlan=$1
    string=""
    cps_vm_list=`hosts-all.sh | sort`
    for vm in $cps_vm_list
        do
                VM_IP=`ping $vm -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
                _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $vlan | grep $VM_IP | awk '{print \$4}'"
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
               _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; neutron port-show $portID | grep admin_state_up | awk '{print \$4}'"
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
        else
                set="SEC-"
        fi

        diagnostics.sh --get_replica | grep $session_port |grep -v "ARBITER" | grep -i $set | awk -F':' '{print $2}' | awk -F'-' '{print $1}' >$VMIP_FILE
        sed -i $'s/[^[:print:]\t]//g' $VMIP_FILE
        sed  -i 's/\[42G//' $VMIP_FILE
        for ip in `cat $VMIP_FILE`
        do
                _ssh_command_ret $OSPD_IP_Address $PASSWORD "source $keyStoneFile ; nova list | grep $ip | awk '{print \$4}'"
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

function osp_network_restart
{
        node=$1
        RET_VAL=""
        VM_IP=`ping $node -c 1 | grep PING | cut -d' ' -f 3 | cut -d'(' -f 2 | cut -d')' -f 1`
        _ssh_command_ret $VM_IP $PASSWORD_VM "lshw -class network | grep -A 1 'bus info' | grep name | awk -F':' '{print \$2}'"
        for iface in ${RET_VAL[@]}
        do  
            _ssh_command_ret $VM_IP $PASSWORD_VM "ifconfig $iface down && sleep 15 &&  ifconfig $iface up"
            RET_VAL=""
            _ssh_command_ret $VM_IP $PASSWORD_VM "cat /sys/class/net/$iface/operstate"
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

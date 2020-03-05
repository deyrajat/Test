#!/bin/bash
#PASSWORD="starent"
#PASSWORD_VM="cisco123"
#LEVEL=1 #1: Debug, 2: Info, 3: Error
BLADEIP_FILE=/root/blade.txt

if [ -z $1 ]; then
        echo "Platform type 1: VM 2: OSP"
        exit;
fi
if [ -z $2 ]; then
        echo "Blade VM Password"
        exit;
fi

if [ -z $3 ]; then
        echo "VM Password"
        exit;
fi

if [ -z $4 ]; then
        echo "Log Level: 1: Debug, 2: Info, 3: Error"
        exit;
fi

if [ -z $5 ]; then
        echo "VM Count"
        exit;
fi

PLATFORM=$1
PASSWORD=$2
PASSWORD_VM=$3
LEVEL=$4
VM_Count=$5
shift 5

while getopts F:V:O:E:P:N:R:K:U: option
do
  case "${option}" in
    F) OPERETION_TYPE=${OPTARG};;
    V) variable=${OPTARG};;
    O) OSPD_IP_Address=${OPTARG};;
    E) ESC_IP_Address=${OPTARG};;
    P) ESC_password=${OPTARG};;
    N) APP_BLD_NUM_SESSION=${OPTARG};;
    R) Eth_Port=${OPTARG};;    
    K) KeyFileLoc=${OPTARG};;
    U) NodeUser=${OPTARG};;
    \?) echo "Invalid option -$OPTARG" >&8
        help_function
    ;;
  esac
done

if [ -z $OPERETION_TYPE ]; then
        echo "Operation Type is Mandatory"
        exit;
fi      
if [ -z $variable ]; then
        echo "VM name format. Eg. qns0x is Mandatory"
        exit;
fi

#Eth_Port=$8

if [ $PLATFORM -eq 3  ] || [ $PLATFORM -eq 5 ]; then
    
        if [ -z $OSPD_IP_Address ]; then
                echo "OSPD IP Address is Mandatory"
                exit;
        fi      
        if [ -z $ESC_IP_Address ]; then
                echo "ESC IP Address is Mandatory"
                exit;
        fi
        if [ -z $ESC_password ]; then
                echo "ESC PASSWORD is Mandatory"
                exit;
        fi
fi

if [ $PLATFORM -eq 6  ]; then
	if [ -z $ESC_IP_Address ]; then
	        echo "ESC IP Address is Mandatory"
	        exit;
	fi
	if [ -z $ESC_password ]; then
	        echo "ESC PASSWORD is Mandatory"
	        exit;
	fi
fi 

help_function()
{
    echo "======================================"
    echo "Mandatory parameters" 
    echo "-F OPERETION_TYPE"
    echo "-V VM name format"    
    echo "-O OSPD IP Address"
    echo "-E ESC IP Address"  
    echo "-P ESC PASSWORD"  
    echo ""
        echo "Optional parameters"      
        echo "-N Application Blade Session Manager Number" 
        echo "-R Ethernet Port" 
        echo "-K Key File Loc"
        echo "-U Node User Name" 
        echo "======================================"
    exit
}

LIST_VM_NAMES=""
if [ $VM_Count -eq 0 ]; then
    LIST_VM_NAMES[0]=$variable
else
    len=`expr "${variable}" : '.*'`
    var=`echo ${variable:0:($len-2)}`
    vm_list=`hosts-all.sh | grep -i $var | sort`
    vm_array=($vm_list)
    flag=0
    arrLength=`echo ${#vm_array[@]}`
    for i in "${!vm_array[@]}"; do
        if [[ ${vm_array[$i]} = $variable ]]; then
             flag=1
             for ((j=0 ; j< $VM_Count ; j++ ))
             do
                 if [[ $i -ge $arrLength ]]; then
                        break;
                 else
                         vmName=${vm_array[$i]}
                         let "i+=1"
                 fi
                 LIST_VM_NAMES[j]=$vmName
             done
             break;
        fi
    done
    if [ $flag -lt 1 ]; then
        echo "vm is not present"
        exit;
    fi
fi


if [ $PLATFORM -lt 3 ]; then
        echo  ${LIST_VM_NAMES[*]}
fi

if [ $PLATFORM -eq 1 ]; then
        echo "VMWare Platform"
        . ./functions_VM.sh
elif [ $PLATFORM -eq 2 ]; then
        echo "OS platform"
        . ./functions_OSP.sh
elif [ $PLATFORM -eq 3 ]; then
#       echo "ESC platform"
        . ./functions_ESC.sh
elif [ $PLATFORM -eq 4 ]; then
#       echo "Cisco VIM platform"
        . ./functions_CVIM.sh        
elif [ $PLATFORM -eq 5 ]; then
#       echo "Cisco ESC NON ULTRA platform"
        . ./functions_ESC_NONULTRA.sh
elif [ $PLATFORM -eq 6 ]; then
#       echo "Cisco ESC UAME platform"
        . ./functions_ESC_UAME.sh   
else
        echo "Wrong platform select"
        exit
fi

function vm_network_restart
{
        if [ -z $Eth_Port ]; then
                echo "Ethernet Port is Mandatory for this function"
                exit;
        fi
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ $PLATFORM -eq 5 ]; then
                if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
	                    osp_network_restart $tnode 
	                    sleep 120
                fi
            else
	            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
	                    network_down $tnode $Eth_Port
	                    sleep 5
	                    network_up $tnode $Eth_Port
	                    sleep 180
	                fi
	        fi
        done
}

function vm_restart
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    power_off_vm $tnode
                    sleep 200
                    power_on_vm $tnode
                    sleep 180
                        printf '\n' | for NH in `hosts.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
                        printf '\n' | for NH in `hosts-sessionmgr.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
                        printf 'y\n' | /var/qps/bin/support/sync_times.sh ha
                fi
        done
}

function vm_power_off
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    power_off_vm $tnode
                fi
        done
        sleep 180
    for tnode in "${LIST_VM_NAMES[@]}"
        do        
                check_vm_state $tnode "oper_vm_down"
    done
}

function vm_power_on
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    power_on_vm $tnode
                fi
        done
        sleep 120
        printf '\n' | for NH in `hosts.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
        printf '\n' | for NH in `hosts-sessionmgr.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
        printf 'y\n' | /var/qps/bin/support/sync_times.sh ha
        sleep 60
    for tnode in "${LIST_VM_NAMES[@]}"
        do
        check_vm_state $tnode "oper_vm_up"
    done
}

function vm_power_reboot
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    reboot_vm $tnode
                fi
        done
        sleep 180
        printf '\n' | for NH in `hosts.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
        printf '\n' | for NH in `hosts-sessionmgr.sh` ; do echo $NH ; ssh $NH service iptables stop ; done
        printf 'y\n' | /var/qps/bin/support/sync_times.sh ha
        for tnode in "${LIST_VM_NAMES[@]}"
        do
        check_vm_state $tnode "oper_vm_up"
    done
}

function primary_balance_down
{
        for type in BALANCE1
        do
                restart_pri_sm $type 10
                sleep 180
        done
}

function primary_session_down
{
        for type in SESSION
        do
                restart_pri_sm $type 10
                sleep 180
        done
}

function primary_spr_down
{
        for type in SPR
        do
                restart_pri_sm $type 10
                sleep 180
        done
}

function non_primary_balance_down
{
        for type in BALANCE1
        do
                restart_non_pri_sm $type 10
                sleep 180
        done
}

function non_primary_session_down
{
        for type in SESSION
        do
                restart_non_pri_sm $type 10
                sleep 180
        done
}

function non_primary_spr_down
{
        for type in SPR
        do
                restart_non_pri_sm $type 10
                sleep 180
        done
}

function blade_network_restart
{
    restart_blade_network $variable
}

function memcached_restart
{
        for tnode in lb01 lb02
        do
                kill_memcached_on_node $tnode
                sleep 30
        done
        for tnode in sessionmgr01 sessionmgr02
        do
                kill_memcached_on_node $tnode
                sleep 30
        done
}

function fix_blade_vm_network_restart
{
        for node in `grep -w $variable $CFG | cut -f2 -d=`
        do
                echo $node
                                vmNic='vmnic'$VM_Count
                restart_blade_real_network $node $vmNic 10
                sleep 100
        done
}

function vm_network_service_restart
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    network_service_restart $tnode
                    sleep 180
                fi
        done
}

function disable_monitor_all_vm_on_blade
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    disable_monitor_on_blade $tnode
                    #sleep 60
                fi
        done
}

function enable_monitor_all_vm_on_blade
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    enable_monitor_on_blade $tnode
                    #sleep 60
                fi
        done
}

function reboot_all_vm_on_blade
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    reboot_VM_on_blade $tnode
                    #sleep 60
                fi
        done
}

function power_off_blade
{
    blade_str=""
    vm_str=""
    for tnode in "${LIST_VM_NAMES[@]}"
    do
        if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
            get_blade_ip_for_vm $tnode
            mcthCnt=`echo $blade_str | grep $BladeIP | wc -c`
            if [ $mcthCnt -eq 0 ] ; then
                blade_str=`echo $blade_str" "$BladeIP`
                vm_str=`echo $vm_str" "$tnode`                                          
            fi
        fi
    done
    echo $vm_str   
    vm_host_list=($vm_str) 
    for vmnode in "${vm_host_list[@]}"
    do
        echo "blade_power_off :" $vmnode
        blade_power_off $vmnode
    done
}

function power_on_blade
{
    blade_str=""
    vm_str=""
    for tnode in "${LIST_VM_NAMES[@]}"
    do
        if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
            get_blade_ip_for_vm $tnode
            mcthCnt=`echo $blade_str | grep $BladeIP | wc -c`
            if [ $mcthCnt -eq 0 ] ; then
                blade_str=`echo $blade_str" "$BladeIP`
                vm_str=`echo $vm_str" "$tnode`                                          
            fi
        fi
    done
    echo $vm_str   
    vm_host_list=($vm_str) 
    for vmnode in "${vm_host_list[@]}"
    do
        blade_power_on $vmnode
    done
}

function check_VM_on_blade
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    check_vm_blade $tnode
                    #sleep 60
                fi
        done
}

function get_sm_on_application_blade
{
        if [ -z $APP_BLD_NUM_SESSION ]; then
                echo "Application Blade Session Manager Number is Mandatory for this function"
                exit;
        fi      
        if [ -z $MongoHost_Name ]; then
                echo "Mongo Host Name is Mandatory for this function"
                exit;
        fi
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    get_appltcation_blade_sm $tnode $APP_BLD_NUM_SESSION
                    #sleep 60
                fi
        done
}

function check_blade_network
{
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                    check_network_on_blade $tnode
                    #sleep 60
                fi
        done
}


function VLAN_interface_down
{
         if [ -z $Eth_Port ]; then
                echo "Ethernet Port->VLAN interface name is Mandatory for this function"
                exit;
        fi

        for eth in $Eth_Port
        do
                interface="$eth"
                down_vlan_interface $interface
        done
        sleep 5
        for eth in $Eth_Port
        do
                check_vlan_status $eth "down"
        done

}


function VLAN_interface_up
{
         if [ -z $Eth_Port ]; then
                echo "Ethernet Port->VLAN interface name is Mandatory for this function"
                exit;
        fi

        for eth in $Eth_Port
        do
                interface="$eth"
                up_vlan_interface $interface
        done
        sleep 5
        for eth in $Eth_Port
        do
                check_vlan_status $eth "up"
        done

}

function power_off_session_shards
{
        if [ -z $Session_Port ]; then
                echo "Session Port is Mandatory for this function"
                exit;
        fi
        session_shards_power_off $variable $Session_Port
}

function power_on_session_shards
{
        if [ -z $Session_Port ]; then
                echo "Session Port is Mandatory for this function"
                exit;
        fi
        session_shards_power_on $variable $Session_Port
}

function vm_blade_reboot
{
        echo "" > $BLADEIP_FILE
        for tnode in "${LIST_VM_NAMES[@]}"
        do
            if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
                get_blade_ip_for_qns_vm $tnode
                blade_ip=$BladeIP
                echo $blade_ip >> $BLADEIP_FILE
             fi
        done
        blade_list=`cat $BLADEIP_FILE | grep -v "$NonQnsBladeIp" | sort | uniq`
        for blade in $blade_list
        do
                reboot_blade $blade
        done
}

function reboot_all_blades
{

        all_blades_reboot

}

function all_blades_power_down
{
        blade_str=""
        vm_str=""
        installer_ip=`cat /etc/hosts | grep $variable | awk '{print $1}'`
        _ssh_vm_command_ret $installer_ip "hosts-all.sh | sort"
        all_vms_list=`echo $RET_VAL`
        for vm in $all_vms_list
        do
            get_blade_ip_for_vm $vm
            mcthCnt=`echo $blade_str | grep $BladeIP | wc -c`
            if [ $mcthCnt -eq 0 ] ; then
                blade_str=`echo $blade_str" "$BladeIP`
                vm_str=`echo $vm_str" "$vm`
            fi
        done
        echo $vm_str
        vm_host_list=($vm_str)
        for vmnode in "${vm_host_list[@]}"
        do
                blade_power_off $vmnode
        done
}

function vm_all_physical_port_restart
{
    if [ -z $Eth_Port ]; then
        echo "Ethernet Port is Mandatory for this function"
        exit;
    fi
    for tnode in "${LIST_VM_NAMES[@]}"
    do
        if [ ! -z "$tnode" -a "$tnode" != " " -o "$tnode" != "" ]; then
            osp_network_restart $tnode
            sleep 120
        fi
    done
}


$OPERETION_TYPE
#lb_restart




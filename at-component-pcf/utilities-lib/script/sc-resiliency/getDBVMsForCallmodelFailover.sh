CALLMODEL_CONFIG_FILE="/etc/broadhop/mon_db_for_callmodel.conf"
MONGO_CONFIG_FILE="/etc/broadhop/mongoConfig.cfg"
TMP_FILE="/tmp/set.txt"
PRIMARY_MEMBER_VM_LIST_FILE="/tmp/members.list"

help () {
        echo -e "
        Usage: $0 [Options]
        Options:
            --1stFOSet     - Get the primary members of the first set mentioned in ${CALLMODEL_CONFIG_FILE}.
            --allFOSets    - Get the primary members of all the sets mentioned in ${CALLMODEL_CONFIG_FILE}.
            --setFOAtIndex - Get the primary members of the set, mentioned at the specified index, in ${CALLMODEL_CONFIG_FILE}.
            --setFOName    - Get the primary members of the set, matching the provided name, from ${CALLMODEL_CONFIG_FILE}.
       
        Only one option can be used at a time." 
}

params=$(getopt -o "" -al "1stFOSet,allFOSets,setFOAtIndex:,setFOName:" --name "$0"  -- "$@")
eval set -- "$params"
while true;
do
    case "$1" in
        --1stFOSet)
            session_set_names=`grep -e SESSION-SET ${CALLMODEL_CONFIG_FILE} | head -1`
            shift
            ;;
        --allFOSets)
            session_set_names=`grep -e SESSION-SET ${CALLMODEL_CONFIG_FILE}`
            shift
            ;;
        --setFOAtIndex)
            index=${2}
            if [[ -z "${index// }" ]] 
            then
                echo "FO set index no is missing"
                exit 1
            fi
            totalNoOfSets=`grep -e SESSION-SET ${CALLMODEL_CONFIG_FILE} | wc -l`
            if [ $totalNoOfSets -lt $index ]
            then
                echo "Invalid index provided. Check ${CALLMODEL_CONFIG_FILE} for number of available sets." 
                exit 1
            fi
            session_set_names=`grep -e SESSION-SET ${CALLMODEL_CONFIG_FILE} | awk "NR==${index}"`
            shift 2
            ;;
        --setFOName)
            session_set_names=`grep -e ${2} ${CALLMODEL_CONFIG_FILE}`
            if [[ -z "${session_set_names// }" ]]
            then
                echo "Provided set name not found in ${CALLMODEL_CONFIG_FILE}"
                exit
            fi
            shift 2
            ;;
       --)
            shift
            break
            ;;
        *)
            help
            exit 1
            ;;
    esac
done

rm -f ${TMP_FILE}
rm -f ${PRIMARY_MEMBER_VM_LIST_FILE}
#session_set_names=`grep -e SESSION-SET ${CALLMODEL_CONFIG_FILE}`
#echo "Session set names found : $session_set_names"
session_set_name_array=($session_set_names)

getPrimaryDBMembers() {
    set_name="${1}"
    block_start=`grep -n $set_name ${MONGO_CONFIG_FILE} | awk -F":" '{print $1}' | head -1`
    block_end=`grep -n $set_name ${MONGO_CONFIG_FILE} | awk -F":" '{print $1}' | tail -1`
    sed -n "${block_start},${block_end}p" ${MONGO_CONFIG_FILE} > ${TMP_FILE}

    #find Primary members in set
    block_start=`grep -n "PRIMARY-MEMBERS" ${TMP_FILE} | awk -F":" '{print $1}' | head -1`
    block_end=`grep -n "SECONDARY-MEMBERS" ${TMP_FILE} | awk -F":" '{print $1}' | tail -1`

    #get next line no to "PRIMARY-MEMBERS"
    block_start=`expr ${block_start} + 1`

    #get previous line no to "SECONDARY-MEMBERS"
    block_end=`expr ${block_end} - 1`

    #get names of primary members
    db_vms=`sed -n "${block_start},${block_end}p" "${TMP_FILE}"`
    primary_db_vms_array=($db_vms)
    for ((j=0; j<${#primary_db_vms_array[@]}; ++j));
    do
        vm_name=`echo ${primary_db_vms_array[j]} | cut -d "=" -f 2 | cut -d ":" -f 1`
        echo -e "${vm_name}" >> "${PRIMARY_MEMBER_VM_LIST_FILE}"
    done
}

for ((i=0; i<${#session_set_name_array[@]}; ++i));
#for ((i=0; i<1; ++i));
do
#    echo "SESSION SET NAME :  ${session_set_name_array[i]}"
    getPrimaryDBMembers ${session_set_name_array[i]}
done

line_count=`cat ${PRIMARY_MEMBER_VM_LIST_FILE} | wc -l`
if [ $line_count -gt 0 ]
then
    echo "Primary members are listed in ${PRIMARY_MEMBER_VM_LIST_FILE}"
else
    echo "Primary members not found"
fi

#!/bin/bash

####################################################################################################
# Date: <09/09/2019> Version: <Initial version: 1.0.0> Create by <Prosenjit Chatterjee, proschat>  #
####################################################################################################

help_function()
{
    echo "============================================="
    echo "All parameters are mandetory"
    echo "-n CEE Namespace"
    echo "-t Time to capture logs from SNMP-Trap Pod"
    echo "-a Alert config file name"
    echo "============================================="
    exit
}

# Check No of argument
#if [ "$#" -ne 3 ]; then
#    echo "Illegal number of parameters"
#    help_function
#    exit
#fi

while getopts n:t:a: option
do
  case "${option}" in
    n) cee_namespace=${OPTARG};;
    t) time_to_capture_logs_from_pod=${OPTARG};;
    a) alert_config_file=${OPTARG};;
    ?) echo "Invalid option $OPTARG"
       help_function
    ;;
  esac
done

alert_config=$(<$alert_config_file)
#cee_namespace='cee-1'
#time_to_capture_logs_from_pod='10m'

logging_pod_name=$(kubectl get pods -n ${cee_namespace} | grep ^snmp-trapper | awk '{print $1}')
logs_from_pod=$(kubectl logs ${logging_pod_name} -n ${cee_namespace} --since=${time_to_capture_logs_from_pod} |grep -a "('Alert: '" | grep -v "This is an alert meant to ensure")
#echo ${logs_from_pod}

#echo "$alert_config"
no_of_rules=$(echo "$alert_config" | grep  'rule ' | wc -l)
#echo "No Of Rules :: $no_of_rules"
for loop_cnt in $(seq $no_of_rules)
do
    rule_name=$(echo "$alert_config" | grep 'rule ' | awk -v awk_num=$loop_cnt ' FNR == awk_num {print $2}' | sed -e 's/[\r\n]//g')
    hostname=$(echo "$alert_config" | grep expression | grep expression | awk -v awk_num=$loop_cnt -F'\' ' FNR == awk_num {print $2}' | cut -c 2- | sed -e 's/[\r\n]//g')
    severity=`echo "$alert_config" | grep 'severity ' | awk -v awk_num=$loop_cnt ' FNR == awk_num {print $2}' | sed -e 's/[\r\n]//g'`
    annotation_summary=$(echo "$alert_config"| sed -n '/annotation summary/,/exit/p' | grep value | awk -v awk_num=$loop_cnt ' FNR == awk_num {print $NF}' | sed -e 's/[\r\n]//g')
    annotation_type=$(echo "$alert_config"| sed -n '/annotation type/,/exit/p' | grep value | awk -v awk_num=$loop_cnt -F'"' ' FNR == awk_num {print $2}' | sed -e 's/[\r\n]//g')
    awk_search_str="/u'severity': u'$severity'/&&/u'annotations': {u'type': u'$annotation_type', u'summary': u'$annotation_summary'}/"

    count=`echo "$logs_from_pod" | awk "$awk_search_str" | wc -l`
    if [ "$count" -eq "0" ];
    then
        echo "Logs not found for Rule : $rule_name"
    else
        echo "Found logs for Rule : $rule_name $count times"
    fi
done

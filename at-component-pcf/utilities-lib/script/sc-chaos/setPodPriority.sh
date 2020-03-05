#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the pcf namespace"
    exit
fi
if [ -z $2 ]; then
    echo "Enter the cee namespace"
    exit
fi
if [ -z $3 ]; then
    echo "Enter the priority value"
    exit
fi
setPriority=$3
#### PCF high pod type list
pcfHighStr="admin-db cdl-ep-session-c1 cdl-index-session-c1 cdl-slot-session-c1 crd-api-"$1"-pcf-engine db-admin-[0-9]+ db-admin-config db-balance-config diameter-ep-rx grafana-dashboard kafka lbvip02 ^ldap-"$1"-cps-ldap-ep pcf-engine-"$1"-pcf-engine-app pcf-rest-ep svn-[0-9]+ zookeeper"
#### CEE high pod type list
ceeHighStr="thanos-query-hi-res"
#### PCF high pod selection
pcfHighSelStr="100 100 100 50 100 100 100 100 100 50 50 100 100 50 100 100 100"
#### CEE high pod selection
ceeHighSelStr="100"

######PCF Low pod type list
pcfLowStr="api-"$1"-ops-center cdl-index-session cdl-slot-session cps-license db-admin-[0-9]+ db-admin-config db-balance1-[0-9]+ db-balance-config db-spr1-[0-9]+ db-spr-config ^document grafana-dashboard kafka lbvip02 network-query ops-center-"$1"-ops-center patch-server pcf-day0-config rs-controller svn-ldap swift-"$1"-ops-center traceid-"$1"-pcf-engine"

#### PCF Low pod selection
pcfLowSelStr="100 1 1 100 1 1 1 1 1 1 100 100 1 100 100 100 100 100 100 100 100 100"

#### CEE low pod type list
ceeLowStr="alert-logger api-"$2"-ops-center ^"$2"-product-documentation core-retriever ^documentation logs-retriever node-exporter ops-center-"$2"-ops-center path-provisioner prometheus-rules prometheus-scrapeconfigs-synch pv-manager pv-provisioner swift-"$2"-ops-center"
#### CEE Low pod selection
ceeLowSelStr="100 100 100 100 100 100 100 100 100 100 100 100 100 100 100"

######PCF Medium pod type list
pcfMedStr="activemq admin-db api-"$1"-ops-center cdl-ep-session-c1 cdl-index-session-c1 cdl-slot-session-c1 db-admin-[0-9]+ db-admin-config db-balance-config db-balance1-[0-9]+ db-spr-config db-spr1-[0-9]+ diameter-ep-rx etcd-"$1"-etcd-cluster grafana-dashboard-cdl lbvip02 ldap-"$1"-cps-ldap-ep pcf-engine-"$1"-pcf-engine pcf-rest-ep redis- smart-agent-"$1"-ops-center unifiedapi-engine-"$1"-pcf zookeeper"
pcfMedSelStr="100 50 100 50 1 50 1 2 2 100 100 1 50 100 50 100 50 50 50 100 100 100 1"

#### PCF Medium pod selection

#### CEE Medium pod type list
ceeMedStr="alertmanager bulk-stats grafana- kube-state-metrics postgres prometheus-hi-res show-tac-manager smart-agent-"$2"-ops-center thanos-query-hi-res"

#### CEE Medium pod selection
ceeMedSelStr="100 100 100 100 100 100 100 100 1"

##### Get the Pods to modify the labels high
if [ $setPriority = "high" ]; then
    pcfHighList=($pcfHighStr)
    pcfHighSelList=($pcfHighSelStr)
    cntr=0
    for pcfHigh in ${pcfHighList[*]}
    do
        cmdStr="kubectl get pods -n $1 | awk '/"$pcfHigh"/' | wc -l"
        numbOfPods=`eval $cmdStr`
        actualPodCnt=$(( $numbOfPods * ${pcfHighSelList[$cntr]} / 100 ))
        podCntr=1
        while [ $podCntr -le $actualPodCnt ]
        do
            cmdStr="kubectl get pods -n $1 | awk '/"$pcfHigh"/' | awk 'FNR == $podCntr {print \$1}'"
            podname=`eval $cmdStr`
            echo "Pod to set is $podname"
            cmdStr="kubectl label pods $podname priority=high -n $1 --overwrite"
            result=`eval $cmdStr`
            podCntr=$(( $podCntr + 1 ))
        done
        cntr=$(( $cntr + 1 ))
    done

    ceeHighList=($ceeHighStr)
    ceeHighSelList=($ceeHighSelStr)
    cntr=0
    for ceeHigh in ${ceeHighList[*]}
    do
        cmdStr="kubectl get pods -n $2 | awk '/"$ceeHigh"/' | wc -l"
        numbOfPods=`eval $cmdStr`
        actualPodCnt=$(( $numbOfPods * ${ceeHighSelList[$cntr]} / 100 ))
        podCntr=1
        while [ $podCntr -le $actualPodCnt ]
        do
            cmdStr="kubectl get pods -n $2 | awk '/"$ceeHigh"/' | awk 'FNR == $podCntr {print \$1}'"
            podname=`eval $cmdStr`
            echo "Pod to set is $podname"
            cmdStr="kubectl label pods $podname priority=high -n $2 --overwrite"
            result=`eval $cmdStr`
            podCntr=$(( $podCntr + 1 ))
        done
        cntr=$(( $cntr + 1 ))
    done
fi

##### Get the Pods to modify the labels low
if [ $setPriority = "low" ]; then
    pcfLowList=($pcfLowStr)
    pcfLowSelList=($pcfLowSelStr)
    cntr=0
    for pcfLow in ${pcfLowList[*]}
    do
        cmdStr="kubectl get pods -n $1 | awk '/"$pcfLow"/' | wc -l"
        numbOfPods=`eval $cmdStr`
        if [ ${pcfLowSelList[$cntr]} -gt 9 ]; then
           actualPodCnt=$(( $numbOfPods * ${pcfLowSelList[$cntr]} / 100 ))
        else
           actualPodCnt=${pcfLowSelList[$cntr]}
        fi
        podCntr=1
        while [ $podCntr -le $actualPodCnt ]
        do
            cmdStr="kubectl get pods -n $1 | awk '/"$pcfLow"/' | awk 'FNR == $podCntr {print \$1}'"
            podname=`eval $cmdStr`
            echo "Pod to set is $podname"
            cmdStr="kubectl label pods $podname priority=low -n $1 --overwrite"
            result=`eval $cmdStr`
            podCntr=$(( $podCntr + 1 ))
        done
        cntr=$(( $cntr + 1 ))
    done

    ceeLowList=($ceeLowStr)
    ceeLowSelList=($ceeLowSelStr)
    cntr=0
    for ceeLow in ${ceeLowList[*]}
    do
        cmdStr="kubectl get pods -n $2 | awk '/"$ceeLow"/' | wc -l"
        numbOfPods=`eval $cmdStr`
        actualPodCnt=$(( $numbOfPods * ${ceeLowSelList[$cntr]} / 100 ))
        podCntr=1
        while [ $podCntr -le $actualPodCnt ]
        do
            cmdStr="kubectl get pods -n $2 | awk '/"$ceeLow"/' | awk 'FNR == $podCntr {print \$1}'"
            podname=`eval $cmdStr`
            echo "Pod to set is $podname"
            cmdStr="kubectl label pods $podname priority=low -n $2 --overwrite"
            result=`eval $cmdStr`
            podCntr=$(( $podCntr + 1 ))
        done
        cntr=$(( $cntr + 1 ))
    done
fi

##### Get the Pods to modify the labels Medium
if [ $setPriority = "med" ]; then
    pcfMedList=($pcfMedStr)
    pcfMedSelList=($pcfMedSelStr)
    cntr=0
    for pcfMed in ${pcfMedList[*]}
    do
        cmdStr="kubectl get pods -n $1 | awk '/"$pcfMed"/' | wc -l"
        numbOfPods=`eval $cmdStr`
        if [ "$pcfMed" == "cdl-slot-session-c1" ]; then
           podCntr=0
           actualPodCnt=$(( $numbOfPods * ${pcfMedSelList[$cntr]} / 100 ))
           while [ $podCntr -lt $actualPodCnt ]
           do
               index=$(( ( $podCntr * 2 ) + 1))
               cmdStr="kubectl get pods -n $1 | awk '/"$pcfMed"/' | awk 'FNR == $index {print \$1}'"
               podname=`eval $cmdStr`
               echo "Pod to set is $podname"
               cmdStr="kubectl label pods $podname priority=med -n $1 --overwrite"
               podCntr=$(( $podCntr + 1 ))
           done
        else
           if [ ${pcfMedSelList[$cntr]} -gt 9 ]; then
              actualPodCnt=$(( $numbOfPods * ${pcfMedSelList[$cntr]} / 100 ))
           else
              actualPodCnt=${pcfMedSelList[$cntr]}
           fi
           podCntr=1
           while [ $podCntr -le $actualPodCnt ]
           do
               cmdStr="kubectl get pods -n $1 | awk '/"$pcfMed"/' | awk 'FNR == $podCntr {print \$1}'"
               podname=`eval $cmdStr`
               echo "Pod to set is $podname"
               cmdStr="kubectl label pods $podname priority=med -n $1 --overwrite"
               result=`eval $cmdStr`
               podCntr=$(( $podCntr + 1 ))
           done
        fi
        cntr=$(( $cntr + 1 ))
    done

    ceeMedList=($ceeMedStr)
    ceeMedSelList=($ceeMedSelStr)
    cntr=0
    for ceeMed in ${ceeMedList[*]}
    do
        cmdStr="kubectl get pods -n $2 | awk '/"$ceeMed"/' | wc -l"
        numbOfPods=`eval $cmdStr`
        actualPodCnt=$(( $numbOfPods * ${ceeMedSelList[$cntr]} / 100 ))
        podCntr=1
        while [ $podCntr -le $actualPodCnt ]
        do
            cmdStr="kubectl get pods -n $2 | awk '/"$ceeMed"/' | awk 'FNR == $podCntr {print \$1}'"
            podname=`eval $cmdStr`
            echo "Pod to set is $podname"
            cmdStr="kubectl label pods $podname priority=med -n $2 --overwrite"
            result=`eval $cmdStr`
            podCntr=$(( $podCntr + 1 ))
        done
        cntr=$(( $cntr + 1 ))
    done
fi

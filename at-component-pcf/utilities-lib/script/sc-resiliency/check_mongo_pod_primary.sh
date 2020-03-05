#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the type(session/spr) "
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the namespace name"
    exit;
fi
if [ -z $3 ]; then
    podCheck=1
else
    podCheck=$3
fi

podType=$1
nameSpace=$2
shards=10
Replica=5
checkCnt=1
shardsCnt=0

while [ $shardsCnt -le $shards ]
do
   ReplicaCnt=-1
   shardsCnt=`expr $shardsCnt + 1`
   while [ $ReplicaCnt -lt $Replica ]
   do
      ReplicaCnt=`expr $ReplicaCnt + 1`
      if [ "$podType" = "session" ]; then
         podCnt=`kubectl get pods -n $nameSpace | grep db-s$shardsCnt-$ReplicaCnt | wc -l`
         if [ $podCnt -eq 0 ]; then
              continue
         fi
         echo "check for db-s$shardsCnt-$ReplicaCnt"
         cmdOutput=`kubectl exec db-s$shardsCnt-$ReplicaCnt -n $nameSpace -- mongo session -eval "printjson(db.session.count())"`
      elif [ "$podType" = "spr" ]; then
         podCnt=`kubectl get pods -n $nameSpace | grep db-spr$shardsCnt-$ReplicaCnt | wc -l`
         if [ $podCnt -eq 0 ]; then
             continue
         fi
         cmdOutput=`kubectl exec db-spr$shardsCnt-$ReplicaCnt -n $nameSpace -- mongo spr -eval "printjson(db.subscriber.count())"`
      else
         echo "Invalid choice"
      fi
      checkSecondary=`echo $cmdOutput | grep NotMasterNoSlaveOk | wc -l`
      checkContent=`echo $cmdOutput | grep "MongoDB shell version" | wc -l`
      if [[ $checkContent -eq 1 ]] && [[ $checkSecondary -eq 0 ]]; then
         if [ "$podType" = "session" ]; then
             mongoPod=`echo db-s$shardsCnt-$ReplicaCnt`
         fi
         if [ "$podType" = "spr" ]; then
             mongoPod=`echo db-spr$shardsCnt-$ReplicaCnt`
         fi
         #echo "checkCnt = $checkCnt"
         if [[ $checkCnt -eq $podCheck ]]; then
            resMongoPod=$mongoPod
            break
         else
            checkCnt=`expr $checkCnt + 1`
         fi
      fi
   done
   if [ $resMongoPod ] ; then
      break
   fi
done


if [ -z $resMongoPod ] ; then
    echo "Mongo Pod not found"
else
    echo "Output Pod is $resMongoPod"
fi
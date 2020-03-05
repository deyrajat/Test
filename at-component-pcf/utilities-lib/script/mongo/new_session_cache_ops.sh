#!/bin/bash
# Copyright (c) 2013 Cisco Systems, Inc.
#
# This script will help to display the sessions count from session cache db
# and remove the sessions form session cache db

BIN_HOME=$(dirname "${BASH_SOURCE[0]}")
[[ "$BIN_HOME" == "." ]] && BIN_HOME=$(pwd)
while [[ "/" != "${BIN_HOME}" ]]
do
    if [[ "$(basename "${BIN_HOME}")" =~ control|diag|support|troubleshooting|update ]]
    then
        BIN_HOME="$(dirname "${BIN_HOME}")"
        break
    fi

    BIN_HOME="$(dirname "${BIN_HOME}")"
done
if [[ "/" == "${BIN_HOME}" ]]
then
    BIN_HOME="/var/qps/bin"
fi
source $BIN_HOME/support/functions.sh
readonly BIN_HOME
declare -r BIN_SUPPORT="${BIN_HOME}/support"

# Checking log directory
LOG_DIR="/var/log/broadhop/scripts"
mkdir -p $LOG_DIR

# Include MONGO related commands
[[ -x ${BIN_HOME}/support/mongo/dbcmds.sh ]] && . ${BIN_HOME}/support/mongo/dbcmds.sh

# Declaration
declare -r SELF=$(basename "${BASH_SOURCE[0]}" .sh)
declare -r EXECDIR=$(dirname "${BASH_SOURCE[0]}")
declare -r COPYRIGHT=$(egrep '^#' "${BASH_SOURCE[0]}" \
                           | sed -e 's/^# \+//' | grep "^Copyright")

SCRIPT_NAME=$(basename "$0")
SCRIPT_NAME_NO_EXT=`echo $SCRIPT_NAME | sed 's/\(.*\)\..*/\1/'`
SYS_DT_TIME=`date +%d%m%Y_%H%M%S`
ALLOWED_ROLES=(qns-su qns-admin qns root)
MONGODB_CONFIG_FILE="/etc/broadhop/mongoConfig.cfg"
GR_CLUSTER_CONFIG_FILE="/etc/broadhop/gr_cluster.conf"
TMP_DIR=$(mktemp -d -t "XXXXXXXX${SELF}")
LOG_FILE="$LOG_DIR/${SCRIPT_NAME_NO_EXT}_${SYS_DT_TIME}.log"
MONGO_QUERY="$TMP_DIR/.get_primary.js"
MONGO_QUERY_OUT="$TMP_DIR/.get_primary.out"
GET_SESSION_DB_FROM_ADMIN_DB_JSON="$TMP_DIR/.get_session_db.js"
GET_SESSION_DB_FROM_ADMIN_DB_OUT="$TMP_DIR/.get_session_db.out"
JSON_QUERY="$TMP_DIR/.get_status.js"
JSON_OUT="$TMP_DIR/.get_status.out"
TMP_MONGO_FILE="$TMP_DIR/.mongoConfig.conf"
AIO="false"
SITE_NAME=""
PRIMARY=""
OPTION=0
GT=0
TRUE=0
FALSE=1
prog=/usr/bin/mongod
MYSTATUS="UNKNOWN"
FILE_COUNT_BEFORE_SHRINK=0
FILE_COUNT_AFTER_SHRINK=0
FILE_SIZE_BEFORE_SHRINK=0
FILE_SIZE_AFTER_SHRINK=0
SESSION_SIZE=0
NO_OF_ARUGMENTS=0
DEFAULT_OPTION_SET=0
ARGUMENTS=""
DEFAULT_OSGI_HOST="qns01"

### session cache shard related parameters
DEFAULT_SHARDS=4
DEFAULT_REBALANCE_RATE_LIMIT=1000
NO_OF_SESSION_SHARDS=0
SETNAMES=""
HOT_STANDBY=1 ## Default is non-hot standby
PREVIOUS_BUCKET_NO=0
CURRENT_BUCKET_NO=0


## SSH related setting
SSH_TIMEOUT=120
SSH_TIMEOUT_BIG=99999
SSH_SCP_USER="root"
SSHCMD="ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$SSH_TIMEOUT -n"
SCPCMD="scp -o StrictHostKeyChecking=no -o ConnectTimeout=$SSH_TIMEOUT"

trap "rm -rf \${TMP_DIR}" EXIT
trap control_c SIGINT

> $LOG_FILE

# run if user hits control-c
function control_c
{
    echo -e "\e[30;3H"
    echo -en "\n*** Exiting ***\n"
    exit $?
}


#
# Show usage of the script
#
showUsage () {
echo "Usage:"
echo
echo "sh ${SCRIPT_NAME} <Argument1> <Argument2>"
echo "    <Argument1>: --count or --remove"
echo "     --count           : Will print the number of sessions present in session_cache* db"
echo "     --remove          : Will remove the sessions from the session_cache* dbs"
echo "     --statistics-count: Will print the number of sessions types present in all session_cache* db"
echo "     --add-shard       : Will support to configure session sharding and also support the hot standby session sharding"
echo "     --add-ringset     : Will add new set to the ring"
echo "     --db-shrink       : Will shrink session_cache* dbs data files"
echo
echo "    <Argument2>: site1 or site2 or site3 ... siten"
echo "                 This argument for GR only, in GR setup user need to pass the site number(site1 or site2 ...) as second argument"
echo
echo "Example for HA setup"
echo " sh $SCRIPT_NAME --count"
echo " sh $SCRIPT_NAME --remove"
echo " sh $SCRIPT_NAME --db-shrink"
echo
echo "Example for GR setup"
echo " sh $SCRIPT_NAME --count site1"
echo " sh $SCRIPT_NAME --remove site1"
echo
}


#
# Remove the sessions from the session cache database
#
removeSession () {

echo -e "---------------------------------------------------------"
echo -e "Session Replica-set SESSION-SET${set_num}"
echo -e "---------------------------------------------------------"
echo " WARNING: Continuing will remove existing sessions in"
echo "          replica-set : SESSION-SET${set_num}"
echo " CAUTION: This result into loss of session data"
echo -en " Are you sure you want to continue (y/yes or n/no)? : "
read yn

if [[ ${yn} == "y" || ${yn} == "yes" ]]; then
  set_num=$1
#  COMMAND="db.session.remove({})"
#COMMAND="db.session.remove({\"_id.diameterSessionKey\" : {\$not :  /^pcef-client-static-1.*/}})"
if [[ ${PLATFORM} == "1" ]];then
	COMMAND="db.session.remove({\"_id.diameterSessionKey\" : {\$not :  /^${REMOVE_MB}.*/}})"
else [[ ${PLATFORM} == "2" || ${PLATFORMR} == "3" ]]
#	COMMAND="db.session.remove({\"tags\" : {\$not :  /^${REMOVE_MB}.*/}})"
	COMMAND="db.session.remove({ \$and : [{\"_id.single\" : { \$not : /^${REMOVE_MB_SNLSy}/ }}, {\"tags\" : { \$not : /${REMOVE_MB}/ }}]})"
fi
  for db_name in `cat $GET_SESSION_DB_FROM_ADMIN_DB_OUT | awk -F' ' '{print $1}'`
  do
    echo "Removing sessions from $db_name db"
    $MONGO_ADMIN ${PRIMARY}/${db_name} --eval "${COMMAND}" | grep -v "MongoDB"
    sleep 5
    echo "Remove sessions operation completed on $db_name db."
  done
elif [[ ${yn} == "n" || ${yn} == "no" ]]; then
  echo
  echo "User selected ${yn}, so skipping to remove sessions from "
  echo "replica-set SESSION-SET${set_num}"
else
  echo
  echo "Exiting script~~ Invalid option passed"
  rm -f $LOG_FILE
  exit 0
fi
echo -e "---------------------------------------------------------"
echo

}

#
# Print the number of sessions in the session cache database
#
printSessionsCount () {

set_num=$1
COMMAND="rs.slaveOk(),db.session.count()"
if [[ "$AIO" == "false" ]]; then
  echo -e "------------------------------------------------------"
  echo -e "Session Replica-set SESSION-SET${set_num}"
fi
echo -e "------------------------------------------------------"
echo -e "Session Database\e[27G: Session Count"
echo -e "------------------------------------------------------"
TOTAL_COUNT=0
for db_name in `cat $GET_SESSION_DB_FROM_ADMIN_DB_OUT | awk -F' ' '{print $1}'`
do
  COUNT=`${MONGO_READOLY} ${PRIMARY}/${db_name} --eval "${COMMAND}" | grep -v -e "^connecting" -e "^MongoDB"`
  echo -e " $db_name \e[27G: $COUNT"
  TOTAL_COUNT=`expr $TOTAL_COUNT + $COUNT`
done
echo -e "------------------------------------------------------"
echo -e " No of Sessions in SET${set_num} \e[27G: $TOTAL_COUNT"
echo -e "------------------------------------------------------"
echo
GT=$TOTAL_COUNT

}

#
# Print the number of sessions type in the session cache database
#
printSessionStatisticsCount () {

HOSTNAME=`hostname`
ADMINSETS=""

echo -e "------------------------------------------------------"
echo -en " Sessions statistic counter on"
if [[ $HOSTNAME == "lab" ]]; then
  AIO="true"
  echo -e "\e[32GAll-In-One"
  echo -e "------------------------------------------------------"
else
  echo -e "\e[32GGenaral"
  echo -e "------------------------------------------------------"
  if [[ -z $SITE_NAME ]]; then
    ADMINSETS=`awk /ADMIN-SET/,/-END/ $MONGODB_CONFIG_FILE | grep -v "^#" | grep -e "ADMIN-SET" | grep -v "END" | cut -d']' -f1 | awk -F'T' '{print $2}'`
    cat $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
  else
    ADMINSETS=`awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE | grep -v "^#" | awk /ADMIN-SET/,/-END/ | grep -e "ADMIN-SET" | grep -v "END" | cut -d']' -f1 | awk -F'T' '{print $2}'`
    awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
    if [[ `grep -e "ADMIN-SET" $TMP_MONGO_FILE | wc -l` -eq 0 ]]; then
      echo -e "\nThere is no admin db found for site $SITE_NAME"
      exit 0
    fi
  fi
fi
echo -e "\e[3GSession Type\e[24G: Session Count"
echo -e "------------------------------------------------------"
if [[ "$AIO" == "false" ]]; then
  for set_num in $ADMINSETS
  do
    echo -e "ADMIN-SET${set_num}"
    NO_ACTIVE_MEMBER=1
    for hnpt in `awk /ADMIN-SET${set_num}]/,/ADMIN-SET${set_num}-END/ $TMP_MONGO_FILE | grep -v "^#" | grep -e "^MEMBER" | cut -d'=' -f2`
    do
      host=`echo $hnpt | cut -d':' -f1`
      port=`echo $hnpt | cut -d':' -f2`
      nc -w 1 $host $port < /dev/null &> /dev/null
      if [[ $? -eq 0 ]]; then
        NO_ACTIVE_MEMBER=0
        break
      fi
    done
    if [[ $NO_ACTIVE_MEMBER -eq 0 ]]; then
      getPrimary $host $port
      printStatisticCount $PRIMARY
    fi
  done
else
  PRIMARY="localhost:27017"
  printStatisticCount $PRIMARY
fi

}

#
# Print session type and count
#
printStatisticCount () {

MONGO_PRIMARY=$1
STATISTIC_QUERY_JS="$TMP_DIR/.get_session_type.js"
STATISTIC_QUERY_OUT="$TMP_DIR/.get_session_type.out"
cat > $STATISTIC_QUERY_JS << EOF
rs.slaveOk()
use sharding
db.counters.aggregate({\$unwind : "\$session_type"},{\$group : {"_id" : "\$session_type.type" , "count" : {"\$sum" : "\$session_type.count"}}})
EOF
$MONGO_READOLY $MONGO_PRIMARY < $STATISTIC_QUERY_JS > $STATISTIC_QUERY_OUT  2>&1
if [[ `cat $STATISTIC_QUERY_OUT | grep -e "Error" | wc -l` -eq 1 ]]; then
  echo -e " Failed to connect to mongo $MONGO_PRIMARY\n"
  rm -f $STATISTIC_QUERY_JS $STATISTIC_QUERY_OUT
  exit 0
fi
if [[ `cat $STATISTIC_QUERY_OUT | grep -e "_id" | wc -l` -ne 0 ]]; then
  for sessiontypeCount in `cat $STATISTIC_QUERY_OUT | grep -e "_id" | tr '"{,}:' ' ' | awk '{print \$2,":",\$4}' | tr -d ' '`
  do
    session_type=`echo $sessiontypeCount | cut -d':' -f1 | tr '[a-z]' '[A-Z]'`
    session_count=`echo $sessiontypeCount | cut -d':' -f2`
    echo -e "\e[3G$session_type\e[24G: $session_count"
  done
else
  echo -e "\e[3G None\e[24G: 0"
fi
rm -f $STATISTIC_QUERY_JS $STATISTIC_QUERY_OUT
echo -e "------------------------------------------------------"

}

#
# Get the primary member from the replica-set
#
getPrimary () {

HOST=$1
PORT=$2

cat > $MONGO_QUERY << EOF
rs.isMaster()
EOF

$MONGO_NOAUTH ${HOST}:${PORT} < $MONGO_QUERY > $MONGO_QUERY_OUT 2>&1

if [[ -e $MONGO_QUERY_OUT ]]; then
  if [[ `cat $MONGO_QUERY_OUT | grep "Error" | wc -l` -ne 0 ]]; then
    log_err "Error while connecting to the mongo server"
    log_delete_file $MONGO_QUERY_OUT
    rm -f $MONGO_QUERY
    return 1
  else
    PRIMARY=`grep -e "primary" $MONGO_QUERY_OUT | awk -F' ' '{print $3}' | cut -d'"' -f2`
    PRIMARY_HOST=`echo $PRIMARY | cut -d':' -f1`
    PRIMARY_PORT=`echo $PRIMARY | cut -d':' -f2`
  fi
else
  log_err "Problem while connecting to the mongo server"
  log_delete_file $MONGO_QUERY_OUT
  rm -f $MONGO_QUERY
  return 1
fi

log "Status of the replica set database."
log_delete_file $MONGO_QUERY_OUT
if [[ ! -z $PRIMARY_HOST ]]; then
  log "Got the primary node from the mongo database (Primary - $PRIMARY)."
else
  rm -f $MONGO_QUERY
  return 1
fi
rm -f $MONGO_QUERY

}

#
#  Find the session cache database in replica-sets and trigger the print sessions count
#
findSessionDbPrintSessionCountAndRemove () {

cat > $GET_SESSION_DB_FROM_ADMIN_DB_JSON << EOF
show dbs
EOF

cat > $JSON_QUERY << EOF
rs.status()
EOF

> $GET_SESSION_DB_FROM_ADMIN_DB_OUT

if [[ "$AIO" == "true" ]]; then
  SETS=0
else
if [[ -z $SITE_NAME ]]; then
  SETS=`awk /SESSION-SET/,/-END/ $MONGODB_CONFIG_FILE | grep -v "^#" | grep -e "SESSION-SET" | grep -v "END" | cut -d']' -f1 | awk -F'T' '{print $2}'`
  cat $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
else
  SETS=`awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE | grep -v "^#" | awk /SESSION-SET/,/-END/ | grep -e "SESSION-SET" | grep -v "END" | cut -d']' -f1 | awk -F'T' '{print $2}'`
  awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
  if [[ `grep -e "SESSION-SET" $TMP_MONGO_FILE | wc -l` -eq 0 ]]; then
    echo -e "\nThere is no session db found for site $SITE_NAME"
    exit 0
  fi
fi
fi
for set_num in $SETS
do
  if [[ $set_num -ne 0 ]]; then
    for hnpt in `awk /SESSION-SET${set_num}]/,/SESSION-SET${set_num}-END/ $TMP_MONGO_FILE | grep -v "^#" | grep -e "^MEMBER" | cut -d'=' -f2`
    do
      NO_ACTIVE_MEMBER=1
      host=`echo $hnpt | cut -d':' -f1`
      port=`echo $hnpt | cut -d':' -f2`
      nc -w 1 $host $port < /dev/null &> /dev/null
      if [[ $? -eq 0 ]]; then
        $MONGO_READOLY $host:$port < $JSON_QUERY > $JSON_OUT 2>&1
        if [[ `cat $JSON_OUT | grep -e '"_id" :' | wc -l` -gt 1 ]]; then
          NO_ACTIVE_MEMBER=0
          break
        fi
      fi
    done
  else
    PRIMARY="localhost:27017"
  fi
  if [[ $NO_ACTIVE_MEMBER -eq 0 ]]; then
    if [[ $set_num -ne 0 ]]; then
      getPrimary $host $port
    fi
    if [[ ! -z $PRIMARY ]]; then
      $MONGO_READOLY $PRIMARY < $GET_SESSION_DB_FROM_ADMIN_DB_JSON  | grep -v "empty" | grep "session_cache" > $GET_SESSION_DB_FROM_ADMIN_DB_OUT  2>&1
      if [[ `cat $GET_SESSION_DB_FROM_ADMIN_DB_OUT | grep -e "Error" | wc -l` -eq 1 ]]; then
        log_err "Failed to connect replica-set member on current setup, due to problem while connecting to the server"
        log_delete_file $GET_SESSION_DB_FROM_ADMIN_DB_OUT
      fi
      if [[ `cat $GET_SESSION_DB_FROM_ADMIN_DB_OUT | grep "session_cache" | wc -l` -ne 0 ]]; then
        if [[ $OPTION -eq 1 ]]; then
          printSessionsCount $set_num
          PRINT_GT=1
          GRAND_TOTAL=`expr $GRAND_TOTAL + $GT`
          GT=0
        elif [[ $OPTION -eq 3 ]]; then
          removeSession $set_num $PLATFORM
        elif [[ $OPTION -eq 2 ]]; then
          removeSession $set_num $REMOVE_MB
        fi
	else
        echo -e "\nThere is no session db found for site $SITE_NAME"
      fi
    else
      log_tee "Could not able to find the primary node from SESSION-SET${set_num} replica-set."
    fi
  fi
done

if [[ $PRINT_GT -eq 1 ]]; then
  echo -e "Total Number of Sessions\e[27G: $GRAND_TOTAL"
  echo
fi

rm -f $GET_SESSION_DB_FROM_ADMIN_DB_JSON $GET_SESSION_DB_FROM_ADMIN_DB_OUT


}

#
#  This run repairDatabase() on all replica-members
#
dbShrinkSessionCache () {


echo -e "---------------------------------------------------------"
echo -e "Session DB Shrink Replica-set"
echo -e "---------------------------------------------------------"
echo " CAUTION: This option must performed in maintenance window and no session data"
echo -en " Are you sure you want to continue (y/yes or n/no)? : "
read yn

if [[ ${yn} == "y" || ${yn} == "yes" ]]; then
  log "User selected ${yn}, so continuing to shrink DB file for session DB"
elif [[ ${yn} == "n" || ${yn} == "no" ]]; then
  echo "User selected ${yn}, so skipping to shrink DB file for session DB"
  exit 0
else
  echo
  echo "Exiting script~~ Invalid option passed"
  exit 0
fi

echo -e "Verify log $LOG_FILE"
echo

if [[ "$AIO" == "true" ]]; then
  SETS=0
else
if [[ -z $SITE_NAME ]]; then
  SETS=`awk /SESSION-SET/,/-END/ $MONGODB_CONFIG_FILE | grep -v "^#" | grep -e "SESSION-SET" | grep -v "END" | cut -d']' -f1 | awk -F'T' '{print $2}'`
  cat $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
else
  SETS=`awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE | grep -v "^#" | awk /SESSION-SET/,/-END/ | grep -e "SESSION-SET" | grep -v "END" | cut -d']' -f1 | awk -F'T' '{print $2}'`
  awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
  if [[ `grep -e "SESSION-SET" $TMP_MONGO_FILE | wc -l` -eq 0 ]]; then
    echo -e "\nThere is no session db found for site $SITE_NAME"
    exit 0
  fi
fi
fi

for set_num in $SETS
do
  if [[ $set_num -ne 0 ]]; then
          log "******* STARTING DB SHRINK FOR SET - SESSION-SET${set_num} **********"
          repairDatabase $set_num
          ret_val=$?
          if [ $ret_val -eq 0 ]; then
             log_tee "DB Shrink operation completed successfully for set - SESSION-SET${set_num}"
             log_tee "   DB File count before Shrink: $FILE_COUNT_BEFORE_SHRINK"
             log_tee "   DB File count after  Shrink: $FILE_COUNT_AFTER_SHRINK"
             log_tee "   DB Size before Shrink: $FILE_SIZE_BEFORE_SHRINK"
             log_tee "   DB Size after  Shrink: $FILE_SIZE_AFTER_SHRINK"
             log "******* DB SHRINK COMPLETED SUCCESSFULLY FOR SET - SESSION-SET${set_num} **********"
          else
             log_err "DB Shrink operation failed for set - SESSION-SET${set_num}"
             log "******* DB SHRINK FAILED FOR SET - SESSION-SET${set_num} **********"
          fi
  else
          log_err “Error - DB Shrink is not supported for standalone mongo”
          exit 1
  fi
done

}

repairDatabase () {

set_num=$1

ARBITER_HOST_PORT=`awk /SESSION-SET${set_num}]/,/SESSION-SET${set_num}-END/ $TMP_MONGO_FILE | grep -v "^#" | grep -e "^ARBITER[^_]*=" | cut -d'=' -f2`

  if [[ ! -z $ARBITER_HOST_PORT ]]; then
     log "Arbiter found for SESSION-SET${set_num} on $arbHost for port $arbPort"
  else
     log_err "Error: Arbiter host not defined in mongoConfig.cfg for SESSION-SET${set_num}"
     return 1
  fi

    for hnpt in `awk /SESSION-SET${set_num}]/,/SESSION-SET${set_num}-END/ $TMP_MONGO_FILE | grep -v "^#" | grep -e "^MEMBER" | cut -d'=' -f2`
    do
      for arbiter in $ARBITER_HOST_PORT
      do
        if [[ ! -z $arbiter ]]; then
           arbHost=`echo $arbiter | cut -d':' -f1`
           arbPort=`echo $arbiter | cut -d':' -f2`
           log "Arbiter found for SESSION-SET${set_num} on $arbHost for port $arbPort"
        else
          log_err "Error: Arbiter host not defined in mongoConfig.cfg for SESSION-SET${set_num}"
          return 1
        fi
        isPrimaryAvailable $arbHost $arbPort
        ret_val=$?
        tries=12
        while [ $tries -gt 0 ]; do
          if [[ $ret_val -eq 0 ]]; then
                log "Found primary " $arbHost $arbPort
             break
          else
             log "Error: No Primary member found for set SESSION-SET${set_num}"
             log "Waiting for member to come online as primary for set SESSION-SET${set_num}.. [tries left $tries]"
          fi
          sleep 5
          isPrimaryAvailable $arbHost $arbPort
          ret_val=$?
          tries=`expr $tries - 1`
        done
        if [[ $ret_val -ne 0 ]]; then
           log_err "Error: No Primary member found for set SESSION-SET${set_num}"
           log_err "Error: Trying other Arbiter $arbHost $arbPort"
        else
            #    log "Found primary " $arbHost $arbPort
           break
        fi
      done
      if [[ $ret_val -ne 0 ]]; then
         log_err "Error: No Primary member found for set SESSION-SET${set_num}"
         return 1
      fi
      host=`echo $hnpt | cut -d':' -f1`
      port=`echo $hnpt | cut -d':' -f2`
      data_path=`awk /SESSION-SET${set_num}]/,/SESSION-SET${set_num}-END/ $TMP_MONGO_FILE | grep -v "^#" | grep "^DATA_PATH"  | cut -d'=' -f2`
      dbsize $host $data_path
      if [[ ! -z $SESSION_SIZE ]]; then
        FILE_SIZE_BEFORE_SHRINK=$SESSION_SIZE
       else
        FILE_SIZE_BEFORE_SHRINK=0
      fi
      log "Session DB size on $host for port $port before shrink: $FILE_SIZE_BEFORE_SHRINK"
      log "Session DB shuting down on $host for port $port"
      $SSHCMD root@${host} "/etc/init.d/sessionmgr-${port} stop" &>> $LOG_FILE
      RETVAL=$?
      tries=3
      PID_COUNT=`$SSHCMD root@${host} "ps -ef | grep $prog | grep $port | grep -v grep | wc -l"` &> /dev/null
      while [ $tries -gt 0 ]; do
        if [[ $PID_COUNT -eq 0 ]]; then
           break
        else
           PID_COUNT=`$SSHCMD root@${host} "ps -ef | grep $prog | grep $port | grep -v grep | wc -l"` &> /dev/null
        fi
        sleep 1
        tries=`expr $tries - 1`
      done
      if [ $RETVAL -eq 0 ] && [ $PID_COUNT -eq 0 ]; then
        log "Session DB shutdown completed successfully on $host for port $port"
      else
        log_err "Error: Unable to Shutdown DB on $host for port $port"
        return 1
      fi
      for arbiter in $ARBITER_HOST_PORT
      do

        if [[ ! -z $arbiter ]]; then
           arbHost=`echo $arbiter | cut -d':' -f1`
           arbPort=`echo $arbiter | cut -d':' -f2`
           log "Arbiter found for SESSION-SET${set_num} on $arbHost for port $arbPort"
        else
          log_err "Error: Arbiter host not defined in mongoConfig.cfg for SESSION-SET${set_num}"
          return 1
        fi
        tries=10
        while [ $tries -gt 0 ]; do
          isPrimaryAvailable $arbHost $arbPort
          ret_val=$?
          if [[ $ret_val -eq 0 ]]; then
             log "Found primary  $arbHost $arbPort"
             break
          else
             log "Error: No Primary member found for set SESSION-SET${set_num}"
             log "Waiting for member to come online as primary for set SESSION-SET${set_num}.. [tries left $tries]"
          fi
          sleep 6
          tries=`expr $tries - 1`
        done
        if [[ $ret_val -ne 0 ]]; then
           log_err "Error: No Primary member found for set SESSION-SET${set_num}"
           log_err "Retrying different arbiter $arbHost $arbPort"
        else
           #log "Found primary  $arbHost $arbPort"
           break
        fi
      done
      if [[ $ret_val -ne 0 ]]; then
         log_err "Error: No Primary member found for set SESSION-SET${set_num}"
         return 1
      fi
      resync $host $port $data_path
      retval=$?
      if [ $retval -eq 0 ]; then
        log "resync completed successfully on $host for port $port"
       else
        log_err "Error: resync not completed successfully on $host for port $port"
        return 1
      fi
      dbsize $host $data_path
      if [[ ! -z $SESSION_SIZE ]]; then
        FILE_SIZE_AFTER_SHRINK=$SESSION_SIZE
       else
        FILE_SIZE_AFTER_SHRINK=0
      fi
      log "Session DB size on $host for port $port after shrink: $FILE_SIZE_AFTER_SHRINK"
    done

return 0

}

dbsize () {

host=$1
data_path=$2

   SESSION_SIZE=`$SSHCMD root@${host} find $data_path -type f -name "session_cache*.*" -exec du -ch {} + | grep total | awk  '{ print $1 }'` &> /dev/null

}

getMyStatus() {

host=$1
port=$2
TMP_LOG=/tmp/getMyStatus
returnStatus=1

> $TMP_LOG

cat > $JSON_QUERY << EOF
rs.status()
EOF

        $MONGO_READOLY $host:$port < $JSON_QUERY > $JSON_OUT 2>&1
        cat $JSON_OUT | grep -e name -e stateStr | cut -d':' -f2 | cut -d'"' -f2 | sed 'N;s/\n/:/' &>> $TMP_LOG
        if [ $? -eq 0 ]; then
              MYHOST=`grep $host $TMP_LOG | cut -d':' -f1`
              if [ "$MYHOST" == "$host" ]; then
                myStatus=`grep $host $TMP_LOG | cut -d':' -f2`
                log "Current member $host:$port Status : $myStatus"
                MYSTATUS=$myStatus
                returnStatus=0
              fi
         else
            MYSTATUS=`echo $hostStatus | cut -d':' -f2`
            log_err "Error while connecting to mongo on host:$host and port:$port"
            returnStatus=1
        fi
return $returnStatus
}


resync () {

host=$1
port=$2
data_path=$3

      log "Session DB file on $host for port $port before shrink"
      $SSHCMD root@${host} "ls -ltrh $data_path/session_cache*" &>> $LOG_FILE
      FILE_COUNT_BEFORE_SHRINK=`$SSHCMD root@${host} find $data_path -name "session_cache*.*" | wc -l` &> /dev/null
      log "Total No. of session cache DB file before shrink: $FILE_COUNT_BEFORE_SHRINK"
      $SSHCMD root@${host} "rm -rf $data_path/session_cache*" &>> $LOG_FILE

      log "Local DB file on $host for port $port before shrink"
      $SSHCMD root@${host} "ls -ltrh $data_path/local*" &>> $LOG_FILE
      $SSHCMD root@${host} "rm -rf $data_path/local*" &>> $LOG_FILE

      log "Session DB staring on $host for port $port"
      $SSHCMD root@${host} "/etc/init.d/sessionmgr-${port} start" &>> $LOG_FILE
      RETVAL=$?
      PID_COUNT=`$SSHCMD root@${host} "ps -ef | grep $prog | grep $port | grep -v grep | wc -l"` &> /dev/null
      if [ $RETVAL -eq 0 ] && [ $PID_COUNT -eq 1 ]; then
        log "Session DB started successfully on $host for port $port"
      else
        log_err "Error: Unable to start DB on $host for port $port"
        return 1
      fi

   tries=60
   MYSTATUS="UNKNOWN"
   getMyStatus $host $port
   while [ $tries -gt 0 ]; do
        if [ "$MYSTATUS" == "PRIMARY" ] || [ "$MYSTATUS" == "SECONDARY" ]; then
           returnStatus=0
           break
        else
          getMyStatus $host $port
        fi
        log "Retrying on $host for port $port for resync..tries left [$tries]"
        sleep 6
        tries=`expr $tries - 1`
   done

      log "Session DB file on $host for port $port after shrink"
      $SSHCMD root@${host} "ls -ltrh $data_path/session_cache*" &>> $LOG_FILE

      log "Local DB file on $host for port $port after shrink"
      $SSHCMD root@${host} "ls -ltrh $data_path/local*" &>> $LOG_FILE

        if [[  "$MYSTATUS" == "PRIMARY"  ||  "$MYSTATUS" == "SECONDARY"  ]] ; then
            returnStatus=0
            FILE_COUNT_AFTER_SHRINK=`$SSHCMD root@${host} find $data_path -name "session_cache*.*" | wc -l` &> /dev/null
            log "Total No. of session cache DB file replicated from primary: $FILE_COUNT_AFTER_SHRINK"
        else
            returnStatus=1
        fi

return $returnStatus

}

isPrimaryAvailable () {

arbHost=$1
arbPort=$2
NO_ACTIVE_MEMBER=1

cat > $GET_SESSION_DB_FROM_ADMIN_DB_JSON << EOF
show dbs
EOF

cat > $JSON_QUERY << EOF
rs.status()
EOF

      nc -w 1 $arbHost $arbPort < /dev/null &> /dev/null
      if [[ $? -eq 0 ]]; then
        $SSHCMD root@${arbHost} "$MONGO_NOAUTH --port $arbPort --eval 'rs.status()'" > $JSON_OUT 2>&1
        if [[ `cat $JSON_OUT | grep -e '"_id" :' | wc -l` -lt 3 ]]; then
          log "Error - There are not enough replica set members found"
          log_delete_file $JSON_OUT
          return 1
        fi
      else
          log "Error - Arbiter Host not reachable for replica set SESSION-SET${set_num}"
          log_delete_file $JSON_OUT
          return 1
      fi

        getPrimary $arbHost $arbPort

   if [[ ! -z $PRIMARY ]]; then
      $MONGO_READOLY $PRIMARY < $GET_SESSION_DB_FROM_ADMIN_DB_JSON  | grep -v "empty" | grep "session_cache" > $GET_SESSION_DB_FROM_ADMIN_DB_OUT  2>&1
      if [[ `cat $GET_SESSION_DB_FROM_ADMIN_DB_OUT | grep -e "Error" | wc -l` -eq 1 ]]; then
        log "Failed to connect replica-set member on current setup, due to problem while connecting to the server"
        log_delete_file $GET_SESSION_DB_FROM_ADMIN_DB_OUT
        return 1
      fi
      if [[ `cat $GET_SESSION_DB_FROM_ADMIN_DB_OUT | grep "session_cache" | wc -l` -ne 0 ]]; then
        log "Session DB found on $PRIMARY for SESSION-SET${set_num}"
        log_delete_file $GET_SESSION_DB_FROM_ADMIN_DB_OUT
      else
        log "Error - there is no session db found on $PRIMARY for SESSION-SET${set_num}"
        return 1
      fi
    else
      log "Error - not able to find the primary node from SESSION-SET${set_num} replica-set."
      return 1
    fi

return 0

}

#
#  Adding shards to the session replica-set
#
addShard () {

echo "===============`date`================" > $LOG_FILE

if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
 clear
 echo -e "\e#6\e[12G Session Sharding"
 echo -e "--------------------------------------------------------"
 echo -e "\e[3;3H"
 echo -e "Select type of session shard \e[29G  Default      [ ] \n\e[29G  Hot Standby  [ ]"
 echo -e "\nSessionmgr pairs : "
 echo -e "\nSession shards per pair : "
 echo -e "\e[20;H--------------------------------------------------------"
 echo -e "Note : \n- Press 'y' to select the shard type\n- If sharding needed for multiple sessionmgr vms with port\n  please provide sessionmge vm with port separated by ':',\n  and pair separated by ','\n(Ex: sessionmgr01:sessionmgr02:27717,sessionmgr03:sessionmgr04:27717)"
 select=n
 HOT_STANDBY=1
 while [[ "$select" != "y" ]];
 do
  echo -en "\e[4;45H"
  read -n 1 select
  if [[ "$select" == "y" ]]; then
    echo -en "\e[4;45H*"
    HOT_STANDBY=1
    break
  else
    echo -en "\e[4;45H ]           "
  fi
  echo -en "\e[5;45H"
  read -n 1 select
  if [[ "$select" == "y" ]]; then
    echo -en "\e[5;45H*"
    HOT_STANDBY=0
    break
  else
    echo -en "\e[5;45H ]           "
  fi
 done
    getAndValidateSessionPair $setnames
    retCode=$?
    if [[ $retCode -eq 0 ]]; then
       log "Session Pair Validation Completed Successfully"
    else
       log "Error: Invalid seeds or port passed for pair: $setnames"
       exit 1
    fi
    getShardCount
    createShards
    if [[ $retCode -eq 0 ]]; then
       log "Session shard creation completed successfully"
       exit $retCode
    else
       log "Error: Session pair validation failed: $setnames"
       exit $retCode
    fi
elif [[ $DEFAULT_OPTION_SET -eq 1 ]]; then
    echo -e " The progress of this script can be monitored in the following log:\n$LOG_FILE"
    log "Add shard arguments passed: $ARGUMENTS"
    for arg in $ARGUMENTS
    do
      if [[ $arg =~ ^[A-Za-z0-9:,]*$ ]]; then
        setnames=$arg
        log "session pair set name passed: $setnames"
        break
      fi
    done
    if [[ -z $setnames ]]; then
       log_err "Error: Session pair seeds and ports not passed"
       exit 1
    fi
    getAndValidateSessionPair $setnames
    retCode=$?
    if [[ $retCode -eq 0 ]]; then
       log "Session Pair Validation Completed Successfully"
    else
       log_err "Error: Session pair validation failed: $setnames"
       exit 1
    fi
    getShardCount
    createShards
    retCode=$?
    if [[ $retCode -eq 0 ]]; then
       log_tee "Session shard creation completed successfully"
       exit $retCode
    else
       log_err "Error: Session shard creation failed"
       exit $retCode
    fi
fi

}

getAndValidateSessionPair ()
{

TEST_QUERY_JS="$TMP_DIR/.test_replica.js"
TEST_QUERY_OUT1="$TMP_DIR/.test_replica1.out"
TEST_QUERY_OUT2="$TMP_DIR/.test_replica2.out"

setnames=$1
SETNAMES=""
SETID=""
cat > $TEST_QUERY_JS << EOF
rs.isMaster().hosts
EOF

# Copying replica-set information to temporary file, in multi cluster environment copying site specific replica-set to temporary file
if [[ -z $SITE_NAME ]]; then
  cat $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
else
  awk /${SITE_NAME}_START/,/${SITE_NAME}_END/ $MONGODB_CONFIG_FILE > $TMP_MONGO_FILE
fi

while [[ -z $SETNAMES ]];
do
  if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
    echo -en "\e[7;20H"
    read setnames
  fi
  if [[ $setnames =~ ^[A-Za-z0-9:,]*$ ]]; then
    for sessionPair in `echo $setnames | tr ',' ' '`
    do
      seed1=`echo $sessionPair | cut -d':' -f1`
      seed2=`echo $sessionPair | cut -d':' -f2`
      port=`echo $sessionPair | cut -d':' -f3`
      seed1_alias=`cat /etc/hosts | grep -w "$seed1"`
      seed2_alias=`cat /etc/hosts | grep -w "$seed2"`
      session_db_ids=`cat $TMP_MONGO_FILE | grep SESSION-SET | grep -v END| cut -d'-' -f2 | tr ']' ' ' | cut -d'T' -f2`
      session_db_members=""
      for ids in $session_db_ids
      do
        pair=`cat $TMP_MONGO_FILE | awk /SESSION-SET$ids]/,/SESSION-SET${ids}-END]/ | grep "^MEMBER" | cut -d'=' -f2 | cut -d':' -f1 | tr '\n' ':' | sed '$s/:$//'`
        pair_port=`cat $TMP_MONGO_FILE | awk /SESSION-SET$ids]/,/SESSION-SET${ids}-END]/ | grep "^MEMBER" | cut -d'=' -f2 | cut -d':' -f2 | sort | uniq`
        session_db_members="$session_db_members $pair:$pair_port"
      done
      PORT_FOUND=1
      SEED1_FOUND=1
      SEED2_FOUND=1
      for pairsOfDb in $session_db_members
      do
         str1=`echo $pairsOfDb | cut -d':' -f1`
         str2=`echo $pairsOfDb | cut -d':' -f2`
         Lt=`echo $pairsOfDb | tr ':' ' ' | wc -w`
         str3=`echo $pairsOfDb | cut -d':' -f${Lt}`
         if [[ $port == $str3 ]]; then
           PORT_FOUND=0
           if [[ `echo $seed1_alias | grep -w $str1 | wc -l` -ne 0 || `echo $seed2_alias | grep -w $str1 | wc -l` -ne 0 ]]; then
             SEED1_FOUND=0
           fi
           if [[ `echo $seed1_alias | grep -w $str2 | wc -l` -ne 0 || `echo $seed2_alias | grep -w $str2 | wc -l` -ne 0 ]]; then
             SEED2_FOUND=0
           fi
         fi

         if [[ $PORT_FOUND -eq 0 && $SEED1_FOUND -eq 0 && $SEED2_FOUND -eq 0 ]]; then
            log "Session pair [$seed1,$seed2:$port] found in $MONGODB_CONFIG_FILE and /etc/hosts"
            break
         fi
      done
      if [[ `cat /etc/hosts | grep -w $seed1 | wc -l` -ne 0  && `cat /etc/hosts | grep -w $seed2 | wc -l` -ne 0 && $port  =~ ^-?[0-9]+$ ]]; then
        $MONGO_READOLY --host $seed1 --port $port < $TEST_QUERY_JS > $TEST_QUERY_OUT1 2>&1
        $MONGO_READOLY --host $seed2 --port $port < $TEST_QUERY_JS > $TEST_QUERY_OUT2 2>&1
        if [[ `cat $TEST_QUERY_OUT1 | grep -v -e "Mongo" -e "bye" -e "connect" | tr -d '[]" ' | grep $str2 | wc -l` -ne 0 && `cat $TEST_QUERY_OUT2 | grep -v -e "Mongo" -e "bye" -e "connect" | tr -d '[]" ' | grep $str1 | wc -l` -ne 0 ]] ;then
          SETNAMES="$SETNAMES $sessionPair"
          echo -e "\e[19;15H                                           "
        else
          SETNAMES=""
          if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
            echo -en "\e[7;20H                                                                         "
            echo -e "\e[19;15H Invalid sessionmgr pair"
           else
             log_err "Error: Invalid sessionmgr pair for seeds:$seed1,$seed2 and port:$port"
             return 1
           fi
        fi
      else
        SETNAMES=""
        if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
          echo -en "\e[7;20H                                                                         "
          echo -e "\e[19;15H Invalid sessionmgr pair"
        else
          log_err "Error: Invalid sessionmgr pair for seeds:$seed1,$seed2 and port:$port"
          return 1
        fi
      fi
      if [[ $PORT_FOUND -eq 1 || $SEED1_FOUND -eq 1 || $SEED2_FOUND -eq 1 ]]; then
        SETNAMES=""
        if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
          echo -en "\e[7;20H                                                                         "
          echo -e "\e[19;15H Invalid sessionmgr pair"
        else
          log_err "Error: Invalid sessionmgr pair for seeds:$seed1,$seed2 and port:$port"
          return 1
        fi
      fi
    done
  else
    SETNAMES=""
    if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
      echo -en "\e[7;20H                                                                         "
      echo -e "\e[19;15H Invalid sessionmgr pair"
    else
      log_err "Error: Invalid sessionmgr pair for seeds:$seed1,$seed2 and port:$port"
      exit 1
    fi
  fi
done

rm -f $TEST_QUERY_JS $TEST_QUERY_OUT1 $TEST_QUERY_OUT2

}

getShardCount ()
{

if [[ $DEFAULT_OPTION_SET -eq 1 ]]; then
  NO_OF_SESSION_SHARDS=$DEFAULT_SHARDS
  log "Setting number of Shards: $NO_OF_SESSION_SHARDS"
elif [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
  count=n
  while [[ $count != ^-?[0-9]+$ ]];
  do
    echo -en "\e[9;27H"
    read count
    if [[ $count =~ ^-?[0-9]+$ ]];then
      NO_OF_SESSION_SHARDS=$count
      log "Setting number of Shards: $NO_OF_SESSION_SHARDS"
      break
      echo -e "\e[19;15H                                    "
    else
      echo -en "\e[9;27H                                                                         "
    fi
     echo -e "\e[19;15H Invalid entry not an integer"
     exit 1
  done
fi

}

createShards() {

CREATE_SHADS_QUERY="$TMP_DIR/.create_session_shard"
CREATE_SHADS_OUT="$TMP_DIR/.create_session_shard.out"
> $CREATE_SHADS_QUERY
> $CREATE_SHADS_OUT
retCode=1

if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
  echo -e "\e[11;HCreating Session sharding [ In Progress ]"
else
  log_tee "Creating Session sharding [ In Progress ]"
fi

# Geo HA enabled
# Below shard commands when Geo HA enabled (i.e. with SiteId)
# addshard <Seed1>[,<Seed2>] <Port> <Index> <SiteId> <BackupDb>
# rebalancebg <SiteId> <time>
# rebalancestatus <SiteId>
#
# Below shard commands when Geo HA disabled (i.e without SiteId) 
# addshard <Seed1>[,<Seed2>] <Port> <Index> <BackupDb>
# rebalancebg <time>
# rebalancestatus
#
# SiteIds which need to be rebalance
declare -A siteIdArr

## Preparing Statements ##
for sessPair in $SETNAMES
do
  seed1=`echo $sessPair | cut -d':' -f1`
  seed2=`echo $sessPair | cut -d':' -f2`
  port=`echo $sessPair | cut -d':' -f3`
  siteId=`echo $sessPair | cut -d':' -f4`

  for (( i=1; i <= $NO_OF_SESSION_SHARDS; i++ ))
  do
     if [[ $HOT_STANDBY -eq 0 ]]; then
       echo "addshard $seed1,$seed2 $port $i $siteId backup" >> $CREATE_SHADS_QUERY
     else
       echo "addshard $seed1,$seed2 $port $i $siteId" >> $CREATE_SHADS_QUERY
     fi
     if [[ $siteId != "" ]] ; then
       # siteId which need to be rebalance
       siteIdArr[${siteId}]=""
     fi
  done
  echo
done
if [[ ${#siteIdArr[@]} -eq 0 ]]; then
    # Geo HA is not enabled 
    echo "rebalancebg $DEFAULT_REBALANCE_RATE_LIMIT" >> $CREATE_SHADS_QUERY
else
  for siteId in ${!siteIdArr[@]}; do
    # Geo HA is enabled, so pass siteId
    echo "rebalancebg ${siteId} $DEFAULT_REBALANCE_RATE_LIMIT" >> $CREATE_SHADS_QUERY
  done
fi
## Statements prepared ##

log "Verifying Qnses are up"
IS_QNS_UP=`/var/qps/bin/diag/diagnostics.sh --qns_diagnostics | grep -e "Retrieving" -e "qns" | grep -e FAIL | wc -l`

if [[ $IS_QNS_UP -ne 0 ]]; then
  if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
     echo -e "\e[11;HCreating Session sharding [ Fail ]          "
     echo -e "\e[28;H\nERROR: QNS process are not up\n"
  else
     log_err "Creating Session sharding [ Fail ]"
     log_err "ERROR: QNS process are not up"
  fi
  return $retCode
fi

cat $CREATE_SHADS_QUERY | while read cmd
do
  log "Executing $cmd"
  if [[ $cmd == *"rebalancebg"* ]]; then
    sleep 10
  fi
  echo -e "\n\n$cmd\n" >> $CREATE_SHADS_OUT

  # Retry commands if they OSGI returns "Unable to connect"
  LOOP=0;
  while (( LOOP < 10 ));
  do
     SHAD_TEMP_OUT=`printf "$cmd \ndisconnect\nyes\n" | nc ${DEFAULT_OSGI_HOST} 9091`
     #echo $SHAD_TEMP_OUT
     if [[ `echo $SHAD_TEMP_OUT | grep -e help -e "Unable to" | wc -l` -ne 0 ]]; then
         ((LOOP++))
         echo "Retry $LOOP of 10" >> $CREATE_SHADS_OUT
         sleep 5
     else
         break
     fi
  done
  # output the last response
  echo $SHAD_TEMP_OUT >> $CREATE_SHADS_OUT
done

if [[ -s $CREATE_SHADS_OUT ]]; then
  if [[ `cat $CREATE_SHADS_OUT | grep -e help -e "Unable to" | wc -l` -ne 0 ]]; then
    if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
     echo -e "\e[11;HCreating Session sharding [ Fail ]          "
     echo -e "\e[28;H\nERROR: While creating shard either servers are not up or unable to obtain lock\n"
    else
     log_err "Creating Session sharding [ Fail ]          "
     log_err "ERROR: While creating shard either servers are not up or unable to obtain lock"
    fi
    retCode=1
  elif [[ `cat $CREATE_SHADS_OUT | grep -e "MongoTimeoutException" | wc -l` -ne 0 ]]; then
    if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
     echo -e "\e[11;HCreating Session sharding [ Fail ]          "
     echo -e "\e[28;H\nERROR: While creating shard, servers are not up or not accessible.\n"
    else
     log_err "Creating Session sharding [ Fail ]          "
     log_err "ERROR: While creating shard, servers are not up or not accessible."
    fi
    retCode=1
  elif [[ `cat $CREATE_SHADS_OUT | grep -e "Shard already exists" | wc -l` -gt 1 ]]; then
    if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
      verifyAllRebalanceStatus
      if [[ $? -eq 0 ]]; then
        echo -e "\e[11;HCreating Session sharding [ Done ]          "
        echo -e "\e[28;H\nShard already exists, Executed rebalance and migrated the setup\n"
        retCode=0
      else
        echo -e "\e[11;HCreating Session sharding [ Fail ]          "
        echo -e "\e[28;H\nERROR: While rebalancing shards, not completed successfully\n"
        retCode=1
     fi
    else
      verifyAllRebalanceStatus
      if [[ $? -eq 0 ]]; then
        log "Creating Session sharding [ Done ]          "
        log "Shard already exists, Executed rebalance and migrated the setup"
        retCode=0
      else
        log "Creating Session sharding [ Fail ]          "
        log_err "ERROR: While rebalancing shards, not completed successfully"
        retCode=1
      fi
  fi
  else
    verifyAllRebalanceStatus
    if [[ $? -eq 0 ]]; then
      if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
       echo -e "\e[11;HCreating Session sharding [ Done ]          "
      else
       log_tee "Creating Session sharding [ Done ]          "
      fi
       retCode=0
    else
      if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
       echo -e "\e[11;HCreating Session sharding [ Fail ]          "
      else
       log_err "Creating Session sharding [ Fail ]          "
      fi
      retCode=1
    fi
  fi
else
  if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
    echo -e "\e[11;HCreating Session sharding [ Fail ]          "
    echo -e "\e[28;H\nERROR: QNS process are not up\n"
    echo -e "\e[30;H"
   else
    log_err "Creating Session sharding [ Fail ]          "
    log_err "ERROR: QNS process are not up"
  fi
  retCode=1
fi

cat $CREATE_SHADS_OUT >> $LOG_FILE
echo "  " >> $LOG_FILE
rm -f $CREATE_SHADS_QUERY $CREATE_SHADS_OUT
return $retCode

}

# Verify rebalance status
verifyAllRebalanceStatus() {
  if [[ ${#siteIdArr[@]} -eq 0 ]]; then
      # Geo HA is not enabled, so call verifyRebalanceStatus without siteId
      verifyRebalanceStatus
  else
    # Geo HA is enabled, so call verifyRebalanceStatus with siteId
    for siteId in ${!siteIdArr[@]}; do
      verifyRebalanceStatus $siteId
    done
  fi
}

verifyRebalanceStatus () {

  siteId=$1
  REBALANCE_STATUS_COMMAND_OUT="$TMP_DIR/.rebalanceStatus.out"
  max_bucket_retries=5

  while true
  do
    log "Executing OSGI Command> rebalancestatus $siteId"
    commandResult=$(echo "rebalancestatus $siteId" | nc ${DEFAULT_OSGI_HOST} 9091 > $REBALANCE_STATUS_COMMAND_OUT)
    sed -i -e "s|osgi>||g" $REBALANCE_STATUS_COMMAND_OUT
    commandResult=$(cat $REBALANCE_STATUS_COMMAND_OUT | xargs | tr -d '\r') # remove cariage return

    log "CommandResult in file $REBALANCE_STATUS_COMMAND_OUT - $commandResult"
    case "$commandResult" in
      "Rebalanced")
        log "Rebalance completed successfully"
        break
      ;;
      "Rebalance is required")
        log "Rebalance is required - retry [retries left: $max_bucket_retries]"
      ;;
      "SiteId must not be empty!")
        log "Site ID for the GR not configured/provided"
        return 1
      ;;
      *)
        if [[ $commandResult == *"Rebalance is running"* ]]; then
          CURRENT_BUCKET_NO=`echo $commandResult | awk -F ":" '{ print $2 }' | cut -d')' -f1`
          if [[ $CURRENT_BUCKET_NO -ne $PREVIOUS_BUCKET_NO ]]; then
              log "Rebalacing sharding is running [Previous Bucket No: $PREVIOUS_BUCKET_NO,Current Bucket No: $CURRENT_BUCKET_NO ]"
              PREVIOUS_BUCKET_NO=$CURRENT_BUCKET_NO
              max_bucket_retries=5
              log "Resetting Max bucket retries: $max_bucket_retries]"
          else
             log "Rebalancing sharding is not running [Previous Bucket No: $PREVIOUS_BUCKET_NO,Current Bucket No: $CURRENT_BUCKET_NO ]"
             log "Rebalancing retry [retries left: $max_bucket_retries]"
          fi
        fi
      ;;
    esac
    if [[ $max_bucket_retries -eq 0 ]]; then
        return 1
    fi
    max_bucket_retries=`expr $max_bucket_retries - 1`
    sleep 5
  done

  return 0
}

getSetupType () {
  isGRSetup="N"
  if [[ `cat /etc/broadhop/qns.conf | grep "DGeoSiteName=" | wc -l` -eq 1 ]]; then
    isGRSetup="Y"
    if [[ `cat /etc/hosts | grep "psessionmgr" | wc -l` -eq 0 ]]; then
        log_err "No remote site host with alias psessionmgr is defined in /etc/hosts"
        exit 1
    fi
  fi
}

getRingId () {
  ringId=1
  setMember=$1
  if [[ $isGRSetup == "Y" ]]; then
    if [[ `cat /etc/hosts | grep "$setMember" | wc -l` -gt 0 ]]; then
      if [[ `cat /etc/hosts | grep "$setMember" | grep "psessionmgr" | wc -l` -eq 1 ]]; then
         ringId=2      # Remote site sessionmgr
      else
         ringId=1      # Local site sessionmgr
      fi
    else
        log_err "Invalid host: $setMember"
        exit 1
    fi
  fi

  log "Calculated ringId is $ringId"
}

getRingSiteId () {
  ringId=$1

  GET_RING_SETID_OUT="$TMP_DIR/.getRingSetId.out"
  >$GET_RING_SETID_OUT

  log "Getting setId for ringId: $ringId"
  getNextSkRingSetResult=$(echo "getNextSkRingSet $ringId" | nc ${DEFAULT_OSGI_HOST} 9091 > $GET_RING_SETID_OUT)
  ringSetId=$(cat $GET_RING_SETID_OUT | grep -v "osgi" | xargs | tr -d '\r') # remove cariage return

  log "Found ringSetId: $ringSetId for ringId: $ringId"
}

runOSGICommand () {

  command=$1
  RUN_OSGI_COMMAND_OUT="$TMP_DIR/.OsgiCommand.out"
  >$RUN_OSGI_COMMAND_OUT

  log_tee "Executing OSGI Command> $command"
  commandResult=$(echo "$command" | nc ${DEFAULT_OSGI_HOST} 9091 > $RUN_OSGI_COMMAND_OUT)
  sed -i -e "s|osgi>||g" $RUN_OSGI_COMMAND_OUT
  commandResult=$(cat $RUN_OSGI_COMMAND_OUT | xargs | tr -d '\r') # remove cariage return

  if [[ $commandResult == *"success"* ]]; then
      log "OSGI Output> $commandResult"
  elif [[ $commandResult == *"already exist"* ]]; then
      log "OSGI Output> $commandResult"
  else
      log_err "OSGI Error> Refer log file for more detail"
      exit 1
  fi
  log_delete_file $RUN_OSGI_COMMAND_OUT
}

validateQnsIsUp() {
  IS_QNS_UP=`/var/qps/bin/diag/diagnostics.sh --qns_diagnostics | grep -e "Retrieving" -e "qns" | grep -e FAIL | wc -l`
  if [[ $IS_QNS_UP -ne 0 ]]; then
     log_err "QNS process are not up"
     exit 1
  else
    log "All QNS processes are up and running"
  fi
}

validateHosts () {

  sets=$1
  setArr=$(echo $sets | tr "," "\n")
  setArr=($(printf "%s\n" "${setArr[@]}" | sort -u)) # remove duplicates

  if [[ "${#setArr[@]}" -le 0 ]]; then
    log_err "Set must not be empty"
    exit 1
  fi

  for set in $setArr
  do
    setMembers=$(echo $set | tr ":" "\n")
    setMembers=($(printf "%s\n" "${setMembers[@]}" | sort -u)) # remove duplicates
    if [[ "${#setMembers[@]}" -le 0 ]]; then
      log_err "Set members must not be empty"
      exit 1
    fi
    for setMember in $setMembers
    do
      if [[ `cat /etc/hosts | grep "$setMember" | wc -l` -eq 0 ]]; then
          log_err "Host entry not found for host: $setMember"
          exit 1
      else
        nc -w 1 $setMember 11211 < /dev/null &> /dev/null
        if [[ $? -ne "0" ]]; then
          log_err "$setMember:11211 is not reachable"
          exit 1
        fi
      fi
    done
  done
}

addRingSet () {

  clear
  echo "Session cache operation script: addRingSet"
  echo -e " The progress of this script can be monitored in the following log:\n$LOG_FILE"

  interactive=$1
  sets=$2

  if [[ $interactive == "yes" ]]; then
    echo ""
    echo ""
    echo ""
    echo "Note :"
    echo "  Please provide sessionmgr vm separated by ':' and pair separated by ','"
    echo "  "
    echo "(Ex HA: sessionmgr01-lab:sessionmgr02-lab)"
    echo "(Ex GR: sessionmgr01-site1:sessionmgr02-site1,sessionmgr01-site2:sessionmgr02-site2)"
    printf "Enter cache servers: "
    read sets
  fi

  log_tee "Verifying Qnses processes is running"
  validateQnsIsUp

  sets=${sets// /} # remove all spaces in between
  log_tee "Adding set $sets to ring"
  getSetupType
  validateHosts $sets

  setArr=$(echo $sets | tr "," "\n")
  ringToRebuild=()

  # (1) Add Set to Ring
  for set in $setArr
  do
    # (1.1) Get RingId
    log "Processing set: $set"
    commandSets=""
    setMembers=$(echo $set | tr ":" "\n")

    for setMember in $setMembers
    do
      log "Processing setMember: $setMember"
      commandSets="$commandSets$setMember:11211,"
      getRingId $setMember
      ringToRebuild=("${ringToRebuild[@]}" "$ringId")
    done

    # (1.2) Get SetId
    getRingSiteId $ringId
    if [[ $ringSetId == *"does not exist"* ]]; then
      runOSGICommand "createSkRing $ringId"
      getRingSiteId $ringId
    fi

    # (1.3) Run osgi> setSkRingSet
    runOSGICommand "setSkRingSet $ringId $ringSetId $commandSets"
  done

  uniqRingToRebuild=($(printf "%s\n" "${ringToRebuild[@]}" | sort -u)) # remove duplicates

  # (2) Rebuild Ring
  for ring in "${uniqRingToRebuild[@]}"
  do
    runOSGICommand "rebuildSkRing $ring"
  done

  log_tee "Ringset added successfully"
}

#
# init
#
init () {

RUNNING_HOST=$(hostname -s)
clear

NO_OF_ARUGMENTS=$#
ARGUMENTS=$*
DEFAULT_OPTION_SET=`echo $ARGUMENTS | grep default | wc -l`

# Check for execution using correct user
GROUP=$(id -gn)
if ! (for e in "${ALLOWED_ROLES[@]}"; do [[ "$e" == "${GROUP}" ]] && exit 0; done; exit 1); then
    echo "Script needs to be executed by user in one of these groups:"
    echo "${ALLOWED_ROLES[@]}"
    exit 0
fi

echo "Session cache operation script"
date

# Check for config file
if [[ "$RUNNING_HOST" != "lab" ]]; then
  if ! command -v mongo >/dev/null; then
    echo "Cannot find MongoDB command-line client 'mongo'"
    exit 1
  fi
  if [[ ! -f $MONGODB_CONFIG_FILE ]]; then
    echo "Configuration file $MONGODB_CONFIG_FILE not found in the current setup."
    exit 0
  fi

  # Check for valid arguments
  if [[ `cat $GR_CLUSTER_CONFIG_FILE | grep -v "^#" | wc -l` -gt 1 ]]; then
    # if default option is not provided then only need site ID
    if [[ $DEFAULT_OPTION_SET -eq 0 ]]; then
      # There are certain use cases where siteid of remote site is passed. 
      if [[ `grep "_START" $MONGODB_CONFIG_FILE | wc -l` -eq 0 || `grep "_END" $MONGODB_CONFIG_FILE | wc -l` -eq 0 ]]; then
         echo "Warning: gr_cluster.conf has configuration for cluster sites but site start/end tags information is not present in mongoConfig.cfg"
      else
        if [[ $# -ge 5 || -z $2 ]]; then
          showUsage
          echo "Please pass site number(site1 or site2...) as second argument."
          exit 0
        fi
        SITE_NAME=`echo $2 | tr '[a-z]' '[A-Z]'`
        if [[ `echo $SITE_NAME | grep -e SITE | wc -l` -eq 0 ]]; then
          showUsage
          exit 0
        elif [[ `grep ${SITE_NAME}_START $MONGODB_CONFIG_FILE | wc -l` -eq 0 || `grep ${SITE_NAME}_END $MONGODB_CONFIG_FILE | wc -l` -eq 0 ]]; then
          showUsage
          echo "There is no mongo configuration availbale for ${SITE_NAME} in $MONGODB_CONFIG_FILE file."
          exit 0
        fi
      fi
    fi
  else
    if [[ $DEFAULT_OPTION_SET -eq 1 ]]; then
       case "$1" in
         --add-shard|-add-shard)
           if [[ "$3" == "--seeds" ||  "$3" == "-seeds" ]]; then
             if [[ -z "$4" ]]; then
               echo "Error: seeds pairs parameters not passed"
               exit 1
             fi
           else
             echo "Error: seeds parameters (--seeds) not passed"
             exit 1
           fi
           NO_OF_ARUGMENTS=`expr $NO_OF_ARUGMENTS - 3`
         ;;

        --add-ringset|-add-ringset)
             if [[ "$3" == "--seeds" ||  "$3" == "-seeds" ]]; then
               if [[ -z "$4" ]]; then
                 echo "Error: seeds pairs parameters not passed"
                 exit 1
               fi
             else
               echo "Error: seeds parameters (--seeds) not passed"
               exit 1
             fi
             NO_OF_ARUGMENTS=`expr $NO_OF_ARUGMENTS - 3`
           ;;
       esac
    fi
    if [[ $NO_OF_ARUGMENTS -ge 5 ]]; then
      showUsage
      exit 1
    fi
  fi
else
   AIO="true"
fi

if [[ -z ${1:-} ]]; then
  showUsage
  exit 0
fi

PLATFORM=$3
if [[ ${PLATFORM} == "2" || ${PLATFORM} == "3" ]];then 
	REMOVE_MB_SNLSy=`echo $4 | awk -F, '{print $1}'`
	REMOVE_MB=`echo $4 | awk -F, '{print $2}'`
else REMOVE_MB=$4
fi
case "$1" in
  --count|-count)
    ACTION="$1"
    OPTION=1
    ;;

  --remove|-remove)
    ACTION="$1"
    OPTION=2
    ;;

  --statistics-count|-statistics-count)
    ACTION="$1"
    OPTION=3
    ;;

  --add-shard|-add-shard)
    ACTION="$1"
    OPTION=4
    ;;

  --db-shrink|-db-shrink)
    ACTION="$1"
    OPTION=5
    ;;

 --add-ringset|-add-ringset)
      ACTION="$1"
      OPTION=6
    ;;

  --help|-help|-h|--h)
    showUsage
    exit 0
    ;;

  *)
    showUsage
    exit 1
    ;;
esac

# --hotstandby & --shardcount <number> are optional parameters with '--add-shard --default' argument
# --hotstandby is not provided then default or non-backup DB
# --shardcount <number> is not provided then default is 4 shards
# --udc for adding the sharing entries to UDC admindb.
while [ $# -ne 0 ]
do
    case $1 in
            --hotstandby)
                HOT_STANDBY=0
                shift
                ;;
            --udc)
                DEFAULT_OSGI_HOST="udc01"
                shift
                ;;             
            --shardcount)
                shift
                DEFAULT_SHARDS=$1
                if [[ $DEFAULT_SHARDS =~ ^-?[0-9]+$ ]];then
                  log "Setting number of Shards: $DEFAULT_SHARDS"
                else
                  echo "Error: Invalid parameter '--shardcount', it should be an integer"
                  exit 1
                fi
                shift
                ;;
            * )
                # Not throwing any error here
                shift
                ;;
    esac
done

}

#
# Main
#
init $*
if [[ "$ACTION" == "--count" || "$ACTION" == "-count" || "$ACTION" == "--remove" || "$ACTION" == "-remove" ]]; then
  findSessionDbPrintSessionCountAndRemove $OPTION
elif [[ "$ACTION" == "--db-shrink" || "$ACTION" == "-db-shrink" ]]; then
  dbShrinkSessionCache
elif [[ "$ACTION" == "--statistics-count" || "$ACTION" == "-statistics-count" ]]; then
  printSessionStatisticsCount
elif [[ "$ACTION" == "--add-shard" || "$ACTION" == "-add-shard" ]]; then
  addShard
elif [[ "$ACTION" == "--add-ringset" || "$ACTION" == "-add-ringset" ]]; then
  if [[ $DEFAULT_OPTION_SET -eq 1 ]]; then
    addRingSet "no" "${*:4}"
  else
    addRingSet "yes"
  fi
else
  showUsage
  exit 1
fi
rm -f $TMP_MONGO_FILE

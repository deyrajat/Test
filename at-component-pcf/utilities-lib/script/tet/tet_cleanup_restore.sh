#!/bin/bash

######################################################################################################################################
#                       Filename        :       tet_cleanup_restore.sh
#                       Author          :       Navneet Kumar Verma
#                       Project         :       Test Effectiveness Toolkit [TET]
#                       About           :       This bash script performs cleanup and restore operations following a system test
#						completion. Furthermore, it can display current system status for various parameters.
#                       Version         :       1 [Date: ] [Initial Version]
######################################################################################################################################

mydate=`date +"%d-%m-%Y-%H-%M-%S"`
TIMESTAMP=${mydate}

echo -e $CBYELLOW"\nCURRENT LOCAL TIMESTAMP: [$CBCYAN $TIMESTAMP $CBYELLOW]\n$CNORMAL"

CNORMAL=`tput sgr0`
CBOLD=`tput bold`
CRED=`tput setaf 1`
CBRED=$CBOLD$CRED
CGREEN=`tput setaf 2`
CBGREEN=$CBOLD$CGREEN
CYELLOW=`tput setaf 3`
CBYELLOW=$CBOLD$CYELLOW
CBLUE=`tput setaf 4`
CBBLUE=$CBOLD$CBLUE
CMAGENTA=`tput setaf 5`
CBMAGENTA=$CBOLD$CMAGENTA
CCYAN=`tput setaf 6`
CBCYAN=$CBOLD$CCYAN

C_SET=1
O_SET=1
D_SET=1
K_SET=1
T_SET=1
A_SET=1
S_SET=1

CPS_STATS_PATH="/var/broadhop/stats/"
MONGO_CONFIG_PATH="/etc/broadhop/mongoConfig.cfg"
QNS_CONFIG_PATH="/etc/broadhop/qns.conf"
TOP_QPS_PATH="/var/qps/bin/control/top_qps.sh"
TRAP_PATH="/var/log/snmp/"
MONGOLOG_PATH="/var/log/mongodb"
MONDB_CALLMODEL_PATH="/var/log/broadhop/scripts/mon_db_for_callmodel_"
MONDB_LBFAILOVER_PATH="/var/log/broadhop/scripts/mon_db_for_lb_failover_"
PUPPET_LOG_PATH="/var/log/puppet.log"
MESSAGE_LOG_PATH="/var/log/messages"
HOSTS_ALL_FILE="/var/qps/bin/support/hosts-all.sh"
INTERFACE_STATS_PATH="/sys/class/net/"
GR_CONF_PARAM_LIST="GeoSiteName SiteId RemoteSiteId sprLocalGeoSiteTag balanceLocalGeoSiteTag sessionLocalGeoSiteTag RemoteGeoSiteName"
MONGO_STATS_LIST="0 STARTUP 1 PRIMARY 2 SECONDARY 3 RECOVERING 5 STARTUP2 6 UNKNOWN 7 ARBITER 8 DOWN 9 ROLLBACK 10 REMOVED"
MAX_REPLICA_MEMBERS=8
SET_PRIORITY_SCRIPT_PATH="/var/platform/modules/mongo_set_priority.py"
INSTALLER_HOSTNAME="installer"
CSV_FILES_PATH="/var/qps/config/deploy/csv"
HOSTS_CSV="$CSV_FILES_PATH/Hosts.csv"
#MONGO_AUTH="-u admin -p stuser123 --authenticationDatabase admin "
MONGO_AUTH=""
EXECUTE_FUNCTION=""

MONGO_CONFIG_FILENAME=""
MONGOSTAT_OUT_FILE=""
MONGOTOP_OUT_FILE=""
SAR_OUT_FILE=""
TOP_OUT_FILE=""
TOP_QPS_OUT_FILE=""
VMSTAT_OUT_FILE=""
MPSTAT_OUT_FILE=""
IOSTAT_OUT_FILE=""
BULKSTAT_OUT_FILE=""
MONGOLOG_OUT_FILE=""
QNS_PARAM_LIST="qns.instancenum instanceId qns.config.dir"
QNS_PARAM_ARRAY=( $QNS_PARAM_LIST )
LB_OSGI_PORTS="9092 9093 9094"
LB_OSGI_QNS="qns-2 qns-3 qns-4"
QNS_OSGI_PORT="9091"
DB_NAMES=""
PING_VLAN_HOSTS="replication:lb,sessionmgr external:lb,sessionmgr,qns"
START="_START"
MIN_FREE_SPACE_PERCENT=90
bar1="---------------------------------------------------------------------------------------------------------"
bar2="========================================================================================================="
#LOCAL_SESSION_TAG_PARAM="sessionLocalGeoSiteTag"
#LOCAL_BALANCE_TAG_PARAM="balanceLocalGeoSiteTag"
#LOCAL_SPR_TAG_PARAM="sprLocalGeoSiteTag"
LOCAL_TAG_PARAM_ARRAY=( "sessionLocalGeoSiteTag" "balanceLocalGeoSiteTag" "sprLocalGeoSiteTag" )

LOCAL_GEO_SITE_NAME_PARAM="GeoSiteName"
REMOTE_GEO_SITE_NAME_PARAM="RemoteGeoSiteName"
LOCAL_GEO_SITE_ID_PARAM="SiteId"
REMOTE_GEO_SITE_ID_PARAM="RemoteSiteId"

TMP_PATH="/tmp/"
USE_USER=root
CONFIG_FILE=""
CONFIG_FILENAME=""
SSH_TIMEOUT=2
NUM_QNS_INSTANCES_LB=4
NUM_QNS_INSTANCES_PC=2
NUM_QNS_INSTANCES_QNS=1

parse_options()
{
echo -e $SEPARATOR"\nParsing options provided on command line ..."
while getopts ":c:d:o:t:s:f:v:l:kauhe" options; do
        case "$options" in
                c)      CONFIG_FILE="${OPTARG}"
                        prefix=`echo $CONFIG_FILE | awk -F"/" '{print $1}'`
                        if [[ $prefix != "" ]]; then
                                echo $CBRED"Please provide absolute path for the config file."$CNORMAL
                                exit $EXIT_STATUS
                        fi
                        echo "Configuration would be read from file [$CBCYAN $CONFIG_FILE $CNORMAL]";
                        CONFIG_FILENAME=$(echo "$CONFIG_FILE" | awk -F"/" '{print $NF}')
                        C_SET=0
                        ;;
                o)      OUTPUT_FILE_PATH="${OPTARG}"
                        prefix=`echo $OUTPUT_FILE_PATH | awk -F"/" '{print $1}'`
                        if [[ $prefix != "" ]]; then
                                echo $CBRED"Please provide absolute path e.g. /root/ or /home/user/Desktop/."$CNORMAL
                                exit $EXIT_STATUS
                        fi
                        suffix=`echo $OUTPUT_FILE_PATH | awk -F"/" '{print $NF}'`
                        if [[ suffix != "" ]]; then
                                OUTPUT_FILE_PATH=$OUTPUT_FILE_PATH"/"
                        fi
                        echo "Files with stats collected would be saved at the location [$CBCYAN $OUTPUT_FILE_PATH $CNORMAL]";
                        O_SET=0
                        ;;
                u|h)    echo -e "Hmm! You requested for usage, Let me help you out!"
                        usage
                        exit 0
                        ;;
                e)      echo -e "Hmm! You requested for examples of config file, Let me help you out!"
                        usage_conf
                        exit 0
                        ;;
                d)      DUT_LIST="${OPTARG}"
			DUT_IP_LIST=$(echo "$DUT_LIST" | awk -F[:,] '{ for (i=2;i<=NF;i=i+2) if (i < NF) printf("%s ", $i); else printf("%s", $i); }')
			DUT_SITE_LIST=$(echo "$DUT_LIST" | awk -F[:,] '{ for (i=1;i<=NF;i=i+2) if (i < NF) printf("%s ", $i); else printf("%s", $i);}')
			DUT_IP_ARRAY=( $DUT_IP_LIST )
			DUT_SITE_ARRAY=( $DUT_SITE_LIST )

			for ip in ${DUT_IP_ARRAY[*]}; do
                        	if [[ "$ip" =~ ([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
					:
				else
                                	echo -e $CBRED"You seem to have provided an invalid IP address, please retry with IP address in correct IPv4 format."$CNORMAL
#                                	usage
                                	exit $EXIT_STATUS
                        	fi
			done
			for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
				MONGO_CONFIG_FILENAME=$(echo "$MONGO_CONFIG_PATH" | awk -F"/" '{print $NF}')_${DUT_IP_ARRAY[$i]}
				scp $USE_USER@${DUT_IP_ARRAY[$i]}:$MONGO_CONFIG_PATH $TMP_PATH$MONGO_CONFIG_FILENAME &>/dev/null
				if [[ $? -eq 0 ]]; then
					break;
				fi
			done
			D_SET=0
                        ;;
		f)	EXECUTE_FUNCTION="${OPTARG}"
			;;
		v)	VM_INTERFACE_LIST=${OPTARG}
			VM_INTERFACE_ARRAY=( $VM_INTERFACE_LIST )
			;;
		l)	LATENCY=${OPTARG}
			;;
                \?)     echo -e $CBRED"Ahh! sorry I don't understand option [$CBRED -$OPTARG $CNORMAL] yet. Check usage below for valid options. You can do it!"$CNORMAL
                        usage
                        exit $EXIT_STATUS
                        ;;
                :)      echo -e $CBRED"Ahh! sorry you seem to have missed passing an argument for option [$CBRED -$OPTARG $CNORMAL]. Check usage below. You can do it!"$CNORMAL
                        usage
                        exit $EXIT_STATUS
                ;;
                *)      echo -e $CBRED"Ahh! You entered something wrong! Check usage below. You can do it!"$CNORMAL
                        usage
                        exit $EXIT_STATUS
                ;;
        esac
done
        echo -e "Completed Parsing options provided on command line ..."
}


check_qns_status()
{
	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		echo -e $CBYELLOW"\nDisplaying QNS process statistics on the CPS [ ${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]} ] VMs:"$CNORMAL
		echo "=============================================================================================================="$CBCYAN
		printf "%-20s%-50s%-50s\n" "NODE" "QNS Processes Running" "QNS Processes NOT Running"
		echo $CNORMAL"=============================================================================================================="

		CPS_ALL_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh)
		CPS_QNS_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts.sh)
		CPS_DB_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep sessionmgr)

		temp_file_qns=`mktemp`
		for node in $CPS_QNS_VM_LIST; do
			ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $node "service qns status" > $temp_file_qns
			printf "%-20s" "$node"

			awk 'BEGIN	{
					strr = ""; 
					strs = "";
				}
				{
					split($0, list, " ");
					if (match($0, "running") > 0) {
						strr = strr list[1] ",";
					}
					else
						strs = strs list[1] ",";
				}
				END	{
					system("tput bold; tput setaf 2");
					printf("%-50s", strr);
					system("tput bold; tput setaf 1");
					printf("%-50s", strs);
					system("tput sgr0");
					printf("\n-----------------------------------------------------------------------------------------------------------")
			}' $temp_file_qns
			printf "\n"
		done
	}
	done
	rm -f $temp_file_qns
}


check_replica_status()
{
	echo -e $CBYELLOW"\n\nDisplaying Replica Set Status ..."$CNORMAL
	
	for((i=1; i<=$MAX_REPLICA_MEMBERS+1; i++)); do
		printf "%-15s" "==============="
	done
	printf "\n"

	tput bold; tput setaf 6;
	printf "%-15s" "SETNAME"
	
	for((i=1; i<=$MAX_REPLICA_MEMBERS; i++)); do
		printf "%-15s" "MEMBER-$i"
	done
	printf "\n"
	tput sgr0;
	
	for((i=1; i<=$MAX_REPLICA_MEMBERS+1; i++)); do
		printf "%-15s" "==============="
	done
	printf "\n"

	temp_file_replica=`mktemp`;
	awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="${DUT_IP_ARRAY[0]}" -v stats_list="$MONGO_STATS_LIST" -v outfile="$temp_file_replica" \
		'BEGIN { 
			RS = "END]";
			FS = "\n";
		}
		{
		for(i=1; i<=NF; i++)	{
			if(match($i, "^MEMBER|^ARBITER=") > 0)	{
				split($i, values, "=");
				command1 = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.status\\(\\).set\" &>/dev/null; printf \"$?\"", user, node, values[2]);
				command1 |& getline result;
				close(command1)
				if (result != 0)
					continue;	
				else {
					command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s<<EOF >%s\nrs.status()\nexit\nEOF", user, node, values[2], outfile);
					system(command);
					command = sprintf("awk -F[%c%c:,%c] %cBEGIN { split(%c%s%c, list, %c %c); len=length(list); }\
							/set/ { system(\"tput bold\"); system(\"tput setaf 3\"); \
								printf(\"%%-15s\", $5); system(\"tput sgr0\")} \
							/state%c/ { \
								for(i=1;i<len;i=i+2) \
									if(list[i] == $4) {\
										if($4 == 1) {\
											system(\"tput bold\"); \
											system(\"tput setaf 2\"); \
											printf(\"%%-15s\", list[i + 1]); \
											system(\"tput sgr0\");\
										} \
										else if($4 == 2 || $4 == 7) {\
											printf(\"%%-15s\", list[i + 1]); \
										} \
										else {\
											system(\"tput bold\"); \
											system(\"tput setaf 1\"); \
											printf(\"%%-15s\", list[i + 1]); \
											system(\"tput sgr0\");\
										} \
									}\
							}%c %s", q1, q2, q1, q1, q2, stats_list, q2, q2, q2, q2, q1, outfile);
					system(command);
					printf("\n")
 					next;
				}
			}
		}
		}' $TMP_PATH$MONGO_CONFIG_FILENAME
	rm -f $temp_file_replica;
}

recover_replica_sets()
{
	echo -e $CBYELLOW"\n\nRecovering replica sets where not in PRIMARY / SECONDARY / ARBITER / STARTUP / REMOVED state ...\n"$CNORMAL
	
	temp_file_replica=`mktemp`;
	awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="${DUT_IP_ARRAY[0]}" -v stats_list="$MONGO_STATS_LIST" -v outfile="$temp_file_replica" \
		'BEGIN { 
			RS = "END]";
			FS = "\n";
			split(stats_list, list, " ");
		}
		{
		for(i=1; i<=NF; i++)	{
			if(match($i, "^MEMBER|^ARBITER=") > 0)	{
				split($i, values, "=");
				split(values[2], host_port, ":");

				command1 = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.status\\(\\).set\" &>/dev/null; printf \"$?\"", user, node, values[2]);
				command1 |& getline result;
				close(command1)

				if (result != 0)
					continue;	
				else {
					system("tput bold; tput setaf 6");
					printf("Verifying Replica Set: ");
					system("tput sgr0");

					command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.status\\(\\).set\"", user, node, values[2]);
					system(command);
					printf("\n");

					command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s<<EOF >%s\nrs.status()\nexit\nEOF", user, node, values[2], outfile);
					system(command);

					command = sprintf("awk -F[%c%c:,%c] %c/name/ { printf(\"%%s\", $5)} /state%c/ {printf(\"%%s \", $4)}  %c %s", q1, q2, q1, q1, q2, q1, outfile);
					command |& getline member_status;
					close(command);

					split(member_status, members, " ");
					len = length(members);

					for (i=2; i<=len; i=i+2) {
						if (match(members[i], "0") == 0 && match(members[i], "1") == 0 && match(members[i], "2") == 0 && match(members[i], "7") == 0 && match(members[i], "10") == 0) {
							printf("--------------------------------------------------------------------------------------\n");
							printf("Attempting to recover mongo instance at port: %s on %s ...\n", host_port[2], members[i-1]);

							command1 = sprintf("ssh %s@%s ping -c 2 -W 1 %s &>/dev/null; printf \"$?\"", user, node, members[i-1]);
							command1 |& getline result2;
							close(command1);

							if (result2 != 0) {
								system("tput bold; tput setaf 1");
								printf ("%s is NOT reachable. Please start the VM if down and retry later ...\n", members[i-1]);
								system("tput sgr0");
							}
							else {
								command2 = sprintf("ssh %s@%s ssh %s /etc/init.d/sessionmgr-%s stop &>/dev/null", user, node, members[i-1], host_port[2]);
								system(command2);
								printf("Now stopped the mongo instance at port: %s on %s if already running ...\n", host_port[2], members[i-1]);

								command3 = sprintf("ssh %s@%s ssh %s grep \"DBPATH=\" /etc/init.d/sessionmgr-%s | cut -d= -f2 | xargs echo -n", user, node, members[i-1], host_port[2]);
								command3 |& getline db_path;
								close(command3);

								command4 = sprintf("ssh %s@%s ssh %s rm -rf %s/* &>/dev/null", user, node, members[i-1], db_path);
								system(command4);
								printf("Now cleared the data directory: %s on %s ...\n", db_path, members[i-1]);

								command2 = sprintf("ssh %s@%s ssh %s /etc/init.d/sessionmgr-%s start &>/dev/null", user, node, members[i-1], host_port[2]);
								system(command2);
								system("tput bold; tput setaf 2");
								printf("Now started the mongo instance at port: %s on %s ...\n", host_port[2], members[i-1]);
								system("tput sgr0");
								printf("--------------------------------------------------------------------------------------\n");
							}
						}
					}
 					next;
				}
			}
		}
		}' $TMP_PATH$MONGO_CONFIG_FILENAME
	rm -f $temp_file_replica;
}

check_peer_status()
{
	LB_OSGI_PORTS_ARRAY=( $LB_OSGI_PORTS )
	LB_OSGI_QNS_ARRAY=( $LB_OSGI_QNS )

	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		read -a LB_NODES <<<$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep 'lb')
		echo -e $CBYELLOW"\n\nDisplaying peer connection status on [${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]}] load balancers ..."$CNORMAL
	
		temp_peer_file=`mktemp`
		for node in ${LB_NODES[*]}; do
			for((j=0; j<${#LB_OSGI_PORTS_ARRAY[*]}; j++)); do
				ssh $USE_USER@${DUT_IP_ARRAY[$i]} "printf \"showPeers\\ndisconnect\\ny\\n\" | nc $node ${LB_OSGI_PORTS_ARRAY[$j]} | grep -v osgi | sed -e 's///g' -e '/^$/ d'" | sed -e "s/^/$node   ${LB_OSGI_QNS_ARRAY[$j]}   /g" | sort >> $temp_peer_file
			done
		done

		column -t $temp_peer_file > $temp_peer_file.tmp
		mv $temp_peer_file.tmp $temp_peer_file

		PEER_STATES=$(awk '{ if(arr[$NF] == "") { arr[$NF] = $NF; printf("%s ", arr[$NF]); }}' $temp_peer_file);
		PEER_STATES=( $PEER_STATES )

		for state in ${PEER_STATES[*]}; do
			for lb in ${LB_NODES[*]}; do
				echo "-------------------------------------------------------------------------------------------------"
				printf $CBCYAN"Displaying peers on$CBGREEN [ $lb ]$CBCYAN with status$CBGREEN [ $state ]$CBCYAN ...\n"$CNORMAL
				echo "-------------------------------------------------------------------------------------------------"
				awk -v lbnode="$lb" -v peer_state="$state" 'BEGIN {count=0;} $0 ~ lbnode { if ($NF == peer_state) { count++; print $0;} } END {system("tput bold; tput setaf 3"); printf("Total = %s\n", count); system("tput sgr0")}' $temp_peer_file
			done
		done
	rm -f $temp_peer_file
	}
	done
}

check_db_records()
{
	read -a DB_NAMES <<< $(awk -F"," '/^LIST_DB_COLLECTION,/{ for(i=2;i<=NF;i++) { split($i, arr, ":"); printf("%s ", arr[1]) };}' $CONFIG_FILE)
	read -a DB_COLLECTIONS <<< $(awk -F"," '/^LIST_DB_COLLECTION,/{ for(i=2;i<=NF;i++) { split($i, arr, ":"); printf("%s ", arr[2]) };}' $CONFIG_FILE)
	if [[ ${#DB_NAMES[*]} -eq 0 || ${#DB_COLLECTIONS[*]} -eq 0 ]]; then
		return;
	fi

	echo "================================================================================================="
	printf $CBYELLOW"Collecting Database information from your setup ...\n"$CNORMAL
	echo "================================================================================================="

	temp_file_records=`mktemp`;
	echo -e $CBMAGENTA"Following [$CBGREEN databases:collection$CBMAGENTA ] are being queried for records ...\n$CNORMAL`awk -F[,] '/^LIST_DB_COLLECTION,/ {for(i=2;i<=NF;i++) printf("%s\n", $i)}' $CONFIG_FILE`"

	printf "\n"
	awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="${DUT_IP_ARRAY[0]}" -v outfile="$temp_file_records" -v dbs="${DB_NAMES[*]}"\
		'BEGIN { 
			RS = "END]";
			FS = "\n";
			str = ""
			split(dbs, db_names, " ");
			len = length(db_names);
			for(n=1; n<=len; n++) {
				if (n < len)
					str = str db_names[n] "\\" "\\|"
				else
					str = str db_names[n]
			}
		}
		{
		for(i=1; i<=NF; i++)	{
			if($i ~ /-SET[0-9]*]/) 
				printf("%s\n",$i) >> outfile;

			if(match($i, "^MEMBER") > 0)	{
				split($i, values, "=");
				command1 = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.status\\(\\).set\" &>/dev/null; printf \"$?\"", user, node, values[2]);
				command1 |& getline result;
				close(command1)

				if (result != 0)
					continue;	
				else {
					printf("%s\n", $i) >> outfile;
					command = sprintf("ssh %s@%s \"mongo $MONGO_AUTH --quiet --host %s<<EOF\nrs.slaveOk()\nshow dbs\nexit\nEOF\n\" | grep -e \"%s\" | awk %s{print $1}%s >> %s", user, node, values[2], str, q1, q1, outfile);
					system(command);
 					next;
				}
			}
		}
		}' $TMP_PATH$MONGO_CONFIG_FILENAME &
	process_id=$!

        flag=0;
        while [[ 1 ]]; do
                kill -0 $process_id &>/dev/null
                val=$?
                if [[ $val -eq 0 ]]; then
                        if [[ $flag -eq 0 ]]; then
				printf $CBCYAN"\rThis could take some time, please wait ... $CBMAGENTA[/]"$CNORMAL
                                flag=1;
                        elif [[ $flag -eq 1 ]]; then
				printf $CBCYAN"\rThis could take some time, please wait ... $CBMAGENTA[-]"$CNORMAL
                                flag=2;
                        else
				printf $CBCYAN"\rThis could take some time, please wait ... $CBMAGENTA[\\]"$CNORMAL
                                flag=0;
                        fi
                else
                        break;
                fi
                sleep 0.5
        done
	printf "\n"

	awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="${DUT_IP_ARRAY[0]}" -v db_type_array="${DB_NAMES[*]}" -v col_type_array="${DB_COLLECTIONS[*]}" 'BEGIN { 
			FS = "\n"; 
			RS = "[";
			bar1 = "--------------------------------------------------";
			split(db_type_array, db_array, " ");
			len_db_array = length(db_array);

			split(col_type_array, col_array, " ");
			len_col_array = length(col_array);
		} 
		{
			if (FNR == 1) next;

			flag_member = 0;
			flag_db = 0;
			col_type = "";

 			delete total;

			for(i=1; i<NF; i++) {
				if (i == 1) {
					command0 = sprintf("echo \"%s\" | cut -d] -f1 | xargs echo -n", $i);
					command0 |& getline db_name;
					close(command0);

					system("tput bold; tput setaf 3");
					printf("%s\n", bar1);
					printf("%s\n", db_name);
					printf("%s\n", bar1);
					system("tput sgr0");

					continue;
				}
				if ($i ~ /^MEMBER/) {
					flag_member = 1;
					command = sprintf("echo \"%s\" | cut -d= -f2 | xargs echo -n", $i);
					command |& getline connect_str;
					close(command);
				}
				else {
					flag_db = 1;
					for(k=1; k<=len_db_array; k++) {
						if (match($i, db_array[k]) > 0) {
							col_type = col_array[k];
							if (total[col_type] == "") total[col_type] = 0;

							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\; db.%s.count\\(\\)\\%s", user, node, connect_str, $i, q2, col_type, q2);

							command |& getline value;

							str = sprintf("%s [%s]", $i, col_type);
							printf("%-35s", str);
							printf("%12s", value);
							close(command);

							total[col_type] = total[col_type] + value;
							if (i == NF-1) {
								system("tput bold; tput setaf 2");
								printf("%s\n", bar1);
								total_val = sprintf("Total [%s]", col_type);
								printf("%-34s%12s\n", total_val, total[col_type]);
								printf("%s\n", bar1);
								system("tput sgr0");
							}
						}
					}
				}
			}
			if (flag_member == 0 || flag_db == 0)	{
				system("tput bold; tput setaf 1");
				printf("No queried database/collection found in this replica set ...\n");
				system("tput sgr0");
			}
		}' $temp_file_records
	rm -f $temp_file_records
}

check_latency_status()
{
	echo -e $CBYELLOW"\nDisplaying latency status between the VMs on VLANs ..."$CNORMAL

	temp_site_records=""

	echo $bar1$CBMAGENTA
	printf "%-30s" "SOURCE"
	printf "%-30s" " DESTINATION"
	printf "%-30s\n" " VLAN			LATENCY"
	tput sgr0;

	node_sets_list=$(awk -F"," '/^CHECK_LATENCY/ { for (i=2;i<=NF;i++) printf("%s ", $i); }' $CONFIG_FILE)
	node_sets_array=( $node_sets_list )

	for node_set in ${node_sets_array[*]}; do
	{
		node1=$(echo $node_set | awk -F":" '{print $1}')
		node2=$(echo $node_set | awk -F":" '{print $2}')

		printf "%s\n" "$bar1"		

		arbiter_host=$(awk -F[=:] '/ARBITER/ { print $2; exit; }' $TMP_PATH$MONGO_CONFIG_FILENAME)

		for((i=0;i<${#DUT_IP_ARRAY[*]};i++)); do
			echo $CBYELLOW"${DUT_SITE_ARRAY[$i]}"$CNORMAL

			from_host_list=""
			to_host_list=""

			if [[ $node1 == "arbiter" ]]; then
				from_host_list=$arbiter_host;
			fi

			if [[ $node2 == "arbiter" ]]; then
				to_host_list=$arbiter_host;
			fi

			if [[ $from_host_list == "" ]]; then
				from_host_list=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} cat /etc/hosts | grep "[^A-Za-z0-9-]$node1[0-9][0-9]" | awk '{print $2}')
			fi
			if [[ $to_host_list == "" ]]; then
				to_host_list=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} cat /etc/hosts | grep "[^A-Za-z0-9-]$node2[0-9][0-9]" | awk '{print $2}')
			fi
			awk -v q=\' -v user=${USE_USER} -v ip="${DUT_IP_ARRAY[$i]}" -v from_nodes="${from_host_list}" -v to_nodes="${to_host_list}" -v bar1=$bar1 \
				'BEGIN {
					printf("%s\n", bar1);
					split(from_nodes, from_nodes_array, " ");
					split(to_nodes, to_nodes_array, " ");

					len_from = length(from_nodes_array);
					len_to = length(to_nodes_array);

					for (i=1; i<=len_from; i++) {
						for (j=1; j<=len_to; j++) {
							if (from_nodes_array[i] != to_nodes_array[j]) {
								printf("%-30s %-30s", from_nodes_array[i], to_nodes_array[j]);
								command = sprintf("ssh %s@%s ssh %s ping -c 1 %s &>/dev/null", user, ip, from_nodes_array[i], to_nodes_array[j]);
								system(command);
								command = sprintf("ssh %s@%s ssh %s ping -c 1 %s | head -2 | tail -1 | awk %s{printf(\"%%s\t\t%%s\", $5, $(NF-1))}%s", user, ip, from_nodes_array[i], to_nodes_array[j], q, q);
								system(command);
								printf("\n");
							}
						}
						printf("%s\n", bar1);
					}
				}'
		done
	}
	done
}

check_df_status()
{
	space_to_check=$(awk -F"," '/^MIN_VM_SPACE_PERCENT/ { printf("%s", $2); }' $CONFIG_FILE)
	if [[ $space_to_check == "" ]]; then
		space_to_check=$MIN_FREE_SPACE_PERCENT
	fi

	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		CPS_SITE_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | sort)
		echo -e $CBYELLOW"\nDisplaying 'disk' status for all VMs on ${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]} ..."$CNORMAL
		echo "$bar2"$CBCYAN
		printf "%-25s%-50s%s\n" "HOSTNAME" "FILESYSTEM" "Available Space %"
		echo $CNORMAL"$bar2"
		for hn in $CPS_SITE_VM_LIST; do
			printf "%-40s" $CBMAGENTA"$hn"$CNORMAL
			ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $hn df -kh | sed 1d | awk -v min_space="$space_to_check" '/%/ { 
										free_space = 100-$5; 
										printf("%-50s ", $1); 
										if (free_space < min_space) {
											system("tput bold; tput setaf 1;");
											printf("%10s%%", free_space);
											system("tput sgr0;");
										}
										else
											printf("%10s%%", free_space);
										printf("\n%-25s", " ");
										}'
			printf "\r$bar1\n"
		done
	}
	done
}

check_monit_status()
{
	monit_input_list=$(awk -F"," '/^CHECK_MONIT_STATUS/ { for (i=2;i<=NF;i++) if(i<NF) printf("\"%s|\"", $i); else printf("\"%s\"", $i); }' $CONFIG_FILE)
	if [[ $monit_input_list == "" ]]; then
		return;
	fi

	printf "\n"
	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		CPS_SITE_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep -v "installer")
		echo -e "\n$bar2"
		echo $CBYELLOW"Displaying selected 'monit' status for VMs on ${DUT_SITE_ARRAY[$i]}, IP: ${DUT_IP_ARRAY[$i]}..."$CNORMAL
		echo "$bar2"
		for hn in $CPS_SITE_VM_LIST; do
			temp_arr=`ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $hn monit summary \| grep -i -E "$monit_input_list"`
			if [[ $? -eq 0 ]]; then
				printf "%s\n" $CBMAGENTA"$hn"$CNORMAL
				echo "$temp_arr"
				printf "\r$bar1\n"
			fi
		done
	}
	done
}

check_session_counts()
{

	static_session_arr=""
	non_static_session_arr=""

	read -a static_session_arr <<< $(awk -F"," '/^LIST_SESSION_TYPE,/ { for(i=2;i<=NF;i++) { split($i, arr, ":"); if (arr[1] == "STATIC") printf("%s:%s:%s ", arr[2], arr[3], arr[4]) };}' $CONFIG_FILE)
	read -a non_static_session_arr <<< $(awk -F"," '/^LIST_SESSION_TYPE,/ { for(i=2;i<=NF;i++) { split($i, arr, ":"); if (arr[1] == "NONSTATIC") printf("%s:%s:%s ", arr[2], arr[3], arr[4]) };}' $CONFIG_FILE)

	if [[ ${#static_session_arr[*]} -eq 0 || ${#non_static_session_arr[*]} -eq 0 ]]; then
		return;
	fi

	echo -e $CBYELLOW"\nSTATIC sessions will be identified for following range/prefix:\n$CBCYAN${static_session_arr[*]}"$CNORMAL
	echo -e $CBYELLOW"\nNONSTATIC sessions will be identified for following range/prefix:\n$CBCYAN${non_static_session_arr[*]}"

	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
		ssh -o BatchMode=yes -o ConnectTimeout=$SSH_TIMEOUT $USE_USER@${DUT_IP_ARRAY[$i]} exit &>/dev/null
		if [[ $? -eq 0 ]]; then
			peer_node=${DUT_IP_ARRAY[$i]};
			break;
		fi
	done

	temp_file_session_sets=`mktemp`;
	awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="$peer_node" -v outfile="$temp_file_session_sets" -v dbs="session_cache"\
		'BEGIN { 
			RS = "END]";
			FS = "\n";
		}
		{
		flag = 0;
		for(i=1; i<=NF; i++)	{
			if($i ~ /SESSION-SET[0-9]*]/) {
				printf("%s\n",$i) >> outfile;
				flag = 1;
			}

			if(flag == 1 && match($i, "^MEMBER") > 0)	{
				split($i, values, "=");
				command1 = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.status\\(\\).set\" &>/dev/null; printf \"$?\"", user, node, values[2]);
				command1 |& getline result;
				close(command1)

				if (result != 0)
					continue;	
				else {
					printf("%s\n", $i) >> outfile;
					command = sprintf("ssh %s@%s \"mongo $MONGO_AUTH --quiet --host %s<<EOF\nrs.slaveOk()\nshow dbs\nexit\nEOF\n\" | grep -e \"%s\" | awk %s{print $1}%s >> %s", user, node, values[2], dbs, q1, q1, outfile);
					system(command);
 					next;
				}
			}
		}
		}' $TMP_PATH$MONGO_CONFIG_FILENAME &
	process_id=$!
echo $temp_file_session_sets
	printf "\n"
        flag=0;
        while [[ 1 ]]; do
                kill -0 $process_id &>/dev/null
                val=$?
                if [[ $val -eq 0 ]]; then
                        if [[ $flag -eq 0 ]]; then
				printf $CBYELLOW"\rIdentifying session replica sets, please wait ... $CBMAGENTA[/]"$CNORMAL
                                flag=1;
                        elif [[ $flag -eq 1 ]]; then
				printf $CBYELLOW"\rIdentifying session replica sets, please wait ... $CBMAGENTA[-]"$CNORMAL
                                flag=2;
                        else
				printf $CBYELLOW"\rIdentifying session replica sets, please wait ... $CBMAGENTA[\\]"$CNORMAL
                                flag=0;
                        fi
                else
                        break;
                fi
                sleep 0.5
        done

	process_id=""
	temp_file_sessions=`mktemp`;

	printf "\n\n%s : `date`\n" "START TIME:"

	if [[ $static_session_arr != "" ]]; then
		for static_item in ${static_session_arr[*]}; do
			awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="$peer_node" -v item_range="$static_item" -v outfile="$temp_file_sessions" 'BEGIN { 
				FS = "\n";
				RS = "[";
				bar1 = "--------------------------------------------------";
				prefix="";
				split(item_range, range, ":");
				type = range[1];

				if (type == "MSISDN_RANGE" || type == "IMSI_RANGE") {
					from = range[2];
					to = range[3];
				}
				else if (type == "MSISDN_PREFIX" || type == "IMSI_PREFIX") {
					prefix = range[2];
				}
			} 
			{
				if (FNR == 1) next;
				count = 0;
				record=""

				for(i=1; i<NF; i++) {
					if (i == 1) {
						command0 = sprintf("echo \"%s\" | cut -d] -f1 | xargs echo -n", $i);
						command0 |& getline db_name;
						close(command0);

						record = record db_name;
						continue;
					}
					if ($i ~ /^MEMBER/) {
						flag_member = 1;
						command = sprintf("echo \"%s\" | cut -d= -f2 | xargs echo -n", $i);
						command |& getline connect_str;
						close(command);
					}
					else {
						if (type == "MSISDN_RANGE")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ str=\\\\\\%sMsisdnKey:msisdn:\\\\\\%s\\;var\\ j=\\\\\\%s\\\\\\%s\\;var\\ counter=0\\;\\for\\(i=%s\\;i\\<=%s\\;i++\\){j=str+i\\;var\\ query={\\\\\\%stags\\\\\\%s:new\\ RegExp\\(j\\)}\\;counter=counter+db.session.count\\(query\\)}\\%s", user, node, connect_str, $i, q2, q2, q2, q2, q2, from, to, q2, q2, q2);
						if (type == "IMSI_RANGE")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ str=\\\\\\%sImsiKey:imsi:\\\\\\%s\\;var\\ j=\\\\\\%s\\\\\\%s\\;var\\ counter=0\\;\\for\\(i=%s\\;i\\<=%s\\;i++\\){j=str+i\\;var\\ query={\\\\\\%stags\\\\\\%s:new\\ RegExp\\(j\\)}\\;counter=counter+db.session.count\\(query\\)}\\%s", user, node, connect_str, $i, q2, q2, q2, q2, q2, from, to, q2, q2, q2);
						if (type == "MSISDN_PREFIX")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ query={\\\\\\%stags\\\\\\%s:{\\\\\\$regex:/^MsisdnKey:msisdn:%s/i}}\\;db.session.find\\(query\\).count\\(\\)\\%s", user, node, connect_str, $i, q2, q2, q2, prefix, q2);
						if (type == "IMSI_PREFIX")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ query={\\\\\\%stags\\\\\\%s:{\\\\\\$regex:/^Imsikey:imsi:%s/i}}\\;db.session.find\\(query\\).count\\(\\)\\%s", user, node, connect_str, $i, q2, q2, q2, prefix, q2);
						command |& getline value;

						if (type == "MSISDN_RANGE" || type == "IMSI_RANGE")
							arr[from"-"to] = arr[from"-"to] + value;

						if (type == "MSISDN_PREFIX" || type == "IMSI_PREFIX")
							arr[prefix] = arr[prefix] + value;
						close(command);
					}
				}
				if (i == NF)	{
					for (i in arr) {
						record = record ":STATIC:" i ":" arr[i];
						printf("%s\n", record) >> outfile
					}
					delete arr;
				}
			}'  $temp_file_session_sets &
		process_id="$! ""$process_id"
		done
	fi

	if [[ $non_static_session_arr != "" ]]; then
		for non_static_item in ${non_static_session_arr[*]}; do
			awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="$peer_node" -v item_range="$non_static_item" -v outfile="$temp_file_sessions" 'BEGIN { 
				FS = "\n"; 
				RS = "[";
				bar1 = "--------------------------------------------------";
				prefix="";
				split(item_range, range, ":");
				type = range[1];
				if (type == "MSISDN_RANGE" || type == "IMSI_RANGE") {
					from = range[2];
					to = range[3];
			}
			else if (type == "MSISDN_PREFIX" || type == "IMSI_PREFIX") {
				prefix = range[2];
			}
			} 
			{
				if (FNR == 1) next;
				count = 0;
				record=""

				for(i=1; i<NF; i++) {
					if (i == 1) {
						command0 = sprintf("echo \"%s\" | cut -d] -f1 | xargs echo -n", $i);
						command0 |& getline db_name;
						close(command0);

						record = record db_name;
						continue;
					}
					if ($i ~ /^MEMBER/) {
						flag_member = 1;
						command = sprintf("echo \"%s\" | cut -d= -f2 | xargs echo -n", $i);
						command |& getline connect_str;
						close(command);
					}
					else {
#		command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\; db.%s.count\\(\\)\\%s", user, node, connect_str, $i, q2, col_type, q2);
						if (type == "MSISDN_RANGE")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ str=\\\\\\%sMsisdnKey:msisdn:\\\\\\%s\\;var\\ j=\\\\\\%s\\\\\\%s\\;var\\ counter=0\\;\\for\\(i=%s\\;i\\<=%s\\;i++\\){j=str+i\\;var\\ query={\\\\\\%stags\\\\\\%s:new\\ RegExp\\(j\\)}\\;counter=counter+db.session.count\\(query\\)}\\%s", user, node, connect_str, $i, q2, q2, q2, q2, q2, from, to, q2, q2, q2);
						if (type == "IMSI_RANGE")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ str=\\\\\\%sImsiKey:imsi:\\\\\\%s\\;var\\ j=\\\\\\%s\\\\\\%s\\;var\\ counter=0\\;\\for\\(i=%s\\;i\\<=%s\\;i++\\){j=str+i\\;var\\ query={\\\\\\%stags\\\\\\%s:new\\ RegExp\\(j\\)}\\;counter=counter+db.session.count\\(query\\)}\\%s", user, node, connect_str, $i, q2, q2, q2, q2, q2, from, to, q2, q2, q2);
						if (type == "MSISDN_PREFIX")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ query={\\\\\\%stags\\\\\\%s:{\\\\\\$regex:/^MsisdnKey:msisdn:%s/i}}\\;db.session.find\\(query\\).count\\(\\)\\%s", user, node, connect_str, $i, q2, q2, q2, prefix, q2);
						if (type == "IMSI_PREFIX")
							command = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet %s/%s --eval \\%srs.slaveOk\\(\\)\\;var\\ query={\\\\\\%stags\\\\\\%s:{\\\\\\$regex:/^Imsikey:imsi:%s/i}}\\;db.session.find\\(query\\).count\\(\\)\\%s", user, node, connect_str, $i, q2, q2, q2, prefix, q2);
						command |& getline value;
						if (type == "MSISDN_RANGE" || type == "IMSI_RANGE")
							arr[from"-"to] = arr[from"-"to] + value;

						if (type == "MSISDN_PREFIX" || type == "IMSI_PREFIX")
							arr[prefix] = arr[prefix] + value;
						close(command);
					}
				}
				if (i == NF)	{
					for (i in arr) {
						record = record ":NONSTATIC:" i ":" arr[i];
						printf("%s\n", record) >> outfile
					}
					delete arr;
				}
		}'  $temp_file_session_sets &
		process_id="$! ""$process_id"
		done
	fi

        flag=0;
        while [[ 1 ]]; do
                kill -0 $process_id &>/dev/null
                val=$?
                if [[ $val -eq 0 ]]; then
                        if [[ $flag -eq 0 ]]; then
				printf $CBYELLOW"\rCalculating session counts. This could take several minutes, please wait ... $CBMAGENTA[/]"$CNORMAL
                                flag=1;
                        elif [[ $flag -eq 1 ]]; then
				printf $CBYELLOW"\rCalculating session counts. This could take several minutes, please wait ... $CBMAGENTA[-]"$CNORMAL
                                flag=2;
                        else
				printf $CBYELLOW"\rCalculating session counts. This could take several minutes, please wait ... $CBMAGENTA[\\]"$CNORMAL
                                flag=0;
                        fi
                else
                        break;
                fi
                sleep 0.5
        done
	printf "\n"

	printf "%s\n" "$bar2"
	tput setaf 6;	
	printf "%-30s%-30s%10s    %10s%20s\n" "SETNAME" "RANGE/PREFIX" "STATIC" "NONSTATIC" "STATIC+NONSTATIC"
	tput sgr0;	
	printf "%s\n" "$bar2"

	cat $temp_file_sessions | sort -V | awk -F":" -v bar1="$bar1" 'BEGIN {
				count_static=0;
				count_non_static=0;
			} 
			{
				if ($2 == "STATIC") {
					printf("%-30s%-30s%10s%14s\n", $1, $3, $4, "0")
					count_static = count_static + $4;
				}
				if ($2 == "NONSTATIC") {
					printf("%-30s%-30s%10s%14s\n", $1, $3, "0", $4)
					count_non_static = count_non_static + $4;
				}
			}
		END {
			printf("%s\n", bar1);
			system("tput bold; tput setaf 6");
			printf("%-30s%-30s%10s    %10s%20s\n", "Total Sessions", " ", count_static, count_non_static, count_static + count_non_static);
			system("tput sgr0");
			printf("%s\n", bar1);
		}'
	printf "%s : `date`\n" "END TIME:"

#	rm -f $temp_file_session_sets
#	rm -f $temp_file_sessions
}

check_config_status()
{
	ONCE_ONLY=0;
	temp_file_site_records=`mktemp`

	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
		tag_array="";
		echo -e $CBYELLOW"\n$bar2"
		echo "Displaying configuration details for ${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]}"
		echo "$bar2"$CNORNAL

		QNS_CONFIG_FILENAME=$(echo "$QNS_CONFIG_PATH" | awk -F"/" '{print $NF}')_${DUT_IP_ARRAY[$i]}
		scp $USE_USER@${DUT_IP_ARRAY[$i]}:$QNS_CONFIG_PATH $TMP_PATH$QNS_CONFIG_FILENAME &>/dev/null

		geositeName=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D$LOCAL_GEO_SITE_NAME_PARAM | cut -d"=" -f2)
		geositeNamePrefix=echo $getsiteName | `cut -d_ -f1`
		remotegeositeName=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D$REMOTE_GEO_SITE_NAME_PARAM | cut -d"=" -f2)
		siteId=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D$LOCAL_GEO_SITE_ID_PARAM | cut -d"=" -f2)
		remotesiteId=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D$REMOTE_GEO_SITE_ID_PARAM | cut -d"=" -f2)

		sessionTag=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D${LOCAL_TAG_PARAM_ARRAY[0]} | cut -d"=" -f2)
		balanceTag=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D${LOCAL_TAG_PARAM_ARRAY[1]} | cut -d"=" -f2)
		sprTag=$(cat $TMP_PATH$QNS_CONFIG_FILENAME | grep D${LOCAL_TAG_PARAM_ARRAY[2]} | cut -d"=" -f2)

		echo -e $CBCYAN"\nFollowing Tags are defined in qns.conf for this site:"$CNORMAL
		echo "${LOCAL_TAG_PARAM_ARRAY[0]}=\"$sessionTag\""
		echo "${LOCAL_TAG_PARAM_ARRAY[1]}=\"$balanceTag\""
		echo "${LOCAL_TAG_PARAM_ARRAY[2]}=\"$sprTag\""

		read -a adminDB_array <<<$(awk -v user="$USE_USER" -v node="${DUT_IP_ARRAY[$i]}" 'BEGIN { 
				RS = "END]";
				FS = "\n";
			}
			{
			flag = 0;
			for(i=1; i<=NF; i++)	{
				if($i ~ /ADMIN-SET[0-9]*]/) {
					flag = 1;
				}

				if(flag == 1 && match($i, "^MEMBER") > 0)	{
					split($i, values, "=");
						printf("%s ", values[2]);
				}
			}
			}' $TMP_PATH$MONGO_CONFIG_FILENAME)
#echo ${adminDB_array[*]}
		for((j=0; j<${#adminDB_array[*]}; j++)); do
			read adminDB_ip_list <<<$(retval=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} mongo $MONGO_AUTH --quiet ${adminDB_array[$j]}/clusters --eval "rs.slaveOk\(\)\;db.hosts.find\({siteName:/^$geositeNamePrefix/}\,{ip:1\,_id:0}\).pretty\(\).shellPrint\(\)" 2>/dev/null); if [[ $? -ne 0 ]]; then echo ""; else echo "$retval" | cut -d'"' -f4; fi;)
			if [[ $adminDB_ip_list == "" ]]; then
				continue;
			else
				adminDB="${adminDB_array[$j]}"
				break;
			fi
		done

		if [[ $adminDB == "" ]]; then
			echo -e $CBRED"\nCannot connect to an adminDB instance OR couldn't match cluster name to verify configuration ..."$CNORMAL
			return;
		fi

		echo -e "\n$bar1"
		echo -e $CBCYAN"Verifying entries in cluster DB ..."$CNORMAL
		echo "$bar1"

		for((k=0; k<${#adminDB_array[*]}; k++)); do
			adminDB_node=$(echo ${adminDB_array[$k]} | cut -d':' -f1 2>/dev/null)
			read -a adminVM_ip_array <<< $(ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $adminDB_node ifconfig | grep "inet addr" | awk -F':' '{print $2}' | cut -d' ' -f1 | grep -v 127.0.0.1 2>/dev/null)
			for((l=0; l<${#adminVM_ip_array[*]}; l++)); do
				index="";
				index=$(echo $adminDB_ip_list | grep -b -o ${adminVM_ip_array[$l]} | cut -d':' -f1)
				if [[ $index != "" ]]; then
					echo "Found entry for IP: ${adminVM_ip_array[$l]} in clusters database of adminDB for geoSiteName: $geositeName."
				else
					echo $CBRED"No entry found for IP: ${adminVM_ip_array[$l]} in clusters database of adminDB for geoSiteName: $geositeName. This may be expected, please check."$CNORMAL
				fi
			done
		done

		cat $TMP_PATH$MONGO_CONFIG_FILENAME | awk -v site="${DUT_SITE_ARRAY[$i]}" 'BEGIN{ RS=site; FS="\n"; } { if (FNR == 2) print $0; }' > $temp_file_site_records

		echo -e "\n$bar1"
		echo -e $CBCYAN"Displaying site TAGs configured in the DBs ..."$CNORMAL
		echo "$bar1"
	
		for((n=0; n<${#LOCAL_TAG_PARAM_ARRAY[*]}; n++)); do
			awk -v q1=\' -v q2=\" -v user="$USE_USER" -v node="${DUT_IP_ARRAY[$i]}" -v tag_param="${LOCAL_TAG_PARAM_ARRAY[$n]}" 'BEGIN { 
				RS = "END]";
				FS = "\n";
			}
			{
			flag = 0;
			for(i=1; i<=NF; i++)	{
				if( tag_param ~ "sessionLocalGeoSiteTag" && $i ~ /SESSION-SET[0-9]*]/) {
					system("tput bold; tput setaf 6");
					printf("%s\n",$i);
					system("tput sgr0");
					flag = 1;
				}
				if( tag_param ~ "balanceLocalGeoSiteTag" && $i ~ /BALANCE-SET[0-9]*]/) {
					system("tput bold; tput setaf 6");
					printf("%s\n",$i);
					system("tput sgr0");
					flag = 1;
				}
				if( tag_param ~ "sprLocalGeoSiteTag" && $i ~ /SPR-SET[0-9]*]/) {
					system("tput bold; tput setaf 6");
					printf("%s\n",$i);
					system("tput sgr0");
					flag = 1;
				}

				if(flag == 1 && match($i, "^MEMBER") > 0)	{
					split($i, values, "=");
					command1 = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.status\\(\\).set\" &>/dev/null; printf \"$?\"", user, node, values[2]);
					command1 |& getline result;
					close(command1)

					if (result != 0)
						continue;	
					else {
						system("tput bold; tput setaf 5");
						printf("%-30s%20s%s\n", "HOST", "", "SITE TAG");
						system("tput sgr0");
						command2 = sprintf("ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.conf\\(\\).members.length\"", user, node, values[2]);
						command2 |& getline num_members;
						close(command2);

						for(k=0; k<num_members; k++) {
							hostname=""; tag="";
							command3 = sprintf("echo -n `ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.conf\\(\\).members[%s].host\"`", user, node, values[2], k);
							command3 |& getline hostname;
							command4 = sprintf("echo -n `ssh %s@%s mongo $MONGO_AUTH --quiet --host %s --eval \"rs.conf\\(\\).members[%s].tags.%s\"`", user, node, values[2], k, tag_param);
							command4 |& getline tag;
							close(command3);
							close(command4);

							printf("%-30s%20s\"%s\"\n", hostname, "",tag);
						}
	 					next;
					}
				}
			}
		}' $temp_file_site_records 
		done
		printf "\n"

		echo -e "\n$bar1"
		echo $CBCYAN"Displaying site lookups configured ..."$CNORMAL
		echo "$bar1"

		read -a lookup_array <<<$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} mongo $MONGO_AUTH --quiet $adminDB/sharding --eval \"rs.slaveOk\(\)\;db.sites.find\({"primarySiteId":/^$siteId/\,"secondarySiteId:/^$remotesiteId/"}\,{loookupValues:1\,_id:0}\).pretty\(\).shellPrint\(\)\" | grep -v 'loookupValues\|]\|{\|}' | sed 's/	//g' | sed 's/[",]//g')

		tput setaf 5;
		printf "\n%-30s %-30s %-30s\n" "LOCAL SITE ID" "REMOTE SITE ID" "LOOKUP VALUE"
		tput sgr0;

		for((l1=0; l1<${#lookup_array[*]}; l1++)); do
			printf "%-30s %-30s %-30s %-30s\n" "$siteId" "$remotesiteId" "\"${lookup_array[$l1]}\""
		done

		echo -e "\n$bar1"
		echo $CBCYAN"Displaying shard status on this site ..."$CNORMAL
		echo "$bar1"

		tput setaf 6;
		printf "\n%-50s %-10s%-20s\n" "Shard" "Status" "Is This BackupDB?"
		tput sgr0;

		ssh $USE_USER@${DUT_IP_ARRAY[$i]} printf \"listshards $siteId\\ndisconnect\\ny\\n\" \| nc qns01 9091 | sed -e 's///g' -e '/^$/d' | grep -v 'osgi\|Rebalance' | awk '{ if (FNR == 1) next; printf("%-50s ", $2); if ($3 ~ "online") { system("tput setaf 2"); printf("%-10s", $3); system("tput sgr0"); printf("%-20s\n", $4);} else {system("tput setaf 1"); printf("%-10s", $3); system("tput sgr0"); printf("%-20s\n", $4);} }'

		if [[ $ONCE_ONLY == 0 ]]; then {
			read -a ring_set_array <<<$(awk 'BEGIN { 
					RS = "END]";
					FS = "\n";
					session_set_count = 0;
				}
				{
					flag = 0;
					for(i=1; i<=NF; i++)	{
						if($i ~ /SESSION-SET[0-9]*]/) {
							++session_set_count;
							flag = 1;
						}

						if(flag == 1 && match($i, "^MEMBER") > 0)	{
							split($i, values, "=");
							split(values[2], hostname, ":")

							if(arr[values[1]] == "") {
								arr[values[1]] = hostname[1];
							}
							else {
								str = "";
								len = asort(arr, arr1);
								for (j=1;j<=len;j++) str = str arr1[j] ":";
								delete arr; delete arr1;
								set_array[str] = str;
								arr[values[1]] = hostname[1];
							}

						}
						if (i == NF) {
							str = "";
							len = asort(arr, arr1);
							for (j=1;j<=len;j++) str = str arr1[j] ":";
							delete arr; delete arr1;
							set_array[str] = str;
						}
					}
				}
				END {
					len = asort(set_array);
					for (k=1; k<=len;k++) printf("%s\n", set_array[k]);
				}' $TMP_PATH$MONGO_CONFIG_FILENAME)

			temp_cache_records=`mktemp`;

			ssh $USE_USER@${DUT_IP_ARRAY[$i]} mongo $MONGO_AUTH --quiet $adminDB/sharding --eval \"rs.slaveOk\(\)\;db.cache_config.find\({}\,{_id:0\,last_build_time:0}\).pretty\(\).shellPrint\(\)\" | grep -v 'port\|{\|}\|]' | sed 's/  //g' > $temp_cache_records


			echo -e "\n$bar1"
			echo $CBCYAN"Displaying ring sets currently configured ..."$CNORMAL
			echo "$bar1"

			for ring_set in ${ring_set_array[*]}; do
				awk -v ring_set=$ring_set 'BEGIN { 
						FS="\n";
						RS="[";
						flag = 0;
						split(ring_set, ring_set_array0, ":");
						len = length(ring_set_array0) - 1;
						new_ring_set = toupper(ring_set);
						split(new_ring_set, ring_set_array, ":");
						for(i=1; i<=len; i++) {
							if (i < len)
								printf("%s, ", ring_set_array0[i]);
							else
								printf("%s ", ring_set_array0[i]);
						}
					}
					{ 
						if (FNR == 1) next;
						str = toupper($0);
	
						count = 0;
						for (i=1; i<=len; i++) {
							if (match(str, ring_set_array[i]) > 0) count++;
							if (count == len) {
								flag++;
							}
						}
					}
					END {
						if (flag == 1) {
							system("tput bold; tput setaf 2")
							printf("%15s%-30s\n", "", "Set Configured As Ring Set");
							system("tput sgr0")
						}
						else if (flag > 1) {
							system("tput bold; tput setaf 5")
							printf("%15s%-30s\n", "", "Set Configured Multiple Times");
							system("tput sgr0")
						}
						else if (flag == 0) {
							system("tput bold; tput setaf 1")
							printf("%15s%-30s\n", "", "Set Not Configured As Ring Set");
							system("tput sgr0")
						}
					}' $temp_cache_records
			done
		}
		fi

		ONCE_ONLY=1;
	done
	rm -f $temp_file_site_records
	rm -f $temp_cache_records
}

check_timezone()
{
	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		CPS_SITE_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh)
		echo -e $CBYELLOW"\nDisplaying 'Timezone' status for all VMs on $CBCYAN${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]}$CBYELLOW ..."$CNORMAL
		echo "$bar2"
		tput setaf 6;
		printf "%-25s%-30s%s\n" "HOSTNAME" "TIMEZONE"
		tput sgr0;
		echo "$bar2"
		for hn in $CPS_SITE_VM_LIST; do
			printf "%-40s" $CBMAGENTA"$hn"$CNORMAL
			ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $hn \'date \+\"\%\:z \%Z\"\' 
		done
	}
	done
}

check_mongo_version()
{
	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		CPS_SITE_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh) 
		echo -e $CBYELLOW"\nDisplaying 'mongo version' for all VMs on $CBCYAN${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]}$CBYELLOW ..."$CNORMAL
		echo "$bar2"
		tput setaf 6;
		printf "%-25s%-30s%s\n" "HOSTNAME" "MONGO VERSION"
		tput sgr0;
		echo "$bar2"
		for hn in $CPS_SITE_VM_LIST; do
			printf "%-40s" $CBMAGENTA"$hn"$CNORMAL
			ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $hn mongo --version 
		done
	}
	done
}

check_redis_status()
{

	for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
	{
		CPS_LB_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep lb) 
		echo -e $CBYELLOW"\nDisplaying 'redis status' for lb VMs on $CBCYAN${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]}$CBYELLOW ..."$CNORMAL

		echo "$bar2"
		for hn in $CPS_LB_VM_LIST; do
			printf "%-40s\n" $CBMAGENTA"$hn"$CNORMAL
			echo "$bar2"
			ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $hn netstat -anp | grep redis-server | grep LISTEN
			echo "$bar2"
		done
	}
	done
}

set_priority_python()
{
	for setname in `grep "\[.*\]" $TMP_PATH$MONGO_CONFIG_FILENAME | grep -v END | cut -d[ -f2 | cut -d] -f1`; do
		echo -e $CBYELLOW"\nSetting priority for SETNAME=$CBGREEN$setname\n"$CNORMAL
		ssh $USE_USER@${DUT_IP_ARRAY[0]} ssh $INSTALLER_HOSTNAME "$SET_PRIORITY_SCRIPT_PATH -r $setname -l /tmp/set_priority_$mydate.log -p DSC" 
	done
}

remove_latency()
{
        for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
        {
		echo -e $CBYELLOW"\nRemoving Latency from the VMs on [ ${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]} ]:"$CNORMAL
		echo "=============================================================================================================="$CBCYAN

                CPS_ALL_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep -v installer)
                CPS_ALL_VM_ARRAY=( $CPS_ALL_VM_LIST )
#                CPS_QNS_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts.sh)
#                CPS_DB_VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep sessionmgr)

                for node in ${CPS_ALL_VM_ARRAY[*]}; do
			echo "Removing latency from: $node on ${DUT_IP_ARRAY[$i]}"
                        ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $node "sed -i \'/netem/ s/add/del/\' /etc/rc.local"
                        ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $node "/etc/rc.local"
                        ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $node "sed -i \'/netem/ d\' /etc/rc.local"
                        ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $node "/etc/rc.local"
		done
	}
	done
	echo "Removed latency from all VMs of all CPS sites"$CNORMAL
}

add_latency()
{
#	remove_latency;
        for((i=0; i<${#DUT_IP_ARRAY[*]}; i++)); do
        {
		echo -e $CBYELLOW"\nAdding Latency on the VMs of [ ${DUT_SITE_ARRAY[$i]}:${DUT_IP_ARRAY[$i]} ]:"$CNORMAL

		for item in ${VM_INTERFACE_ARRAY[*]}; do
			VM_LIST=$(ssh $USE_USER@${DUT_IP_ARRAY[$i]} hosts-all.sh | grep -v installer | grep ${item%:*})
			VM_ARRAY=( $VM_LIST )
			INTERFACE_LIST=${item#*:}
			INTERFACE_ARRAY=( $(echo ${VM_INTERFACE_ARRAY[0]#*:} | sed 's/,/ /g') )

			for node in ${VM_ARRAY[*]}; do
				for interface in ${INTERFACE_ARRAY[*]}; do
					ssh $USE_USER@${DUT_IP_ARRAY[$i]} "ssh $node \"echo \\"tc qdisc add dev $interface root netem delay $LATENCY\\"\\"ms\\" >> /etc/rc.local\""
				done
				ssh $USE_USER@${DUT_IP_ARRAY[$i]} ssh $node "/etc/rc.local"
				echo "Latency added on ${DUT_SITE_ARRAY[$i]}:$node"
			done
		done
	}
	done
}

parse_options "$@";
$EXECUTE_FUNCTION;
#check_qns_status;
#check_replica_status;
#recover_replica_sets;
#sleep 30
#set_priority_python;
#check_replica_status;
#check_replica_status;
#check_peer_status;
#check_monit_status;
#check_redis_status;
#check_timezone;
#check_df_status;
#check_mongo_version;
#check_session_counts;
#check_config_status;
#check_db_records;
#check_latency_status;
#remove_latency;


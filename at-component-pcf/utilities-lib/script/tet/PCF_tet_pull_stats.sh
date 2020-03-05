#!/bin/bash

######################################################################################################################################
#                       Filename        :       tet_pull_stats.sh
#                       Author          :       Prosenjit Chatterjee
#                       Date            :       26-02-2020
#                       Type Of Stats   :       sar,top,vmstat,iostat,mpstat
######################################################################################################################################


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
TOP_QPS_PATH="/var/qps/bin/control/top_qps.sh"
TRAP_PATH="/var/log/snmp/trap"
MONGOLOG_PATH="/var/log/mongodb"
MONDB_CALLMODEL_PATH="/var/log/broadhop/scripts/mon_db_for_callmodel_"
MONDB_LBFAILOVER_PATH="/var/log/broadhop/scripts/mon_db_for_lb_failover_"
PUPPET_LOG_PATH="/var/log/puppet.log"
MESSAGE_LOG_PATH="/var/log/messages"
INTERFACE_STATS_PATH="/sys/class/net/"

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

TMP_PATH="/tmp/"
CONFIG_FILE=""
CONFIG_FILENAME=""
NO_ARGS=0
EXIT_STATUS=60
mydate=`date +"%d-%m-%Y-%H-%M-%S"`
SEPARATOR="$CBBLUE==============================================================================================================$CNORMAL"
SSH_TIMEOUT=2
DEFAULT_CONFIG_CHECK_INTERVAL=5
CONNECTION_RECHECK_INTERVAL=1
MIN_DISK_SPACE=500
MONITORING_DISK_SPACE=1

TIMED_STATS_LIST="top sar vmstat iostat mpstat"
#UNTIMED_STATS_LIST="bulkstat trap mongologs mondblogs puppetlogs messagelogs interfacestats"

#DISPLAY_LIST=$TIMED_STATS_LIST" "$UNTIMED_STATS_LIST" ""Exit_&_Keep_Capturing Exit_&_Stop_Capture"
DISPLAY_LIST=$TIMED_STATS_LIST" ""Exit_&_Keep_Capturing Exit_&_Stop_Capture"
DISPLAY_ARRAY=( $DISPLAY_LIST )

# STATS_LIST=$TIMED_STATS_LIST" "$UNTIMED_STATS_LIST
STATS_LIST=$TIMED_STATS_LIST
STATS_ARRAY=( $STATS_LIST )


STATS_TYPE_TOP=${STATS_ARRAY[0]}
STATS_TYPE_SAR=${STATS_ARRAY[1]}
STATS_TYPE_VMSTAT=${STATS_ARRAY[2]}
STATS_TYPE_IOSTAT=${STATS_ARRAY[3]}
STATS_TYPE_MPSTAT=${STATS_ARRAY[4]}
# STATS_TYPE1=${STATS_ARRAY[0]}
# STATS_TYPE2=${STATS_ARRAY[1]}
# STATS_TYPE3=${STATS_ARRAY[2]}
# STATS_TYPE9=${STATS_ARRAY[8]}
# STATS_TYPE10=${STATS_ARRAY[9]}
# STATS_TYPE11=${STATS_ARRAY[10]}
# STATS_TYPE12=${STATS_ARRAY[11]}
# STATS_TYPE13=${STATS_ARRAY[12]}
# STATS_TYPE14=${STATS_ARRAY[13]}
# STATS_TYPE15=${STATS_ARRAY[14]}

# NODE_LIST="kube-master kube-minion"
# NODE_ARRAY=( $NODE_LIST )
# NODE_TYPE1=${NODE_ARRAY[0]}
# NODE_TYPE2=${NODE_ARRAY[1]}

MONGOSTAT_WPID=""
MONGOSTAT_SPID_LIST=""
MONGOTOP_WPID=""
MONGOTOP_SPID_LIST=""
SAR_WPID=""
SAR_SPID=""
TOP_WPID=""
TOP_SPID=""
TOP_QPS_WPID=""
TOP_QPS_SPID=""
VMSTAT_WPID=""
VMSTAT_SPID=""
IOSTAT_WPID=""
IOSTAT_SPID=""
MPSTAT_WPID=""
MPSTAT_SPID=""
BULKSTAT_WPID=""
BULKSTAT_SPID=""
TRAP_WPID=""
TRAP_SPID_LIST=""
MONGOLOG_WPID=""
MONGOLOG_SPID_LIST=""

TIMESTAMP=${mydate}
echo -e $CBYELLOW"\nCURRENT LOCAL TIMESTAMP: [$CBCYAN $TIMESTAMP $CBYELLOW]\n$CNORMAL"

usage()
{
        echo -e "$SEPARATOR"
        echo -e $CBMAGENTA"About: $CNORMAL"
        echo -e $CBCYAN"This script can be used to capture and save various stats from CPS at run time for system test analysis. The stats are saved in a file based upon the path you provide and can therefore be observed at run time by tailing the particular file. Furthermore, the script allows you to exit but keep capturing the stats in the background, so you don't need to keep the terminal window open, from where you ran the script. The script also allows run time modification of time duration for certain time duration specific captures by editing the config file while the stats are being captured."
        echo -e "\nFollow the details below to understand how this script can be run. \nThe script can be invoked from any linux machine that can reach your DUT(CPS)."
        echo -e "$CBMAGENTA$FUNCNAME: $CNORMAL"
        echo "$CBGREEN${PWD}/`basename $0` -c <config_filename> -d <DUT IP> -o <Output Folder Path>$CNORMAL"
        echo -e $CBMAGENTA"OPTIONS: $CNORMAL"
        echo -e "$CBYELLOW-c $CNORMAL[Optional]\t: Absolute path to config filename. Optional only if '-k' option is used, else this field is Mandatory"
        echo -e "$CBYELLOW-o $CNORMAL[Mandatory]\t: Absolute path to folder where stats should be saved or from where stats capture needs to be stopped, in case of using the '-k' option."
        echo -e "$CBYELLOW-d $CNORMAL[Optional]\t: IP address of pcrfclient VM on DUT (CPS). Mandatory except when using the '-k' option."
        echo -e "$CBYELLOW-a $CNORMAL[Optional]\t: Capture all stats without prompt."
        echo -e "$CBYELLOW-s $CNORMAL[Optional]\t: Capture selected stats without prompt. This option is given precedence over -a. Give a ',' and '-' separated list of stats to be captured, assuming you know the list displayed in the Menu for selective stats capture. If you don't, then run the script without -a or -s option on command line to display this list."
        echo -e "$CBYELLOW-k $CNORMAL[Optional]\t: Stop existing captures started in background. You need to provide the path where existing capture is being saved."
        echo -e "$CBYELLOW-u/-h $CNORMAL[Optional]: Shows help / usage of the script."
        echo -e "$CBYELLOW-e $CNORMAL[Optional]\t: Shows examples for creation of config file for this script."
        echo -e "$CBYELLOW-t $CNORMAL[Optional]\t: Local timestamp at which any running stats capture should be stopped. Input can be a timestamp in dd-mm-yy-hr-min-sec format or it could be in \"1 hour\", \"30 mins\", etc. format, such that stats will be captured till this time from now."
        echo -e "$CBMAGENTA\nEXAMPLES: $CNORMAL"
        echo -e $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c /root/Temp/config.txt -o /home/Tyw13415y -d 10.11.12.13 $CNORMAL ---> Stats will be saved in the folder provided with -o option. The stats filename will describe the type of stats and the filename will also take input from 3rd parameter of a row in the config file you provide as input. Check more details with option -e to this script."
        echo -e $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c /root/Temp/config.txt -o /home/Tyw13415y -d 10.11.12.13 -a $CNORMAL ---> No Menu displayed, instead all stats, for which configuration is provided in the config file, will be captured and saved in the folder provided with -o option."
        echo -e $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c /root/Temp/config.txt -o /home/Tyw13415y -d 10.11.12.13 -s 1-4,7,9,10 $CNORMAL ---> No Menu displayed, instead stats from the input list provided herewith, will be captured and saved in the folder provided with -o option. Make sure the respective stats config is provided in the config file."
        echo -e $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -d 10.11.12.13 -k -o /home/Tyw13415y $CNORMAL ---> Stats that are being captured at the path /home/Tyw13415y, in background, by a previous invocation of this script, can be stopped with this command at any later time."
        echo -e $SEPARATOR

}

usage_conf()
{
        echo -e $SEPARATOR
	echo -e $CBYELLOW"\nThe config file is in csv format and needs to have following details:"
        echo -e $CBMAGENTA"\na) First parameter$CNORMAL of a row must be one of top / sar / vmstat / iostat / mpstat / "
        echo -e $CBMAGENTA"\nb) Second parameter$CNORMAL of the row must be a number mentioning the duration of gaps between stats capture, e.g. in case of iostat, mpstat, vmstat, etc. This value $CBYELLOW\"can be modified at run time\"$CNORMAL to capture at a different duration than what was provided when starting the script. The script automatically checks for any changes to duration provided in the file, every 5 seconds. Note that this parameter is not used for stats like bulkstat, traps, capture_env, consolidated_log, etc. but you MUST provide a zero(0) value in this field for such stats."
        echo -e $CBMAGENTA"\nc) Third parameter$CNORMAL can be any name you want to be suffixed to the particular stats filename that is saved by this script at the location you provided with -o option."
        echo -e $CBMAGENTA"\nd) Fourth and subsequent parameters$CNORMAL in a row are provided on basis of the respective stat mentioned as the first parameter in the row. Check below:"
        echo -e $CBMAGENTA"\nEXAMPLE:"
        echo -e $CBGREEN"### This is an example config file. ###"
        echo -e $CCYAN"sar,5,SITE1,qns,lb,sessionmgr"
        echo -e "### Rows starting with '#' are for entering comments in the config file and not used by the script."
        echo -e "iostat,5,SESSION-SITE1,label1,label2"
        echo -e "sar,2,SESSION-SITE2,label3,label4,label5"
        echo -e "mpstat,1,SESSION-SITE1-set01,label1"
        echo -e "vmstat,5,SESSION-SITE1-set03,label5"
		echo -e "#vmstat,15,SESSION-SITE1-set03,label4"
        echo -e $CBGREEN"### The example config file ends here. ###"$CNORMAL
        echo -e $SEPARATOR
}

parse_options()
{
echo -e $SEPARATOR"\nParsing options provided on command line ..."
while getopts ":c:d:o:t:s:x:p:m:kauhe" options; do
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
                e)    	echo -e "Hmm! You requested for examples of config file, Let me help you out!"
                        usage_conf
                        exit 0
                        ;;
                d)	DUT_IP="${OPTARG}"
			if [[ "$DUT_IP" =~ ([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
				:
			else
				echo -e $CBRED"You seem to have provided an invalid IP address, please retry with IP address in correct IPv4 format."$CNORMAL
	                        usage
        	                exit $EXIT_STATUS
			fi
			D_SET=0
                        ;;
                k)	K_SET=0
                        ;;
                a)	A_SET=0
                        ;;
                t)      TILL_TIME="${OPTARG}"
                        echo "You have requested to capture the stats till time [$CBCYAN $TILL_TIME $CNORMAL]";
                        T_SET=0
                        ;;
                s)      INPUT_STATS_LIST="${OPTARG}"
                        S_SET=0
                        ;;
				x)      USE_USER="${OPTARG}"
                        ;;
				p)      KEY_PATS="${OPTARG}"
                        ;;
				m)      KEY_MASTER="${OPTARG}"
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

validate_options()
{
        echo -e $SEPARATOR"\nValidating the command line options ..."

	if [[ $K_SET == 1 ]]; then
        	if [[ $C_SET -eq 1 || $CONFIG_FILE == "" ]]; then
                	echo -e "Mandatory option [$CBRED -c $CNORMAL] is missing or passed as argument to another option. Cannot proceed. Check usage below.$CBRED \nExiting now!"$CNORMAL
			usage;
	                exit $EXIT_STATUS
        	else
                	if [[ ! -e $CONFIG_FILE ]] || [[ ! -f $CONFIG_FILE ]] ; then
                        	echo "Configuration file [$CBRED $CONFIG_FILE $CNORMAL] does not exist or is not a regular file. This is a mandatory input.$CBRED Exiting now!"$CNORMAL
	                        exit $EXIT_STATUS
	                fi
	        fi

		if [[ $O_SET -eq 1 || $OUTPUT_FILE_PATH == "" ]]; then
                	echo "Mandatory option [$CBRED -o $CNORMAL] is missing or passed as argument to another option. Cannot proceed.$CBRED Exiting now!"$CNORMAL
	                exit $EXIT_STATUS
        	else
                	if [[ ! -d $OUTPUT_FILE_PATH ]] ; then
                        	echo "Output path [$CBRED $OUTPUT_FILE_PATH $CNORMAL] does not exist.$CBGREEN Creating this path now."$CNORMAL
	                       	mkdir -p $OUTPUT_FILE_PATH
			fi
		fi

		if [[ $D_SET -eq 1 || $DUT_IP == "" ]]; then
                	echo "Mandatory option [$CBRED -d $CNORMAL] is missing or passed as argument to another option. Cannot proceed.$CBRED Exiting now!"$CNORMAL
	                exit $EXIT_STATUS
		fi

                if  [[ $T_SET -eq 0 ]]; then
                        if [[ $TILL_TIME =~ [0-3][0-9]-[0-1][0-9]-[0-9]{4}-[0-2][0-9]-[0-5][0-9] ]]; then
                                temp_time=`awk -F"-" '{printf("%s/%s/%s %s:%s",$2,$1,$3,$4,$5)}' <<<"$TILL_TIME"`
                                END_TIME=$(date -d "$temp_time" +"%s")
                                if [[ $? -ne 0 ]]; then
                                        echo "Looks like the date you have mentioned is invalid or not in desired format. Please retry with correct input. Exiting Now!!!"
                                        exit $EXIT_STATUS
                                fi
                                echo "You have requested to capture stats till the local time [$CBCYAN $(date -d "$temp_time" +"%d-%m-%Y-%H-%M-%S") $CNORMAL]"
                        else
                                END_TIME=$(date -d "$TILL_TIME" +"%s")
                                if [[ $? -ne 0 ]]; then
                                        echo "Looks like the date you have mentioned is invalid or not in desired format. Please retry with correct input. Exiting Now!!!"
                                        exit $EXIT_STATUS
                                fi
                                echo "You have requested to capture stats till the local time [$CBCYAN $(date -d "$TILL_TIME" +"%d-%m-%Y-%H-%M-%S") $CNORMAL]"
                        fi

			CURRENT_TIME=$(date -d "now" +"%s")
			if [[ $CURRENT_TIME -gt	$END_TIME ]]; then
                                echo "Please give a future timestamp with '-t' option. Exiting Now!!!"
				exit $EXIT_STATUS
			fi
                fi
		
		if [[ $S_SET -eq 0 && $INPUT_STATS_LIST =~ [^0-9,-] ]]; then
			echo $CBRED"Looks like the input you have provided for selected stats capture with '-s' option is not in desired format. Please check usage. Exiting Now!!!"$CNORMAL
			exit $EXIT_STATUS
		else
			SELECTED_STATS_LIST=$(echo $INPUT_STATS_LIST | awk -F"," -v q=\' '{ for(n=1; n<=NF; n++) { if($n ~ "-") { command = sprintf("echo %s | awk -F\"-\" %s{ for(i=$1; i<=$2; i++) printf(\"%%s\\n\", i)}%s", $n, q, q); system(command); } else printf("%s\n", $n); } }' | sort -n -u)
			SELECTED_STATS_LIST=( $SELECTED_STATS_LIST )
		fi
	else
		if [[ $O_SET -eq 1 || $OUTPUT_FILE_PATH == "" || $D_SET -eq 1 || $DUT_IP == "" ]]; then
                	echo "Mandatory option(s) [$CBRED -o/-d $CNORMAL] is missing or passed as argument to another option. Cannot proceed.$CBRED Exiting now!"$CNORMAL
	        	exit $EXIT_STATUS
	        else
        	        if [[ ! -d $OUTPUT_FILE_PATH ]] ; then
                	        echo "Output path [$CBRED $OUTPUT_FILE_PATH $CNORMAL] does not exist. Cannot proceed.$CBRED Exiting now!"$CNORMAL
	        		exit $EXIT_STATUS
			fi
		fi
	fi
        echo -e "Completed validating options provided on command line ..."
}

validate_config()
{
        echo -e $SEPARATOR"\nValidating the config file ..."

        if [[ -e ${CONFIG_FILE}.orig ]]; then
                echo -e $CBGREEN"Original config file with name [$CBYELLOW $CONFIG_FILE.orig $CBGREEN] already exists hence not creating a new one.$CNORMAL"
        else
                sed -i.orig 's/ //g' $CONFIG_FILE
                echo -e "Saved original config file with name [$CBYELLOW $CONFIG_FILE.orig $CNORMAL]"
        fi

        echo -e "Checking and removing duplicate entries if present in config file ..."
        uniq $CONFIG_FILE > $TMP_HOME$CONFIG_FILENAME.tmp
        mv $TMP_HOME$CONFIG_FILENAME.tmp $CONFIG_FILE

        tput bold; tput setaf 1;
        awk -F"," -v mongo="mongo" -v config_file="$CONFIG_FILE" -v stats_list="$STATS_LIST" -v exit_code=$EXIT_STATUS -v node_list="$NODE_LIST" \
        'BEGIN { config_error="Configuration File Error."
		}
        /^[^#]/ {
		if ( index(stats_list, $1) == 0 || $1 == "" ) {
				printf("%s Please verify entries in column 1 of [ %s ]. Appears to be an issue with config. Exiting now!\n", config_error, config_file);
                        exit exit_code;
                }
                if ( !match($2, /[1-9]*/ ) ) {
                        printf("%s Please verify entries in column 2 of [ %s ]. Appears to be an issue with config. Exiting now!\n", config_error, config_file);
                        exit exit_code;
                }
		if (arr[$1] == "") 
			arr[$1] = $1; 
		else {
			if ( match($1, mongo) == 0) {
	                        printf("%s Please verify entries in column 1 of [ %s ]. Appears you have duplicate entries for \"%s\". Exiting now!\n", config_error, config_file, $1);
        	                exit exit_code;
			}
		}
        }' $CONFIG_FILE
        if [[ $? -eq $EXIT_STATUS ]]; then
                tput sgr0;
                exit $EXIT_STATUS;
        fi
        
	tput sgr0;
        echo  "Completed Validation of config file [$CBYELLOW $CONFIG_FILE $CNORMAL] ..."
}

verify_connectivity()
{
        echo -e $SEPARATOR"\nVerifying password-less connectivity to DUT IP provided on command line with '-d' option ..."
	ssh -i ${KEY_PATS} -o BatchMode=yes -o ConnectTimeout=$SSH_TIMEOUT $USE_USER@$DUT_IP exit &>/dev/null
	if [[ $? -ne 0 ]]; then
                        tput bold; tput setaf 1;
                        printf "Connectivity NOT working for IP [ %s ]. Ensure passwordless connectivity to this IP is setup before rerunning. Exiting now ...\n" $DUT_IP;
                        tput bold; tput setaf 5;
                        printf "To enable passwordless connection to an IP, run following commands as root on the local machine from where you want to ssh.\n"
                        printf "ssh-keygen\n"
                        printf "keep-pressing ENTER key unless it asks if you want to Overwrite, in which case select <n>.\n"
                        printf "ssh-copy-id root@<Destination machine IP>\n"
                        printf "Enter the password for ssh to destination machine. This is one time.\n"
                        printf "You should now be able to do a passwordless ssh using ssh root@<Destination machine IP>\n"
                        tput sgr0;
                        exit $EXIT_STATUS;
	fi
        echo  "Connecivity working to IP [$CBYELLOW $DUT_IP $CNORMAL] ..."
	
	local_time=$(date)
	remote_time=$(ssh -i ${KEY_PATS} $USE_USER@$DUT_IP date)
	local_tz=$(date +%Z)
	remote_tz=$(ssh -i ${KEY_PATS} $USE_USER@$DUT_IP "date +%Z")

	DUT_TIMESTAMP=$(date -d "$remote_time" +"%d-%m-%Y-%H-%M-%S")
	time_diff=$(( `date -d "$local_time" +%s` - `date -d "$remote_time" +%s` ))
	
        echo  -e $CBYELLOW"\nCURRENT DUT TIMESTAMP: [$CBCYAN $DUT_TIMESTAMP $CBYELLOW]$CNORMAL"
        echo  -e "\nOFFSET BETWEEN LOCAL AND DUT TIMESTAMPS: [$CBCYAN $time_diff seconds ].$CBRED You should sync the times if there is a difference of more than few seconds.$CNORMAL"

	if [[ $local_tz != $remote_tz ]]; then
		echo  -e $CBRED"WARNING:$CNORMAL The local ($local_tz) and remote ($remote_tz)$CBRED TIMEZONES$CNORMAL do not match. You should have common timezones for ease in matching time of stats captured by this script w.r.t DUT timestamp.$CNORMAL"
	fi
}

validate_disk_space()
{
        echo -e $SEPARATOR"\nVerifying DISK SPACE in root partition ..."
	min_space=$(( $MIN_DISK_SPACE * 1024 ))
	disk_space=$(df -k | awk '{if ($NF ~ "/$") print $(NF-2)}')

	echo -e $CBYELLOW"CURRENT DISK SPACE IN ROOT PARTITION: [$CBCYAN $disk_space KB $CBYELLOW]. The stats capture will automatically stop in case the disk space reduces below [$CBCYAN $min_space KB $CBYELLOW]"$CNORMAL
	if [[ $disk_space -le $min_space ]]; then
		echo -e "Disk space is only [$CBRED $disk_space KB $CNORMAL] in root partition. You need more than$CBGREEN 500 MB$CNORMAL of space. Hence exiting!!!"
		exit $EXIT_STATUS
	fi
}
parse_options "$@";
validate_options;

pull_top_stats()
{
	if [[ $TOP_OUT_FILE == "" ]]; then
		TOP_OUT_FILE="$OUTPUT_FILE_PATH$STATS_TYPE_TOP"
	fi
	while [[ 1 ]]; do
	awk -F"," -v key_master="$KEY_MASTER" -v key_pats="$KEY_PATS" -v user="$USE_USER" -v ip="$DUT_IP" -v stype="$STATS_TYPE_TOP" -v hosts_list="${CPS_HOSTS_LIST[*]}" -v out_file="$TOP_OUT_FILE" -v ctime="$TIMESTAMP" ' BEGIN{
				 orig_out_file = out_file; split(hosts_list, hosts, " ");
				 len_hosts = length(hosts);
				 bar1="==================================================================================================="
	}
	/^[^#]/	{
			if ($1 == stype) {
				timer = $2
				out_file = orig_out_file "_" $3 "_" ctime;
				for(i=4;i<=NF;i++) {
					for (j=1;j<=len_hosts;j++) {
						temp=""
						command = sprintf("ssh -i %s %s@%s  kubectl get node %s  --show-labels |  grep -Eo '"'node-type=\\\w+?-?\\\w+'"' | cut -d'"'='"' -f2- ", key_pats, user, ip, hosts[j]);
						command |& getline temp;
						close(command);
						if(match(temp, $i) > 0) {
							printf("%s\n", bar1) >> out_file
							system("wait");
							printf("HOSTNAME\t: %s\n", hosts[j]) >> out_file
							system("wait");
                                                        printf("OUTPUT\t\t: %s\n", stype) >> out_file
							system("wait");
                                                        printf("TIMESTAMP\t: ") >> out_file
							system("wait");
							command1 = sprintf("ssh -i %s %s@%s nice -n19 ssh -i %s %s nice -n19 date >> %s", key_pats, user, ip, key_master, hosts[j], out_file);
							system(command1);
							system("wait");
                                                        printf("%s\n", bar1) >> out_file
                                                        command2 = sprintf("ssh -i %s %s@%s nice -n19 ssh -i %s %s nice -n19 %s -b -n1 >> %s", key_pats, user, ip, key_master, hosts[j], stype, out_file);
                                                        system(command2);
							system("wait");
							system("sleep 0.5");
						}
					}
				}
			}
	}
	END {
		if (timer != "") { 
			command0=sprintf("sleep %s", timer);
			printf("\nNext Capture in %s seconds ...\n", timer) >> out_file;
			system("wait");
			system(command0);
			system("wait");
		}
	}' $CONFIG_FILE
	wait
	done &
	TOP_SPID=$!
	echo $TOP_SPID > $OUTPUT_FILE_PATH$TOP_PID_FILE
}

pull_sar_stats()
{
	if [[ $SAR_OUT_FILE == "" ]]; then
		SAR_OUT_FILE="$OUTPUT_FILE_PATH$STATS_TYPE_SAR"
	fi

	while [[ 1 ]]; do
	awk -F"," -v q=\' -v key_master="$KEY_MASTER" -v key_pats="$KEY_PATS" -v user="$USE_USER" -v ip="$DUT_IP" -v stype="$STATS_TYPE_SAR" -v hosts_list="${CPS_HOSTS_LIST[*]}" -v out_file="$SAR_OUT_FILE" -v ctime="$TIMESTAMP" ' BEGIN{
				orig_out_file = out_file; split(hosts_list, hosts, " ");
				len_hosts = length(hosts);
				bar1="======================================================================================================================================"
				flag=0;
				str_cpu = "          CPU       %user     %nice     %system   %iowait   %steal    %idle"
				str_memory = "          kbmemfree kbmemused %memused  kbbuffers kbcached  kbcommit  %commit"
	}
	/^[^#]/	{
			if ($1 == stype) {
				timer = $2
				count = 0
				stype_cpu = stype " " timer " 1 ";
				out_file_cpu = orig_out_file "_" "CPU" "_" $3 "_" ctime;
				stype_memory = stype " -r " timer " 1 ";
				out_file_memory = orig_out_file "_" "MEMORY" "_" $3 "_" ctime;

				for(i=4;i<=NF;i++) {
					for (j=1;j<=len_hosts;j++) {
						temp=""
						command = sprintf("ssh -i %s %s@%s  kubectl get node %s  --show-labels |  grep -Eo '"'node-type=\\\w+?-?\\\w+'"' | cut -d'"'='"' -f2- ", key_pats, user, ip, hosts[j]);
						command |& getline temp;
						close(command);
						if(match(temp, $i) > 0) {
							if (flag == 0) {
								printf("%s\n", bar1) >> out_file_cpu
								printf("%s\n", str_cpu) >> out_file_cpu
								printf("%s\n", bar1) >> out_file_memory
								printf("%s\n", str_memory) >> out_file_memory
								printf("%s\n", bar1) >> out_file_cpu
								printf("%s\n", bar1) >> out_file_memory
								system("wait");
								flag = 1;
							}
							system("wait");
							command3 = sprintf("echo -n `ssh -i %s %s@%s nice -n19 ssh -i %s %s \"nice -n19 %s \\\| nice -n19 tail -1 \\\; nice -n19 hostname \\\; nice -n19 date +\\\"%%d-%%m-%%Y-%%H-%%M-%%S\\\"\"` | nice -n19 awk -F\"[ ]\" %s{for(i=1;i<=(NF-2);i++) printf(\"%%-9s \", $i); for(i=(NF-1);i<=NF;i++) printf(\"%%-30s\", $i); printf(\"\\n\") }%s  >> %s &", key_pats, user, ip, key_master, hosts[j], stype_cpu, q, q, out_file_cpu);
                                                        system(command3);
							command4 = sprintf("echo -n `ssh -i %s %s@%s nice -n19 ssh -i %s %s \"nice -n19 %s \\\| nice -n19 tail -1 \\\; nice -n19 hostname \\\; nice -n19 date +\\\"%%d-%%m-%%Y-%%H-%%M-%%S\\\"\"` | nice -n19 awk -F\"[ ]\" %s{for(i=1;i<=(NF-2);i++) printf(\"%%-9s \", $i); for(i=(NF-1);i<=NF;i++) printf(\"%%-30s\", $i); printf(\"\\n\") }%s  >> %s &", key_pats, user, ip, key_master, hosts[j], stype_memory, q, q, out_file_memory);
                                                        system(command4);
							system("sleep 0.05");
							count++;
						}
					}
				}
			}
	}
	END {
		if (timer != "") {
			command0=sprintf("sleep %s", timer - count*0.05);
			system(command0);
			system("wait");
			printf("\nNext Capture in %s seconds ...\n", timer) >> out_file_cpu;
			system("wait");
			printf("\nNext Capture in %s seconds ...\n", timer) >> out_file_memory;
			system("wait");
		}
	}' $CONFIG_FILE
	wait
	done &
	SAR_SPID=$!
	echo $SAR_SPID > $OUTPUT_FILE_PATH$SAR_PID_FILE
}

pull_vm_stats()
{
	if [[ $VMSTAT_OUT_FILE == "" ]]; then
		VMSTAT_OUT_FILE="$OUTPUT_FILE_PATH$STATS_TYPE_VMSTAT"
	fi

	while [[ 1 ]]; do
	awk -F"," -v q=\' -v key_master="$KEY_MASTER" -v key_pats="$KEY_PATS" -v user="$USE_USER" -v ip="$DUT_IP" -v stype="$STATS_TYPE_VMSTAT" -v hosts_list="${CPS_HOSTS_LIST[*]}" -v out_file="$VMSTAT_OUT_FILE" -v ctime="$TIMESTAMP" ' BEGIN{
				orig_out_file = out_file; split(hosts_list, hosts, " ");
				len_hosts = length(hosts);
				bar1="=============================================================================================================================================================================================================================="
				flag=0;
	}
	/^[^#]/	{
			if ($1 == stype) {
				timer = $2
				out_file = orig_out_file "_" $3 "_" ctime;
				count = 0;
				for(i=4;i<=NF;i++) {
					for (j=1;j<=len_hosts;j++) {
						temp=""
						command = sprintf("ssh -i %s %s@%s  kubectl get node %s  --show-labels |  grep -Eo '"'node-type=\\\w+?-?\\\w+'"' | cut -d'"'='"' -f2- ", key_pats, user, ip, hosts[j]);
						command |& getline temp;
						close(command);
						if(match(temp, $i) > 0) {
							if (flag == 0) {
								printf("%s\n", bar1) >> out_file
                                                        	command1 = sprintf("ssh -i %s %s@%s nice -n19 ssh -i %s %s nice -n19 %s | sed 1d | head -1 | awk -F\" \" %s{for(i=1;i<=NF;i++) printf(\"%%-9s \", $i)}%s >> %s", key_pats, user, ip, key_master, hosts[j], stype,  q, q, out_file);
                                                        	system(command1);
								printf("\n%s\n", bar1) >> out_file
								system("wait");
								flag = 1;
							}
							system("wait");
							command2 = sprintf("echo -n `ssh -i %s %s@%s nice -n19 ssh -i %s %s \"nice -n19 %s %s 2 \\\| nice -n19 tail -1 \\\; nice -n19 hostname \\\; nice -n19 date +\\\"%%d-%%m-%%Y-%%H-%%M-%%S\\\"\"` | nice -n19 awk -F\"[ ]\" %s{for(i=1;i<=(NF-2);i++) printf(\"%%-9s \", $i); for(i=(NF-1);i<=NF;i++) printf(\"%%-30s\", $i); printf(\"\\n\") }%s >> %s &", key_pats, user, ip, key_master, hosts[j], stype, timer, q, q, out_file);
                                                        system(command2);
							system("sleep 0.08");
							count++;
						}
					}
				}
			}
	}
	END {
		if (timer != "") {
			command0=sprintf("sleep %s", timer - count*0.08);
			system(command0);
			system("wait");
			printf("\nNext Capture in %s seconds ...\n", timer) >> out_file;
			system("wait");
		}
	}' $CONFIG_FILE
	wait
	done &
	VMSTAT_SPID=$!
	echo $VMSTAT_SPID > $OUTPUT_FILE_PATH$VMSTAT_PID_FILE
}

pull_io_stats()
{
	if [[ $IOSTAT_OUT_FILE == "" ]]; then
		IOSTAT_OUT_FILE="$OUTPUT_FILE_PATH$STATS_TYPE_IOSTAT"
	fi
	while [[ 1 ]]; do
	awk -F"," -v key_master="$KEY_MASTER" -v key_pats="$KEY_PATS" -v user="$USE_USER" -v ip="$DUT_IP" -v stype="$STATS_TYPE_IOSTAT" -v hosts_list="${CPS_HOSTS_LIST[*]}" -v out_file="$IOSTAT_OUT_FILE" -v ctime="$TIMESTAMP" ' BEGIN{
				 orig_out_file = out_file; split(hosts_list, hosts, " ");
				 len_hosts = length(hosts);
				 bar1="============================================================================================================="
	}
	/^[^#]/	{
			if ($1 == stype) {
				timer = $2
				out_file = orig_out_file "_" $3 "_" ctime;
				for(i=4;i<=NF;i++) {
					for (j=1;j<=len_hosts;j++) {
						temp=""
						command = sprintf("ssh -i %s %s@%s  kubectl get node %s  --show-labels |  grep -Eo '"'node-type=\\\w+?-?\\\w+'"' | cut -d'"'='"' -f2- ", key_pats, user, ip, hosts[j]);
						command |& getline temp;
						close(command);
						if(match(temp, $i) > 0) {
							printf("%s\n", bar1) >> out_file
							system("wait");
							printf("HOSTNAME\t: %s\n", hosts[j]) >> out_file
							system("wait");
                                                        printf("OUTPUT\t\t: %s\n", stype) >> out_file
							system("wait");
                                                        printf("TIMESTAMP\t: ") >> out_file
							system("wait");
							command1 = sprintf("ssh -i %s %s@%s nice -n19 ssh -i %s %s nice -n19 date >> %s", key_pats, user, ip, key_master, hosts[j], out_file);
							system(command1);
							system("wait");
                                                        printf("%s\n", bar1) >> out_file
                                                        command2 = sprintf("ssh -i %s %s@%s nice -n19 ssh -i %s %s nice -n19 %s -x -y %s 1 >> %s", key_pats, user, ip, key_master, hosts[j], stype, timer, out_file);
                                                        system(command2);
							system("wait");
						}
					}
				}
			}
	}
	END {
		if (timer != "") {
			command0=sprintf("sleep %s", timer);
			printf("\nNext Capture in %s seconds ...\n", timer) >> out_file;
			system("wait");
			system(command0);
			system("wait");
		}
	}' $CONFIG_FILE
	wait
	done &
	IOSTAT_SPID=$!
	echo $IOSTAT_SPID > $OUTPUT_FILE_PATH$IOSTAT_PID_FILE
}

pull_mp_stats()
{
	if [[ $MPSTAT_OUT_FILE == "" ]]; then
		MPSTAT_OUT_FILE="$OUTPUT_FILE_PATH$STATS_TYPE_MPSTAT"
	fi
	while [[ 1 ]]; do
	awk -F"," -v q=\' -v key_master="$KEY_MASTER" -v key_pats="$KEY_PATS" -v user="$USE_USER" -v ip="$DUT_IP" -v stype="$STATS_TYPE_MPSTAT" -v hosts_list="${CPS_HOSTS_LIST[*]}" -v out_file="$MPSTAT_OUT_FILE" -v ctime="$TIMESTAMP" ' BEGIN{
				orig_out_file = out_file; split(hosts_list, hosts, " ");
				len_hosts = length(hosts);
				bar1="=============================================================================================================================================================================="
				flag=0;
	}
	/^[^#]/	{
			if ($1 == stype) {
				timer = $2
				count = 0;
				out_file = orig_out_file "_" $3 "_" ctime;
				for(i=4;i<=NF;i++) {
					for (j=1;j<=len_hosts;j++) {
						temp=""
						command = sprintf("ssh -i %s %s@%s  kubectl get node %s  --show-labels |  grep -Eo '"'node-type=\\\w+?-?\\\w+'"' | cut -d'"'='"' -f2- ", key_pats, user, ip, hosts[j]);
						command |& getline temp;
						close(command);
						if(match(temp, $i) > 0) {
							if (flag == 0) {
								printf("%s\n", bar1) >> out_file
                                                        	command1 = sprintf("ssh -i %s %s@%s nice -n19 ssh -i %s %s nice -n19 %s | sed 1d | sed 1d | head -1 | awk -F\" \" %s{for(i=1;i<=NF;i++) printf(\"%%-9s \", $i)}%s >> %s", key_pats, user, ip, key_master, hosts[j], stype,  q, q, out_file);
                                                        	system(command1);
								printf("\n%s\n", bar1) >> out_file
								system("wait");
								flag = 1;
							}
							system("wait");
							command2 = sprintf("echo -n `ssh -i %s %s@%s nice -n19 ssh -i %s %s \"nice -n19 %s %s 1 \\\| nice -n19 tail -2 \\\| nice -n19 head -1 \\\; nice -n19 hostname \\\; nice -n19 date +\\\"%%d-%%m-%%Y-%%H-%%M-%%S\\\"\"` | nice -n19 awk -F\"[ ]\" %s{for(i=1;i<=(NF-2);i++) printf(\"%%-9s \", $i); for(i=(NF-1);i<=NF;i++) printf(\"%%-30s\", $i); printf(\"\\n\") }%s  >> %s &", key_pats, user, ip, key_master, hosts[j], stype, timer, q, q, out_file);
                                                        system(command2);
							system("wait");
							system("sleep 0.05");
							count++;
						}
					}
				}
			}
	}
	END {
		if (timer != "") {
			command0=sprintf("sleep %s", timer - count*0.05);
			system(command0);
			system("wait");
			printf("\nNext Capture in %s seconds ...\n", timer) >> out_file;
			system("wait");
		}
	}' $CONFIG_FILE
	wait
	done &
	MPSTAT_SPID=$!
	echo $MPSTAT_SPID > $OUTPUT_FILE_PATH$MPSTAT_PID_FILE
}


modify_config_file()
{
	INPUT_STATUS=$1
	TIME_INTERVAL=""
	TIME_INTERVAL=`cat $CONFIG_FILE | grep ^$INPUT_STATUS | head -1 | awk -F"," '{print $2}' `
	if [ -z $TIME_INTERVAL ] 
	then
		if [ "$INPUT_STATUS" == "mongologs" ]
		then
			TIME_INTERVAL=0
		else
			TIME_INTERVAL=5
		fi
	fi
	SET_LIST=`grep "SETNAME=" $TMP_PATH$MONGO_CONFIG_FILENAME  | awk -F"=" '{print $2}'`
	for SET in $SET_LIST
	do
		SETNAME=`grep -B1 "SETNAME=$SET"  $TMP_PATH$MONGO_CONFIG_FILENAME| tr -d "[|]" | tr -d "\n"| awk -F"SETNAME=" '{print $1}'`
		if [ $(grep -w $SET $CONFIG_FILE | grep ^$INPUT_STATUS | wc -l ) -eq 0 ]
		then
			echo "$INPUT_STATUS,$TIME_INTERVAL,$SETNAME,$SET" >> $CONFIG_FILE
		fi
	done

		
}

save_wpids()
{
	if [[ $SAR_WPID != "" ]]; then
		echo $SAR_WPID >> $OUTPUT_FILE_PATH$SAR_WPID_FILE
	fi
	if [[ $TOP_WPID != "" ]]; then
		echo $TOP_WPID >> $OUTPUT_FILE_PATH$TOP_WPID_FILE
	fi
	if [[ $VMSTAT_WPID != "" ]]; then
		echo $VMSTAT_WPID >> $OUTPUT_FILE_PATH$VMSTAT_WPID_FILE
	fi
	if [[ $IOSTAT_WPID != "" ]]; then
		echo $IOSTAT_WPID >> $OUTPUT_FILE_PATH$IOSTAT_WPID_FILE
	fi
	if [[ $MPSTAT_WPID != "" ]]; then
		echo $MPSTAT_WPID >> $OUTPUT_FILE_PATH$MPSTAT_WPID_FILE
	fi
}

kill_pids()
{
	cat $OUTPUT_FILE_PATH.*pid* 2> /dev/null | xargs kill -9 &>/dev/null
	rm -f $OUTPUT_FILE_PATH.*pid* &>/dev/null

	if [[ $SAR_WPID != "" ]]; then
		kill -9 $SAR_WPID;
	fi

	if [[ $TOP_WPID != "" ]]; then
		kill -9 $TOP_WPID;
	fi

	if [[ $VMSTAT_WPID != "" ]]; then
		kill -9 $VMSTAT_WPID;
	fi

	if [[ $IOSTAT_WPID != "" ]]; then
		kill -9 $IOSTAT_WPID;
	fi

	if [[ $MPSTAT_WPID != "" ]]; then
		kill -9 $MPSTAT_WPID;
	fi

	for((a=0; a<${#CPS_HOSTS_LIST[*]}; a++)); do
		if [[ ${CPS_HOSTS_LIST[$a]} =~ "pcrfclient" ]]; then
			ssh -i ${KEY_PATS} $USE_USER@$DUT_IP "pkill -P 1 -f \"tail -f \""
		fi
	done &
	p1id=$!

	for((b=0; b<${#CPS_HOSTS_LIST[*]}; b++)); do
		ssh -i ${KEY_PATS} $USE_USER@$DUT_IP "ssh -i ${KEY_MASTER} ${CPS_HOSTS_LIST[$b]} 'pkill -P 1 -f \"tail -f |tail -1\"'"
	done &
	p2id=$!

	flag=0;
        while [[ 1 ]]; do
		kill -0 $p1id $p2id &>/dev/null
	        val=$?
        	if [[ $val -eq 0 ]]; then
           		if [[ $flag -eq 0 ]]; then
                      		printf $CBCYAN"\rStopping processess, please wait ... $CBMAGENTA[/]"$CNORMAL
	                        flag=1;
        	        elif [[ $flag -eq 1 ]]; then
                	        printf $CBCYAN"\rStopping processess, please wait ... $CBMAGENTA[-]"$CNORMAL
                        	flag=2;
	                else
        	                printf $CBCYAN"\rStopping processess, please wait ... $CBMAGENTA[\\]"$CNORMAL
                	        flag=0;
	                fi
        	else
                	break;
	        fi
	sleep 0.5
	done
	pkill -P 1 -f "awk |tail -f |tail -1"
}

monitor_disk_space()
{
	DISK_SPACE_PID_FILE=".disk_space_check""_pid.list.`date +"%d-%m-%Y-%H-%M-%S"`"

	min_space=$(( $MIN_DISK_SPACE * 1024 ))
	disk_space=$(df -k | awk '{if ($NF ~ "/$") print $(NF-2)}')

	while [[ 1 ]]; do
		disk_space=$(df -k | awk '{if ($NF ~ "/$") print $(NF-2)}')
		if [[ $disk_space -le $min_space ]]; then
			kill_pids;
			wall "Disk space is exhausted and is only [$CBRED $disk_space KB $CNORMAL] in root partition. Hence exiting the running tet_pull_stats captured at the path [ $OUTPUT_FILE_PATH ]. Please clear disk space and rerun the toolkit."
			exit $EXIT_STATUS
		fi
	sleep 5
	done &
	DISK_SPACE_MONITOR_SPID=$!
	echo $DISK_SPACE_MONITOR_SPID >> $OUTPUT_FILE_PATH$DISK_SPACE_PID_FILE
}

capture_selected_stats()
{	
        echo -e $SEPARATOR$CBCYAN"\n\nPlease choose among options 1 to ${#DISPLAY_ARRAY[*]} from below $CBYELLOW\"Menu\"$CBCYAN to start capture of the respective stats, one option at a time.\n"$CNORMAL

	if [[ $MONITORING_DISK_SPACE -eq 1 ]]; then
		monitor_disk_space;
		MONITORING_DISK_SPACE=0;
	fi

	select item in ${DISPLAY_ARRAY[*]}; do
		case $REPLY in
			1)	if [[ $TOP_WPID == "" ]]; then
					TOP_PID_FILE=".$STATS_TYPE_TOP""_pid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					TOP_WPID_FILE=".$STATS_TYPE_TOP""_wpid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					while [[ 1 ]]; do
						if [[ $T_SET == 0 ]]; then
							CURRENT_TIME=$(date -d "now" +"%s")
							if [[ $TOP_TIMER == "" ]]; then
						        	TOP_TIMER=$(awk -F"," -v stype=$STATS_TYPE_TOP '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $TOP_TIMER != "" ]]; then
									pull_top_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $TOP_TIMER != "" ]]; then
					        		NEW_TOP_TIMER=$(awk -F"," -v stype=$STATS_TYPE_TOP '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_TOP_TIMER != $TOP_TIMER ]]; then
									TOP_TIMER=$NEW_TOP_TIMER
									cat $OUTPUT_FILE_PATH$TOP_PID_FILE | xargs kill -9 &>/dev/null

									if [[ $TOP_TIMER != "" ]]; then
										pull_top_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
							if [[ $CURRENT_TIME -gt	$END_TIME ]]; then
								TOP_PIDS=$(cat $OUTPUT_FILE_PATH$TOP_PID_FILE)
								rm -f $OUTPUT_FILE_PATH$TOP_PID_FILE
								kill -9 $TOP_PIDS

								if [[ $TOP_WPID != "" ]]; then
									kill -9 $TOP_WPID;
								fi

								exit 0
							fi
						else
							if [[ $TOP_TIMER == "" ]]; then
						        	TOP_TIMER=$(awk -F"," -v stype=$STATS_TYPE_TOP '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $TOP_TIMER != "" ]]; then
									pull_top_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $TOP_TIMER != "" ]]; then
					        		NEW_TOP_TIMER=$(awk -F"," -v stype=$STATS_TYPE_TOP '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_TOP_TIMER != $TOP_TIMER ]]; then
									TOP_TIMER=$NEW_TOP_TIMER
									cat $OUTPUT_FILE_PATH$TOP_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $TOP_TIMER != "" ]]; then
										pull_top_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
						fi
						sleep $DEFAULT_CONFIG_CHECK_INTERVAL
					done 2>/dev/null &
					TOP_WPID=$!
				else
					printf "Looks like these stats are already being captured. Please tail the corresponding stats file in the folder you provided above OR Do you want to stop this stats capture? (y/n):"
					read -n 2 val
					if [[ $val == "y" ]]; then
						cat $OUTPUT_FILE_PATH$TOP_PID_FILE | xargs kill -9 &>/dev/null
						if [[ $TOP_WPID != "" ]]; then
							kill -9 $TOP_WPID;
						fi
						TOP_WPID=""
						rm -f $OUTPUT_FILE_PATH$TOP_PID_FILE
						printf "Your selected stats capture have been stopped, you may reselect the option to restart the capture in same file.\n"
					else
						:
					fi
				fi
				;;
			2)	if [[ $SAR_WPID == "" ]]; then
					SAR_PID_FILE=".$STATS_TYPE_SAR""_pid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					SAR_WPID_FILE=".$STATS_TYPE_SAR""_wpid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					while [[ 1 ]]; do
						if [[ $T_SET == 0 ]]; then
							CURRENT_TIME=$(date -d "now" +"%s")
							if [[ $SAR_TIMER == "" ]]; then
						        	SAR_TIMER=$(awk -F"," -v stype=$STATS_TYPE_SAR '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $SAR_TIMER != "" ]]; then
									pull_sar_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $SAR_TIMER != "" ]]; then
					        		NEW_SAR_TIMER=$(awk -F"," -v stype=$STATS_TYPE_SAR '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_SAR_TIMER != $SAR_TIMER ]]; then
									SAR_TIMER=$NEW_SAR_TIMER
									cat $OUTPUT_FILE_PATH$SAR_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $SAR_TIMER != "" ]]; then
										pull_sar_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
							if [[ $CURRENT_TIME -gt	$END_TIME ]]; then
								SAR_PIDS=$(cat $OUTPUT_FILE_PATH$SAR_PID_FILE)
								rm -f $OUTPUT_FILE_PATH$SAR_PID_FILE
								kill -9 $SAR_PIDS

								if [[ $SAR_WPID != "" ]]; then
									kill -9 $SAR_WPID;
								fi

								exit 0
							fi
						else
							if [[ $SAR_TIMER == "" ]]; then
						        	SAR_TIMER=$(awk -F"," -v stype=$STATS_TYPE_SAR '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $SAR_TIMER != "" ]]; then
									pull_sar_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $SAR_TIMER != "" ]]; then
					        		NEW_SAR_TIMER=$(awk -F"," -v stype=$STATS_TYPE_SAR '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_SAR_TIMER != $SAR_TIMER ]]; then
									SAR_TIMER=$NEW_SAR_TIMER
									cat $OUTPUT_FILE_PATH$SAR_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $SAR_TIMER != "" ]]; then
										pull_sar_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
						fi
						sleep $DEFAULT_CONFIG_CHECK_INTERVAL
					done 2>/dev/null &
					SAR_WPID=$!
				else
					printf "Looks like these stats are already being captured. Please tail the corresponding stats file in the folder you provided above OR Do you want to stop this stats capture? (y/n):"
					read -n 2 val
					if [[ $val == "y" ]]; then
						cat $OUTPUT_FILE_PATH$SAR_PID_FILE | xargs kill -9 &>/dev/null
						if [[ $SAR_WPID != "" ]]; then
							kill -9 $SAR_WPID;
						fi
						SAR_WPID=""
						rm -f $OUTPUT_FILE_PATH$SAR_PID_FILE
						printf "Your selected stats capture have been stopped, you may reselect the option to restart the capture in same file.\n"
					else
						:
					fi
				fi
				;;
			3)	if [[ $VMSTAT_WPID == "" ]]; then
					VMSTAT_PID_FILE=".$STATS_TYPE_VMSTAT""_pid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					VMSTAT_WPID_FILE=".$STATS_TYPE_VMSTAT""_wpid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					while [[ 1 ]]; do
						if [[ $T_SET == 0 ]]; then
							CURRENT_TIME=$(date -d "now" +"%s")
							if [[ $VMSTAT_TIMER == "" ]]; then
						        	VMSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_VMSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $VMSTAT_TIMER != "" ]]; then
									pull_vm_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $VMSTAT_TIMER != "" ]]; then
					        		NEW_VMSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_VMSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_VMSTAT_TIMER != $VMSTAT_TIMER ]]; then
									VMSTAT_TIMER=$NEW_VMSTAT_TIMER
									cat $OUTPUT_FILE_PATH$VMSTAT_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $VMSTAT_TIMER != "" ]]; then
										pull_vm_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
							if [[ $CURRENT_TIME -gt	$END_TIME ]]; then
								VMSTAT_PIDS=$(cat $OUTPUT_FILE_PATH$VMSTAT_PID_FILE)
								rm -f $OUTPUT_FILE_PATH$VMSTAT_PID_FILE
								kill -9 $VMSTAT_PIDS

								if [[ $VMSTAT_WPID != "" ]]; then
									kill -9 $VMSTAT_WPID;
								fi

								exit 0
							fi
						else
							if [[ $VMSTAT_TIMER == "" ]]; then
						        	VMSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_VMSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $VMSTAT_TIMER != "" ]]; then
									pull_vm_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $VMSTAT_TIMER != "" ]]; then
					        		NEW_VMSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_VMSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_VMSTAT_TIMER != $VMSTAT_TIMER ]]; then
									VMSTAT_TIMER=$NEW_VMSTAT_TIMER
									cat $OUTPUT_FILE_PATH$VMSTAT_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $VMSTAT_TIMER != "" ]]; then
										pull_vm_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
						fi
						sleep $DEFAULT_CONFIG_CHECK_INTERVAL
					done 2>/dev/null &
					VMSTAT_WPID=$!
				else
					printf "Looks like these stats are already being captured. Please tail the corresponding stats file in the folder you provided above OR Do you want to stop this stats capture? (y/n):"
					read -n 2 val
					if [[ $val == "y" ]]; then
						cat $OUTPUT_FILE_PATH$VMSTAT_PID_FILE | xargs kill -9 &>/dev/null
						if [[ $VMSTAT_WPID != "" ]]; then
							kill -9 $VMSTAT_WPID;
						fi
						VMSTAT_WPID=""
						rm -f $OUTPUT_FILE_PATH$VMSTAT_PID_FILE
						printf "Your selected stats capture have been stopped, you may reselect the option to restart the capture in same file.\n"
					else
						:
					fi
				fi
				;;
			4)	if [[ $IOSTAT_WPID == "" ]]; then
					IOSTAT_PID_FILE=".$STATS_TYPE_IOSTAT""_pid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					IOSTAT_WPID_FILE=".$STATS_TYPE_IOSTAT""_wpid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					while [[ 1 ]]; do
						if [[ $T_SET == 0 ]]; then
							CURRENT_TIME=$(date -d "now" +"%s")
							if [[ $IOSTAT_TIMER == "" ]]; then
						        	IOSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_IOSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $IOSTAT_TIMER != "" ]]; then
									pull_io_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $IOSTAT_TIMER != "" ]]; then
					        		NEW_IOSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_IOSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_IOSTAT_TIMER != $IOSTAT_TIMER ]]; then
									IOSTAT_TIMER=$NEW_IOSTAT_TIMER
									cat $OUTPUT_FILE_PATH$IOSTAT_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $IOSTAT_TIMER != "" ]]; then
										pull_io_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
							if [[ $CURRENT_TIME -gt	$END_TIME ]]; then
								IOSTAT_PIDS=$(cat $OUTPUT_FILE_PATH$IOSTAT_PID_FILE)
								rm -f $OUTPUT_FILE_PATH$IOSTAT_PID_FILE
								kill -9 $IOSTAT_PIDS

								if [[ $IOSTAT_WPID != "" ]]; then
									kill -9 $IOSTAT_WPID;
								fi

								exit 0
							fi
						else
							if [[ $IOSTAT_TIMER == "" ]]; then
						        	IOSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_IOSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $IOSTAT_TIMER != "" ]]; then
									pull_io_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $IOSTAT_TIMER != "" ]]; then
					        		NEW_IOSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_IOSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_IOSTAT_TIMER != $IOSTAT_TIMER ]]; then
									IOSTAT_TIMER=$NEW_IOSTAT_TIMER
									cat $OUTPUT_FILE_PATH$IOSTAT_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $IOSTAT_TIMER != "" ]]; then
										pull_io_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
						fi
						sleep $DEFAULT_CONFIG_CHECK_INTERVAL
					done 2>/dev/null &
					IOSTAT_WPID=$!
				else
					printf "Looks like these stats are already being captured. Please tail the corresponding stats file in the folder you provided above OR Do you want to stop this stats capture? (y/n):"
					read -n 2 val
					if [[ $val == "y" ]]; then
						cat $OUTPUT_FILE_PATH$IOSTAT_PID_FILE | xargs kill -9 &>/dev/null
						if [[ $IOSTAT_WPID != "" ]]; then
							kill -9 $IOSTAT_WPID;
						fi
						IOSTAT_WPID=""
						rm -f $OUTPUT_FILE_PATH$IOSTAT_PID_FILE
						printf "Your selected stats capture have been stopped, you may reselect the option to restart the capture in same file.\n"
					else
						:
					fi
				fi
				;;
			5)	if [[ $MPSTAT_WPID == "" ]]; then
					MPSTAT_PID_FILE=".$STATS_TYPE_MPSTAT""_pid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					MPSTAT_WPID_FILE=".$STATS_TYPE_MPSTAT""_wpid.list.`date +"%d-%m-%Y-%H-%M-%S"`"
					while [[ 1 ]]; do
						if [[ $T_SET == 0 ]]; then
							CURRENT_TIME=$(date -d "now" +"%s")
							if [[ $MPSTAT_TIMER == "" ]]; then
						        	MPSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_MPSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $MPSTAT_TIMER != "" ]]; then
									pull_mp_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $MPSTAT_TIMER != "" ]]; then
						        	NEW_MPSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_MPSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_MPSTAT_TIMER != $MPSTAT_TIMER ]]; then
									MPSTAT_TIMER=$NEW_MPSTAT_TIMER
									cat $OUTPUT_FILE_PATH$MPSTAT_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $MPSTAT_TIMER != "" ]]; then
										pull_mp_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
							if [[ $CURRENT_TIME -gt	$END_TIME ]]; then
								MPSTAT_PIDS=$(cat $OUTPUT_FILE_PATH$MPSTAT_PID_FILE)
								rm -f $OUTPUT_FILE_PATH$MPSTAT_PID_FILE
								kill -9 $MPSTAT_PIDS

								if [[ $MPSTAT_WPID != "" ]]; then
									kill -9 $MPSTAT_WPID;
								fi

								exit 0
							fi
						else
							if [[ $MPSTAT_TIMER == "" ]]; then
						        	MPSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_MPSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $MPSTAT_TIMER != "" ]]; then
									pull_mp_stats;
									continue;
								else
									continue;
								fi
							fi
							if [[ $MPSTAT_TIMER != "" ]]; then
						        	NEW_MPSTAT_TIMER=$(awk -F"," -v stype=$STATS_TYPE_MPSTAT '/^[^#]/ { if ($1 == stype) printf("%s",$2) }' $CONFIG_FILE)
								if [[ $NEW_MPSTAT_TIMER != $MPSTAT_TIMER ]]; then
									MPSTAT_TIMER=$NEW_MPSTAT_TIMER
									cat $OUTPUT_FILE_PATH$MPSTAT_PID_FILE | xargs kill -9 &>/dev/null
									if [[ $MPSTAT_TIMER != "" ]]; then
										pull_mp_stats;
										continue;
									else
										continue;
									fi
								fi
							fi
						fi
						sleep $DEFAULT_CONFIG_CHECK_INTERVAL
					done 2>/dev/null &
					MPSTAT_WPID=$!
				else
					printf "Looks like these stats are already being captured. Please tail the corresponding stats file in the folder you provided above OR Do you want to stop this stats capture? (y/n):"
					read -n 2 val
					if [[ $val == "y" ]]; then
						cat $OUTPUT_FILE_PATH$MPSTAT_PID_FILE | xargs kill -9 &>/dev/null
						if [[ $MPSTAT_WPID != "" ]]; then
							kill -9 $MPSTAT_WPID;
						fi
						MPSTAT_WPID=""
						rm -f $OUTPUT_FILE_PATH$MPSTAT_PID_FILE
						printf "Your selected stats capture have been stopped, you may reselect the option to restart the capture in same file.\n"
					else
						:
					fi
				fi
				;;
			6)	printf "You have opted to exit and keep capturing stats at the $CBGREEN\"background\"$CNORMAL. Nevermind, you can later use the '-k' option with this script to STOP the running captures. Are you sure?(y/n):"
				read -n 2 val
				if [[ $val == "y" ]]; then
					save_wpids;
					exit 0
				else 	
					if [[ $val == "n" ]]; then
						:
					else
						echo -e "Please choose between y/n."
					fi
				fi
				;;
			7) printf "You have opted to exit and$CBRED \"STOP\"$CNORMAL capturing stats. Are you sure?(y/n):"
				read -n 2 val
				if [[ $val == "y" ]]; then
					kill_pids;
					kill -9 $DISK_SPACE_MONITOR_SPID &>/dev/null;
					echo -e "\nAny stats capture you selected from above Menu are saved at the path [$CBCYAN $OUTPUT_FILE_PATH $CNORMAL]\nBye!!!"
					exit 0
				else
					if [[ $val == "n" ]]; then
						:
					else
						echo -e "Please choose between y/n."
					fi
				fi	
				;;
		esac 2>/dev/null
	done
}

stop_stats_capture()
{
	printf "You have opted to$CBRED STOP$CNORMAL any running stats capture at the path [$CBCYAN $OUTPUT_FILE_PATH $CNORMAL] against DUT [$CBCYAN $DUT_IP $CNORMAL]. Are you sure?(y/n):"
	read -n 2 val
	if [[ $val == "y" ]]; then
		cat $OUTPUT_FILE_PATH.*pid* 2> /dev/null | xargs kill -9 &>/dev/null
		rm -f $OUTPUT_FILE_PATH.*pid* &>/dev/null

		for((a=0; a<${#CPS_HOSTS_LIST[*]}; a++)); do
			if [[ ${CPS_HOSTS_LIST[$a]} =~ "pcrfclient" ]]; then
				ssh -i ${KEY_PATS} $USE_USER@$DUT_IP "pkill -P 1 -f \"tail -f \""
			fi
		done &
		p1id=$!

		for((b=0; b<${#CPS_HOSTS_LIST[*]}; b++)); do
			ssh -i ${KEY_PATS} $USE_USER@$DUT_IP "ssh -i ${KEY_MASTER} ${CPS_HOSTS_LIST[$b]} 'pkill -P 1 -f \"tail -f |tail -1\"'"
		done &
		p2id=$!

	        flag=0;
        	while [[ 1 ]]; do
                	kill -0 $p1id $p2id &>/dev/null
	                val=$?
        	        if [[ $val -eq 0 ]]; then
                	        if [[ $flag -eq 0 ]]; then
                        	        printf $CBCYAN"\rStopping processess, please wait ... $CBMAGENTA[/]"$CNORMAL
	                                flag=1;
        	                elif [[ $flag -eq 1 ]]; then
                	                printf $CBCYAN"\rStopping processess, please wait ... $CBMAGENTA[-]"$CNORMAL
                        	        flag=2;
	                        else
        	                        printf $CBCYAN"\rStopping processess, please wait ... $CBMAGENTA[\\]"$CNORMAL
                	                flag=0;
	                        fi
        	        else
                	        break;
	                fi
	                sleep 0.5
        	done
		pkill -P 1 -f "awk |tail -f "
		echo -e $CBGREEN"\nAny runnig stats at the path mentioned above have been stopped. Bye!"$CNORMAL
	else
		if [[ $val == "n" ]]; then
			echo "You entered 'n' hence exiting without stopping any stats being captured at the path mentioned above. Make sure to stop stats capture at a later time with -k option. Bye!!!"
			exit 0
		else
			echo -e $CBRED"Please retry and choose between y/n. Bye!"$CNORMAL
		fi
	fi
}

capture_all_stats()
{
	for((i=1; i<=${#STATS_ARRAY[*]};i++ )); do
		capture_selected_stats <<< $(printf "$i\n") &>/dev/null
		sleep 1
		save_wpids;
	done &
	css_pid=$!
	css_flag=0;
 
	while [[ 1 ]]; do
        	kill -0 $css_pid &>/dev/null
	        val=$?
        	if [[ $val -eq 0 ]]; then
          		if [[ $css_flag -eq 0 ]]; then
                       		printf $CBCYAN"\rStarting captures, please wait ... $CBMAGENTA[/]"$CNORMAL
	                        css_flag=1;
        		elif [[ $css_flag -eq 1 ]]; then
                		printf $CBCYAN"\rStarting captures, please wait ... $CBMAGENTA[-]"$CNORMAL
                        	css_flag=2;
	                else
        	        	printf $CBCYAN"\rStarting captures, please wait ... $CBMAGENTA[\\]"$CNORMAL
                	        css_flag=0;
	                fi
        	else
                	break;
	        fi
	        sleep 0.5
       	done

	echo -e "\nNow capturing All stats/logs for which config is provided in the configuration file entered with -c option and saving at the path [$CBGREEN $OUTPUT_FILE_PATH $CNORMAL].$CBGREEN\nUse -k option later on to stop capturing stats being saved at this path.$CNORMAL\n\nBye!!!"
	exit 0
}

capture_input_stats()
{	
	echo $CBGREEN"Following stats will be captured. Use -k option later on to stop capturing stats being saved at the path.[$CBYELLOW $OUTPUT_FILE_PATH $CBGREEN]"$CBYELLOW

	for i in ${SELECTED_STATS_LIST[*]}; do
		echo "${STATS_ARRAY[$i-1]}"
	done
	
	for i in ${SELECTED_STATS_LIST[*]}; do
		capture_selected_stats <<< $(printf "$i\n") &>/dev/null
		sleep 1
		save_wpids;
	done &
	cis_pid=$!
	cis_flag=0;
 
	while [[ 1 ]]; do
        	kill -0 $cis_pid &>/dev/null
	        val=$?
        	if [[ $val -eq 0 ]]; then
          		if [[ $cis_flag -eq 0 ]]; then
                       		printf $CBCYAN"\rStarting captures, please wait ... $CBMAGENTA[/]"$CNORMAL
	                        cis_flag=1;
        		elif [[ $cis_flag -eq 1 ]]; then
                		printf $CBCYAN"\rStarting captures, please wait ... $CBMAGENTA[-]"$CNORMAL
                        	cis_flag=2;
	                else
        	        	printf $CBCYAN"\rStarting captures, please wait ... $CBMAGENTA[\\]"$CNORMAL
                	        cis_flag=0;
	                fi
        	else
                	break;
	        fi
	        sleep 0.5
       	done

	echo -e $CBGREEN"\nStarted stats capture. Use -k option later on to stop capturing stats being saved at the path.[$CBYELLOW $OUTPUT_FILE_PATH $CBGREEN]"$CBYELLOW
	tput sgr0;
	printf "Bye.\n"
	exit 0
}

control_c()
{
	kill_pids &>/dev/null;
        echo -en "$CBRED\n***** Stopped any running stats captures *****"
        echo -en "$CBRED\n***** Exiting *****\n$CNORMAL"
        exit $?
}

trap control_c SIGINT

# read -a CPS_HOSTS_LIST <<< $(ssh $USE_USER@$DUT_IP kubectl get nodes -o wide | grep -v NAME | awk '{print $1}')
mapfile -t CPS_HOSTS_LIST <<< $(ssh -i ${KEY_PATS} $USE_USER@$DUT_IP kubectl get nodes -o wide | grep -v NAME | awk '{print $1}')

if [[ $K_SET -eq 1 ]]; then
	validate_config;
	verify_connectivity;
	validate_disk_space;

	if [[ $A_SET -eq 1 && $S_SET -eq 1 ]]; then
		capture_selected_stats;
	elif [[ $S_SET -eq 0 ]]; then
		capture_input_stats;
	elif [[ $A_SET -eq 0 ]]; then
		capture_all_stats;
	fi
else
	stop_stats_capture;
fi

#TO DO: Check to ensure that both -a and -s options cannot be given.
#TO DO: Restrict Minimum time to 1 in config file

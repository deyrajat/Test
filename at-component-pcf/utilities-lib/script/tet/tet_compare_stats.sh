#!/bin/bash

######################################################################################################################################
#			Filename	:	tet_compare_stats.sh
#			Author		:	Navneet Kumar Verma
#			Project		:	Test Effectiveness Toolkit [TET]
#			About		:	This is a bash script displaying stats from dsTest and CPS for easy 
#						comparison.
#			Version		:	1 [Date: 02-May-16] [Initial Version, support for dsTest stats only]
#					:	2 [Date: 04-May-16] [Enabled pretty formatting]
#					:	3 [Date: 09-May-16] [Support for multiple interfaces from any node like:
#						pcef-Gx, pcef-Gy, ocs-Sy, ocs-Syp, etc. Support for dsTest stats only.]
#					:	4 [Date: 25-May-16] [Support for capturing CPS stats along with dsTest stats. Also
#						support for hashed entries in config file. All rows prefixed with # are ignored.]
#					:	5 [Date: 26-May-16] [Identified that in case date is mentioned as "now", etc. the 
#						timestamps are picked from local machine instead of CPS. This is fixed. Also fixed an
#						irritating prompt thrown asking for password.]
#					:	6 [Date: 13-Jun-16] [
#						a) Column sizes were fixed in length and could create issues in display
#						of report when config defines larger length interface names. Now it is picked from 
#						definitions in the config file.
#						b) Fixed timestamp issue related to incorrect dates.
#						c) Now displaying CPS FROM and TO stats timestamps in report file.]
#					:	7 [Date: 28-Aug-17] [
#						a) Included support for all diameter interfaces supported by dsTest.
#						b) Included support for stats capture irrespective of the diameter client / server name.
#						   Earlier the stats capture worked only for diameter and diameter_secondary names.
#						c) included support for multiple interfaces to a single node e.g. for hss nodes the
#						   interface could be sh, cx, etc., likewise for other network nodes too.]
#					:	8 [Date: 30-Aug-17] [ Fixed issue related to a few dsTest stats shown as "-". ]
######################################################################################################################################
# TO DO: identify method to identify column sizes for CPS stats.
# TO DO: exit if awk version installed is lower
# TO DO: Check implementation of match in awk. Check for conditional matches, they should be > 0

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

BIN_HOME=/etc/bin/
CPSSTATS_HOME=/var/broadhop/stats/
#CPSSTATS_HOME=/root/temp_stats/
CPSSTATS_PREFIX=bulk
CPSSTATS_SUFFIX=csv
DSCLIENT_HOME="/usr/local/devsol/bin/"
DSCLIENT=dsClient
TMP_HOME=/tmp/
C_SET=1
CONFIG_FILE=""
CONFIG_FILENAME=""
O_SET=1
OUTPUT_FILE=""
F_SET=1
FROM_TIME=""
START_TIME=""
T_SET=1
TILL_TIME=""
END_TIME=""
P_SET=1
NO_ARGS=0
EXIT_STATUS=60
mydate=`date +"%d-%m-%Y-%H-%M-%S"`
SEPARATOR="$CBBLUE==============================================================================================================$CNORMAL"
SSH_TIMEOUT=2
USE_USER=root
NODE_TYPES=( "dsTest" "CPS" )
NODE_TYPES1=${NODE_TYPES[0]}
NODE_TYPES2=${NODE_TYPES[1]}
DSTEST_NODES=""
DSTEST_INTERFACES=""
CPS_INTERFACES=""
DSTEST_NODE_TYPES="pcef ocs tdf cscf hss mme as agw aaa"
CPS_NODE_TYPES="lb qns"
CPS_STATS_TYPES="success error counters"
MAX_COLUMN_WIDTH=13
TIMESTAMP=""
CPS_TIMESTAMP=""

INTERFACE_MESSAGE_TYPES=( Gx_CCR-I Gx_CCA-I Gx_CCR-U Gx_CCA-U Gx_CCR-T Gx_CCA-T Gx_RAR Gx_RAA Gy_CCR-I Gy_CCA-I Gy_CCR-U Gy_CCA-U Gy_CCR-T Gy_CCA-T Gy_RAR Gy_RAA Gy_STR Gy_STA Sd_TSR Sd_TSA Sd_CCR-U Sd_CCA-U Sd_CCR-T Sd_CCA-T Sd_RAR Sd_RAA Rx_AAR Rx_AAA Rx_ASR Rx_ASA Rx_RAR Rx_RAA Rx_STR Rx_STA Sy_SLR Sy_SLA Sy_SNR Sy_SNA Sy_STR Sy_STA Syp_AAR Syp_AAA Syp_STR Syp_STA Syp_ASR Syp_ASA Syp_RAR Syp_RAA Sh_UDR Sh_UDA Sh_SNR Sh_SNA )

DIAM_MESSAGE_TYPES=( CCR-I CCA-I CCR-U CCA-U CCR-T CCA-T RAR RAA STR STA TSR TSA AAR AAA ASR ASA SLR SLA SNR SNA UDR UDA )


usage ()
{
        echo -e "$SEPARATOR"
        echo -e $CBMAGENTA"About: $CNORMAL"
        echo -e $CBCYAN"This script provides a consolidated report for signalling stats on dsTest and CPS. CPS stats are provided as difference between the \"bulk\" stats for the timestamps you provide as input to this script. So you need to know the \"CPS\" timestamp when you started your test. And it is assumed that dsTest nodes are restarted/reset at the beginning of your test such that the stats in dsTest are only for the test against which you are running this script."
        echo -e "\nFollow the details below to understand how this script can be run. Ensure timestamps are synced between CPS, dsTest and the current node from where you are running the tet_compare_stats.sh script. \nThe script can be invoked from any linux machine that can reach your dsTest and CPS."
	echo -e "\nJust make sure you have $CBMAGENTA\"awk version 3.1.7\"$CBCYAN or above installed onto the machine.$CNORMAL\n"
        echo -e "$CBMAGENTA$FUNCNAME: $CNORMAL"
        echo "$CBGREEN${PWD}/`basename $0` -c <config_filename> -w <output_file> -f <from_date> -t <to_date>$CNORMAL"
        echo -e $CBMAGENTA"OPTIONS: $CNORMAL"
        echo -e "$CBYELLOW-c $CNORMAL[Mandatory]\t: config filename / path to filename."
        echo -e "$CBYELLOW-w $CNORMAL[Optional]\t: output filename / path to filename."
        echo -e "$CBYELLOW-f $CNORMAL[Optional]\t: CPS date/timestamp from which CPS bulk stat needs to be captured. Inputs like \"-15 mins\", \"-1 hour\", \"now\", etc. can be given."
        echo -e "$CBYELLOW-t $CNORMAL[Optional]\t: CPS date/timestamp till which CPS bulk stat needs to be captured. Inputs like \"-15 mins\", \"-2 hours\", \"now\", etc. can be given."
        echo -e "$CBYELLOW-p $CNORMAL[Optional]\t: Enables pretty formatting for output report. Report will be in color format when \"cat\" to a terminal for easy readability."
        echo -e "$CBYELLOW-u/-h $CNORMAL[Optional]: Shows help / usage of the script."
        echo -e "$CBYELLOW-e $CNORMAL[Optional]\t: Shows examples for creation of config file for this script."
        echo -e "$CBMAGENTA\nEXAMPLES: $CNORMAL"
        echo -e $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c config.txt -w report.txt$CNORMAL ---> This creates a report file with filename \"report.txt\" in the current directory. Only dsTest stats are captured in this case as -f and -t inputs are not provided."
        echo $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c config.txt$CNORMAL               ---> This creates a report file with timestamp attached to filename. Only dsTest stats are captured in this case as -f and -t inputs are not provided."
        echo $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c /root/Temp/config.txt -w /root/reports/myreport.txt $CNORMAL---> This creates a report file with filename myreport.txt in the mentioned path. Only dsTest stats are captured in this case as -f and -t inputs are not provided."
        echo $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c /root/Temp/config.txt -w /root/reports/myreport.txt -f \"-45 mins\" -t \"now\"$CNORMAL ---> This creates a report file with filename myreport.txt in the mentioned path. The difference between bulk stats at CPS for the mentioned times is saved in the report. The nearest 5th minute timestamp of the hour, is used."
        echo $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c config.txt -f \"-12 hours\" -t \"-15 mins\"$CNORMAL               ---> This creates a report file with timestamp attached to filename. The difference between bulk stats at CPS for the mentioned times is saved in the report. The nearest 5th minute timestamp of the hour, is used."
        echo $CBMAGENTA"e.g.$CNORMAL $CBGREEN${PWD}/`basename $0` -c config.txt -w report.txt -f 12-04-2016-00-01 -t 12-04-2016-23-59$CNORMAL ---> You can provide the timestamps in DD-MM-YYYY-HH-MM format. The difference between bulk stats at CPS for the mentioned times is saved in the report. The nearest 5th minute timestamp of the hour, is used."
        echo -e $SEPARATOR
}

usage_conf()
{
        echo -e $SEPARATOR
	echo -e $CBMAGENTA"\nThe config file needs to have following details:"
        echo -e $CBGREEN"Two types of rows can be provided in the config file."
        echo -e $CBYELLOW"1. Rows with \"dsTest\" details from where dsTest stats are to be captured. Note that stats for each \"unique combination\" of 3rd and 5th values in the rows defined for dsTest are combined together. This is to ensure that if there are multiple dsTest nodes sending traffic to the same interfaces, their stats are combined."
        echo -e "2. Rows with \"CPS\" details from where CPS stats are to be captured. One row for one interface."
        echo -e $CBGREEN"\nRows with \"dsTest\" details MUST have 5 comma separated values with:"
        echo -e $CNORMAL"   -- First value MUST be the name dsTest."
        echo -e "   -- Second value is the dsTest IP from which you intend to capture the stats."
        echo -e "   -- Third value is the dsTest node type e.g. pcef, cscf, ocs, etc. This MUST be as defined by dsTest."
        echo -e "   -- Fourth value is the dsTest node-name as defined in your dsTest config."
        echo -e "   -- Fifth value is the interface name. This can be any name like Gx, Rx, etc. The name you defined here will be used in output report from this script."
        echo -e $CBGREEN"\nRows with \"CPS\" details MUST have 4 comma separated values with:"
        echo -e $CNORMAL"   -- First value MUST be the name CPS."
        echo -e "   -- Second value is the CPS pcrfclient IP from which you intend to differentiate the \"bulk\" stats between the -f and -t times you provide on command line."
        echo -e "   -- Third value is the CPS pcrfclient hostname."
        echo -e "   -- Fourth value is the interface name as known by CPS."
        echo -e $CBMAGENTA"\nEXAMPLE:"
        echo -e $CBGREEN"### This is an example config file. ###"
        echo -e $CCYAN"dsTest,111.12.11.10,pcef,Site_2_TEJAS_Solution2_PCEF_1,-Gx"
        echo -e "### Rows starting with '#' are for entering comments in the config file and not used by the script."
        echo -e "dsTest,111.12.11.10,pcef,Site_2_TEJAS_Solution2_PCEF_2,-Gx"
        echo -e "dsTest,110.11.10.11,pcef,Site_2_TEJAS_Solution2_PCEF_3,-Gx"
        echo -e "dsTest,110.11.10.11,ocs,Site_2_TEJAS_Solution2_OCS_1,-Syp"
        echo -e "dsTest,110.11.10.11,ocs,Site_2_TEJAS_Solution2_OCS_2,-Syp"
        echo -e "dsTest,110.11.10.11,ocs,Site_2_TEJAS_Solution2_OCS_3,-Sy"
        echo -e "dsTest,111.12.11.10,cscf,Site_2_TEJAS_Solution2_CSCF_1,-Rx"
	echo -e "CPS,172.2.2.11,PRI-pcrfclient01,Gx"
	echo -e "CPS,172.2.2.11,PRI-pcrfclient01,Rx"
	echo -e "CPS,172.2.2.11,PRI-pcrfclient01,Sy"
	echo -e "CPS,172.2.2.11,PRI-pcrfclient01,Sd"
	echo -e "CPS,172.2.2.11,PRI-pcrfclient01,Syp"
        echo -e $CBGREEN"### The example config file ends here. ###"$CNORMAL
        echo -e $SEPARATOR
}

if [[ $# -eq "NO_ARGS" ]]
then
        usage
	exit $EXIT_STATUS
fi

control_c_or_kill_hang()
{
	rm -f $DSTEST_TEMP_FILE $CPS_TEMP_FILE
	echo -en "$CBRED\n***** Exiting *****\n$CNORMAL"
	exit $?
}

trap control_c_or_kill_hang SIGHUP SIGINT SIGTERM

TIMESTAMP=${mydate}
echo -e $CBYELLOW"\nCURRENT LOCAL TIMESTAMP: [$CBCYAN $TIMESTAMP $CBYELLOW]\n$CNORMAL"

parse_options()
{
echo -e $SEPARATOR"\nParsing options provided on command line ..."
while getopts ":c:w:f:t:uhpe" options; do
	case "$options" in
		c)	CONFIG_FILE="${OPTARG}"
			echo "Configuration would be read from file [$CBCYAN $CONFIG_FILE $CNORMAL]";
			CONFIG_FILENAME=$(echo "$CONFIG_FILE" | awk -F"/" '{print $NF}')
			C_SET=0
			;;
		w)	OUTPUT_FILE="${OPTARG}"
			echo "Output will be written to file:[$CBCYAN $OUTPUT_FILE $CNORMAL]";
			W_SET=0
			;;
		f)	FROM_TIME="${OPTARG}"
			echo "You have requested to capture$CBOLD $NODE_TYPES2$CNORMAL stats from time [$CBCYAN $FROM_TIME $CNORMAL]";
			F_SET=0
			;;
		t)	TILL_TIME="${OPTARG}"
			echo "You have requested to capture$CBOLD $NODE_TYPES2$CNORMAL stats till time [$CBCYAN $TILL_TIME $CNORMAL]";
			T_SET=0
			;;
		u|h)	echo -e "Hmm! You requested for usage, Let me help you out!"
			usage
			exit 0
			;;
		e)	echo -e "Hmm! You requested for examples of config file, Let me help you out!"
			usage_conf
			exit 0
			;;
		p)	echo -e "Great! You have \"$CBCYAN enabled pretty formatting $CNORMAL\", the output report can be printed on screen in colored format ... :-)"
			P_SET=0
			;;
		\?)	echo -e "Ahh! sorry I don't understand option [$CBRED -$OPTARG $CNORMAL] yet. Check usage below for valid options. You can do it!"
			usage
			exit $EXIT_STATUS
			;;
		:)	echo -e "Ahh! sorry you seem to have missed passing an argument for option [$CBRED -$OPTARG $CNORMAL]. Check usage below. You can do it!"
			usage
			exit $EXIT_STATUS
		;;
		*)	echo -e "Ahh! You entered something wrong! Check usage below. You can do it!"
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

	if [[ $C_SET -eq 1 || $CONFIG_FILE == "" ]]; then
		echo "Mandatory option [$CBRED -c $CNORMAL] is missing or passed as argument to another option. Cannot proceed.$CBRED Exiting now!"$CNORMAL
		exit $EXIT_STATUS
	else 
		if [[ ! -e $CONFIG_FILE ]] || [[ ! -f $CONFIG_FILE ]] ; then
			echo "Configuration file [$CBRED $CONFIG_FILE $CNORMAL] does not exist or is not a regular file. This is a mandatory input.$CBRED Exiting now!"$CNORMAL
			exit $EXIT_STATUS
		fi
	fi

	if [[ $W_SET -eq 1 ]] || [[ $OUTPUT_FILE == "" ]]; then
		temp_file="${PWD}/output.${TIMESTAMP}";
		OUTPUT_FILE=${temp_file}
		echo "Since you have not provided an output file, the results will be saved in [$CBYELLOW $OUTPUT_FILE $CNORMAL] in the current directory. Continuing ahead ..."
	else
		if [[ ${OUTPUT_FILE##*/} == "" ]]; then
			echo -e "The output file [$CBRED $OUTPUT_FILE $CNORMAL] you mentioned is an existing file/directory, please provide a$CBYELLOW filename or /<path>/filename$CNORMAL. Exiting Now !!!\n"
			exit $EXIT_STATUS
		fi
		if [[ -e $OUTPUT_FILE ]]; then
			echo -e "The output file [$CBRED $OUTPUT_FILE $CNORMAL] you mentioned is an existing file/directory, please provide a$CBYELLOW filename or /<path>/filename$CNORMAL. Exiting Now !!!\n"
			exit $EXIT_STATUS
		fi

		local temp_path=${OUTPUT_FILE%/*};
		if [[ "$temp_path" != "$OUTPUT_FILE" ]]; then
			mkdir $temp_path &>/dev/null
			if (( $? != 0 )); then
				echo  "Looks like the output file path you have mentioned does not exist. Creating path [$CBYELLOW $temp_path $CNORMAL]"
				mkdir -p $temp_path
			fi
		fi
	fi
	
	if [[ $F_SET -eq 0 && $T_SET -eq 1 ]] || [[ $F_SET -eq 1 && $T_SET -eq 0 ]]; then
		echo "Sorry! I don't support just one input for the date range, please retry with both -f and -t inputs... Exiting Now!!!"
		exit $EXIT_STATUS
	fi

	if [[ $F_SET -eq 0 && $T_SET -eq 0 ]]; then
		cps_ip=`awk -F"," -v cps="$NODE_TYPES2" '/^[^#]/ { if($1 == cps) { printf("%s",$2); exit; } }' $CONFIG_FILE 2>/dev/null`
		ssh -o BatchMode=yes -o ConnectTimeout=$SSH_TIMEOUT $USE_USER@$cps_ip exit &>/dev/null
		if [[ $? -ne 0 ]]; then
			tput bold; tput setaf 1;
			printf "Connectivity NOT working for [ %s ] IP [ %s ] defined in config file [ %s ] to check current timestamp. Ensure passwordless connectivity to this IP is setup before rerunning. Exiting now ...\n" $NODE_TYPES2 $cps_ip $CONFIG_FILE;
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
		CPS_TIMESTAMP=$(ssh $USE_USER@$cps_ip date +"%d-%m-%Y-%H-%M-%S" 2>/dev/null)
		echo -e $CBYELLOW"\nCURRENT CPS TIMESTAMP: [$CBCYAN $CPS_TIMESTAMP $CBYELLOW]\n$CNORMAL"
		if  [[ $F_SET -eq 0 ]]; then
			if [[ $FROM_TIME =~ [0-3][0-9]-[0-1][0-9]-[0-9]{4}-[0-2][0-9]-[0-5][0-9] ]]; then
				temp_time=`awk -F"-" '{printf("%s/%s/%s %s:%s",$2,$1,$3,$4,$5)}' <<<"$FROM_TIME"`

				START_TIME=$(val=`date -d "$temp_time" +"%M"`; suffix=${val:1:1}; if [[ $suffix =~ [1234] ]]; then new_suffix=`expr 5 - $suffix`; date -d "$temp_time $new_suffix mins" +"%Y%m%d%H%M"; fi; if [[ $suffix =~ [6789] ]]; then new_suffix=`expr 10 - $suffix`; date -d "$temp_time $new_suffix mins" +"%Y%m%d%H%M"; fi; if [[ $suffix =~ [05] ]]; then date -d "$temp_time" +"%Y%m%d%H%M"; fi)
				if [[ $? -ne 0 ]]; then
					echo "Looks like the date you have mentioned is invalid or not in desired format. Please retry with correct input. Exiting Now!!!"
					exit $EXIT_STATUS
				fi
			else
#				ssh $USE_USER@$cps_ip date -d \""$FROM_TIME"\" +"%Y%m%d%H%M" 2>/dev/null`
				START_TIME=$(ssh $USE_USER@$cps_ip "val=\`date -d \"$FROM_TIME\" +\"%M\"\`; suffix=\${val:1:1}; if [[ \$suffix =~ [1234] ]]; then new_suffix=\`expr 5 - \$suffix\`; date -d \"$FROM_TIME \$new_suffix mins\" +\"%Y%m%d%H%M\"; fi; if [[ \$suffix =~ [6789] ]]; then new_suffix=\`expr 10 - \$suffix\`; date -d \"$FROM_TIME \$new_suffix mins\" +\"%Y%m%d%H%M\"; fi; if [[ \$suffix =~ [05] ]]; then date -d \"$FROM_TIME\" +\"%Y%m%d%H%M\"; fi" 2>/dev/null)
				if [[ $? -ne 0 ]]; then
					echo "Looks like the date you have mentioned is invalid or not in desired format. Please retry with correct input. Exiting Now!!!"
					exit $EXIT_STATUS
				fi
			fi
		fi

		if  [[ $T_SET -eq 0 ]]; then
			if [[ $TILL_TIME =~ [0-3][0-9]-[0-1][0-9]-[0-9]{4}-[0-2][0-9]-[0-5][0-9] ]]; then
				temp_time=`awk -F"-" '{printf("%s/%s/%s %s:%s",$2,$1,$3,$4,$5)}' <<<"$TILL_TIME"`
#				END_TIME=`date -d "$temp_time" +"%Y%m%d%H%M" 2>/dev/null`
				END_TIME=$(val=`date -d "$temp_time" +"%M"`; suffix=${val:1:1}; if [[ $suffix =~ [1234] ]]; then new_suffix=`expr 0 - $suffix`; date -d "$new_suffix mins $temp_time" +"%Y%m%d%H%M"; fi; if [[ $suffix =~ [6789] ]]; then new_suffix=`expr 5 - $suffix`; date -d "$new_suffix mins $temp_time" +"%Y%m%d%H%M"; fi; if [[ $suffix =~ [05] ]]; then date -d "$temp_time" +"%Y%m%d%H%M"; fi;)
				if [[ $? -ne 0 ]]; then
					echo "Looks like the date you have mentioned is invalid or not in desired format. Please retry with correct input. Exiting Now!!!"
					exit $EXIT_STATUS
				fi
			else
#				END_TIME=`ssh $USE_USER@$cps_ip date -d \""$TILL_TIME"\" +"%Y%m%d%H%M" 2>/dev/null`
				END_TIME=$(ssh $USE_USER@$cps_ip "val=\`date -d \"$TILL_TIME\" +\"%M\"\`; suffix=\${val:1:1}; if [[ \$suffix =~ [1234] ]]; then new_suffix=\`expr 0 - \$suffix\`; date -d \"\$new_suffix mins $TILL_TIME\" +\"%Y%m%d%H%M\"; fi; if [[ \$suffix =~ [6789] ]]; then new_suffix=\`expr 5 - \$suffix\`; date -d \"\$new_suffix mins $TILL_TIME\" +\"%Y%m%d%H%M\"; fi; if [[ \$suffix =~ [05] ]]; then date -d \"$TILL_TIME\" +\"%Y%m%d%H%M\"; fi;")
				if [[ $? -ne 0 ]]; then
					echo "Looks like the date you have mentioned is invalid or not in desired format. Please retry with correct input. Exiting Now!!!"
					exit $EXIT_STATUS
				fi
			fi
		fi
		if [[ $F_SET -eq 0 ]] && [[ $T_SET -eq 0 ]]; then
			echo -e "Stats will be collected from CPS between [$CBCYAN ${START_TIME:6:2}-${START_TIME:4:2}-${START_TIME:0:4} ${START_TIME:8:2}:${START_TIME:10:2} $CNORMAL] and [$CBCYAN ${END_TIME:6:2}-${END_TIME:4:2}-${END_TIME:0:4} ${END_TIME:8:2}:${END_TIME:10:2} $CNORMAL] timestamps (inclusive) ..."
		fi
	fi

	echo -e "Completed Validation of command line options ..."
}
parse_options "$@";
validate_options;

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
	awk -F"," -v config_file=$CONFIG_FILE -v node_types1="$NODE_TYPES1" -v node_types2="$NODE_TYPES2" -v exit_code=$EXIT_STATUS --re-interval \
	'BEGIN { config_error="Configuration File Error." }
	/^[^#]/ { if ( $1 != node_types1 && $1 != node_types2 ) {
			printf("%s Please verify entries in column 1 of [ %s ]. Appears to be an issue with config. Exiting now!\n", config_error, config_file);
			exit exit_code;
		}
		if ( !match($2, /^([0-9]{1,3}\.){3}([0-9]{1,3})$/ )) {
			printf("%s Please verify entries in column 2 of [ %s ]. Appears to be an issue with config. Exiting now!\n", config_error, config_file);
			exit exit_code;
		}
		if ( $1 == node_types1 && NF < 5) {
			printf("%s Please verify the field entries for rows having [ %s ] configuration. Appears some entries are missing. Exiting now!\n", config_error, node_types1);
			exit exit_code;
		}
		if ( $1 == node_types2 && NF < 4) {
			printf("%s Please verify the field entries for rows having [ %s ] configuration. Appears some entries are missing. Exiting now!\n", config_error, node_types2);
			exit exit_code;
		}
		for (i=1; i <= NF; i++){
			if ($i == "") {
				printf("%s Please verify the field entries in config file for row %s. Appears some entries are missing/blank. Exiting now!\n", config_error, NR);
				exit exit_code;
			}
		}
	}' $CONFIG_FILE
	if [[ $? -eq $EXIT_STATUS ]]; then 
		tput sgr0; 
		exit $EXIT_STATUS; 
	fi

	DSTEST_NODES=$(awk -F"," -v dstest=$NODE_TYPES1 '/^[^#]/ { if ($1 == dstest && arr[$3] == "") arr[$3]=$3; } END { len=asort(arr); for (i=1;i<=len;i++) printf("%s ", arr[i]); }' $CONFIG_FILE)
	DSTEST_INTERFACES=$(awk -F"," -v dstest=$NODE_TYPES1 '/^[^#]/ { if ($1 == dstest && arr[$NF] == "") arr[$NF]=$NF; } END { len=asort(arr); for (i=1;i<=len;i++) printf("%s ", arr[i]); }' $CONFIG_FILE)
	CPS_INTERFACES=$(awk -F"," -v cps=$NODE_TYPES2 '/^[^#]/ { if ($1 == cps && arr[$NF] == "") arr[$NF]=$NF; } END { len=asort(arr); for (i=1;i<=len;i++) printf("%s ", arr[i]); }' $CONFIG_FILE)

	tput sgr0;
	echo  "Completed Validation of config file [$CBYELLOW $CONFIG_FILE $CNORMAL] ..."
	echo  "Identified following types of$CBGREEN dsTest nodes$CNORMAL in [$CBYELLOW $CONFIG_FILE $CNORMAL]:[$CBCYAN $DSTEST_NODES $CNORMAL]"
	echo  "Identified following types of$CBGREEN dsTest interfaces$CNORMAL in [$CBYELLOW $CONFIG_FILE $CNORMAL]:[$CBCYAN $DSTEST_INTERFACES $CNORMAL]"
	echo  "Identified following types of$CBGREEN cps interfaces$CNORMAL in [$CBYELLOW $CONFIG_FILE $CNORMAL]:[$CBCYAN $CPS_INTERFACES $CNORMAL]"
}

validate_config;

verify_connectivity()
{
	echo -e $SEPARATOR"\nChecking connectivity to IP addresses mentioned in config file [$CBYELLOW $CONFIG_FILE $CNORMAL] ..."

	tput bold; tput setaf 1;
	awk -F"," -v config_file=$CONFIG_FILE -v exit_code=$EXIT_STATUS -v ssh_timeout=$SSH_TIMEOUT -v user=$USE_USER --re-interval \
	'/^[^#]/ { arr[$2]=$1 }
	END { 
	for (ip in arr) {
		connect_string=sprintf("ssh -o BatchMode=yes -o ConnectTimeout=%d %s@%s exit &>/dev/null",ssh_timeout,user,ip);
		ret_val=system(connect_string);
		if (ret_val != 0) {
			system("tput bold");
			system("tput setaf 1");
			printf("Connectivity NOT working for [ %s ] IP [ %s ] defined in config file [ %s ]. Ensure passwordless connectivity to this IP is setup before rerunning. Exiting now!\n", arr[ip], ip, config_file);
			system("tput setaf 5");
			printf("======== HELP ========\n");
			system("tput sgr0");
			system("tput setaf 4");
			printf("To enable passwordless connection to an IP, run following commands as root on the local machine from where you want to ssh.\n");
			printf("ssh-keygen\n");
			printf("keep-pressing ENTER key unless it asks if you want to Overwrite, in which case select <n>.\n");
			printf("ssh-copy-id root@<Destination machine IP>\n");
			printf("Enter the password for ssh to destination machine. This is one time.\n");
			printf("You should now be able to do a passwordless ssh using ssh root@<Destination machine IP>\n");
			system("tput bold");
			system("tput setaf 5");
			printf("======== HELP ========\n");
			system("tput sgr0");
			exit exit_code;
		}
		else {
			system("tput bold");
			system("tput setaf 2");
			printf("Connectivity working for [ %s ] IP [ %s ] defined in config file [ %s ]\n", arr[ip], ip, config_file);
			system("tput sgr0");
		}
	}
	}' $CONFIG_FILE

	if [[ $? -eq $EXIT_STATUS ]]; then tput sgr0; exit $EXIT_STATUS; fi

	tput sgr0;
	echo -e "Completed checking connectivity to IP addresses mentioned in config file [$CBYELLOW $CONFIG_FILE $CNORMAL] ..."

}
verify_connectivity;

capture_dstest_stats()
{
	local count=$(cat $CONFIG_FILE | sed -n "/^$NODE_TYPES1,/ p" | wc -l);
	
	echo -e $SEPARATOR"\nNow capturing dsTest stats for nodes defined in the config file ..."

	DSTEST_STATS_FILE="${PWD}/dsTest_stats.${TIMESTAMP}";

	tput bold; tput setaf 2;
	awk -F"," -v q1=\' -v q2=\" -v dstest="$NODE_TYPES1" -v user="$USE_USER" -v count="$count" -v dsclient_home="$DSCLIENT_HOME" -v dsclient="$DSCLIENT" -v dstest_nodes="$DSTEST_NODE_TYPES" -v outfile="$DSTEST_STATS_FILE" --re-interval \
	'BEGIN	{ gx_om="gx om"; rx_om="rx om"; ocs_om="sy om"; tdf_om="sd om"; hss_om="sh om"; diam_om="diameter om"; diam_sec_om="diameter_secondary om";
		progress="####"; val=1; split(dstest_nodes,nodes," "); }
	/^[^#]/ { if($1 == dstest) {
			split($3, node_interface, "-");

			if (node_interface[2] != "") {
				capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s %s om\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, node_interface[1], $4, node_interface[2]);
				ret_val=system(capture);
			}
			else {
				if (node_interface[1] == nodes[1]) {
					capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s %s\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, $3, $4, gx_om);
					ret_val=system(capture);
				}
				if (node_interface[1] == nodes[2]) {
					capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s %s\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, $3, $4, ocs_om);
					ret_val=system(capture);
				}
				if (node_interface[1] == nodes[3]) {
					capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s %s\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, $3, $4, tdf_om);
					ret_val=system(capture);
				}
				if (node_interface[1] == nodes[4]) {
					capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s %s\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, $3, $4, rx_om);
					ret_val=system(capture);
				}
				if (node_interface[1] == nodes[5]) {
					capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s %s\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, $3, $4, hss_om);
					ret_val=system(capture);
				}
			}

			str=sprintf("ssh root@%s %s%s -c %s:%s | grep diameter.*name | awk -F%s%s%s %s{printf(\"%%s \", $2)}%s", $2, dsclient_home, dsclient, node_interface[1], $4, q2, q1, q2, q1, q1);
			str |& getline temp;
			close(str);

			split(temp, arr, " ");
			len = length(arr);
			for(i=1; i<=len; i++) {
				capture=sprintf("ssh root@%s %s%s<<EOF >> %s\n%s:%s diameter:%s om\nexit\nEOF\n", $2, dsclient_home, dsclient, outfile, node_interface[1], $4, arr[i]);
				ret_val=system(capture);
			}
		progress=progress "####";
		printf("\r%s", progress);
		printf("> [%d%%]", (val*100/count));
		++val;
		}
	}' $CONFIG_FILE
	tput sgr0;

	sed -i s/**//g $DSTEST_STATS_FILE
	echo -e "\nCompleted capturing current dsTest stats for all nodes and saved in [$CBYELLOW $DSTEST_STATS_FILE $CNORMAL]."

	echo -e "Now working on dsTest stats and preparing report ..."
	DSTEST_TEMP_FILE=`mktemp`	

	awk -F"," -v q=\' -v dstest_stats_file="$DSTEST_STATS_FILE" 'BEGIN { command1="mktemp"; }
	/^[^#]/ { 
			split($3, node_interface, "-");
			if(arr[$3$5] == "") {
				command1 |& getline arr[$3$5];
				close(command1);

				if (node_interface[2] == "") {
					command2=sprintf("sed -n \"/%s:%s/,/exit/ p\" %s >> %s", node_interface[1], $4, dstest_stats_file, arr[$3$5]);
					system(command2);
				}
				else {
					command2=sprintf("sed -n \"/%s:%s %s/,/exit/ p\" %s >> %s", node_interface[1], $4, node_interface[2], dstest_stats_file, arr[$3$5]);
					command21=sprintf("sed -n \"/%s:%s diameter:/,/exit/ p\" %s >> %s", node_interface[1], $4, dstest_stats_file, arr[$3$5]);
					system(command2);
					system(command21);
				}
			}
			else {
				if (node_interface[2] == "") {
					command2=sprintf("sed -n \"/%s:%s/,/exit/ p\" %s >> %s", node_interface[1], $4, dstest_stats_file, arr[$3$5]);
					system(command2);
				}
				else {
					command2=sprintf("sed -n \"/%s:%s %s/,/exit/ p\" %s >> %s", node_interface[1], $4, node_interface[2], dstest_stats_file, arr[$3$5]);
					command21=sprintf("sed -n \"/%s:%s diameter:/,/exit/ p\" %s >> %s", node_interface[1], $4, dstest_stats_file, arr[$3$5]);
					system(command2);
					system(command21);
				}
			}
		}
		END {
			for (i in arr){
				command3=sprintf("awk -F\"[%c:]\" %c/name=/ { if (param[$4] == \"\") param[$4]=$6; else param[$4]+=$6; } END {total=asorti(param, iparamnew); printf(\"START_%s\\n\"); for(j=1;j<=total;j++) { printf(\"%%s:%%s\\n\", iparamnew[j], param[iparamnew[j]]); } printf(\"END_%s\\n\"); }%c %s", q, q, i, i, q, arr[i]);
				system(command3);
				command4=sprintf("rm -f %s", arr[i]);
				system(command4);
			}
		}' $CONFIG_FILE  > $DSTEST_TEMP_FILE
}

display_dstest_stats()
{
	OIFS=$IFS
	temp_param_list=`awk -F":" '/.*:.*/ {if(arr[$1] == "") arr[$1]=$1} END { len=asorti(arr,iarr); for (i=1;i<=len;i++) printf("%s:",iarr[i]);}' $DSTEST_TEMP_FILE`
	temp_interface_list=`awk -F"," -v node="$NODE_TYPES1" '/^[^#]/ { if ($1 == node) { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf("%s:", arr[$3$5]);} } }' $CONFIG_FILE`

	IFS=':'
	read -a param_list <<< "$temp_param_list"
	read -a interface_list <<< "$temp_interface_list"

	length_param_list=${#param_list[*]}
	length_interface_list=${#interface_list[*]}
	
	max_len_plist=0;
	max_len_ilist=0;

	for pelement in ${param_list[*]}; do
		if [[ ${#pelement} -gt $max_len_plist ]]; then
			max_len_plist=${#pelement}
		fi
	done

	for ielement in ${interface_list[*]}; do
		if [[ ${#ielement} -gt $max_len_ilist ]]; then
			max_len_ilist=${#ielement}
		fi
	done

	if [[ $max_len_ilist -lt $MAX_COLUMN_WIDTH ]]; then
		max_len_ilist=$MAX_COLUMN_WIDTH;
	fi
	
	max_len_ilist=$(( max_len_ilist + 1 ));
	max_len_plist=$(( max_len_plist + 1 ));

	bar1=""; bar2=""; bar3=""; bar4=""; bar5=""
	
	for((i=1; i <= max_len_plist; i++)); do
		bar1=$bar1"="
		bar2=$bar2"-"
		bar5=$bar5" "
	done
	
	for((i=1; i <= max_len_ilist; i++)); do
		bar3=$bar3"="
		bar4=$bar4"-"
	done

	display_format_plist="%-"$max_len_plist"s";
	display_format_ilist="|%-"$max_len_ilist"s";
	
	IFS=$OIFS

	if (($P_SET == 0)); then
	{
		printf $CBMAGENTA"\nDisplaying DSTEST stats :\n\n"$CNORMAL

		awk -F"," -v bar1="$bar1" -v bar3="$bar3" 'BEGIN {printf(bar1);} /^[^#]/ { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf(bar3);} }' $CONFIG_FILE;
		printf "\n";

		tput bold; tput setaf 3;
		printf "$bar5";
		for(( i=0;i < length_interface_list; i++ )); do
			printf $display_format_ilist ${interface_list[$i]};
		done
		printf "\n";
		tput sgr0;

		awk -F"," -v bar1="$bar1" -v bar3="$bar3" 'BEGIN {printf(bar1);} /^[^#]/ { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf(bar3);} }' $CONFIG_FILE;
		printf "\n";

		for ((i=0; i < length_param_list; i++)); do
			if (( $i%2 == 0 )); then
				tput setaf bold; tput setaf 2;
				printf $display_format_plist "${param_list[$i]}";
				for((j=0; j < length_interface_list; j++)); do
					str=$(awk /^START_"${interface_list[$j]}"$/,/^END_"${interface_list[$j]}"$/ $DSTEST_TEMP_FILE | grep "${param_list[$i]}")
					if [[ "$str" != "" ]]; then
						awk -F":" -v disp="$display_format_ilist" '{if ($2 != "") printf(disp, $2); else printf(disp,"-");}' <<< $str
					else
						printf $display_format_ilist "-"
					fi
				done
				printf "\n"
			else
				tput setaf bold; tput setaf 6;
				printf $display_format_plist "${param_list[$i]}";
				for((j=0; j < length_interface_list; j++)); do
					str=$(awk /^START_"${interface_list[$j]}"$/,/^END_"${interface_list[$j]}"$/ $DSTEST_TEMP_FILE | grep "${param_list[$i]}")
					if [[ "$str" != "" ]]; then
						awk -F":" -v disp="$display_format_ilist" '{if ($2 != "") printf(disp, $2); else printf(disp,"-");}' <<< $str
					else
						printf $display_format_ilist "-"
					fi
				done
				printf "\n"
			fi
			tput sgr0;
			awk -F"," -v bar2="$bar2" -v bar4="$bar4" 'BEGIN {printf(bar2);} /^[^#]/ { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf(bar4);} }' $CONFIG_FILE;
			printf "\n";
		done
		tput sgr0;
	}
	else	{
		printf "\nDisplaying DSTEST stats :\n\n"

		awk -F"," -v bar1="$bar1" -v bar3="$bar3" 'BEGIN {printf(bar1);} /^[^#]/ { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf(bar3);} }' $CONFIG_FILE;
		printf "\n";

		printf "$bar5";
		for(( i=0;i < length_interface_list; i++ )); do
			printf $display_format_ilist ${interface_list[$i]};
		done
		printf "\n";

		awk -F"," -v bar1="$bar1" -v bar3="$bar3" 'BEGIN {printf(bar1);} /^[^#]/ { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf(bar3);} }' $CONFIG_FILE;
		printf "\n";

		for (( i=0; i < length_param_list; i++ )); do
			printf $display_format_plist "${param_list[$i]}";
			for (( j=0; j < length_interface_list; j++ )); do
				str=$(awk /^START_"${interface_list[$j]}"$/,/^END_"${interface_list[$j]}"$/ $DSTEST_TEMP_FILE | grep "${param_list[$i]}")
				if [[ "$str" != "" ]]; then
					awk -F":" -v disp="$display_format_ilist" '{if ($2 != "") printf(disp, $2); else printf(disp,"-");}' <<< $str
				else
					printf $display_format_ilist "-"
				fi
			done
			printf "\n";
			awk -F"," -v bar2="$bar2" -v bar4="$bar4" 'BEGIN {printf(bar2);} /^[^#]/ { if (arr[$3$5]=="") { arr[$3$5]=$3$5; printf(bar4);} }' $CONFIG_FILE;
			printf "\n";
		done
	}
	fi >> $OUTPUT_FILE
	echo -e "Report prepared for dsTest and saved in [$CBYELLOW $OUTPUT_FILE $CNORMAL]."
}


capture_cps_stats()
{
	local count=$(cat $CONFIG_FILE | sed -n "/^$NODE_TYPES2,/ p" | wc -l);
	
	echo -e $SEPARATOR"\nNow capturing CPS stats for nodes defined in the config file for the timestamps provided ..."
	CPS_STATS_FILE="${PWD}/CPS_stats.${TIMESTAMP}";

	awk -F"," -v node="$NODE_TYPES2" -v user="$USE_USER" -v count="$count" -v stats_home="$CPSSTATS_HOME" -v prefix="$CPSSTATS_PREFIX" -v suffix="$CPSSTATS_SUFFIX" -v outfile="$CPS_STATS_FILE" -v start_time="$START_TIME" -v end_time="$END_TIME" -v exit_status="$EXIT_STATUS" \
	'/^[^#]/{ 
			if ($1 == node) { 
				if ( arrip[$2] == "") arrip[$2]=$3;
				}
		}
	END	{ 
			for ( i in arrip ) {
				capture_start=sprintf("ssh %s@%s cat %s%s-%s-%s.%s >> %s 2>/dev/null", user, i, stats_home, prefix, arrip[i], start_time, suffix, outfile);
				capture_end=sprintf("ssh %s@%s cat %s%s-%s-%s.%s >> %s 2>/dev/null", user, i, stats_home, prefix, arrip[i], end_time, suffix, outfile);
				printf("%s", "BEGIN_STARTTIME_STATS\n") >> outfile;
				ret_val1=system(capture_start);
				if ( ret_val1 != 0 ) { 
					system("tput bold;tput setaf 1");
					printf("Could not capture CPS stats for starting timestamp [ %s ] from [ %s ]. You may want to check hostname corresponding to CPS entries in config file or timestamp. Will continue with whatever data available.\n", start_time, i);
				}
				else	{
					system("tput bold;tput setaf 2");
					printf("Captured CPS stats for starting timestamp [ %s ] from [ %s ].\n", start_time, i);
				}
				printf("%s", "END_STARTTIME_STATS\n") >> outfile;
				printf("%s", "BEGIN_ENDTIME_STATS\n") >> outfile;
				ret_val2=system(capture_end);
				if ( ret_val2 != 0 ) { 
					system("tput bold;tput setaf 1");
					printf("Could not capture CPS stats for ending timestamp [ %s ] from [ %s ]. You may want to check hostname corresponding to CPS entries in config file or timestamp. Will continue with whatever data available.\n", end_time, i);
				}
				else	{
					system("tput bold;tput setaf 2");
					printf("Captured CPS stats for ending timestamp [ %s ] from [ %s ].\n", end_time, i);
				}
				printf("%s", "END_ENDTIME_STATS\n") >> outfile;
			}
	}' $CONFIG_FILE

	tput sgr0;
	echo -e "Completed capturing CPS stats for all nodes and saved in [$CBYELLOW $CPS_STATS_FILE $CNORMAL]."

	echo -e "Now working on CPS stats and preparing report ..."

	CPS_TEMP_FILE=`mktemp`
	awk -F"[,.]" '/BEGIN_STARTTIME_STATS/,/END_STARTTIME_STATS/ { 
				if ($4 == "counters" && $2 ~ "lb")	{
					if (arr_counters["lb,"$5] == "")
						arr_counters["lb,"$5]=$7;
					else
						arr_counters["lb,"$5]+=$7;
				}
				if ($4 == "counters" && $2 ~ "qns")	{
					if (arr_counters["qns,"$5] == "")
						arr_counters["qns,"$5]=$7;
					else
						arr_counters["qns,"$5]+=$7;
				}
				if ($4 == "messages" && $7 == "success" && $2 ~ "lb")	{
					if (arr_success_mesg["lb,"$5] == "")
						arr_success_mesg["lb,"$5]=$8;
					else
						arr_success_mesg["lb,"$5]+=$8;
				}
				if ($4 == "messages" && $7 == "success" && $2 ~ "qns")	{
					if (arr_success_mesg["qns,"$5] == "")
						arr_success_mesg["qns,"$5]=$8;
					else
						arr_success_mesg["qns,"$5]+=$8;
				}
				if ($4 == "messages" && $7 == "error" && $2 ~ "lb")	{
					if (arr_error_mesg["lb,"$5] == "")
						arr_error_mesg["lb,"$5]=$8;
					else
						arr_error_mesg["lb,"$5]+=$8;
				}
				if ($4 == "messages" && $7 == "error" && $2 ~ "qns")	{
					if (arr_error_mesg["qns,"$5] == "")
						arr_error_mesg["qns,"$5]=$8;
					else
						arr_error_mesg["qns,"$5]+=$8;
				}
		}
		END	{
			for (i in arr_counters)	
				printf("counters,%s,%s\n", i, arr_counters[i]);
			for (j in arr_success_mesg)
				printf("success_messages,%s,%s\n", j, arr_success_mesg[j]);
			for (k in arr_error_mesg)
				printf("error_messages,%s,%s\n", k, arr_error_mesg[k]);
		}
		' $CPS_STATS_FILE >> $CPS_TEMP_FILE

	awk -F"[,.]" '/BEGIN_ENDTIME_STATS/,/END_ENDTIME_STATS/ { 
				if ($4 == "counters" && $2 ~ "lb")	{
					if (arr_counters["lb,"$5] == "")
						arr_counters["lb,"$5]=$7;
					else
						arr_counters["lb,"$5]+=$7;
				}
				if ($4 == "counters" && $2 ~ "qns")	{
					if (arr_counters["qns,"$5] == "")
						arr_counters["qns,"$5]=$7;
					else
						arr_counters["qns,"$5]+=$7;
				}
				if ($4 == "messages" && $7 == "success" && $2 ~ "lb")	{
					if (arr_success_mesg["lb,"$5] == "")
						arr_success_mesg["lb,"$5]=$8;
					else
						arr_success_mesg["lb,"$5]+=$8;
				}
				if ($4 == "messages" && $7 == "success" && $2 ~ "qns")	{
					if (arr_success_mesg["qns,"$5] == "")
						arr_success_mesg["qns,"$5]=$8;
					else
						arr_success_mesg["qns,"$5]+=$8;
				}
				if ($4 == "messages" && $7 == "error" && $2 ~ "lb")	{
					if (arr_error_mesg["lb,"$5] == "")
						arr_error_mesg["lb,"$5]=$8;
					else
						arr_error_mesg["lb,"$5]+=$8;
				}
				if ($4 == "messages" && $7 == "error" && $2 ~ "qns")	{
					if (arr_error_mesg["qns,"$5] == "")
						arr_error_mesg["qns,"$5]=$8;
					else
						arr_error_mesg["qns,"$5]+=$8;
				}
		}
		END	{
			for (i in arr_counters)	
				printf("counters,%s,%s\n", i, arr_counters[i]);
			for (j in arr_success_mesg)
				printf("success_messages,%s,%s\n", j, arr_success_mesg[j]);
			for (k in arr_error_mesg)
				printf("error_messages,%s,%s\n", k, arr_error_mesg[k]);
		}
		' $CPS_STATS_FILE >> $CPS_TEMP_FILE
}

display_cps_stats()
{
	local length_mtypes=${#DIAM_MESSAGE_TYPES[*]}

	if (($P_SET == 0)); then
	{
	printf $CBMAGENTA"\n\nDisplaying CPS stats :\n"$CNORMAL
	printf "CPS TIMESTAMP : %s\n" "$CBGREEN$CPS_TIMESTAMP"$CNORMAL
	printf "Displaying stats between CPS TIMESTAMPS : [$CBGREEN %s$CNORMAL ] AND [$CBGREEN %s$CNORMAL ]\n" "$START_TIME" "$END_TIME"
	awk -v interface_list="$CPS_INTERFACES" -v nodes="$CPS_NODE_TYPES" -v node_items="$CPS_STATS_TYPES" ' BEGIN { \
		split(interface_list, interfaces, " ");
		split(nodes, node_list, " ");
		split(node_items, stats_items, " ");

		system("tput sgr0")
		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}
		printf ("\n");
	
		printf ("%30s|", " ");
		system("tput bold; tput setaf 3;")
		for (i=1; i<=length(interfaces); i++) {
			len = length(interfaces[i]);
			if (len == 2)
				prefix = (66 - len)/2 + 2;
			else
				prefix = (66 - len)/2 + 3;
			if (len == 2)
				suffix = (66 - prefix - 1);
			else
				suffix = (66 - prefix);
			str = "%" prefix "s" "%" suffix "s|";
			printf (str, interfaces[i], " ")
		}

		system("tput sgr0")
		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}

		printf ("\n");
		printf ("%30s|", " ");
		system("tput bold; tput setaf 5;")
		for (i=1; i<= length(interfaces); i++) {
			prefix1 = 17;
			suffix1 = 15;
			prefix2 = 18;
			suffix2 = 14;
			str = "%" prefix1 "s" "%" suffix1 "s|" "%" prefix2 "s" "%" suffix2 "s|";
			printf (str, "lb", " ", "qns", " ");
		}
		system("tput sgr0")

		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}

		printf ("\n");
		printf ("%30s|", " ");
		system("tput bold; tput setaf 3;")
		for (i=1; i<= length(interfaces)*length(node_list); i++) {
			printf("%s%s%s|%s%s%s|%s%s%s|", "  ", "success", " ", "  ", "errors", "  ", " ", "counters", " ");
		}
		system("tput sgr0")

		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}
	}'

	for ((i=0; i<length_mtypes; i++)); do
		awk -F"," -v mesg_type="${DIAM_MESSAGE_TYPES[$i]}" -v interface_list="$CPS_INTERFACES" -v nodes="$CPS_NODE_TYPES" -v node_items="$CPS_STATS_TYPES" ' BEGIN { \
			split(interface_list, interfaces, " ");
			split(nodes, node_list, " ");
			split(node_items, stats_items, " ");
			}
			{
				for(i=1; i<=length(interfaces); i++) {
					message=interfaces[i] "_" mesg_type;
					if ($3 ~ message) {
						if (arr[$1","$2","$3] == "")
							arr[$1","$2","$3]=$4;
						else
							arr[$1","$2","$3]=$4-arr[$1","$2","$3];
					}
				}
			}
			END {
				for (i in arr) {
					split(i, elements, ",");
					if (newarr[elements[3]] == "" ) {
						newarr[elements[3]] = elements[3];
					}
				}
				for (i in newarr) {
					for (j=1; j<= length(interfaces) ; j++) {
						message=interfaces[j] "_" mesg_type;
						if ( newarr[i] ~ message ) {
							split(newarr[i], items, message); 
							if (items[1]=="" && items[2]=="") {
								if (list[mesg_type] == "") list[mesg_type] = mesg_type;
							}
							else {
								if(substr(items[1],length(items[1]), 1) == "_")
									items[1] = substr(items[1], 1, length(items[1])-1);
								if(substr(items[2], 1, 1) == "_")
									items[2] = substr(items[2], 2, length(items[2]));
								if (list[items[1] items[2]] == "")
									list[items[1] items[2]] = items[1] "," items[2];
							}
						}
					}
				}

				len=asort(list);
				for (i=1;i<=len;i++) {
					if ( i%2 == 0 ) system("tput bold; tput setaf 2"); else system("tput bold; tput setaf 6"); 
					str1 = substr(list[i], 1, index(list[i],",")-1);
					str2 = substr(list[i], index(list[i],",")+1, length(list[i]));
					if (str1 == "" && str2 != "")
						str = mesg_type " : " str2;
					else
					if (str2 == "" && str1 != "") 
							str = mesg_type " : " str1;
					else
					if (str2 != "" && str1 != "") str = mesg_type " : " str1 "_" str2;

					printf("\n%-30s|", str);

					split(list[i], sub_list, ",");
					if (sub_list[1] != "")
						sub_list[1] = sub_list[1] "_";
					if (sub_list[2] != "")
						sub_list[2] = "_" sub_list[2];

					subset = substr(sub_list[1], 1, length(sub_list[1])-1);
					for (j=1;j<=length(interfaces); j++) {
						message = interfaces[j] "_" mesg_type;
						if ( subset == mesg_type )
							sub_list[1] = message;
						for(k=1; k <= length(node_list); k++) {
							for(l=1; l<= length(stats_items); l++) {
								found=0;
								for (item in arr) {
									if ( match(item, message) && match(item, node_list[k]) && match(item, stats_items[l]) ) {
										split(item, sub_item, ",");
										split(sub_item[3], sub_item_parts, message);
										if (sub_item_parts[1] == "" && sub_item_parts[2] == "") {
											if (sub_list[1] == message) {
												found = 1; break;
											}
										}
										if (sub_list[1] == sub_item_parts[1] && sub_list[2] == sub_item_parts[2]) {
											found = 1; break;
										}
									}
								}
							if (found == 1) printf("%-10s|", arr[item]); else printf ("%-10s|", "-");
    							}
						}
					}
				}
				if (length(arr) > 0) {
					system("tput sgr0");
					printf ("\n%s", "-------------------------------");
					for (i=1; i<=length(interfaces); i++) {
						str="-----------";
						printf("%s%s%s%s%s%s",str, str, str, str, str, str);
					}
				}
			}' $CPS_TEMP_FILE
	done
	printf "\n";
	} else {
	printf "\n\nDisplaying CPS stats :\n"
	printf "CPS TIMESTAMP : %s\n" "$CPS_TIMESTAMP"
	printf "Displaying stats between CPS TIMESTAMPS : [ %s ] AND [ %s ]\n" "$START_TIME" "$END_TIME"
	awk -v interface_list="$CPS_INTERFACES" -v nodes="$CPS_NODE_TYPES" -v node_items="$CPS_STATS_TYPES" ' BEGIN { \
		split(interface_list, interfaces, " ");
		split(nodes, node_list, " ");
		split(node_items, stats_items, " ");

		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}
	
		printf ("\n");
		printf ("%30s|", " ");
		for (i=1; i<=length(interfaces); i++) {
			len = length(interfaces[i]);
			if (len == 2)
				prefix = (66 - len)/2 + 2;
			else
				prefix = (66 - len)/2 + 3;
			if (len == 2)
				suffix = (66 - prefix - 1);
			else
				suffix = (66 - prefix);
			str = "%" prefix "s" "%" suffix "s|";
			printf (str, interfaces[i], " ")
		}

		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}

		printf ("\n");
		printf ("%30s|", " ");
		for (i=1; i<= length(interfaces); i++) {
			prefix1 = 17;
			suffix1 = 15;
			prefix2 = 18;
			suffix2 = 14;
			str = "%" prefix1 "s" "%" suffix1 "s|" "%" prefix2 "s" "%" suffix2 "s|";
			printf (str, "lb", " ", "qns", " ");
		}

		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}

		printf ("\n");
		printf ("%30s|", " ");
		for (i=1; i<= length(interfaces)*length(node_list); i++) {
			printf("%s%s%s|%s%s%s|%s%s%s|", "  ", "success", " ", "  ", "errors", "  ", " ", "counters", " ");
		}

		printf ("\n");
		printf ("%s", "-------------------------------");
		for (i=1; i<=length(interfaces); i++) {
			str="-----------";
			printf("%s%s%s%s%s%s",str, str, str, str, str, str);
		}
	}'


	for ((i=0; i<length_mtypes; i++)); do
		awk -F"," -v mesg_type="${DIAM_MESSAGE_TYPES[$i]}" -v interface_list="$CPS_INTERFACES" -v nodes="$CPS_NODE_TYPES" -v node_items="$CPS_STATS_TYPES" ' BEGIN { \
			split(interface_list, interfaces, " ");
			split(nodes, node_list, " ");
			split(node_items, stats_items, " ");
			}
			{
				for(i=1; i<=length(interfaces); i++) {
					message=interfaces[i] "_" mesg_type;
					if ($3 ~ message) {
						if (arr[$1","$2","$3] == "")
							arr[$1","$2","$3]=$4;
						else
							arr[$1","$2","$3]=$4-arr[$1","$2","$3];
					}
				}
			}
			END {
				for (i in arr) {
					split(i, elements, ",");
					if (newarr[elements[3]] == "" ) {
						newarr[elements[3]] = elements[3];
					}
				}
				for (i in newarr) {
					for (j=1; j<= length(interfaces) ; j++) {
						message=interfaces[j] "_" mesg_type;
						if ( newarr[i] ~ message ) {
							split(newarr[i], items, message); 
							if (items[1]=="" && items[2]=="") {
								if (list[mesg_type] == "") list[mesg_type] = mesg_type;
							}
							else {
								if(substr(items[1],length(items[1]), 1) == "_")
									items[1] = substr(items[1], 1, length(items[1])-1);
								if(substr(items[2], 1, 1) == "_")
									items[2] = substr(items[2], 2, length(items[2]));
								if (list[items[1] items[2]] == "")
									list[items[1] items[2]] = items[1] "," items[2];
							}
						}
					}
				}

				len=asort(list);
				for (i=1;i<=len;i++) {
					str1 = substr(list[i], 1, index(list[i],",")-1);
					str2 = substr(list[i], index(list[i],",")+1, length(list[i]));
					if (str1 == "" && str2 != "")
						str = mesg_type " : " str2;
					else
					if (str2 == "" && str1 != "") 
							str = mesg_type " : " str1;
					else
					if (str2 != "" && str1 != "") str = mesg_type " : " str1 "_" str2;

					printf("\n%-30s|", str);

					split(list[i], sub_list, ",");
					if (sub_list[1] != "")
						sub_list[1] = sub_list[1] "_";
					if (sub_list[2] != "")
						sub_list[2] = "_" sub_list[2];

					subset = substr(sub_list[1], 1, length(sub_list[1])-1);
					for (j=1;j<=length(interfaces); j++) {
						message = interfaces[j] "_" mesg_type;
						if ( subset == mesg_type )
							sub_list[1] = message;
						for(k=1; k <= length(node_list); k++) {
							for(l=1; l<= length(stats_items); l++) {
								found=0;
								for (item in arr) {
									if ( match(item, message) && match(item, node_list[k]) && match(item, stats_items[l]) ) {
										split(item, sub_item, ",");
										split(sub_item[3], sub_item_parts, message);
										if (sub_item_parts[1] == "" && sub_item_parts[2] == "") {
											if (sub_list[1] == message) {
												found = 1; break;
											}
										}
										if (sub_list[1] == sub_item_parts[1] && sub_list[2] == sub_item_parts[2]) {
											found = 1; break;
										}
									}
								}
							if (found == 1) printf("%-10s|", arr[item]); else printf ("%-10s|", "-");
    							}
						}
					}
				}
				if (length(arr) > 0) {
					printf ("\n%s", "-------------------------------");
					for (i=1; i<=length(interfaces); i++) {
						str="-----------";
						printf("%s%s%s%s%s%s",str, str, str, str, str, str);
					}
				}
			}' $CPS_TEMP_FILE
	done
	printf "\n";
	}
	fi >> $OUTPUT_FILE
	
	tput sgr0;
	echo -e "Report prepared for CPS and saved in [$CBYELLOW $OUTPUT_FILE $CNORMAL]."
}

if (($P_SET == 0)); then
	printf "\nFILENAME : $CBGREEN%s\n" "$OUTPUT_FILE$CNORMAL"
	printf "LOCAL TIMESTAMP : $CBGREEN%s\n" "$TIMESTAMP$CNORMAL"
else 
	printf "\nFILENAME : %s\n" "$OUTPUT_FILE"
	printf "LOCAL TIMESTAMP : %s\n" "$TIMESTAMP"
fi >> $OUTPUT_FILE

if [[ "$DSTEST_INTERFACES" != "" ]]; then
	capture_dstest_stats;
	display_dstest_stats;
fi

if [[ "$CPS_INTERFACES" != "" ]]; then
	if ((F_SET == 0 && T_SET == 0)); then
		capture_cps_stats;
		display_cps_stats;
	fi
fi

echo -e $SEPARATOR
rm -f $DSTEST_TEMP_FILE $CPS_TEMP_FILE
echo -e "\nAll Done ...\n"

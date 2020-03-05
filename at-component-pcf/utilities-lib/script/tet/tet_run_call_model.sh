#!/bin/bash
######################################################################################################################################
#                       Filename        :       tet_run_call_model.sh
#                       Author          :       Navneet Kumar Verma
#                       Project         :       Test Effectiveness Toolkit [TET]
#                       About           :       This bash script can run user selected call models at user defined CCR-I TPS and assumes
#						that the corresponding database and nodes are already loaded in the tool (dsTest).
#                       Version         :       1 [Date: 01-Dec-17] [Initial Version. Support for starting selected call models. The
#						script does not validate error conditions at the moment, this would be coded later]
######################################################################################################################################
DSCLIENT_HOME="/usr/local/devsol/bin/dsClient"
TMP_HOME=/tmp/
EXIT_STATUS=60
NO_ARGS=0
COMMAND_LIST_ITEMS=( DB CM START END RATE CYC INCR )
COMMAND_ARRAY=""
COMMAND_DB_TYPE="spr"
COMMAND_APP_TYPE="SmartEvents"
COMMAND_EVENT_TYPE="start"
REMOTE_USERNAME="root"
SCRIPTNAME=`basename $0`
mydate=`date +"%d-%m-%Y-%H-%M-%S"`
D_SET=1
T_SET=1
L_SET=1

usage()
{
	echo -e "\nUSAGE:\n"
	echo -e "$SCRIPTNAME -d \"Space separated list of tool IPs against the space separated list of commands\" -l \"Space separated list of commands as shown in example below\" -t \"Time delay between TPS increments\"\n"
	echo -e "$SCRIPTNAME -d \"172.16.1.100 172.16.1.100\" \"DB=SPR_SITE1;CM=BROADBAND_MANIFEST_SITE1,START=100001,END=200000,RATE=50,CYC=-1,INCR=5 DB=SPR_SITE1;CM=IMS_VOWIFI_SITE1,START=200001,END=300000,RATE=70,CYC=-1,INCR=10\" -t 10\n"
}

if [[ $# -eq "NO_ARGS" ]]
then
	usage;
	exit $EXIT_STATUS
fi

run_on_receiving_signal()
{
	# any other operations before exiting
	echo -e "Exiting on request ..."
	exit $?
}

trap run_on_receiving_signal SIGHUP SIGINT SIGTERM

run_call_models()
{
	count=0;
	for item in ${COMMAND_ARRAY[*]}; do
		awk -F";" -v dsClient=${DSCLIENT_HOME} -v ip=${IP_LIST[$count]} -v db=${COMMAND_DB_TYPE} -v app=${COMMAND_APP_TYPE} -v event=${COMMAND_EVENT_TYPE} -v user=${REMOTE_USERNAME} -v timer=$SLEEP_TIME 'BEGIN {
			command0 = sprintf("sleep %s", timer); 
			command1 = sprintf("date +\"%%d-%%b-%Y-%H-%M-%S\"");
			initial_rate = 0;
			total_rate = 0;
		}
		{
			for (i=1; i<=NF; i++) {
				initial_rate = total_rate;
				if(i == 1) {
					split($i, db_array, "=");
					db_name = db_array[2];
				}
				else {
					split($i, command_kv_pairs, ",");
					len_array = length(command_kv_pairs);

					for(j=1; j<=len_array; j++) {
						split(command_kv_pairs[j], command_params, "=");
						command_values_array["VALUE_"command_params[1]] = command_params[2];
					}
					if (command_values_array["VALUE_INCR"] == 0) {
						command_str = sprintf("ssh %s@%s \"%s -c \\\"%s:%s action:%s rate::%s cycle::%s start::%s end::%s app::%s event::%s\\\"\" &", user, ip, dsClient, db, db_name, command_values_array["VALUE_CM"], command_values_array["VALUE_RATE"], command_values_array["VALUE_CYC"], command_values_array["VALUE_START"], command_values_array["VALUE_END"], app, event);
						system(command_str);

						command1 |& getline temp;
						close(command1);

						total_rate = initial_rate + command_values_array["VALUE_RATE"];
						printf("\n%s: Running %s call model at MAX CCR-I rate of %s, Total rate = %s", temp, command_values_array["VALUE_CM"], command_values_array["VALUE_RATE"], total_rate);
						
						continue;
					}
					if (command_values_array["VALUE_INCR"] > 0) {
						counter = command_values_array["VALUE_INCR"];
						while (counter < command_values_array["VALUE_RATE"])
						{
							command_str = sprintf("ssh %s@%s \"%s -c \\\"%s:%s action:%s rate::%s cycle::%s start::%s end::%s app::%s event::%s\\\"\" &", user, ip, dsClient, db, db_name, command_values_array["VALUE_CM"], counter, command_values_array["VALUE_CYC"], command_values_array["VALUE_START"], command_values_array["VALUE_END"], app, event);
							system(command_str);

							command1 |& getline temp;
							close(command1);

							total_rate = initial_rate + counter;
							printf("\n%s: Running %s call model at CCR-I rate of %s, Total rate = %s", temp, command_values_array["VALUE_CM"], counter, total_rate);
							system(command0);

							counter = counter + command_values_array["VALUE_INCR"];
						}
							if (counter >= command_values_array["VALUE_RATE"]){
								command_str = sprintf("ssh %s@%s \"%s -c \\\"%s:%s action:%s rate::%s cycle::%s start::%s end::%s app::%s event::%s\\\"\" &", user, ip, dsClient, db, db_name, command_values_array["VALUE_CM"], command_values_array["VALUE_RATE"], command_values_array["VALUE_CYC"], command_values_array["VALUE_START"], command_values_array["VALUE_END"], app, event);
								system(command_str);
								command1 |& getline temp;
								close(command1);

								total_rate = initial_rate + command_values_array["VALUE_RATE"];
								printf("\n%s: Running %s call model at MAX CCR-I rate of %s, Total rate = %s", temp, command_values_array["VALUE_CM"], command_values_array["VALUE_RATE"], total_rate);
							}
					}
					system(command0);
				}
			}
		}'<<<"${item}" &
	(( count++ ));
	done #&> ./tmp.txt
}

validate_list()
{
	for item in ${COMMAND_ARRAY[*]}; do
		awk -F";" -v command_list_items="${COMMAND_LIST_ITEMS[*]}" 'BEGIN {
			split(command_list_items, command_list_array, " ");
			len_cl_array = length(command_list_array);
		}
		{
			for(i=1; i<=NF; i++) {
				split($i, domain_list_array, ",");
				len_dl_array = length(domain_list_array);
				
				if (i == 1) {
					str = command_list_array[i] "=";
					if (match($i, str) == 0) {
						printf("Please provide positional element \"%s\" in command list provided under the option -l\n", command_list_array[i]);
						exit 60;
					}
					else {
						continue;
					}
				}
				for (j=2; j<=len_cl_array; j++) {
					str = command_list_array[j] "=";
					if (match(domain_list_array[j-1], str) ==  0) {
						printf("Please provide positional element \"%s\" in command list provided under the option -l\n", command_list_array[j]);
						exit 60;
					}
				}
			}
		}'<<<"${item}"

		if [[ $? != 0 ]]; then
			exit $EXIT_STATUS
		fi
	done
}

parse_options()
{
	while getopts ":d:l:t:" options; do
        	case "$options" in
                d)      read -a IP_LIST<<<"${OPTARG}";
			for element in ${IP_LIST[*]}; do
				if [[ ${element} =~ ([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        	                        :
                	        else
                        	        echo -e "You seem to have provided an invalid IP address, please retry with IP address in correct IPv4 format.\n"
					usage;
                                	exit $EXIT_STATUS
	                        fi
			done
                        D_SET=0;
                        ;;
		l)	read -a COMMAND_ARRAY <<<"${OPTARG}";
			if [[ ${#COMMAND_ARRAY[*]} -ne ${#IP_LIST[*]} ]]; then
				echo -e "Looks like the count of parameters does not match between the options -d and -l. Please check.\nExiting..."
				usage;
				exit $EXIT_STATUS
			fi
			validate_list;
			L_SET=0;
			;;
		t)	SLEEP_TIME="${OPTARG}"
			T_SET=0;
			;;
                :)      echo -e "Looks like you didn't pass an argument after -${OPTARG}.\nExisting..."
			usage;
			exit $EXIT_STATUS
			;;
	esac
done
}

parse_options "$@";

if [[ $D_SET == 0 ]] && [[ $L_SET == 0 ]] && [[ $T_SET == 0 ]]; then
	run_call_models;
else
	echo -e "\nPlease ensure you have passed all arguments -d, -l and -t.\n"
	exit $EXIT_STATUS
fi

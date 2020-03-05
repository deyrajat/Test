#! /bin/bash

START_FLAG=false
STOP_FLAG=false
input_mem_usage=0
u_sleep=1
test_run_flag=false
idx=3

user=`whoami`

start_noisy_mem_sim (){

        while true
        do
                memory=$(free | grep Mem)
                memory_total=$(echo $memory | awk '{ print $2 }')
                memory_used=$(echo $memory | awk '{ print $3 }')
                memory_usage_percentage=`echo $(( $memory_used*100/$memory_total ))`

		head_index=`echo $((( memory_total*$input_mem_usage/100000000 )*(1/$idx)))`
                #head_index=`echo $(( memory_total/1000000 ))`
                echo "Head Index: $head_index"

		#cpu_usage=$(top -bn1 | grep load | awk '{printf "%.2f\t\t\n", $(NF-2)}')
		cpu_idle=`top -b -n1 | grep "Cpu(s)" | awk '{print $8}'`
		#cpu_idle=`ssh -o StrictHostKeyChecking=no -i cps.pem cps@10.81.68.17 'bash -s' < /root/cpu_usage.sh -- `
		echo "cpu idle: $cpu_idle"
		full_cpu_usage=100
		#current_cpu_usage=$(echo "($full_cpu_usage-$cpu_idle_float)"| bc -l)
		current_cpu_usage=`awk "BEGIN {print ($full_cpu_usage-$cpu_idle)}"`
		echo "cpu usage: $current_cpu_usage"

                if [[ $memory_usage_percentage -lt $input_mem_usage && $current_cpu_usage < 80 ]]
                then
                        echo "Actual MEMORY usage $memory_usage_percentage% is lesser than provided threshold ($input_mem_usage%)"
                        echo "starting new process"
			`nohup yes | tr '\\n' x | head -c $((1024*1024*1024*10)) | grep n>/dev/null 2>&1 &`
                        ##`nohup /usr/bin/yes | tr '\\n' x | head -c $((1024*1024*1024*$head_index)) | grep n >/dev/null 2>&1 &`
                        processes=`ps -fu $user | grep 'yes' | grep -v 'grep' | awk '{print $2}'`
                        echo "Started processes: "
                        echo $processes
                        test_run_flag=true
                elif [[ ( $current_cpu_usage > 80 || $current_cpu_usage == 80) || ( $memory_usage_percentage -gt $input_mem_usage && $test_run_flag == true ) ]]
                then
                        echo "Actual MEMORY usage $memory_usage_percentage% is greater than provided threshold ($input_mem_usage%)"
                        started_process=`ps -fu $user | grep 'yes' | grep -v 'grep' | awk '{print $2}'`
						started_process=( $started_process )
                        echo "Processes running: "
                        echo "${started_process[@]}"
			#echo "procs: ${#started_process[*]}"

			echo "Exiting from process: ${started_process[-1]} ${started_process[-2]}"

                        `kill -9 ${started_process[0]} ${started_process[1]} > /dev/null 2>&1`

                elif [ $memory_usage_percentage -gt $input_mem_usage -a $test_run_flag == false ]
		then
                        echo "Actual MEMORY usage $memory_usage_percentage% is greater than provided threshold ($input_mem_usage%) but no process has been started from script. Please check."
			break

                fi
                sleep $u_sleep
        done
}


stop_noisy_mem_sim () {

        pids=`ps -fu $user | grep 'yes' | grep -v 'grep' | awk '{print $2}'`
        `kill -9 $pids > /dev/null 2>&1`

        echo "Script is stopped"
}


function usage () {
   echo "Usage: $0 [-e] [-u memory_usage] [-s] [-w]"
   exit 0
}

while getopts ":su:w:eh" opt; do
   case $opt in

   s )  START_FLAG=true
        echo "Starting the script..."
                ;;
   e )  STOP_FLAG=true
        echo "Stoping the script..."
                ;;
   u )  input_mem_usage=$OPTARG
        echo $mem_usage
        ;;
   w )  u_sleep=$OPTARG
       ;;
   w )  u_sleep=$OPTARG
        ;;
   h )  usage ;;
   \?)  usage ;;
    *)  usage ;;
   esac
done

if [ $START_FLAG == true ]
then
start_noisy_mem_sim
elif [ $START_FLAG == true -a $STOP_FLAG == true ]
then
        start_noisy_mem_sim
elif [ $STOP_FLAG == true ]
then
        stop_noisy_mem_sim
fi


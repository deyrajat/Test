#!/bin/bash

START_FLAG=false
STOP_FLAG=false
vCPU_Count=0
start_noisy_cpu_sim () {
    echo "Number of vCPUs: $vCPU_Count"
    if [ -e noisy_cpu_pid ]
    then
       `rm -rf noisy_cpu_pid`
    fi

    index=0
    declare -a PIDS
    while [ $index -lt ${vCPU_Count} ]
    do
        echo "Starting process for vCPU $index"
        yes > /dev/null &
        PIDS[$index]=`echo $!`
        echo "PID of started process is ${PIDS[$index]}"
        pid=`ps -ef | grep ${PIDS[$index]} | grep -v 'grep' |  awk '{print $2}'`
        #echo "pid is $pid"
        if [ $pid -eq ${PIDS[$index]} ]; then
            echo "Process with pid ${PIDS[$index]}, is triggered successfully"
            echo $pid >> noisy_cpu_pid
        else
            echo "Process with pid ${PIDS[$index]}, is not triggered successfully"
        fi
        #increment the index
        index=`expr $index + 1`
    done
}
stop_noisy_cpu_sim () {
    if [ -e noisy_cpu_pid ]
    then
        while IFS= read -r line
        do
            `kill -9 $line`
        done < noisy_cpu_pid
        `rm noisy_cpu_pid`
        while true
        do
            pid_count=`ps -aef | grep 'yes' | grep -v 'grep' | wc -l`
            echo "Current PID count for yes process is $pid_count"
            if [ $pid_count -eq 0 ]
            then
                break
            fi
            echo "`ps -aef | grep 'yes' | grep -v 'grep' | awk '{print $2}'`" >> noisy_cpu_pid
            while IFS= read -r line
            do
                echo "Killing PID $line"
                `kill -9 $line`
            done < noisy_cpu_pid
            `rm noisy_cpu_pid`
        done
		echo "Killing $$"
		`kill -9 $$`
        echo "Script is stopped"
    else
        echo "Script is already stopped"
    fi
}

function usage () {
   echo "Usage: $0 [-s] [-c vCPU_Count] [-e]"
   exit 0
}

while getopts ":sc:eh" opt; do
   case $opt in

   s )  START_FLAG=true
        echo "Starting the script..."
                ;;
   e )  STOP_FLAG=true
        echo "Stoping the script..."
                ;;
   c )  vCPU_Count=$OPTARG
            echo "vCPU_Count: $OPTARG"
            ;;
   h )  usage ;;
   \?)  usage ;;
    *)  usage ;;
   esac
done

vCPU_Count_On_VM=`nproc`
if [ $START_FLAG == true ]
then
if [ ${vCPU_Count} -le 0 -o ${vCPU_Count} -gt ${vCPU_Count_On_VM} ]
then
    echo -e "vCPU count cannot be blank, zero, alphanumeric value, or greater then the no of vCPUs present on VM.\\nThe no of vCPUs present on target VM is ${vCPU_Count_On_VM}. Exiting..."
    usage
    exit 0
fi
start_noisy_cpu_sim
elif [ $START_FLAG == true -a $STOP_FLAG == true ]
then
        start_noisy_cpu_sim
elif [ $STOP_FLAG == true ]
then
        stop_noisy_cpu_sim
fi

#!/bin/bash

START_FLAG=false
STOP_FLAG=false

start_capture () {
    if [ -e noisy_cpu_pid ]
    then
       `rm -rf noisy_cpu_pid`
    fi

    echo "Starting packet capture..."
    sudo tcpdump -x -X -iany -s0 port 3868 -v -w capture.pcap &
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
}

stop_capture () {
    if [ -e noisy_cpu_pid ]
    then
        while IFS= read -r line
        do
            `kill -9 $line`
        done < noisy_cpu_pid
        `rm noisy_cpu_pid`
        echo "Script is stopped"
    else
        echo "Script is already stopped"
    fi
}

function usage () {
   echo "Usage: $0 [-s] [-e]"
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
   h )  usage ;;
   \?)  usage ;;
    *)  usage ;;
   esac
done

vCPU_Count_On_VM=`nproc`
if [ $START_FLAG == true ]
then
    start_capture
elif [ $START_FLAG == true -a $STOP_FLAG == true ]
then
    start_capture
elif [ $STOP_FLAG == true ]
then
    stop_capture
fi

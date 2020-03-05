#!/bin/bash

START_FLAG=false
STOP_FLAG=false

start_noisy_io_sim () {

     if [ -e noisy_io_pid ]
     then
         `rm -rf noisy_io_pid`
     fi
index=0

echo "`ps -aef | grep 'bash -s' | grep -v 'grep' | awk '{print $2}'`" >> noisy_io_pid

while true
     #echo "Index Value : $index"
#while [ $index -lt 2 ]
     do
     	if [ "$Files_Count" -gt 1 ]; then
			for i in $(seq 1 $Files_Count)
			do
				echo "Starting noisy io command for more than 1 file..."
				#echo "FileName Value : largefile_${index}_$i"
				`dd if=/dev/zero of=/var/tmp/largefile_${index}_$i bs=1024 count=2048000 && yes y|gzip /var/tmp/largefile_${index}_$i && yes y|gunzip /var/tmp/largefile_${index}_$i.gz && yes y|rm -f /var/tmp/largefile_${index}_$i;` &
				pids+=" $!"
			done
			echo $pids | tr " " "\n" >> noisy_io_pid
			#echo "######### PIDS : $pids"
			#wait $pids || { echo "there were errors" >&2; exit 1; }
			wait $pids
		else
			echo "Starting noisy io command..."
			`dd if=/dev/zero of=/var/tmp/largefile_${index} bs=1024 count=10240000 && sleep 5 && yes y|gzip /var/tmp/largefile_${index} && sleep 5 && yes y|gunzip /var/tmp/largefile_${index}.gz && yes y|rm -f /var/tmp/largefile_${index};` &
			sleep 30
		fi
	index=`expr $index + 1`
     #echo `ps -aef | grep 'dd if' | grep -v 'grep' | tail -1 | awk '{print $2}'` >> noisy_io_pid
     #echo "Sleeping 1 Sec"
done
     #echo `ps -aef | grep 'dd if' | grep -v 'grep' | awk '{print $2}'` >> noisy_io_pid
}

stop_noisy_io_sim () {
    #Killing main script
    #if [ -e noisy_io_bash_pid ]
    #then
    #    while IFS= read -r line
    #    do
    #       echo "Killing PID $line"
    #       `kill -9 $line`
    #   done < noisy_io_pid
    #   `rm noisy_io_pid`
    #    echo "Script is stopped"
    #else
    #   echo "Script is already stopped"
    #fi
    #sleep 300
    echo "`ps -aef | grep 'bash -s' | grep -v 'grep' | awk '{print $2}' | grep -v $$`" >> noisy_io_pid
    #echo `ps -aef | grep 'dd if' | grep -v 'grep' | awk '{print $2}'` >> noisy_io_pid
    if [ -e noisy_io_pid ]
    then
		script_name=`basename "$0"`
		#echo "kill -9 `ps ux | grep $script_name | awk -F\  -v pid=$$ 'pid != $2 {print $2}'`"
		kill -9 `ps ux | grep $script_name | awk -F\  -v pid=$$ 'pid != $2 {print $2}'`
        while IFS= read -r line
        do
           echo "Killing PID $line"
           `kill -9 $line`
        done < noisy_io_pid
        `rm -f noisy_io_pid`
        while true
        do
            pid_count=`ps -aef | grep 'dd if' | grep -v 'grep' | wc -l`
            echo "Current PID count for dd if process is $pid_count"
            if [ $pid_count -eq 0 ]
            then
                break
            fi
            echo "`ps -aef | grep 'dd if' | grep -v 'grep' | awk '{print $2}'`" >> noisy_io_pid
            while IFS= read -r line
            do
                echo "Killing PID $line"
                `kill -9 $line`
            done < noisy_io_pid
            `rm -f noisy_io_pid`
            sleep 2
        done
		`yes y|rm -f /var/tmp/largefile_*`	
		echo "Killing $$"
		`kill -9 $$`
        echo "Script is stopped"
    else
    	`yes y|rm -f /var/tmp/largefile_*`
        echo "Script is already stopped"
    fi
}

function usage () {
    echo "Usage: $0 [-s] [-e] [-f Files_Count]"
    exit 0
}
Files_Count=1

while getopts ":sf:eh" opt; do
     case $opt in
         s )  START_FLAG=true
              echo "Starting the script..."
              ;;
         e )  STOP_FLAG=true
              echo "Stoping the script..."
              ;;
         f )  Files_Count=$OPTARG
              echo "Files Count: $OPTARG"
              ;;
         h )  usage ;;
         \?)  usage ;;
          *)  usage ;;
     esac
done

if [ $START_FLAG == true ]
then
    start_noisy_io_sim
elif [ $START_FLAG == true -a $STOP_FLAG == true ]
then
    start_noisy_io_sim
elif [ $STOP_FLAG == true ]
then
    stop_noisy_io_sim
fi

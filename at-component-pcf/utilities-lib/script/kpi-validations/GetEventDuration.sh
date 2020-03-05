#!/bin/bash
if [ "$1" -eq 0 ]; then
    echo "Start time is provided"
    #exit;
fi
if [ "$2" -eq 0 ]; then
    echo "End time is not provided"
    #exit;
fi
duration=$(( ($2) - $1 ))
echo $duration

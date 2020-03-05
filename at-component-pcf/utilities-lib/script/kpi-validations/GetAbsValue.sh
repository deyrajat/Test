#!/bin/bash

if [ -z $1 ]; then
    echo "Enter the total number for the specified period :"
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the total time in seconds :"
    exit;
fi

echo "scale=2; $2 * $1" | bc

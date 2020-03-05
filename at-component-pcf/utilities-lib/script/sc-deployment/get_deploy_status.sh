#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the API URL"
    exit;
fi
if [ -z $2 ]; then
    echo "Enter the API username"
    exit;
fi
if [ -z $3 ]; then
    echo "Enter the API password"
    exit;
fi
OPS_API=$1
USER=$2
PASSWORD=$3
echo "API Status:"
curl --noproxy "*" -X GET -s -k -u $USER:$PASSWORD ${OPS_API}/operational/system/status -H "Accept: application/vnd.yang.data+json" -H "Content-Type: application/vnd.yang.data+json"
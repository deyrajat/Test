#!/bin/bash -p

KPI_NAME=${1}

FILE_NAME="/tmp/execStatus.txt"

#Check if file exists. If not, then give error and exit
if [ ! -f ${FILE_NAME} ]; then
    echo "${FILE_NAME} does not exist"
    exit 1
fi

comment=`\grep "${KPI_NAME}" "${FILE_NAME}" | awk '{print $2}'`

#Check if comment for the KPI is present on the file. If not print error and exit
if [[ -z "${comment// }" ]];then
    echo "${KPI_NAME} not present in file."
    exit 1
fi

failCount=`echo ${comment} | \grep -oE 'Fail:[0-9]*' | cut -d ":" -f 2`
neCount=`echo ${comment} | \grep -oE 'NE:[0-9]*' | cut -d ":" -f 2`
totalCount=`echo ${comment} | \grep -oE 'Total:[0-9]*' | cut -d ":" -f 2`

#echo "Current Fail count is ${failCount}"

#Check if failcount is > 0 then mark the KPI as failed
#if [ ${failCount} -gt 0 -o ${neCount} -gt 0 ]; then
if [ ${failCount} -gt 0 ]; then
    echo "Fail ${comment}"
elif [ ${neCount} -eq ${totalCount} ]; then
    echo "NE ${comment}"
else 
    echo "Pass ${comment}"
fi

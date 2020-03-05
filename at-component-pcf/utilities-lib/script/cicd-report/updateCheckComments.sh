#!/bin/bash -p

KPI_NAME=${1}
STATUS=${2}
FILE_NAME="/tmp/execStatus.txt"

#Create file if it does not exist.
if [ ! -f ${FILE_NAME} ]; then
    touch ${FILE_NAME}
fi

comment=`\grep "${KPI_NAME}" "${FILE_NAME}" | awk '{print $2}'`

#Update KPI status in file
if [[ ! -z "${comment// }" ]];then
    echo "Comment test for ${KPI_NAME} is ${comment}"
    neCount=`echo ${comment} | \grep -oE 'NE:[0-9]*' | cut -d ":" -f 2`
    echo "Current NE count is ${neCount}"
    passCount=`echo ${comment} | \grep -oE 'Pass:[0-9]*' | cut -d ":" -f 2`
    echo "Current Pass count is ${passCount}"
    failCount=`echo ${comment} | \grep -oE 'Fail:[0-9]*' | cut -d ":" -f 2`
    echo "Current Fail count is ${failCount}"
    totalCount=`echo ${comment} | \grep -oE 'Total:[0-9]*' | cut -d ":" -f 2`
    echo "Current Total count is ${totalCount}"
    case ${STATUS} in
        -1)
            echo "Status is NE"
            echo "Updating ${FILE_NAME}"
            neCount=`expr $neCount + 1`
            ;;
        0)
            echo "Status is Pass"
            echo "Updating ${FILE_NAME}"
            passCount=`expr $passCount + 1`
            ;;
        1)
            echo "Status is Fail"
            echo "Updating ${FILE_NAME}"
            failCount=`expr $failCount + 1`
            ;;
        *)
            echo "Invalid option."
            exit 1
            ;;
    esac
    totalCount=`expr $totalCount + 1`
    echo "${KPI_NAME} NE:${neCount},Fail:${failCount},Pass:${passCount},Total:${totalCount}"
    newComment="NE:${neCount},Fail:${failCount},Pass:${passCount},Total:${totalCount}"
    echo "sed -i 's/.*${KPI_NAME}.*/${KPI_NAME} ${newComment}/' ${FILE_NAME}"
    sed -i "s/.*${KPI_NAME}.*/${KPI_NAME} ${newComment}/" ${FILE_NAME}
    echo "Updated ${FILE_NAME} with comment - ${newComment}"
else
    echo "${KPI_NAME} NE:0,Fail:0,Pass:0,Total:0" >>/tmp/execStatus.txt
fi

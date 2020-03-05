#!/bin/bash
if [ -z $1 ]; then
    echo "Enter the namespace values"
    exit
fi
if [ -z $2 ]; then
    echo "Enter the cnee URL"
    exit
fi
if [ -z $3 ]; then
    echo "Enter the pcf URL"
    exit
fi
if [ -z $4 ]; then
    echo "Enter the target build type ( master / release )"
    exit
fi
if [ -z $5 ]; then
    echo "Enter the cnee yaml file path"
    exit
fi
if [ -z $6 ]; then
    echo "Enter the pcf yaml file path"
    exit
fi
if [ -z $7 ]; then
    echo "Enter the Kubernetes Master IP"
    exit
fi

if [ -z $8 ]; then
    checkFor="all"
else
    checkFor=$8
fi

namespace=$1
cneeurl=$2
pcfurl=$3
buildtype=$4
cneepath=$5
pcfpath=$6
masterIP=$7
upgradeSystem=0
cneeRelStr="logging-visualization cnat-monitoring cnee-documentation cnat-foundation zing cnee-ops-center"
pcfRelStr="pcf-ops-center cnat-cps-infrastructure cnat-datastore-mongo-db cps-diameter-ep cps-ldap-ep mobile-cnat-etcd network-query pcf-services"
releaseStr=$(helm list -d --namespace $namespace | grep -v NAME | awk '{print $1}')
releaselist=($releaseStr)

isPcrfRelease=`helm repo list | grep --color=never pcf-ops-center | grep --color=never builds | wc -l`
if [ $isPcrfRelease -eq 1 ]; then
    if [ "$buildtype" = "master" ] ; then
        upgradeSystem=1
    fi
elif [ $isPcrfRelease -eq 0 ]; then
    if [ "$buildtype" = "release" ]; then
        upgradeSystem=1
    fi
else
    upgradeSystem=0
fi
if [ $upgradeSystem -eq 0 ]; then
    for releas in ${releaselist[*]}
    do
        #echo $releas
        helmReleaseDate=`helm list | grep --color=never $releas | awk '{print $9}' | rev | cut -d'-' -f 2 | rev `
        #echo "helmReleaseDate = $helmReleaseDate"
        helmReleaseDate=`echo $helmReleaseDate | awk -v FS="" '{print $3$4"/"$5$6"/"$1$2" "$7$8":"$9$10":"$11$12}'`
        #echo "helmReleaseDate = $helmReleaseDate"
        helmReleaseDateSec=`date --date="$helmReleaseDate" +%s`
        #echo "helmReleaseDateSec = $helmReleaseDateSec"
        if [[ "$releas" != *"ops"* ]]; then
            releas=`echo $releas | cut -d'-' -f 2-`
        fi
        if [[ "$releas" == *"diameter"* ]]; then
            releas=`echo $releas | rev | cut -d'-' -f 2- | rev`
        fi
        #echo $releas

        rm -rf /tmp/listMaster
        touch /tmp/listMaster
        #echo "checkFor : $checkFor"
        if [[ ( "$cneeRelStr" == *"$releas"* ) && ( "$checkFor" != "pcf" ) ]]; then
            `curl -s $cneeurl -o /tmp/listMaster`
            uploadDate=`cat /tmp/listMaster | grep $releas | awk 'END {print $3}'`
            #echo $uploadDate
            uploadDateSec=`date --date="$uploadDate" +%s`
            #echo $uploadDateSec
            if [ $uploadDateSec -gt $helmReleaseDateSec ]; then
                upgradeSystem=1
            fi
        fi
        if [[ ( "$pcfRelStr" == *"$releas"* ) && ( "$checkFor" != "cnee" ) ]]; then
            `curl -s $pcfurl -o /tmp/listMaster`
            uploadDate=`cat /tmp/listMaster | grep $releas | awk 'END {print $3}'`
            #echo $uploadDate
            uploadDateSec=`date --date="$uploadDate" +%s`
            #echo $uploadDateSec
            if [ $uploadDateSec -gt $helmReleaseDateSec ]; then
                upgradeSystem=1
            fi
        fi
        #echo "upgradeSystem : $upgradeSystem"
        #echo "===================================================="
    done
fi
#echo "change the yaml files"
cneeglobalFile=$(echo $cneepath\global.yaml)
cneeFile=$(echo $cneepath\cnee.yaml)
pcfglobalFile=`echo $pcfpath\global.yaml`
pcfFile=`echo $pcfpath\pcf.yaml`

sed -i -e 's/ingressHostname: .*.nip.io/ingressHostname: '${masterIP}'.nip.io/g' $cneeglobalFile
sed -i -e 's,url: .*,url: '${cneeurl}',g' $cneeFile
sed -i -e 's/ingressHostname: .*.nip.io/ingressHostname: '${masterIP}'.nip.io/g' $pcfglobalFile
sed -i -e 's,url: .*,url: '${pcfurl}',g' $pcfFile

if [ "$buildtype" = "master" ]; then
    sed -i -e 's/dockerhub.cisco.com\/.*/dockerhub.cisco.com\/mobile-cnat-dev-docker/g' $cneeglobalFile
    sed -i -e 's/dockerhub.cisco.com\/.*/dockerhub.cisco.com\/mobile-cnat-dev-docker/g' $pcfglobalFile
fi
if [ "$buildtype" = "release" ]; then
    sed -i -e 's/dockerhub.cisco.com\/.*/dockerhub.cisco.com\/mobile-cnat-docker/g' $cneeglobalFile
    sed -i -e 's/dockerhub.cisco.com\/.*/dockerhub.cisco.com\/mobile-cnat-docker/g' $pcfglobalFile
fi

if [ $upgradeSystem -eq 1 ]; then
   echo "Upgrade_is_needed"
else
   echo "Latest_build_is_installed"
fi

dos2unix $cneeglobalFile
dos2unix $cneeFile
dos2unix $pcfglobalFile
dos2unix $pcfFile
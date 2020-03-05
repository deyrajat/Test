#!/bin/bash -p
if [ -z $1 ]; then
    echo "Please provide the master IP"
    exit
fi

MASTER_IP=${1}

instVersion=`ssh $MASTER_IP "helm list | grep --color=never cnee-ops-center"`
instVersion=`echo $instVersion | awk '{ print $9}'`
if [ -z $instVersion ] ; then
   echo "instVersion is empty "
   instVersion="Not_Available"
fi
echo $instVersion

pcrfVersion=`ssh $MASTER_IP "helm list | grep --color=never pcrf-ops-center"`
pcrfVersion=`echo $pcrfVersion | awk '{ print $9}'`
if [ -z $pcrfVersion ] ; then
   echo "pcrfVersion is empty "
   pcrfVersion="Not_Available"
fi
echo $pcrfVersion

diaEpVersion=`ssh $MASTER_IP "helm list | grep --color=never diameter"`
diaEpVersion=`echo $diaEpVersion | awk '{ print $9}'`
if [ -z $diaEpVersion ] ; then
   echo " diaEpVersion is empty "
   diaEpVersion="Not_Available"
fi
echo $diaEpVersion

pcrfEngVersion=`ssh $MASTER_IP "helm list | grep --color=never pcrf-engine-app-engine"`
pcrfEngVersion=`echo $pcrfEngVersion | awk '{ print $9}'`
if [ -z $pcrfEngVersion ] ; then
   echo " pcrfEngVersion is empty "
   pcrfEngVersion="Not_Available"
fi
echo $pcrfEngVersion

echo "Change values now"

`sed -i 's/Installer_Version/'${instVersion}'/g' /root/about.sh`
`sed -i 's/PCRF_Version/'${pcrfVersion}'/g' /root/about.sh`
`sed -i 's/diameter_ep_iso/'${diaEpVersion}'/g' /root/about.sh`
`sed -i 's/pcrf_engine_iso/'${pcrfEngVersion}'/g' /root/about.sh`

`chmod 755 /root/about.sh`
`scp /root/about.sh root@$MASTER_IP:/root/`
`ssh $MASTER_IP "chmod 755 /root/about.sh"`
#!/bin/bash -p

instVersion=`helm list --debug | grep --color=never cee-ops-center`
instVersion=`echo $instVersion | awk '{ print $10}'`
if [ -z $instVersion ] ; then
   echo "instVersion is empty "
   instVersion="Not_Available"
fi
echo $instVersion

pcfVersion=`helm list --debug | grep --color=never pcf-ops-center`
pcfVersion=`echo $pcfVersion | awk '{ print $10}'`
if [ -z $pcfVersion ] ; then
   echo "pcfVersion is empty "
   pcfVersion="Not_Available"
fi
echo $pcfVersion

diaEpVersion=`helm list | grep --color=never diameter`
diaEpVersion=`echo $diaEpVersion | awk '{ print $9}'`
if [ -z $diaEpVersion ] ; then
   echo " diaEpVersion is empty "
   diaEpVersion="Not_Available"
fi
echo $diaEpVersion

pcfEngVersion=`helm list | grep --color=never pcf-engine-app`
pcfEngVersion=`echo $pcfEngVersion | awk '{ print $9}'`
if [ -z $pcfEngVersion ] ; then
   echo " pcfEngVersion is empty "
   pcfEngVersion="Not_Available"
fi
echo $pcfEngVersion

echo "Change values now"

`sed -i 's/Installer_Version/'${instVersion}'/g' about.sh`
`sed -i 's/PCRF_Version/'${pcfVersion}'/g' about.sh`
`sed -i 's/diameter_ep_iso/'${diaEpVersion}'/g' about.sh`
`sed -i 's/pcf_engine_iso/'${pcfEngVersion}'/g' about.sh`

`chmod 755 about.sh`
sh about.sh
#!/bin/bash
rm -rf /root/outputkpi
mkdir /root/outputkpi
hostsAll=`hosts-all.sh`
for hosts in $hostsAll
do
	if [[ "$" =~ "portal" ]] || [[ "$hosts" =~ "installer" ]] ; then
                echo ""
        else 
		ssh $hosts free -k | grep -v "+" >/root/outputkpi/outputkpi_$hosts
	fi 
done

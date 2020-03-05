#/!bin/bash
bulkStatPath="/var/broadhop/stats/"
for NH in `hosts-all.sh` 
do 
	if ( [ "$NH" != "installer" ] ) && ( [ "$NH" != "portal" ] )
	then
		#echo $NH
                newHostName=`ssh $NH hostname | tr -d '\n'`
		totalFree=`grep "df.root.df_complex.free" /var/broadhop/stats/*.csv | grep $newHostName | awk -F"," '{print $4}' | awk -F"E" '{ a = 10 ** $2 ; integer = $1 * a ; sum += integer } END { print sum }'`
		totalUsed=`grep "df_complex.used" /var/broadhop/stats/*.csv | grep $newHostName | awk -F"," '{print $4}' | awk -F"E" '{ a = 10 ** $2 ; integer = $1 * a ; sum += integer } END { print sum }'`
		disk=$(($totalUsed+$totalFree))
		diskUsedPer=$((100 * $totalUsed / $disk))
		#echo "$diskUsedPer"
		if [ $diskUsedPer -gt 80 ]
		then
			echo "$NH: Disk usage is greater than 80%"
		else
			echo "$NH: Disk usage is less than 80%"
		fi
	fi
	if [ $( echo $NH | grep sessionmgr ) ]
	then
                newHostName=`ssh $NH hostname | tr -d '\n'`
		sessionStoreFree=`grep "var-data-sessions.1.*.free" /var/broadhop/stats/*.csv | grep $newHostName | awk -F"," '{print $4}' | awk -F"E" '{ a = 10 ** $2 ; integer = $1 * a ; sum += integer } END { print sum }'`
		sessionStoreUsed=`grep "var-data-sessions.1.*.used" /var/broadhop/stats/*.csv | grep $newHostName | awk -F"," '{print $4}' | awk -F"E" '{ a = 10 ** $2 ; integer = $1 * a ; sum += integer } END { print sum }'`
		sessionDisk=$(($sessionStoreFree+$sessionStoreUsed))
                sessionDiskUsedPer=$((100 * $sessionStoreUsed / $sessionDisk))
                #echo "$diskUsedPer"
                if [ $sessionDiskUsedPer -gt 80 ]
                then
                        echo "$NH: Session Store utilization is greater than 80%"
                else
                        echo "$NH: Session Store utilization is less than 80%"
                fi
	fi
done

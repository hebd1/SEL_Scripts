#!/bin/bash

#This script queries ember event logs and updates sel time of each node. If the logs are full, logs are saved and then cleared. If a node is unresponsive, "Unresponsive IPMI" is written to the log file. For all nodes, events that frequently occur/clog up the event log are also saved. 
 
NOW=$(date +"%Y-%m-%d") 

#query ember nodes
printf "\n----------------ember----------------\n" >> ~/SEL_Archive/SEL_Clogs/${NOW}.clog
for i in `scontrol show nodes | grep ^Node | awk '{print $1}' | cut -d "=" -f2`
do
	echo $i ---------------
	LOG=$(ipmitool -I lanplus -H $i-ipmi.ember.arches -U root -P sel elist)
	# save unresponsive ipmi 
	if [ $? != 0 ]
        then
                echo "IPMI Unresponsive" > ~/SEL_Archive/ember/$i/${NOW}.log
		continue 
        fi
	
	# update sel time 	
	ipmitool -I lanplus -H $i-ipmi.ember.arches -U root -P sel time set now 
	
	#parse out events that clog up the log
	CLOG=$(echo "$LOG" | cut -d "|" -f4 | sort | uniq -c | sort -n | tail -1)
        if [[ $(echo "$CLOG" | awk '{ print $1 }') -gt 10 ]]
        then
	         echo $i " | " $CLOG >> ~/SEL_Archive/SEL_Clogs/${NOW}.clog
        fi

	#clear the event log if it's full	
	if [[ "$LOG" =~ "Log full" ]]
	then
        	echo "$LOG" > ~/SEL_Archive/ember/$i/${NOW}.log
                echo $i " | Log Full | " $CLOG
                ipmitool -I lanplus -H $i-ipmi.ember.arches -U root -P  sel clear
	else	
		continue
	fi
done


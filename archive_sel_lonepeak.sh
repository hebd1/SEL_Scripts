#!/bin/bash

#This script queries lonepeak event logs of a single node and updates sel time of each node. If the logs are full, logs are saved and then cleared. Events that frequently occur/clog up the event log are also saved. 
 
NOW=$(date +"%Y-%m-%d") 

#query node logs
LOG=$(ipmitool sel elist)

# save unresponsive ipmi 
if [ $? != 0 ]
then
        echo "IPMI Unresponsive" > /uufs/chpc.utah.edu/common/home/u0871009/SEL_Archive/lonepeak/$HOSTNAME/${NOW}.log
	exit	
fi


# update sel time 	
#ipmitool sel time set now

#parse out events that clog up the log
CLOG=$(echo "$LOG" | cut -d "|" -f4 | sort | uniq -c | sort -n | tail -1)
if [[ $(echo "$CLOG" | awk '{ print $1 }') -gt 10 ]]
then
         echo $HOSTNAME " | " $CLOG >> /uufs/chpc.utah.edu/common/home/u0871009/SEL_Archive/SEL_Clogs/${NOW}.clog
fi

#clear the event log if it's full	
if [[ "$LOG" =~ "Log full" ]]
then
	echo "$LOG" > /uufs/chpc.utah.edu/common/home/u0871009/SEL_Archive/lonepeak/$HOSTNAME/${NOW}.log
        echo $HOSTNAME " | Log Full | " $CLOG
	ipmitool sel clear
else	
	exit	
fi



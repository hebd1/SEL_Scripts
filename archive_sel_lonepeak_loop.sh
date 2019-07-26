#!/bin/bash

#This script queries lonepeak event logs and updates sel time of each node. If the logs are full, logs are saved and then cleared. For all nodes, events that frequently occur/clog up the event log are also saved. 

NOW=$(date +"%Y-%m-%d")

printf "\n----------------lonepeak----------------\n" >> /uufs/chpc.utah.edu/common/home/u0871009/SEL_Archive/SEL_Clogs/${NOW}.clog
for i in `scontrol show nodes | grep ^Node | awk '{print $1}' | cut -d "=" -f2`
do
        echo $i
	#ssh to each node in the cluster and skip if it hangs
        ssh -no ConnectTimeout=20 $i /uufs/chpc.utah.edu/common/home/u0871009/Scripts/archive_sel_lonepeak.sh
done



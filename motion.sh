#!/bin/bash
MAC_ADDRESSES=("00:ab:bc:de:fg:hi" "12:34:56:78:90:ab"); #Add device MAC addresses
DEVICE_PRESENT=0; #Boolean variable for device presence
MOTIONEYE=0; #Boolean variable for motion on or off
LOGFILE="/var/log/detection.log"; #logfile location
DATE=`date "+%Y-%m-%d %H:%M:%S"`; #get current date

for DEVICE in "${MAC_ADDRESSES[@]}"
do
	OUTPUT=$(sudo arp-scan -l | grep $DEVICE)
	if [ -n "$OUTPUT" ];
	then
		#echo "$DATE: $DEVICE is detected!" >> $LOGFILE #Write to log file
		DEVICE_PRESENT=1;
#	else
		#echo "$DATE: $DEVICE is not detected!" >> $LOGFILE #Write to log file
	fi
done
if curl -sSf "http://192.168.1.1:7999/1/detection/status" | grep -q "ACTIVE" #Connect to motion and check if motion detection is on
then
	#echo "$DATE: Motion is on!" >> $LOGFILE #Write to log file
	MOTIONEYE=1; #Motion is on so change boolean to on
#else
	#echo "$DATE: Motion is off!" >> $LOGFILE #Write to log file #Write to log file
fi

if [[ $DEVICE_PRESENT -eq 1 ]] && [[ $MOTIONEYE -eq 1 ]]; #If you're home and motion detection is on
then
	echo "$DATE: You are at home & motioneye is active. Stopping motioneye." >> $LOGFILE #Write to log file 
	wget -q -O- "http://192.168.1.1:7999/1/detection/pause" >/dev/null #Connect to URL to turn off motion detection

#elif [[ $DEVICE_PRESENT -eq 1 ]] && [[ $MOTIONEYE -eq 0 ]]; #If you're home and motion detection  is off
#then
	#echo "$DATE: You are at home & motioneye is already inactive. Nothing to do..." >> $LOGFILE #Write to log file
#elif [[ $DEVICE_PRESENT -eq 0 ]] && [[ $MOTIONEYE -eq 1 ]]; #If you're not home and motion detection is on
#then
	#echo "$DATE: You are away & motioneye is already active. Nothing to do..." >> $LOGFILE #Write to log file
elif [[ $DEVICE_PRESENT -eq 0 ]] && [[ $MOTIONEYE -eq 0 ]]; #If you're not home and motion detection is off
then
	echo "$DATE: You are away from home & motioneye is inactive. Starting motioneye." >> $LOGFILE #Write to log file
	wget -q -O- "http://192.168.1.1:7999/1/detection/start" >/dev/null #Connect to URL to turn motion detection on
fi

#!/bin/bash
# A Simple Script to help visualize a WiFi AP for Fox-Hunting.

# @Bugg
# 07/21/18

#Parameters, change these:
interface="wlan0"
wifi_name="mywifi"

while true;
do

num=$(iwlist $interface scan | grep -B 2 $wifi_name | grep "Signal" | cut -d = -f 3 | cut -d " " -f 1 | tail -c 3)

if [ ! -z $num ]
then

bar=$(head -c $num < /dev/zero | tr '\0' '\167')

echo $num"dBm $bar"

else

echo "Signal Lost..."
sleep 1

fi

done

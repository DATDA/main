#!/bin/bash
# A Simple Script to help visualize a WiFi AP for Fox-Hunting.

# @Bugg
# 07/21/18

while true;
do

num=$(iwlist wlan0 scan | grep -B 2 "mywifi" | grep "Signal" | cut -d = -f 3)

len=$(echo $num | cut -d " " -f 1 | tail -c 3)

bar=$(head -c $len < /dev/zero | tr '\0' '\167')

echo "$num$bar"

done

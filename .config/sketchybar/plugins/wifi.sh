#!/bin/sh

SSID=$(system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; print substr($0, 13, (length($0) - 13)); exit }')

if [ "$SSID" = "" ]; then
	sketchybar --set $NAME icon="􀙈" label="Err"
else
	DBM=$(system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; getline; getline; getline; getline; getline; getline; split($0, a, ": "); split(a[2], b, " /"); print b[1]; exit }')
	sketchybar --set $NAME icon="􀙇" label="$DBM"
fi

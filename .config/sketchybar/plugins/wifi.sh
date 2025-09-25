#!/bin/sh

if [ "$SSID" = "" ]; then
	sketchybar --set $NAME icon="􀙈" label="Disconnected"
else
	sketchybar --set $NAME icon="􀙇" label=""
fi

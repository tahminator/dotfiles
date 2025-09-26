#!/bin/bash

sketchybar --add item wifi right \
	--set wifi \
	icon=" 􀙥" \
	label="" \
	script="$PLUGIN_DIR/wifi.sh" \
	--subscribe wifi wifi_change

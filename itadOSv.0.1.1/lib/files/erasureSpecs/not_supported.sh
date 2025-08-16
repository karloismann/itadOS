#!/bin/bash

# Options: one, two
not_supported_clear() {

    local disk="$1"
    local type="$2"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	local specMessage="Clear"
	local methodMessage
    local toolMessage

    # Add an arrow to method message if other erasure attempts made prior
	if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
		methodMessage=" >"
	fi
	
	# Erasure
	if [[ "$type" == "one" ]]; then
		overwriteZero "$disk"
		methodMessage="${methodMessage} Overwrite [Zero]"
		
	elif [[ "$type" == "two" ]]; then 
		overwriteRandomZero "$disk"
		methodMessage="${methodMessage} Overwrite [Random > Zero]"
	fi

    # Log tools used
	toolMessage="$(shred --version | awk 'NR==1{print}') "
	
	# Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
	echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
	echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"
    
}
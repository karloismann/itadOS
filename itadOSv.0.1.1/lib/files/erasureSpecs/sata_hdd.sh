#!/bin/bash

#Add more from Nist 800-88 P.40


sata_hdd_purge_secure_erase() {
	
	local disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	local specMessage="Purge"
	local methodMessage
	local toolMessage
	local secure_erase_exit_code
	
	# Add an arrow to method message if other erasure attempts made prior
	if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
		methodMessage=" >"
	fi
	
	# Erasure
	secureErase "$disk"
	secure_erase_exit_code=$?
	
	if [[ "$secure_erase_exit_code" == 0 ]]; then
		methodMessage="${methodMessage} Secure Erase"
		
	else
		methodMessage="${methodMessage} Secure Erase [FAILED]"
	fi
	
	# Log tools used
	toolMessage="${toolMessage} $(hdparm -V)"
	
	# Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
	echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
	echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

	# Return codes
	if [[ "$secure_erase_exit_code" == 0 ]]; then
		return 0
	else
		return 1
	fi

}

# Options: one, two
sata_hdd_clear_overwrite() {
	
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
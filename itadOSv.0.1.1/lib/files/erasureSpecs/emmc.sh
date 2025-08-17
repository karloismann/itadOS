#!/bin/bash

# Sanitize > Secure Erase > overwrite
# @Param $1: disk to process
# @Param $2: Overwrite type [zero] or [random > zero]
# option: one = zero pass
# option: two = random > zero pass
emmc_clear() {

    local disk="$1"
    local type="$2"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	local specMessage="Clear"
	local methodMessage
    local OWTool
	local mmcSanitize_exit_code
    local mmcSecure_erase_exit_code

    # Get mmc-utils tool information
    local tool=$(apt-cache show mmc-utils | awk '/Package:/ {print $2}')
	local version=$(apt-cache show mmc-utils | awk '/Version:/ {print $2}')
    local mmcTool="${tool} ${version}"
    local toolMessage="$mmcTool"

    # Add an arrow to method message if other erasure attempts made prior
	if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
		methodMessage=" >"
	fi

    # Erasure commands
    mmcSanitize "$disk"
    mmcSanitize_exit_code=$?

	mmcSecureErase "$disk"
    mmcSecure_erase_exit_code=$?

    # Construct Method message for report
    if [[ "$mmcSanitize_exit_code" == "0" ]]; then
        methodMessage="$methodMessage Sanitize"
    else
        methodMessage="$methodMessage Sanitize [FAILED]"
    fi

    if [[ "$mmcSecure_erase_exit_code" == "0" ]]; then
        methodMessage="$methodMessage > Secure Erase"
    else
        methodMessage="$methodMessage > Secure Erase [FAILED]"
    fi

    if [[ "$type" == "one" ]]; then
		overwriteZero "$disk"
		methodMessage="${methodMessage} > Overwrite [Zero]"
		
	elif [[ "$type" == "two" ]]; then 
		overwriteRandomZero "$disk"
		methodMessage="${methodMessage} > Overwrite [Random > Zero]"
	fi

    # Log tools overwrite tool
	toolMessage="${toolMessage} $(shred --version | awk 'NR==1{print}')"

    
    # Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
	echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
	echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"


}
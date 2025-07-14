#!/bin/bash

# SSD Purge level erasure using block erase command.
# Block erase > Secure Erase/Zero fill > Block erase
# @Param $1: disk to process
# @Returns 0 if first block erase successful
# @Returns 1 if first block erase NOT successful
sata_ssd_purge_block_erase() {
	
	disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	local specMessage="Purge"
	local methodMessage
	local toolMessage
	local OWTool
	local block_erase_exit_code
	local block2_erase_exit_code
	local secure_erase_exit_code
	
	# Add an arrow to method message if other erasure attempts made prior
	if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
		methodMessage=" >"
	fi
	
	# Check if disk supports secure erase
	supportsSecureErase "$disk"
	secureEraseSupport=$?

	while true; do
		
		# ERASURE 1
		# Mandatory for purge spec (p. 36)
		# If this does not finish successfully then end.
		# If first attempt fails then try again once
		for (( i=0; i<2; i++ )); do
			blockErase "$disk"
			block_erase_exit_code=$?
			
			if 	[[ "$block_erase_exit_code" == 0 ]]; then
				break
			fi
		done
		
		# Construct Method message for report
		# If initial Block erase fails then end the erasure attempt
		if [[ "$block_erase_exit_code" == 0 ]]; then
			methodMessage="${methodMessage} Block Erase"
			
		else
			methodMessage="${methodMessage} Block Erase [FAILED]"
			echo "${disk}: Block Erase [Purge] failed." >> "${DISK_FILES}/${disk}/warnings.txt"
			break
		fi
		
		# Optional: secure erase/zero fill and block erase
		
		#ERASURE 2
		# If disk supports secure erase then use it
		if [[ "$secureEraseSupport" == 0 ]]; then
			secureErase "$disk"
			secure_erase_exit_code=$?
		fi
		
		# If secure erase not supported then zero fill
		if [[ "$secure_erase_exit_code" == 0 ]]; then
			methodMessage="${methodMessage} > Secure Erase"
			
		elif [[ "$secure_erase_exit_code" != 0 ]]; then
			methodMessage="${methodMessage} > Secure Erase [FAILED]"
			
		else
			overwriteZero "$disk"
			methodMessage="${methodMessage} > Overwrite [Zero]"
			OWTool="$(shred --version | awk 'NR==1{print}')"
		fi
		
		#ERASURE 3
		# Second block erase
		blockErase "$disk"
		block2_erase_exit_code=$?
			
		if [[ "$block2_erase_exit_code" == 0 ]]; then
			methodMessage="${methodMessage} > Block Erase"
			
		else
			methodMessage="${methodMessage} > Block Erase [FAILED]"
		fi
		
		break
	done
	
	# Log tools used
	toolMessage="$(hdparm -V)"
	if [[ -n "$OWTool" ]]; then
		toolMessage="${toolMessage} ${OWTool}"
	fi
	
	# Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

	# Return codes
	if [[ "$block_erase_exit_code" == 0 ]]; then
		return 0
	else
		return 1
	fi

}

# Performs a "Clear" level secure erase using hdparm's secure erase functionality.
# @Param $1: disk to process
# @Returns 0 if successful
# @Returns 1 if NOT successful
sata_ssd_clear_secure_erase() {
	
	local disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	local specMessage="Clear"
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

# Performs a "Clear" level secure erase using hdparm's secure erase functionality.
# @Param $1: disk to process
# @Param $2: overwrite type
# Options: one, two   [one = zero], [two = random > zero ]
sata_ssd_clear_overwrite() {
	
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

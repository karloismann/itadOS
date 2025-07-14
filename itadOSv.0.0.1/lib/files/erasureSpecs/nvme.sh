#!/bin/bash

# Crypto sanitize > Sanitize/Secure Format
# @Param $1: disk to process
# @Returns 0 if successful
# @Returns 1 if not successful
nvme_purge_crypto_erase() {

    disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	specMessage="Purge"
	local methodMessage
	local toolMessage
    local OWTool
    local comparison

    # Add an arrow to method message if other erasure attempts made prior
    if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
        methodMessage=" >"
    fi

    while true; do

        # Snapshot of first lines on disk before Crypto Erase
        verifyErasure "$disk" "1M" "snapshot_before"

        # Crypto erase
        nvmeCryptoSanitize "$disk"
        nvmeCrypto_sanitize_exit_code=$?

        # Construct Method message for report
        if [[ "$nvmeCrypto_sanitize_exit_code" == 0 ]]; then
            methodMessage="$methodMessage Crypto Sanitize"
        else
            methodMessage="$methodMessage Crypto Sanitize [FAILED]"
            break
        fi

        # Snapshot of first lines on disk after Crypto Erase
        verifyErasure "$disk" "1M" "snapshot_after"

        # Compare hashes of snapshots. If different then continue, else fail
        if [[ $(verifyErasure "$disk" "1M" "compare_snapshots") == 5 ]]; then

            comparison="ok"

            # If disk also supports Sanitize command then use it
            if nvmeSupportsCommand "$disk" "sanitize"; then
                nvmeSanitize "$disk"
                nvme_sanitize_exit_code=$?

                if [[ "$nvme_sanitize_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Sanitize"

                # If Sanitize fails and supports Secure Format then use it
                else

                    methodMessage="$methodMessage > Sanitize [FAILED]"
                    
                    if nvmeSupportsCommand "$disk" "secureFormat"; then

                        nvmeFormatSecure "$disk"
                        nvmeFormat_secure_exit_code=$?

                        if [[ "$nvmeFormat_secure_exit_code" == 0 ]]; then

                            methodMessage="$methodMessage > Secure Format"

                        else

                            methodMessage="$methodMessage > Secure Format [FAILED]"

                            overwriteZero "$disk"
		                    methodMessage="${methodMessage} > Overwrite [Zero]"
                            OWTool="$(shred --version | awk 'NR==1{print}')"

                        fi

                    else

                        overwriteZero "$disk"
		                methodMessage="${methodMessage} > Overwrite [Zero]"
                        OWTool="$(shred --version | awk 'NR==1{print}')"

                    fi

                fi

            # If disk also supports Secure Format command then use it
            elif nvmeSupportsCommand "$disk" "secureFormat"; then
                nvmeFormatSecure "$disk"
                nvmeFormat_secure_exit_code=$?

                if [[ "$nvmeFormat_secure_exit_code" == 0 ]]; then

                    methodMessage="$methodMessage > Secure Format"

                else

                    methodMessage="$methodMessage > Secure Format [FAILED]"
                    overwriteZero "$disk"

		            methodMessage="${methodMessage} > Overwrite [Zero]"
                    OWTool="$(shred --version | awk 'NR==1{print}')"

                fi

            else

                overwriteZero "$disk"
		        methodMessage="${methodMessage} > Overwrite [Zero]"
                OWTool="$(shred --version | awk 'NR==1{print}')"

            fi

        else

            if [[ "$methodMessage" != *"Crypto Sanitize [FAILED]"* ]]; then
                methodMessage="${methodMessage} Crypto Sanitize [FAILED]"
            fi

            comparison="bad"
            echo "${disk}: Crypto Sanitize verification FAILED." >> "${DISK_FILES}/${disk}/warnings.txt"

        fi

        break

    done

    # Log NVMe cli tool used
    toolMessage="$toolMessage $(nvme --version) ${OWTool}"

    # Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

    # Return codes
	if [[ "$nvmeCrypto_sanitize_exit_code" == 0 && "$comparison" == "ok" ]]; then
		return 0
	else
		return 1
	fi

}

# Crypto Format > Sanitize/Secure Format
# @Param $1: disk to process
# @Returns 0 if successful
# @Returns 1 if not successful
nvme_purge_crypto_format() {

    disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	specMessage="Purge"
	local methodMessage
	local toolMessage
    local OWTool
    local comparison

    # Add an arrow to method message if other erasure attempts made prior
    if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
        methodMessage=" >"
    fi

    while true; do

        # Snapshot of first lines on disk before Crypto Erase
        verifyErasure "$disk" "1M" "snapshot_before"

        # Crypto erase
        nvmeFormatCrypto "$disk"
        nvmeFormat_crypto_exit_code=$?

        # Construct Method message for report
        if [[ "$nvmeFormat_crypto_exit_code" == 0 ]]; then
            methodMessage="$methodMessage Crypto Format"
        else
            methodMessage="$methodMessage Crypto Format [FAILED]"
            break
        fi

        # Snapshot of first lines on disk after Crypto Erase
        verifyErasure "$disk" "1M" "snapshot_after"

        # Compare hashes of snapshots. If different then continue, else fail
        if [[ $(verifyErasure "$disk" "1M" "compare_snapshots") == 5 ]]; then

            comparison="ok"

            # If disk also supports Sanitize command then use it
            if nvmeSupportsCommand "$disk" "sanitize"; then

                nvmeSanitize "$disk"
                nvme_sanitize_exit_code=$?

                if [[ "$nvme_sanitize_exit_code" == 0 ]]; then
                    methodMessage="$methodMessage > Sanitize"

                # If Sanitize fails and supports Secure Format then use it
                else

                    methodMessage="$methodMessage > Sanitize [FAILED]"
                    
                    if nvmeSupportsCommand "$disk" "secureFormat"; then
                        nvmeFormatSecure "$disk"
                        nvmeFormat_secure_exit_code=$?

                        if [[ "$nvmeFormat_secure_exit_code" == 0 ]]; then
                            methodMessage="$methodMessage > Secure Format"

                        else

                            methodMessage="$methodMessage > Secure Format [FAILED]"

                            overwriteZero "$disk"
                            methodMessage="${methodMessage} > Overwrite [Zero]"
                            OWTool="$(shred --version | awk 'NR==1{print}')"
                            
                        fi
                    else

                        overwriteZero "$disk"
		                methodMessage="${methodMessage} > Overwrite [Zero]"
                        OWTool="$(shred --version | awk 'NR==1{print}')"

                    fi

                fi

            # If disk also supports Secure Format command then use it
            elif nvmeSupportsCommand "$disk" "secureFormat"; then
                nvmeFormatSecure "$disk"
                nvmeFormat_secure_exit_code=$?

                if [[ "$nvmeFormat_secure_exit_code" == 0 ]]; then
                    methodMessage="$methodMessage > Secure Format"
                else
                    methodMessage="$methodMessage > Secure Format [FAILED]"
                fi
                
            else

                overwriteZero "$disk"
		        methodMessage="${methodMessage} > Overwrite [Zero]"
                OWTool="$(shred --version | awk 'NR==1{print}')"

            fi

        else

            if [[ "$methodMessage" != *"Crypto Format [FAILED]"* ]]; then
                methodMessage="${methodMessage} Crypto Format [FAILED]"
            fi

            comparison="bad"
            echo "${disk}: Crypto Format verification FAILED." >> "${DISK_FILES}/${disk}/warnings.txt"

        fi

        break

    done

    # Log NVMe cli tool used
    toolMessage="$toolMessage $(nvme --version) ${OWTool}"

    # Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

    # Return codes
	if [[ "$nvmeFormat_crypto_exit_code" == 0 && "$comparison" == "ok" ]]; then
		return 0
	else
		return 1
	fi

}

# Sanitize > Secure Format
# @Param $1: disk to process
# @Returns 0 if successful (Sanitize OR Secure Format)
# @Returns 1 if not successful (Santizeze AND Secure Format)
nvme_purge_sanitize() {

    disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	specMessage="Purge"
	local methodMessage
	local toolMessage

    # Add an arrow to method message if other erasure attempts made prior
    if [[ -s "${DISK_FILES}/${disk}/method.txt" ]]; then
        methodMessage=" >"
    fi


    nvmeSanitize "$disk"
    nvme_sanitize_exit_code=$?

    if [[ "$nvme_sanitize_exit_code" == 0 ]]; then
        methodMessage="${methodMessage} Sanitize"
    else
        methodMessage="${methodMessage} Sanitize [FAILED]"
    fi

    if nvmeSupportsCommand "$disk" "secureFormat"; then

        nvmeFormatSecure "$disk"
        nvmeFormat_secure_exit_code=$?

        if [[ "$nvmeFormat_secure_exit_code" == 0 ]]; then
            methodMessage="${methodMessage} > Secure Format"
        else
            methodMessage="${methodMessage} > Secure Format [FAILED]"
        fi

    fi

    # Log NVMe cli tool used
    toolMessage="$toolMessage $(nvme --version)"

    # Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

    # Return codes
	if [[ "$nvme_sanitize_exit_code" == 0 || "$nvmeFormat_secure_exit_code" == 0 ]]; then
		return 0
	else
		return 1
	fi

}

# Secure Format
# @Param $1: disk to process
# @Returns 0 if successful
# @Returns 1 if not successful
nvme_purge_format() {

    disk="$1"
	local DISK_FILES="lib/files/tmp/chosenDisks/"
	specMessage="Purge"
	local methodMessage
	local toolMessage

    nvmeFormatSecure "$disk"
    nvmeFormat_secure_exit_code=$?

    if [[ "$nvmeFormat_secure_exit_code" == 0 ]]; then
        methodMessage="${methodMessage} Secure Format"
    else
        methodMessage="${methodMessage} Secure Format [FAILED]"
    fi

    # Log NVMe cli tool used
    toolMessage="$toolMessage $(nvme --version)"

    # Record data for report
	echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

    # Return codes
	if [[ "$nvme_sanitize_exit_code" == 0 || "$nvmeFormat_secure_exit_code" == 0 ]]; then
		return 0
	else
		return 1
	fi

}

# Secure Format
# @Param $1: disk to process
# @Param $2: Overwrite type [zero] or [random > zero]
# option: one = zero pass
# option: two = random > zero pass
nvme_clear_overwrite() {
	
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


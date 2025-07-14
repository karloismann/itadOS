#!/bin/bash

# Start script from own path
cd "$(dirname "$0")"

# Used in taskManager.sh
erasureVerificatioDone=""

source lib/initialize.sh
source lib/userConfig.sh
source ./config.sh
source lib/interaction.sh
source lib/reportToUSB.sh
source lib/getAssetTag.sh
source lib/log.sh
source lib/getAttachedDisks.sh
source lib/getSystemInfo.sh
source lib/getChosenDisks.sh
source lib/getDiskInfo.sh
source lib/files/erasureMethods/sata.sh
source lib/files/erasureMethods/nvme.sh
source lib/files/erasureMethods/emmc.sh
source lib/verifyErasure.sh
source lib/files/erasureSpecs/sata_ssd.sh
source lib/files/erasureSpecs/sata_hdd.sh
source lib/files/erasureSpecs/nvme.sh
source lib/files/erasureSpecs/emmc.sh
source lib/files/erasureSpecs/not_supported.sh
source lib/erasureAlgorithm.sh
source lib/erasureProgress.sh
source lib/diskHealth.sh
source lib/taskManager.sh
source lib/reportGenerator.sh

export RUNNING="true"

while [[ "$RUNNING" == "true" ]]; do

    initialize
    GetSystemInfo


    if [[ "$MANUAL_USER_CONF" == "on" ]]; then
        menu
    fi

    if [[ "$ASSET_CONF" == "asset" ]]; then
        getAssetTagRQ
    elif [[ "$ASSET_CONF" == "serial" ]]; then
        export ASSET_TAG="$SERIAL_NUMBER"
    fi

    # Create log file
    export LOG_FILE="lib/files/tmp/logs/${ASSET_TAG}_log.txt"
    if [[ ! -f $LOG_FILE ]]; then
        > "$LOG_FILE"
    fi
    log "Asset tag: ${ASSET_TAG}"

    getAttachedDisks

    # Log start time
    export ERASURE_START=$(date +"%d-%m-%Y %H:%M")

    if [[ "$SUSPEND_CONF" == "on" ]]; then
        suspend "4"
    fi

    if [[ "$AUTO_ERASURE_CONF" == "on" ]]; then
    
        autoSelectAttachedDisks

    elif [[ "$AUTO_ERASURE_CONF" == "off" ]]; then

        getChosenDisks
        checkStatus

    fi


    if [[ -z "$ERRORS" ]]; then

    getDiskInfo
    reportGenerator
    reportToUSB
    finalMenu

    else

        finalMenu

    fi

done

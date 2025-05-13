#!/bin/bash

# Start script from own path
cd "$(dirname "$0")"

# Used in process.sh
erasureVerificatioDone=""

source lib/initialize.sh
#getAssetTag - asset tag can be bypassed
#getAssetTagRQ - asset tag cannot be bypassed
source lib/getAssetTag.sh
#getAttachedDisks - looks for attached disks
source lib/getAttachedDisks.sh
#getChosenDisks - allows user to choose which disk to erase
source lib/getChosenDisks.sh
#getDiskType - gets chosen disks' types (nvme, sata hdd, sata ssd etc.)
source lib/getDiskType.sh
#isDiskFrozen - checks if disk is frozen
#suspend - suspends computer
#wakeFromFrozen - attempts to unfreeze 3 times
#supportsSecureErase - checks if sata disk supports secure erase
#supportsBlockErase - checks if sata disk supports block erase
#secureErase - start secure erase
#blockErase - starts block erase
#overwrite - starts overwrite erasure (THIS IS FOR ALL TYPES)
source lib/files/erasureMethods/sata.sh
source lib/files/erasureMethods/nvme.sh
source lib/files/erasureMethods/emmc.sh
#erasure - erasure logic
source lib/erasure.sh
#erasureProgressTUI - erasure progress indicators with whiptail --msgbox
#erasureProgress - erasure progress indicators in terminal
source lib/erasureProgress.sh
source lib/verifyErasure.sh
source lib/reportGenerator.sh
source lib/process.sh
source lib/reportToUSB.sh

initialize
getAssetTagRQ
getAttachedDisks
getChosenDisks

# Assign a condition to this
#suspend "4"

case $CHOSEN_DISK_STATUS in
    # If 'OK' is pressed and no disks are selected then only getting specifications.
    # If disks are selected then the erasure will start
    0)  
        if [[ "$CHOSEN_DISKS_COUNT" -le 0 ]]; then
            whiptail --msgbox "Disks were not selected.. Getting specifications." 0 0
        else
            echo "$CHOSEN_DISKS_COUNT"
            processWithVerification
        fi
    ;;
    1)
        # If 'Cancel' is pressed then only getting specifications.
        whiptail --msgbox "Erasure cancelled.. Getting specifications." 0 0
    ;;
    *)  
        # If 'Esc' is pressed or error occurred then only getting specifications.
        whiptail --msgbox "Erasure cancelled or error occurred.. Getting specifications." 0 0
    ;;
esac


reportGenerator
reportToUSB


#echo "$ASSET_TAG"
#echo "$(cat "$CHOSEN_DISKS_DESC")"
#echo "$CHOSEN_DISK_STATUS"

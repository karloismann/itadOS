#!/bin/bash

CHOSEN_DISKS="lib/files/tmp/chosenDisks.txt"
DISK_FILES="lib/files/tmp/chosenDisks/"

#
# Gives disk sectors
# @param $1 drive
# @returns sectors
#
getDiskSectors() {
    local disk="$1"

	local sectors=$(cat /sys/block/"$disk"/size)
	echo "$sectors"

}


#
# Gives disk sector size
# @param $1 drive
# @returns sector size
#
getDiskSectorSize() {
    local disk="$1"

	local sectorSize=$(cat /sys/block/"$disk"/queue/hw_sector_size)
	echo "$sectorSize"

}


#
# Gives disk size in bytes
# @param $1 drive
# @returns size in bytes
#
getDiskSizeInBytes() {
    local disk="$1"

    local sizeInBytes=$(( $(getDiskSectors "$disk") * $(getDiskSectorSize "$disk") ))

    echo "$sizeInBytes"

}


#
# Gets full specs of a disk and places then into specifications.txt folder
# @param $1 drive
#
getFullDiskSpecs() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | grep "$disk" > "${DISK_FILES}${disk}/specifications.txt"
}

# Get disk type
# Param $1 disk to check
# Returns disk type value to "${DISK_FILES}${disk}/type" and console
getDiskType() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    local specifications="${DISK_FILES}${disk}/specifications.txt"
    local name=$(awk '{print $1}' "$specifications")
    local rota=$(awk '{print $5}' "$specifications")
    local tran=$(awk '{print $6}' "$specifications")

    if [[ "${tran}" == "sata" && "${rota}" == "1" ]]; then
        TYPE="SATA HDD"
    elif [[ "${tran}" == "sata" && "${rota}" == "0" ]]; then
        TYPE="SATA SSD"
    elif [[ "${name}" == mmc* ]]; then
        TYPE="eMMC"
    else
        TYPE="${tran^^}"
    fi

    echo "$TYPE" > "${DISK_FILES}${disk}/type.txt"
    echo "$TYPE"

    export TYPE
}

# Get disk model
# Param $1 disk to check
# Returns disk model value to "${DISK_FILES}${disk}/model" and console
getDiskModel() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    local specifications="${DISK_FILES}${disk}/specifications.txt"

    local model="$(awk '{for(i=7; i<=NF; i++) printf $i " "; print ""}' "$specifications")"
    
    echo "$model" > "${DISK_FILES}${disk}/model.txt"
    echo "$model"
}


# Get disk model
# Param $1 disk to check
# Returns size value to "${DISK_FILES}${disk}/size" and console
getDiskSize() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    local specifications="${DISK_FILES}${disk}/specifications.txt"

    local size="$(awk '{print $2}' "$specifications")"
    
    echo "$size" > "${DISK_FILES}${disk}/size.txt"
    echo "$size"
}

# Get disk serial
# Param $1 disk to check
# Returns serial value to "${DISK_FILES}${disk}/serial" and console
getDiskSerial() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    local specifications="${DISK_FILES}${disk}/specifications.txt"

    local serial="$(awk '{print $3}' "$specifications")"
    
    echo "$serial" > "${DISK_FILES}${disk}/serial.txt"
    echo "$serial"
}

# Initialize Disk files for report
# Param $1 disk to process
initializeDiskFiles() {
    local disk="$1"

    # KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL
    > "${DISK_FILES}${disk}/specifications.txt"
    > "${DISK_FILES}${disk}/type.txt"
    > "${DISK_FILES}${disk}/HPA.txt"
    > "${DISK_FILES}${disk}/DCO.txt"
    > "${DISK_FILES}${disk}/model.txt"
    > "${DISK_FILES}${disk}/size.txt"
    > "${DISK_FILES}${disk}/serial.txt"
    > "${DISK_FILES}${disk}/warnings.txt"
    > "${DISK_FILES}${disk}/sectors.txt"
    > "${DISK_FILES}${disk}/tool.txt"
    > "${DISK_FILES}${disk}/method.txt"
    > "${DISK_FILES}${disk}/verification.txt"
    > "${DISK_FILES}${disk}/time.txt"
    > "${DISK_FILES}${disk}/health.txt"
    > "${DISK_FILES}${disk}/spec.txt"

}

# Place disk specs into specified folders
# Param $1 disk to process
placeSpecsToFolders() {
    local disk="$1"
    
    getDiskType "$disk"
    getDiskModel "$disk"
    getDiskSize "$disk"
    getDiskSerial "$disk"
}


# Create directory for each selected disk
createDiskDir() {
    log "Chosen disks: $(cat "$CHOSEN_DISKS")"

    if [[ "$AUTO_ERASURE_CONF" == "off" ]]; then

        for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
            local disk=$(awk -v field="$i" '{print $field}' "$CHOSEN_DISKS")

            if [[ -z "$disk" || "$disk" == "*" ]]; then
                
                log "ERROR: Unable to initialize disks."
                ERRORS="${ERRORS} ERROR: Unable to initialize disks."
                whiptail --msgbox "ERROR: Unable to initialize disks." 0 0
                return 1

            elif [[ -n "$(echo "$disk" | awk '{print $2}')" ]]; then

                log "ERROR: ${disk} is invalid."
                ERRORS="${ERRORS} ERROR: ${disk} is invalid."
                whiptail --msgbox "ERROR: ${disk} is invalid." 0 0
                return 2

            else

                mkdir -p "${DISK_FILES}${disk}"
                initializeDiskFiles "$disk"

            fi

        done

    elif [[ "$AUTO_ERASURE_CONF" == "on" ]]; then

        for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
            local disk=$(awk -v row="$i" 'NR==row {print $1}' "$CHOSEN_DISKS")

            if [[ -z "$disk" || "$disk" == "*" ]]; then

                log "ERROR: Unable to initialize disks."
                ERRORS="${ERRORS} ERROR: Unable to initialize disks."
                whiptail --msgbox "ERROR: Unable to initialize disks." 0 0
                return 1

            elif [[ -n "$(echo "$disk" | awk '{print $2}')" ]]; then

                log "ERROR: ${disk} is invalid."
                ERRORS="${ERRORS} ERROR: ${disk} is invalid."
                whiptail --msgbox "ERROR: ${disk} is invalid." 0 0
                return 2

            else

                mkdir -p "${DISK_FILES}${disk}"
                initializeDiskFiles "$disk"

            fi

        done

    fi

    return 0
    
}   

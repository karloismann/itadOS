#!/bin/bash

CHOSEN_DISKS="lib/files/tmp/chosenDisks.txt"
DISK_FILES="lib/files/tmp/chosenDisks/"


#
# Gives disk sectors
# @param $1 drive
# @returns sectors
#
getDiskSectors() {
    disk="$1"

	sectors=$(cat /sys/block/"$disk"/size)
	echo "$sectors"

}


#
# Gets full specs of a disk and places then into specifications.txt folder
# @param $1 drive
#
getFullDiskSpecs() {
    local disk="$1"

    lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | grep "$disk" > "${DISK_FILES}${disk}/specifications.txt"
}

# Get disk type
# Param $1 disk to check
# Returns disk type value to "${DISK_FILES}${disk}/type" and console
getDiskType() {
    disk="$1"
    specifications="${DISK_FILES}${disk}/specifications.txt"
    name=$(awk '{print $1}' "$specifications")
    rota=$(awk '{print $5}' "$specifications")
    tran=$(awk '{print $6}' "$specifications")

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
    disk="$1"
    specifications="${DISK_FILES}${disk}/specifications.txt"

    model="$(awk '{for(i=7; i<=NF; i++) printf $i " "; print ""}' "$specifications")"
    
    echo "$model" > "${DISK_FILES}${disk}/model.txt"
    echo "$model"
}


# Get disk model
# Param $1 disk to check
# Returns size value to "${DISK_FILES}${disk}/size" and console
getDiskSize() {
    disk="$1"
    specifications="${DISK_FILES}${disk}/specifications.txt"

    size="$(awk '{print $2}' "$specifications")"
    
    echo "$size" > "${DISK_FILES}${disk}/size.txt"
    echo "$size"
}

# Get disk serial
# Param $1 disk to check
# Returns serial value to "${DISK_FILES}${disk}/serial" and console
getDiskSerial() {
    disk="$1"
    specifications="${DISK_FILES}${disk}/specifications.txt"

    serial="$(awk '{print $3}' "$specifications")"
    
    echo "$serial" > "${DISK_FILES}${disk}/serial.txt"
    echo "$serial"
}

# Initialize Disk files for report
# Param $1 disk to process
initializeDiskFiles() {
    disk="$1"

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

}

# Place disk specs into specified folders
# Param $1 disk to process
placeSpecsToFolders() {
    disk="$1"
    
    getDiskType "$disk"
    getDiskModel "$disk"
    getDiskSize "$disk"
    getDiskSerial "$disk"
}


# Create directory for each selected disk
createDiskDir() {
    for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
        disk=$(awk -v field_number="$i" '{print $field_number}' "$CHOSEN_DISKS")
        mkdir -p "${DISK_FILES}${disk}"
        initializeDiskFiles "$disk"
    done
}

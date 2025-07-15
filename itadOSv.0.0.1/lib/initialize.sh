#!/bin/bash

# Checks if disk is removable.
# @Param $1: disk to check
# @Returns 0 if disk is removable
# @Returns 1 if disk is NOT removable
isDiskRemovable() {
    disk="$1"
    
    removable=$(cat /sys/class/block/${disk}/removable)

    if [[ "$removable" == 0 ]]; then
        return 1
    else
        return 0
    fi

}

# Print amount of partitions found on a disk
# @Param $1: disk to check
# @Returns amount of partitions found
amountOfPartitions() {
    disk="$1"

    amount=$(ls /sys/class/block/${disk} | grep "$disk" | awk 'END{print NR}')

    echo "$amount"
}

# Find name of partition
# @Param $1: disk to check
# @Returns name of partition
partitionLabel() {
    disk="$1"

    label=$(lsblk -no PKNAME,LABEL | awk -v d="$disk" '$1 == d {print $2; exit}' | xargs)

    echo "$label"
}

# Find itadOS file (Currently commented out). Old method should be enough
findItadOS() {

    BOOT_DISK=$(lsblk -no pkname | xargs | awk '{print $1}' )

    # Find itadOS folder
    #FIND="lib/files/tmp/findItadOS.txt"
    #> "$FIND"

    #find / -type d -iname "itados28-04" > "$FIND"
    #found=$(awk 'END{print}' "$FIND")

    #BOOT_DISK=$(df "$found" | awk 'NR==2 {print $1}' )
    #BOOT_DISK=$(lsblk -no pkname "$BOOT_DISK" | xargs | awk '{print $1}')
}


# Get boot disk information. Used to filter boot disk from attached disk list
getBootDisk() {

    export BOOT_DISK_LOCATION="lib/files/tmp/bootDisk.txt"

    # Look for boot disk if not previously found.
    if [[ ! -f "$BOOT_DISK_LOCATION" ]]; then

        > "$BOOT_DISK_LOCATION"

        local i=1

        # Looks if disk is removele, if it is look if partition name is "ITADOS", if so then it is boot disk
        # If previous logic failed then find itadOS
        while true; do

            BOOT_DISK=$(lsblk -no pkname | xargs | awk -v disk="$i" '{print $disk}' )

            if [[ -z "$BOOT_DISK" ]]; then
                
                findItadOS
                break

            fi

            if isDiskRemovable "$BOOT_DISK"; then 
                if [[ $(partitionLabel "$disk") == "ITADOS" ]]; then
                    break
                fi
            fi

            (( i=i+1 ))

        done



        BOOT_SERIAL=$(lsblk -do kname,serial | awk -v boot="$BOOT_DISK" '$1 == boot {print $2}')

        echo "$BOOT_DISK" >> "$BOOT_DISK_LOCATION"
        echo "$BOOT_SERIAL" >> "$BOOT_DISK_LOCATION"

    fi

    BOOT_DISK=$(cat "$BOOT_DISK_LOCATION" | awk 'NR==1{print $1}' | xargs)
    BOOT_SERIAL=$(cat "$BOOT_DISK_LOCATION" | awk 'NR==2{print $1}' | xargs)

    export BOOT_DISK
    export BOOT_SERIAL

}


initialize() {
    
    if [[ ! -d lib/files/tmp/logs/ ]]; then
        mkdir -p lib/files/tmp/logs/
        mkdir lib/files/tmp/verificationStatus
        mkdir lib/files/tmp/verifyFiles
        mkdir lib/files/tmp/progress
        mkdir lib/files/tmp/chosenDisks
        mkdir lib/files/reports
    fi

    if [[ ! -z "$BOOT_DISK_WARNING" ]]; then
        BOOT_DISK_WARNING=""
    fi

    rm lib/files/tmp/verificationStatus/*
    rm lib/files/tmp/verifyFiles/*
    rm lib/files/tmp/progress/*
    rm -rf lib/files/tmp/chosenDisks/*
    > lib/files/tmp/attachedDisks.txt
    > lib/files/tmp/attachedDisksFilter.txt
    > lib/files/tmp/chosenDisks.txt
    > lib/files/tmp/chosenDisksDesc.txt
    > lib/files/tmp/usbDrives.txt
    
    getBootDisk
    
    export ERRORS=""
    export HIDDEN_TRIGGERED="false" #This is triggered when DCO or HPO has been processed. If triggered, suspend is prompted to restore disk values.
    export CONFIRMED="no" #Used in userConfig
    export RECAP_MESSAGE="" #Used in process.sh
    export CHOSEN_DISK_WARNING="" #Used in getChosendisks.sh
    export CHOSEN_DISK_STATUS="" #Used in getChosendisks.sh

}

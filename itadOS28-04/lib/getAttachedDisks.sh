#!/bin/bash
# 
# Gets attached disk information and exports it into /files/attachedDisks
# Returns count of attached disks
#

ATTACHED_DISKS="lib/files/tmp/attachedDisks.txt"
ATTACHED_DISKS_FILTER="lib/files/tmp/attachedDisksFilter.txt"
BOOT_DISK_WARNING=""

#
# Gets attached disks information and appends it into a file /files/AttachedDisks.txt
# @Returns global attached disk amount
# @Returns attached disks file as a golbal variable
#
getAttachedDisks() {
    # Attached disks
    lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | awk '$4=="disk" {print}' > "$ATTACHED_DISKS_FILTER";

    # Filter boot disk
    filterBootUSB

    export ATTACHED_DISKS_COUNT=$(awk 'END {print NR}' "$ATTACHED_DISKS")
    export ATTACHED_DISKS
}


# Filter boot drive (MEANT FOR LIVE USB)
filterBootUSB() {
    BOOT_DRIVE=$(lsblk -no pkname | xargs | awk '{print $1}')

    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}' | xargs)

        if [[ ${name} !=  ${BOOT_DRIVE} ]]; then
            echo "$line" >> "$ATTACHED_DISKS"
        fi
        
    done < "$ATTACHED_DISKS_FILTER"

    attachedCount=$(awk 'END {print NR}' "$ATTACHED_DISKS")
    filteredCount=$(awk 'END {print NR}' "$ATTACHED_DISKS_FILTER")

    if [[ "$attachedCount" -ne "$filteredCount" ]]; then
        BOOT_DISK_WARNING="Boot disk attached: ${BOOT_DRIVE}"
    fi

    export BOOT_DISK_WARNING
    export BOOT_DRIVE
}

#!/bin/bash
# 
# Gets attached disk information and exports it into /files/attachedDisks
# Returns count of attached disks
#

ATTACHED_DISKS="lib/files/tmp/attachedDisks.txt"
ATTACHED_DISKS_FILTER="lib/files/tmp/attachedDisksFilter.txt"

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
    bootDrive=$(lsblk -no pkname | xargs)

    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}' | xargs)

        if [[ ${name} !=  ${bootDrive} ]]; then
            echo "$line" >> "$ATTACHED_DISKS"
        fi
        
    done < "$ATTACHED_DISKS_FILTER"
}

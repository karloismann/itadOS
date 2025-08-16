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
# If FILTER_BOOT_DISK_CONF='on' then Boot disk is not shown to the user, preventing erasure of boot disk
# @Returns global attached disk amount
# @Returns attached disks file as a golbal variable
#
getAttachedDisks() {


    if [[ "$FILTER_BOOT_DISK_CONF" == "on" ]]; then
        # Attached disks
        lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | awk '$4=="disk" {print}' > "$ATTACHED_DISKS_FILTER";

        # Filter boot disk
        filterBootUSB
        
    else
        # Attached disks
        lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | awk '$4=="disk" {print}' > "$ATTACHED_DISKS";
    fi

    log "Attached disks: $(cat "$ATTACHED_DISKS")"
    export ATTACHED_DISKS_COUNT=$(awk 'END {print NR}' "$ATTACHED_DISKS")
    export ATTACHED_DISKS
}


# Filter boot drive (MEANT FOR LIVE USB)
filterBootUSB() {

    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}' | xargs)
        serial=$(echo "$line" | awk '{print $3}' | xargs)

        if [[ "$name" !=  "$BOOT_DISK" && "$serial" !=  "$BOOT_SERIAL" ]]; then
            echo "$line" >> "$ATTACHED_DISKS"
        fi
        
    done < "$ATTACHED_DISKS_FILTER"

    attachedCount=$(awk 'END {print NR}' "$ATTACHED_DISKS")
    filteredCount=$(awk 'END {print NR}' "$ATTACHED_DISKS_FILTER")

    if [[ "$attachedCount" -ne "$filteredCount" ]]; then
        BOOT_DISK_WARNING="Boot disk attached: ${BOOT_DISK}"
    fi

    export BOOT_DISK_WARNING

}

#!/bin/bash
#
# Get drive type information
#


#
# Gets disk's transmission method (SATA, NVME, USB etc.)
# @Params $1 selected disk
# @Returns Local tran information
#
getDiskTran() {
    disk="$1"

    tran="$(cat "$CHOSEN_DISKS_DESC" | grep "$disk" | awk '{print $6}')"
    echo "$tran"
}

#
# Gets disk's rotation method (1 - SSD, 0 - HDD)
# @Params $1 selected disk
# @Returns local rota information
#
getDiskRota() {
    disk="$1"

    rota="$(cat "$CHOSEN_DISKS_DESC" | grep "$disk" | awk '{print $5}')"
    echo "$rota"
}


#
# Gets disk type (emmc, nvme, sata_hdd, sata_ssd, etc.)
# @Params $1 selected
# @Returns Global disk type
#
getDiskType() {
    disk="$1"

    rota=$(getDiskRota "$1")
    tran=$(getDiskTran "$1")
    
    if [[ "$disk" == mmc* ]]; then
        DISK_TYPE="emmc"
    elif [[ "$tran" == "nvme" ]]; then
            DISK_TYPE="nvme"
    elif [ "$tran" == "sata" ] && [ "$rota" == "1" ]; then
        DISK_TYPE="sata_hdd"
    elif [ "$tran" == "sata" ] && [ "$rota" == "0" ]; then
        DISK_TYPE="sata_ssd"
    else
        DISK_TYPE="$tran"
    fi

    export DISK_TYPE
}
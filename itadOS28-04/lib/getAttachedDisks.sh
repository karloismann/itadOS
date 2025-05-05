#!/bin/bash
# 
# Gets attached disk information and exports it into /files/attachedDisks
# Returns count of attached disks
#

ATTACHED_DISKS="lib/files/tmp/attachedDisks.txt"

#
# Gets attached disks information and appends it into a file /files/AttachedDisks.txt
# @Returns global attached disk amount
# @Returns attached disks file as a golbal variable
#
getAttachedDisks() {
    lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | awk '$4=="disk" {print}' > "$ATTACHED_DISKS";

    export ATTACHED_DISKS_COUNT=$(awk 'END {print NR}' "$ATTACHED_DISKS")
    export ATTACHED_DISKS
}

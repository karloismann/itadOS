#!/bin/bash
#
# Provides whiptail UI to users
# Users choose which attached disks to erase
#

CHOSEN_DISKS="lib/files/tmp/chosenDisks.txt"
CHOSEN_DISKS_DESC="lib/files/tmp/chosenDisksDesc.txt"
CHOSEN_DISK_WARNING=""


# Initialize disk descrption variables
size=""
serial=""
type=""
rota=""
tran=""
model=""

#
# Gets disk description
#
diskDescription() {
    echo "$size" "$serial" "$type" "$rota" "$tran" "$model"
}

#
# Let user choose which disk to erase
# @Returns chosen disks into /files/chosenDisksDesc.txt file
# @Returns CHOSEN_DISK_STATUS (0= user chose a disk, 1= user cancelled selection)
#
getChosenDisks() {
    # Initialize files/chosenDisks.txt
    > "$CHOSEN_DISKS"

    disks=()
    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        #serial=$(echo "$line" | awk '{print $3}') # UNCOMMENT IF BROKEN
        #type=$(echo "$line" | awk '{print $4}') # UNCOMMENT IF BROKEN
        #rota=$(echo "$line" | awk '{print $5}') # UNCOMMENT IF BROKEN
        tran=$(echo "$line" | awk '{print $6}') 
        # Print everything after 7th column
        model=$(echo "$line" | awk '{
            for(i=7; i<=NF; i++)
                printf $i " ";
                print ""}')

        disks+=("$name" "$(diskDescription)" OFF)
    done < "$ATTACHED_DISKS"

    # Whiptail UI listing all attached disks
	chosen=$(whiptail --title "Wipe disks" --checklist \
    "Choose disks to wipe" 30 100 5 \
	"${disks[@]}" 3>&1 1>&2 2>&3)

    # Checks if user chose a disk or pressed cancel
	CHOSEN_DISK_STATUS=$?
    
    # Disk name get placed into files/tmp/chosenDisks.txt (gsub removes quotation marks)
	echo "$chosen" | awk '{gsub(/\"/, ""); print}' > "$CHOSEN_DISKS"
    CHOSEN_DISKS_COUNT=$(awk '{print NF}' $CHOSEN_DISKS)

    # Initialize files/tmp/chosenDisksDesc.txt" 
    > "$CHOSEN_DISKS_DESC"

    # Populate files/tmp/chosenDisksDesc.txt" with disk information
    for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
        disk=$(awk -v disk="$i" '{print $disk}' "$CHOSEN_DISKS")
        lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | grep "$disk" >> "$CHOSEN_DISKS_DESC"
    done
    
    # Warning IF not all detected disks are not processed
    if (( CHOSEN_DISKS_COUNT < ATTACHED_DISKS_COUNT )); then
        CHOSEN_DISK_WARNING="Disks detected: ${ATTACHED_DISKS_COUNT}. Disks selected by user: ${CHOSEN_DISKS_COUNT}."
    fi

    export CHOSEN_DISK_WARNING
    export CHOSEN_DISK_STATUS
    export CHOSEN_DISKS_COUNT
    export CHOSEN_DISKS_DESC
    export CHOSEN_DISKS

}


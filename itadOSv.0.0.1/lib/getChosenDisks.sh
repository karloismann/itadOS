#!/bin/bash
#
# Provides whiptail UI to users
# Users choose which attached disks to erase
#

CHOSEN_DISKS="lib/files/tmp/chosenDisks.txt"
DISK_FILES="lib/files/tmp/chosenDisks/"
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
# Used to show the information for the operator in whiptail
#
diskDescription() {
    echo "$size" "$type" "$model"
}

#
# Let user choose which disk to erase
# @Returns chosen disks into /files/chosenDisksDesc.txt file
# @Returns CHOSEN_DISK_STATUS (0= user chose a disk, 1= user cancelled selection)
#
getChosenDisks() {
    # Initialize files/chosenDisks.txt
    > "$CHOSEN_DISKS"
    CHOSEN_DISK_STATUS=""

    disks=()
    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        #serial=$(echo "$line" | awk '{print $3}')
        #type=$(echo "$line" | awk '{print $4}')
        rota=$(echo "$line" | awk '{print $5}')
        tran=$(echo "$line" | awk '{print $6}')

        # Get disk type
        if [[ "${tran}" == "sata" && "${rota}" == "1" ]]; then
            type="SATA HDD"
        elif [[ "${tran}" == "sata" && "${rota}" == "0" ]]; then
            type="SATA SSD"
        elif [[ "${name}" == mmc* && "$(cat /sys/block/${name}/removable)" == "0" ]]; then
            type="eMMC"
        elif [[ "${name}" == mmc* && "$(cat /sys/block/${name}/removable)" == "1" ]]; then
            type="MMC"
        else
            type="${tran^^}"
        fi

        # Print everything after 7th column
        model=$(echo "$line" | awk '{
            for(i=7; i<=NF; i++)
                printf $i " ";
                print ""}')

        disks+=("$name" "$(diskDescription)" OFF)
    done < "$ATTACHED_DISKS"

    # Whiptail UI listing all attached disks
    if (( ${#disks[@]} > 0 )); then
        chosen=$(whiptail --title "Wipe disks" --checklist \
        "Choose disks to wipe" 0 0 0 \
        "${disks[@]}" 3>&1 1>&2 2>&3)

        # Checks if user chose a disk or pressed cancel
	    CHOSEN_DISK_STATUS=$?
        export CHOSEN_DISK_STATUS

    else
        whiptail --msgbox "Disks were not detected.. Getting specifications." 0 0
    fi

    
    # Disk name get placed into files/tmp/chosenDisks.txt (gsub removes quotation marks)
	echo "$chosen" | awk '{gsub(/\"/, ""); print}' > "$CHOSEN_DISKS"
    CHOSEN_DISKS_COUNT=$(awk '{print NF}' $CHOSEN_DISKS)

    # Create directories for chosen disks
    createDiskDir
    dir_exit=$?

    if [[ "$dir_exit" == 0 ]]; then

        # Populate disk directories with disk specifications
        for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
            disk=$(awk -v disk="$i" '{print $disk}' "$CHOSEN_DISKS")
            lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | grep "$disk" | awk 'NR==1 {print}' > "${DISK_FILES}${disk}/specifications.txt"

            # Place disk specs into specified folders
            placeSpecsToFolders "$disk"
        done
        
        # Warning IF not all detected disks are not processed
        if (( CHOSEN_DISKS_COUNT < ATTACHED_DISKS_COUNT )); then
            CHOSEN_DISK_WARNING="Disks detected: ${ATTACHED_DISKS_COUNT}. Disks selected by user: ${CHOSEN_DISKS_COUNT}."
        fi

        export CHOSEN_DISKS_COUNT
        export CHOSEN_DISKS_DESC
        export CHOSEN_DISKS

    else
        return
    fi
}

# Evaluates the user's action after the disk selection prompt and continues or cancels erasure accordingly.
checkStatus() {
    if [[ -n "$CHOSEN_DISK_STATUS" ]]; then
        case $CHOSEN_DISK_STATUS in
            # If 'OK' is pressed and no disks are selected then only getting specifications.
            # If disks are selected then the erasure will start
            0)  
                if [[ "$CHOSEN_DISKS_COUNT" -le 0 && "$ATTACHED_DISKS_COUNT" -eq 0 ]]; then
                    whiptail --msgbox "Disks were not detected.. Getting specifications." 0 0
                elif [[ "$CHOSEN_DISKS_COUNT" -le 0 ]]; then

                    while (( "$CHOSEN_DISKS_COUNT" <= 0 && "$CHOSEN_DISK_STATUS" == 0 )); do
                        whiptail --msgbox "Please select disks to erase." 0 0
                        getChosenDisks
                        checkStatus
                    done

                else
                    echo "$CHOSEN_DISKS_COUNT"
                    TaskManager
                fi
            ;;
            1)  
                reasonForCancel

            ;;
            *)  
                # If 'Esc' is pressed or error occurred then only getting specifications.
                whiptail --msgbox "Erasure cancelled or error occurred.. Getting specifications." 0 0
            ;;
        esac
    fi
}

# Automatically selects all attached disks for erasure without prompting the user.
autoSelectAttachedDisks(){
    # Initialize files/chosenDisks.txt
    > "$CHOSEN_DISKS"

    if (( $ATTACHED_DISKS_COUNT <= 0)); then
        whiptail --msgbox "Disks were not detected.. Getting specifications." 0 0
        return
    
    else

        for (( i=1; i<=$ATTACHED_DISKS_COUNT; i++ )); do

            awk -v row="$i" 'NR==row {print $1}' "$ATTACHED_DISKS" >> "$CHOSEN_DISKS"

        done

        CHOSEN_DISKS_COUNT=$(awk 'END {print NR}' "$CHOSEN_DISKS")

        # Create directories for chosen disks
        createDiskDir
        dir_exit=$?

        if [[ "$dir_exit" == 0 ]]; then

            # Populate disk directories with disk specifications
            for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
                local disk=$(awk -v disk="$i" 'NR==disk {print $1}' "$CHOSEN_DISKS")
                lsblk -d -o KNAME,SIZE,SERIAL,TYPE,ROTA,TRAN,MODEL | grep "$disk" | awk 'NR==1 {print}' > "${DISK_FILES}${disk}/specifications.txt"

                # Place disk specs into specified folders
                placeSpecsToFolders "$disk"
            done

            echo "$CHOSEN_DISKS_COUNT"
            TaskManager

        else
            return
        fi

    fi

}
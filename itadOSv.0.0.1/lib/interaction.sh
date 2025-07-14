#!/bin/bash

# Remove boot disk information
removeBootInfo() {
    rm lib/files/tmp/bootDisk.txt
}

# Turn off the system
shutdownNow() {
    RUNNING="false"
    shutdown now
}

# Get reason for canceling erasure
reasonForCancel() {
    while true; do
        REASON_FOR_CANCEL=$(whiptail --inputbox "Enter a reason for canceling erasure:" 0 0 3>&1 1>&2 2>&3 3>&-)
        local exit_status=$?
        
        if [[ "$exit_status" == 0 && -z "$REASON_FOR_CANCEL" ]]; then
            whiptail --msgbox "Please enter reason for canceling erasure." 0 0
        elif [[ "$exit_status" == 1 ]]; then
            export REASON_FOR_CANCEL="Not given."
            break
        elif [[ "$REASON_FOR_CANCEL" != "" ]]; then
            export REASON_FOR_CANCEL
            break
        fi

    done
}

# Menu appearing after erasure
finalMenu() {

    choice=$(whiptail --title "Menu" --menu "Choose an option:" 0 0 0 \
        "Shutdown" "Turn off the computer." \
        "Retry" "Rerun the erasure process." \
        "Exit" "Exit to CLI" 3>&1 1>&2 2>&3)
        
    local exit_status=$?

    if [[ "$choice" == "Shutdown" ]]; then
        shutdownNow
    elif [[ "$choice" == "Retry" ]]; then
        log "Starting erasure process again."
    elif [[ "$choice" == "Exit" ]]; then
        RUNNING="false"
        removeBootInfo
    fi

    if [[ "$exit_status" == 0 && -z "$choice" ]]; then
        whiptail --msgbox "Selection not made, please select an option." 0 0
    elif [[ "$exit_status" == 1 ]]; then
        RUNNING="false"
        removeBootInfo
    fi

}
#!/bin/bash

processWithVerification() {
    
    declare -A disk_erasure_pids
    declare -A disk_verify_pids

    #
    # Process frozen states and detect and remove hidden areas of SATA
    #
    for diskDir in lib/files/tmp/chosenDisks/*; do

        # $disk will be used throughout the program for erasure etc.
        local disk="$(basename "$diskDir")"
        local DISK_FILES="lib/files/tmp/chosenDisks/"
        local type="$(cat ${DISK_FILES}/${disk}/type.txt | xargs)"
        
        case "$type" in
            "SATA SSD"|"SATA HDD")
            
                # Check if disk is frozen. If frozen then automatic suspension and wakes in 10 secs. tries 3 times
                if ! isDiskFrozen "$disk"; then
                    wakeFromFrozen "$disk"
                fi

                # Recheck frozen status 
                if ! isDiskFrozen "$disk"; then
                    echo "Unable to unfreeze" >> "${DISK_FILES}/${disk}/warning.txt"
                fi
                
                # Sectors before erasure
                sectorsBefore="before:  $(getSataDiskSectors "$disk" combined)"
                echo "$sectorsBefore" >> "${DISK_FILES}/${disk}/sectors.txt"
                
                #Check and remove HPA and DCO
                checkAndRemoveHPA "$disk"
                checkAndRemoveDCO "$disk"

                # Refresh disk values
                suspend 10
                
                # Refresh disk size
                getFullDiskSpecs "$disk"
                getDiskSize "$disk"


                
            ;;
            *)
              # Sectors before erasure
              sectorsBefore="before:  $(getDiskSectors "$disk")"
              echo "$sectorsBefore" >> "${DISK_FILES}/${disk}/sectors.txt"
            ;;
        esac
    done

    #
    # Get chosen disk types and start erasure
    # Collect PIDs of erasures
    #
    for diskDir in lib/files/tmp/chosenDisks/*; do

        # $disk will be used throughout the program for erasure etc.
        disk="$(basename "$diskDir")"

        # Start erasure as a background process
        erasure "$disk" &

        # Collect PID of erasure
        disk_erasure_pids["$disk"]=$!
    done

    #
    # Check erasure progress using PIDs
    #
    erasureCompleted=()
    verifyCompleted=()

    # Do this while disks are still processing.
    # Checks if disks are still erasing, if not start verification.
    # This is async e.g. two disks are being processed, 1 disk erased faster then this
    # disk will start verification, while other one is still erasing.
    while true; do

        # Loop through each disk
        for disk in "${!disk_erasure_pids[@]}"; do
            # Current Disk erasure pid
            pid="${disk_erasure_pids[$disk]}"

            # If disk has been erased then continue
            if [[ "${erasureCompleted[@]}"  =~ "$disk" ]]; then
                continue
            fi

            # If disk's pid is active then erasure ongoing
            if kill -0 "$pid" 2>/dev/null; then
                continue

            # If disk's pid is not active then disk has been erased
            # and start erasure verification.
            else
                wait "$pid"
                if [[ $? == 0 ]]; then
                    echo "$disk was erased"
                    #Start verification
                    echo "STARTING VERIFICATION OF $disk"
                    verifyErasure "$disk" "64M" &
                    disk_verify_pids["$disk"]=$!
                else
                    echo "$disk erasure failed"
                fi
                # Add disk to completed array
                erasureCompleted+=("$disk")
            fi
        done

        for disk in "${!disk_verify_pids[@]}"; do
            # Current Disk erasure pid
            verifypid="${disk_verify_pids[$disk]}"

            # If disk has been verified then continue
            if [[ "${verifyCompleted[@]}"  =~ "$disk" ]]; then
                continue
            fi

            # If disk's pid is active then still verifying
            if kill -0 "$verifypid" 2>/dev/null; then
                continue

            # disk verification completed
            else
                wait "$verifypid"
                if [[ $? == 0 ]]; then
                    echo "$disk was verified"
                else
                    echo "$disk was not verified"
                fi
                # Add disk to completed array
                verifyCompleted+=("$disk")
            fi
        done

        # Cleating terminal window
        clear
        
        # Show processing Progress
        erasureProgress
        sleep 1


        # If disks have been erased and verified, give input to the user. (Success/Fail)
        if (( ${#verifyCompleted[@]} == ${#disk_erasure_pids[@]} && ${#erasureCompleted[@]} == ${#disk_erasure_pids[@]} )); then
            clear
            erasureProgress

            for file in lib/files/tmp/verificationStatus/*; do
                content=$(<"$file")
                erasureVerificationDone+="${content}"$'\n'
            done
            
            whiptail --title "Erasure result of ${ASSET_TAG}" --msgbox "$erasureVerificationDone" 0 0
            # Initialize verification progress files
            rm lib/files/tmp/verifyFiles/*
            break;
        fi
    done
}
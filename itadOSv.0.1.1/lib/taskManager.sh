#!/bin/bash

# Manages the lifecycle of selected disk erasure. Ensures frozen state handling, secure wipe initiation, progress monitoring, 
# post-wipe verification, and health checking — all asynchronously for multiple disks.
TaskManager() {
    
    declare -A disk_erasure_pids
    declare -A disk_verify_pids
    declare -A disk_health_pids

    #
    # Process frozen states and detect and remove hidden areas of SATA
    #
    for diskDir in lib/files/tmp/chosenDisks/*; do

        # $disk will be used throughout the program for erasure etc.
        local disk="$(basename "$diskDir")"
        local DISK_FILES="lib/files/tmp/chosenDisks/"
        local type="$(cat ${DISK_FILES}/${disk}/type.txt | xargs)"

        # Disk processing start time
        echo "start: $(date +"%H:%M")" >> "${DISK_FILES}/${disk}/time.txt"
        case "$type" in
            "SATA SSD"|"SATA HDD")
            
                # Check if disk is frozen. If frozen then automatic suspension and wakes in 10 secs. tries 3 times
                if ! isDiskFrozen "$disk"; then
                    log "${disk}: Frozen state detected, attempting to unfreeze."
                    wakeFromFrozen "$disk"
                fi

                # Recheck frozen status 
                if ! isDiskFrozen "$disk"; then
                    log "${disk}: Unable to unfreeze."
                    echo "${disk}: Unable to unfreeze" >> "${DISK_FILES}/${disk}/warnings.txt"
                fi
                
                # Sectors before erasure
                sectorsBefore="before:  $(getSataDiskSectors "$disk" combined)"
                echo "$sectorsBefore" >> "${DISK_FILES}/${disk}/sectors.txt"

                #Check and remove HPA and DCO
                log "${disk}: Checking for HPA."
                checkAndRemoveHPA "$disk"
                hpa_exit=$?

                log "${disk}: Checking for DCO."
                checkAndRemoveDCO "$disk" 
                dco_exit=$?

                # Refresh disk values if needed
                if [[ "$hpa_exit" == 0 || "$hpa_exit" == 1 || "$dco_exit" == 0 || "$dco_exit" == 1 ]]; then
                    log "${disk}: Suspending after DCO/HPA processing."
                    suspend 10

                    getFullDiskSpecs "$disk"
                    getDiskSize "$disk"
                    getDiskSectors "$disk"
                else
                    log "${disk}: DCO/HPA not detected or unable to detect."
                fi
                
                
            ;;
            *)
              # Sectors before erasure
              echo "N/A" >> "${DISK_FILES}/${disk}/HPA.txt"
              echo "N/A" >> "${DISK_FILES}/${disk}/DCO.txt"
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
        local disk="$(basename "$diskDir")"

        # Start erasure as a background process
        log "${disk}: Erasure starting."

        erasure "$disk" "$ERASURE_SPEC_CONF" &

        # Collect PID of erasure
        disk_erasure_pids["$disk"]=$!
    done

    #
    # Check erasure progress using PIDs
    #
    erasureCompleted=()
    verifyCompleted=()
    healthCompleted=()

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
                    log "${disk}: Erasure SUCCESS"
                else
                    log "${disk}: Erasure FAIL."
                    echo "${disk}: Erasure failed" >> "${DISK_FILES}/${disk}/warnings.txt"
                fi

                # Sectors after erasure
                if [[ $(cat "${DISK_FILES}/${disk}/type.txt" | xargs) == "SATA SSD" || $(cat "${DISK_FILES}/${disk}/type.txt" | xargs) == "SATA HDD" ]]; then
                    sectorsAfter="after:  $(getSataDiskSectors "$disk" combined)"
                    echo "$sectorsAfter" >> "${DISK_FILES}/${disk}/sectors.txt"
                else
                    sectorsAfter="after:  $(getDiskSectors "$disk")"
                    echo "$sectorsAfter" >> "${DISK_FILES}/${disk}/sectors.txt"
                fi

                #Start verification
                log "${disk}: Starting verification."
                verifyErasure "$disk" "1M" "$VERIFICATION_CONF" &
                disk_verify_pids["$disk"]=$!

                # Add disk to completed array
                erasureCompleted+=("$disk")
            fi
        done

        
        for disk in "${!disk_verify_pids[@]}"; do
            # Current Disk verify pid
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
                    log "${disk}: Verification SUCCESS."
                else
                    log "${disk}: Verification FAIL."
                fi

                # Start disk health check
                log "${disk}: Health test starting."
                diskHealth "$disk" &
                disk_health_pids["$disk"]=$!

                # Add disk to completed array
                verifyCompleted+=("$disk")
            fi
        done
        
        # Check disk health
        for disk in "${!disk_health_pids[@]}"; do
            # Current Disk health chech pid
            healthpid="${disk_health_pids[$disk]}"

            # If disk has been checked then continue
            if [[ "${healthCompleted[@]}"  =~ "$disk" ]]; then
                continue
            fi

            # If disk's pid is active then still checking health
            if kill -0 "$healthpid" 2>/dev/null; then
                continue

            # disk health check completed
            else
                wait "$healthpid"
                log "${disk}: Health test finished."

                # Disk processing start time
                echo "end: $(date +"%H:%M")" >> ${DISK_FILES}/${disk}/time.txt
                # Add disk to completed array
                healthCompleted+=("$disk")
            fi
        done


        # Clearing terminal window
        clear
        
        # Show processing Progress
        erasureProgress
        sleep 1

        
        # If disks have been erased and verified, give input to the user. (Success/Fail)
        if (( ${#verifyCompleted[@]} == ${#disk_erasure_pids[@]} && ${#erasureCompleted[@]} == ${#disk_erasure_pids[@]}  && ${#verifyCompleted[@]} == ${#healthCompleted[@]} )); then
            
            log "Processing finished."
            clear
            erasureProgress
            
            for file in lib/files/tmp/verificationStatus/*; do
                content=$(<"$file")
                RECAP_MESSAGE+="${content}"$'\n'
            done
            
            whiptail --title "Erasure result of ${ASSET_TAG}" --msgbox "$RECAP_MESSAGE" 0 0
            # Initialize verification progress files
            rm lib/files/tmp/verifyFiles/*
            break;
        fi
    done
}

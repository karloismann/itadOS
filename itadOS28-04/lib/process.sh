#!/bin/bash

processWithVerification() {

    # Initialize progress files
    rm lib/files/tmp/progress/erasure/*

    #
    # Get chosen disk types and start erasure
    # Collect PIDs of erasures
    #
    for (( i=1; i<="$CHOSEN_DISKS_COUNT"; i++ )); do
        # Create a temporary file to keep details for reporting
        TMP_REPORT="lib/files/tmp/reports/"$disk"_tmp_report.txt"

        # Gather disk information ($disk will be used throughout the program for erasure etc.)
        disk="$(awk -v disk="$i"  'NR==disk {print $1}' "$CHOSEN_DISKS_DESC")"
        serial="$(awk -v disk="$i"  'NR==disk {print $3}' "$CHOSEN_DISKS_DESC")"
        model="$(awk -v disk="$i"  'NR==disk {for(i=7; i<=NF; i++) printf $i " "; print ""}' "$CHOSEN_DISKS_DESC")"
        # Informaiton for report
        echo "Disk (location, Serial Number, Model):" "$disk" "$serial" "$model" > "$TMP_REPORT"

        # Look at chosen disks and get their type (nvme, sata ssd, sata hdd etc.)
        getDiskType "$disk"

        # Debug messages
        echo "$i of $CHOSEN_DISKS_COUNT"
        echo "$disk is type of "$DISK_TYPE""

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

            # If disk's pid is active then..
            if kill -0 "$pid" 2>/dev/null; then
                continue

            # If disk's pid is not active then..
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

            # If disk has been erased then continue
            if [[ "${verifyCompleted[@]}"  =~ "$disk" ]]; then
                continue
            fi

            # If disk's pid is active then..
            if kill -0 "$verifypid" 2>/dev/null; then
                continue
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
            
            whiptail --title "Erasure result" --msgbox "$erasureVerificationDone" 0 0
            # Initialize verification progress files
            rm lib/files/tmp/verifyFiles/*
            break;
        fi
    done
}
#!/bin/bash

# Initialize variables
TMP_PROGRESS="lib/files/tmp/progress"
#verifyProgressFiles="lib/files/tmp/progress/verify"
message=""


#
# Erasure progress shown with whiptail --msgbox TUI.
# This is inconvenient as it does not refresh automatically
# 'OK' needs to be pressed to refresh progress meters
#
erasureProgressTUI() {
    
    # Progress for every erasure
    for file in "$TMP_PROGRESS"/*_progress.txt; do

        # Get disk name from file name
        disk=$(basename "$file" | sed 's/_progress\.txt//')
        # Progress is received from the file
        progress=$(cat "$file")
        # Append progress message to variable
        PROGRESS_MSG+="Disk: $disk - Progress: $progress%\n"

    done

    # Display progress
    whiptail --title "Wipe Progress: PRESS 'OK' to refresh" --msgbox "$PROGRESS_MSG" 0 0

    # Initialize message variable
    PROGRESS_MSG=""
}


#
# Erasure progress shown in terminal
#
erasureProgress() {

    # Progress for every erasure
    for file in "$TMP_PROGRESS"/*_progress.txt; do

        # Get disk name from file name removing '_progress.txt'
        disk=$(basename "$file" | sed 's/_progress\.txt//')
        # Progress is received from the file
        progress=$(cat "$file")
        # Append progress message to variable
        PROGRESS_MSG+="Status: $progress\n"
    done

    # Display progress
    echo "Erasure progress:"
    echo -e "$PROGRESS_MSG"

    # Initialize message variable
    PROGRESS_MSG=""

    sleep 0.4
}

#!/bin/bash

# Initialize variables
TMP_PROGRESS="lib/files/tmp/progress"
CHOSEN_DISKS_DESC="lib/files/tmp/chosenDisksDesc.txt"
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

        # Get disk name from file name removing '_progress.txt'
        disk=$(basename "$file" | sed 's/_progress\.txt//')

        # Get disk size
        size=$(awk -v d="$disk" '$1 == d {print $2}' "$CHOSEN_DISKS_DESC")

        # Progress is received from the file
        progress=$(sed 's/^/    /' "$file") # THIS HAS AN ISSUE NULL BYTE SUBSTITUDE

        # Append progress message to variable
        PROGRESS_MSG+="$disk ($size):\n$progress\n\n"
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

        # Get disk size
        size=$(awk -v d="$disk" '$1 == d {print $2}' "$CHOSEN_DISKS_DESC")

        # If file not yet generated, print staring erasure, otherwise print progress
        if [ ! -e "$file" ]; then
            progress="Starting erasure.."
        else
            # Progress is received from the file
            #progress=$(awk '{ print "    " $0 }' "$file") # THIS HAS NULL SUBSTITUDE ISSUE
            progress=$(tr -d '\000' < "$file" | awk '{ print "    " $0 }') # POTENTIAL FIX [seems to be working]
        fi
        
        # Append progress message to variable
        PROGRESS_MSG+="$disk ($size):\n$progress\n\n"
    done

    # Display progress
    echo "Erasure progress of $ASSET_TAG:"
    echo "=========================="
    echo ""
    echo ""
    echo -e "$PROGRESS_MSG"

    # Initialize message variable
    PROGRESS_MSG=""

}

#!/bin/bash
TMP_REPORTS="lib/files/tmp/reports/"
TMP_VERIFICATION="lib/files/tmp/verificationStatus/"

reportGenerator() {
    REPORT=lib/files/reports/"$ASSET_TAG".txt
    i=1;

    echo "Asset Tag: $ASSET_TAG" >> "$REPORT"
    echo "Serial Number: $(dmidecode -t system | awk '/Serial Number:/ {print $3}')" >> "$REPORT"
    echo "Date and Time (BIOS): $(date +"%d-%m-%Y %H:%M")" >> "$REPORT"
    echo "" >> "$REPORT"
    echo "" >> "$REPORT"

    # Place verification into disks' report file
    for file in "$TMP_VERIFICATION"*; do
        # Get file name (remove directory)
        base=$(basename "$file")
        # Get current disk name
        disk=$(echo "$base" | awk -F'_' '{print $1}')
        # Report for the disk
        diskReport="$TMP_REPORTS""$disk""_tmp_report.txt"

        # If disk report exists, add verification status to it
        if [[ -f "$diskReport" ]]; then
            cat "$file" >> "$diskReport"
        fi
        cat "$diskReport"
    done

    for file in "$TMP_REPORTS"*; do
        echo "Disk $i: " >> "$REPORT"
        cat "$file" >> "$REPORT"
        echo "" >> "$REPORT"
        echo "" >> "$REPORT"
        ((i++))
    done

    echo "" >> "$REPORT"
    echo "" >> "$REPORT"
    echo "Specifications:" >> "$REPORT"
    echo "" >> "$REPORT"
    lshw -short >> "$REPORT"

}




#!/bin/bash


#
# Disks are verified by reading each bit in disks. The disks are expected to be 0.
# If non 0 bit is found then verification fails.
#
verifyErasure() {
    disk="$1"

    #default 64M
    bs="$2"
    

    TMP_NON_ZERO_BITS="lib/files/tmp/verifyFiles/"$disk"_nonZeroBits.txt"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
    TMP_REPORT="lib/files/tmp/reports/"$disk"_tmp_report.txt"
    VERIFICATION_STATUS="lib/files/tmp/verificationStatus/"$disk"_verificationStatus.txt" # SEEMS TO BE UNUSED, USING IT IN DD FOR TESTING
    TMP_FIFO=$(mktemp -u)

    # Initialize tmp file
    > "$TMP_NON_ZERO_BITS"
    > "$TMP_PROGRESS"
    > "$VERIFICATION_STATUS"
    mkfifo "$TMP_FIFO"

    #THIS WORKS
    #dd if=/dev/$disk bs="$bs" status=progress > "$TMP_FIFO" 2> "$TMP_PROGRESS" & 

    #TESTING TO FIX DUPLICATE FILE READ
    dd if=/dev/$disk bs="$bs" status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
    dd_pid=$!

    #
    # Show verification progress
    #
    status() {
        while kill -0 "$dd_pid" 2>/dev/null; do
            currentProgress=$(tr -d '\000' < "$VERIFICATION_STATUS" | awk 'END {print}')
            echo "$currentProgress" > "$TMP_PROGRESS"
            sleep 5
        done
    }

    # Gives user verification status updates
    status &
    status_pid=$!

    od -An -t x1 < "$TMP_FIFO" | while read -r line; do
        hex_part=$(echo "$line" | awk '{print $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17}')
        if  echo "$hex_part" | grep -q '[^0]'; then
            echo "$line" > "$TMP_NON_ZERO_BITS"
            # Stop verifying process
            if kill -0 "$dd_pid" 2>/dev/null; then
                kill "$dd_pid" 2>/dev/null
            fi
            break
        fi
        sleep 0.1
    done

    # If status updates are still active then kill
    kill "$status_pid" 2>/dev/null

    # If TMP_NON_ZERO_BITS is empty, then erasure is a SUCCESS
    if [[ ! -s "$TMP_NON_ZERO_BITS" ]]; then
        ERASURE_VERIFICATION="SUCCESS [disk is zeroed]"
        result="Verification of ${disk}: $ERASURE_VERIFICATION"

        echo "$result" > "$TMP_PROGRESS"
        echo "$result" >> "$TMP_REPORT"
        echo "$result" > "$VERIFICATION_STATUS"

        rm "$TMP_FIFO"
        export ERASURE_VERIFICATION
        return 0

    # If TMP_NON_ZERO_BITS is NOT empty, then erasure is a FAIL
    else
        ERASURE_VERIFICATION="FAIL [data found]"
        result="Verification of ${disk}: $ERASURE_VERIFICATION"

        echo "$result" > "$TMP_PROGRESS"
        echo "$result" >> "$TMP_REPORT"
        echo "$result" > "$VERIFICATION_STATUS"

        rm "$TMP_FIFO"
        export ERASURE_VERIFICATION
        return 1
    fi

}

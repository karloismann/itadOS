#!/bin/bash


#
# Disks are verified by reading each bit in disks. The disks are expected to be 0.
# If non 0 bit is found then verification fails.
# @Param $1 disk to verify
# @Param $2 Block size for dd
# @Param $3 verification type (full, partial, skip snapshot_before, snapshot_after, compare_snapshots)
# @Returns 0 if verification success
# @Returns 1 if verification failed
# @Returns 2 if verification skipped
# @Returns 4 if sha comparison fail
# @Returns 5 if sha comparison success
# @Returns 6 if quick check success
# @Returns 7 if quick check fail
#
verifyErasure() {
    disk="$1"

    #default 64M
    # This needs to be 1M for partial verification to function correctly
    bs="$2"

    # full, partial, skip, quick_check, snapshot_before, snapshot_after, compare_snapshots
    scan="$3"
    

    TMP_NON_ZERO_BITS="lib/files/tmp/verifyFiles/"$disk"_nonZeroBits.txt"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
    DISK_FILES="lib/files/tmp/chosenDisks/"
    BEFORE_CRYPTO="${DISK_FILES}/${disk}/before_crypto.txt"
    AFTER_CRYPTO="${DISK_FILES}/${disk}/after_crypto.txt"
    VERIFICATION_STATUS="lib/files/tmp/verificationStatus/"$disk"_verificationStatus.txt"

    # Initialize tmp file
    > "$TMP_NON_ZERO_BITS"
    > "$TMP_PROGRESS"
    > "$VERIFICATION_STATUS"

    #
    # Show verification progress
    # @Param $1 pid of verification in progress
    #
    status() {
        pid="$1"
        while kill -0 "$pid" 2>/dev/null; do
            currentProgress=$(tr -d '\000' < "$VERIFICATION_STATUS" | awk 'END {print}')
            echo "$currentProgress" > "$TMP_PROGRESS"
            sleep 2
        done
    }

    #
    # Checks for 0 bits. If non 0 bit found then verification failed
    #
    checkBits() {
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
    }

    case "$scan" in
        full)

            TMP_FIFO=$(mktemp -u)
            mkfifo "$TMP_FIFO"

            checkBits &
            check_pid=$!

            dd if=/dev/$disk bs="$bs" status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
            dd_pid=$!

            # Gives user verification status updates
            status "$dd_pid" &
            status_pid=$!

            wait "$dd_pid"

            # If status updates are still active then kill
            kill "$status_pid" 2>/dev/null
            kill "$check_pid" 2>/dev/null
            rm "$TMP_FIFO"
        ;;
        partial)

            sizeInBytes=$(getDiskSizeInBytes "$disk")
            # Convert size to MB
            sizeInBytes=$(( "$sizeInBytes" / 1048576 ))

            firstBlock=$(( sizeInBytes / 10 ))
            lastBlocks=$(( sizeInBytes - firstBlock ))

            TMP_FIFO=$(mktemp -u)
            mkfifo "$TMP_FIFO"


            checkBits &
            check_pid=$!

            dd if=/dev/$disk bs="$bs" count="$firstBlock" status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
            dd_pid=$!

            status "$dd_pid" &
            status_pid=$!
            wait "$dd_pid"
            
            # If status updates are still active then kill
            kill "$status_pid" 2>/dev/null
            kill "$check_pid" 2>/dev/null
            rm "$TMP_FIFO"

            TMP_FIFO=$(mktemp -u)
            mkfifo "$TMP_FIFO"

            checkBits &
            check_pid=$!

            dd if=/dev/$disk bs="$bs" skip="$lastBlocks" count="$firstBlock" status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
            dd_pid=$!

            status "$dd_pid" &
            status_pid=$!
            wait "$dd_pid"

            # If status updates are still active then kill
            kill "$status_pid" 2>/dev/null
            kill "$check_pid" 2>/dev/null
            rm "$TMP_FIFO"
        ;;
        sampling)
            
            MiB=1048576
			local sizeInBytes="$(getDiskSizeInBytes "$disk")"
			local sections="$(( $RANDOM % ( 1500 - 1000 + 1 ) + 1000 ))"
			local sectionSize="$(( (sizeInBytes / sections) / $MiB ))"
			local percentage="$(( $RANDOM % ( 20 - 10 + 1 ) + 10 ))"
			local count="$(( (sectionSize * $percentage) / 100 ))"
			if (( $count == 0 )); then
				count=1
			fi
			local sectionSizeMinusCount="$(( $sectionSize - $count ))"
			local areaProcessed=0
			
			TMP_FIFO=$(mktemp -u)
			mkfifo "$TMP_FIFO"
			
			checkBits &
            check_pid=$!
			
			for (( i=0; i<$sections; i++ )); do
				skip="$(( $RANDOM % (sectionSizeMinusCount - 0 + 1) + 0 ))"
				skip="$(( $areaProcessed + $skip ))"
				dd if=/dev/$disk bs=1M skip="$skip" count="$count" status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
				dd_pid=$!
				
				status "$dd_pid" &
				status_pid=$!
				wait "$dd_pid"
				areaProcessed="$(( areaProcessed + sectionSize ))"
					
			done

				
			# If status updates are still active then kill
			kill "$status_pid" 2>/dev/null
			kill "$check_pid" 2>/dev/null
			rm "$TMP_FIFO"
           
        ;;
        skip)

            ERASURE_VERIFICATION="SKIPPED"
            result="Verification of ${disk} $(cat ${DISK_FILES}${disk}/serial.txt) $(cat ${DISK_FILES}${disk}/model.txt): $ERASURE_VERIFICATION"

            echo "$result" > "$TMP_PROGRESS"
            echo "$ERASURE_VERIFICATION" > "${DISK_FILES}${disk}/verification.txt"
            echo "$result" > "$VERIFICATION_STATUS"
            return 2
        ;;
        quick_check)

            TMP_FIFO=$(mktemp -u)
            mkfifo "$TMP_FIFO"

            checkBits &
            check_pid=$!

            dd if=/dev/$disk bs="$bs" count=2 status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
            local dd_pid=$!

            # Gives user verification status updates
            status "$dd_pid" &
            status_pid=$!

            wait "$dd_pid"

            # If status updates are still active then kill
            kill "$status_pid" 2>/dev/null
            kill "$check_pid" 2>/dev/null
            rm "$TMP_FIFO"
        ;;
        snapshot_before)

            TMP_FIFO=$(mktemp -u)
            mkfifo "$TMP_FIFO"

            > "$BEFORE_CRYPTO"

            dd if=/dev/$disk bs="$bs" count=2 status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
            local dd_pid=$!

            od -An -t x1 < "$TMP_FIFO" | while read -r line; do
                local hex_part=$(echo "$line" | awk '{print $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17}')
                echo "$hex_part" >> "$BEFORE_CRYPTO"
            done

            # Gives user verification status updates
            status "$dd_pid" &
            status_pid=$!

            wait "$dd_pid"

            # If status updates are still active then kill
            kill "$status_pid" 2>/dev/null
            rm "$TMP_FIFO"
        ;;
        snapshot_after)

            TMP_FIFO=$(mktemp -u)
            mkfifo "$TMP_FIFO"

            > "$AFTER_CRYPTO"

            dd if=/dev/$disk bs="$bs" count=2 status=progress > "$TMP_FIFO" 2> "$VERIFICATION_STATUS" & 
            local dd_pid=$!

            od -An -t x1 < "$TMP_FIFO" | while read -r line; do
                local hex_part=$(echo "$line" | awk '{print $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17}')
                echo "$hex_part" >> "$AFTER_CRYPTO"
            done

            # Gives user verification status updates
            status "$dd_pid" &
            status_pid=$!

            wait "$dd_pid"

            # If status updates are still active then kill
            kill "$status_pid" 2>/dev/null
            rm "$TMP_FIFO"
        ;;
        compare_snapshots)
            shaBefore=$(echo sha256sum "$BEFORE_CRYPTO" | awk '{print $1}')
            shaAfter=$(echo sha256sum "$AFTER_CRYPTO" | awk '{print $1}')

            if [ "$shaBefore" != "$shaAfter" ]; then
                return 5
            else
                return 4
            fi
        ;;

    esac


    # If TMP_NON_ZERO_BITS is empty, then erasure is a SUCCESS
    if [[ ! -s "$TMP_NON_ZERO_BITS" ]]; then
        if [[ "$scan" == "full" ]]; then
            ERASURE_VERIFICATION="SUCCESS [full]"
            result="Verification of ${disk} $(cat ${DISK_FILES}${disk}/serial.txt) $(cat ${DISK_FILES}${disk}/model.txt): $ERASURE_VERIFICATION"
        elif [[ "$scan" == "partial" ]]; then
            ERASURE_VERIFICATION="SUCCESS [partial]"
            result="Verification of ${disk} $(cat ${DISK_FILES}${disk}/serial.txt) $(cat ${DISK_FILES}${disk}/model.txt): $ERASURE_VERIFICATION"
        elif [[ "$scan" == "quick_check" ]]; then
            return 6
        else
            ERASURE_VERIFICATION="SKIPPED"
            result="Verification of ${disk} $(cat ${DISK_FILES}${disk}/serial.txt) $(cat ${DISK_FILES}${disk}/model.txt): $ERASURE_VERIFICATION"

            echo "$result" > "$TMP_PROGRESS"
            echo "$ERASURE_VERIFICATION" > "${DISK_FILES}${disk}/verification.txt"
            echo "$result" > "$VERIFICATION_STATUS"
            return 2
        fi

        echo "$result" > "$TMP_PROGRESS"
        echo "$ERASURE_VERIFICATION" > "${DISK_FILES}${disk}/verification.txt"
        echo "$result" > "$VERIFICATION_STATUS"
        return 0

    # If TMP_NON_ZERO_BITS is NOT empty, then erasure is a FAIL
    else


        if [[ "$scan" == "full" ]]; then
            ERASURE_VERIFICATION="FAIL [full]"
            result="Verification of ${disk} $(cat ${DISK_FILES}${disk}/serial.txt) $(cat ${DISK_FILES}${disk}/model.txt): $ERASURE_VERIFICATION"
        elif [[ "$scan" == "partial" ]]; then
            ERASURE_VERIFICATION="FAIL [partial]"
            result="Verification of ${disk} $(cat ${DISK_FILES}${disk}/serial.txt) $(cat ${DISK_FILES}${disk}/model.txt): $ERASURE_VERIFICATION"
        elif [[ "$scan" == "quick_check" ]]; then
            return 7
        fi


        echo "$result" > "$TMP_PROGRESS"
        echo "$ERASURE_VERIFICATION" > "${DISK_FILES}${disk}/verification.txt"
        echo "$result" > "$VERIFICATION_STATUS"
        return 1
    fi

}

#
# Checks if disk is filled with 0 pattern, if not then fills disk with 0
# This can be turned on or off from config file by modifying 'CHECK_ZERO_PATTERN_AND_OVERWRITE'
# Else it will check for zero pattern, if zero pattern not found then adds a warning message.
# @Param $1: disk to check
#
quickCheckAndOverwrite() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"
    local disk_warning="${DISK_FILES}${disk}/warnings.txt"

    if [[ "$CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF" == "on" ]]; then
        # Check if disk is filled with 0 pattern
        verifyErasure "$disk" "1M" "quick_check"
        local quick_verify_code=$?

        # If disk is not filled with 0 pattern then fill it.
        if [[ "$quick_verify_code" == 7 ]]; then
            overwriteZero "$disk"
            echo "${disk} Non zero pattern found. Owerwrote disk with zero pattern." >> "$disk_warning"
            echo " Overwrite [Zero]" >> "${DISK_FILES}${disk}/method.txt"
        fi
    else
        verifyErasure "$disk" "1M" "quick_check"
        local quick_verify_code=$?

        if [[ "$quick_verify_code" == 7 ]]; then
            echo "${disk} Non zero pattern found during pattern check." >> "$disk_warning"
        fi
    fi
}

#!/bin/bash

#
# Check if disk supports smart tools
# @Param $1 disk to check
# @Returns 0 if supports 1 if does not support
#
healthSupported() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    test=$(smartctl -H /dev/"$disk" | awk -v disk="$disk" -F ':' '$0 ~ "/dev/" disk {print $2}' | xargs)

    if [[ "$test" == "Unable to detect device type" || "$test" == "No such device" || "$test" == *"Unknown"* ]]; then
        echo "Health: Not Supported" >> "${DISK_FILES}${disk}/health.txt"
        return 1
    else
        return 0
    fi
}


#
# Get results of last disk health scan. places the result into ${DISK_FILES}${disk}/health.txt
# @Param $1: disk to check
#
diskHealthResult() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"

    echo $(smartctl -H /dev/"$disk" | awk '/result/{print}') >> "${DISK_FILES}${disk}/health.txt"
}

#
# Checks progress of disk health
# @Param $1: disk to check
#
checkHealthProgress() {
    local disk="$1"
    local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
    local progress
    local duration

    while true; do

        progress=$(smartctl -c /dev/${disk} | awk '/remaining/' | xargs)

        if [[ "$progress" != *%* ]]; then
            break
        fi

        if [[ "$SMART_TEST_CONF" == "long" ]]; then
            duration=$(smartctl -c /dev/${disk} | awk -F ':' '/Extended/{getline; print $2}' | xargs)
        elif [[ "$SMART_TEST_CONF" == "short" ]]; then
            duration=$(smartctl -c /dev/${disk} | awk -F ':' '/Short/{getline; print $2}' | xargs)
        fi

        echo "Testing disk health.. ${progress} estimated duration: ${duration}" > "$TMP_PROGRESS"

        sleep 2
    done

}


#
# Get results of last disk health scan. places the result into ${DISK_FILES}${disk}/health.txt
# @Param $1 disk to test
# @Param $2 disk test (short, long)
#
startTest() {
    local disk="$1"
    local test="$2"
    
    smartctl -t "$test" /dev/"$disk"

    sleep 2

    checkHealthProgress "$disk"
}

#
# Run health check and place results into health.txt file
# @Param $1 disk to test
#
diskHealth() {
    local disk="$1"
    local DISK_FILES="lib/files/tmp/chosenDisks/"
    local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

    if [[ "$SMART_TEST_CONF" != "skip" ]]; then

        healthSupported "$disk"
        local exit_code=$?

        if [[ "$exit_code" -ne 0 ]]; then
            echo "$(cat ${DISK_FILES}${disk}/verification.txt)" > "$TMP_PROGRESS"
            return
        else
            startTest "$disk" "$SMART_TEST_CONF"
            diskHealthResult "$disk"
            echo "$(cat ${DISK_FILES}${disk}/verification.txt)" > "$TMP_PROGRESS"
        fi
    
    elif [[ "$SMART_TEST_CONF" == "skip" ]]; then
        # Health messages need to have a colon
        echo "status: Skipped" >> "${DISK_FILES}${disk}/health.txt"
    fi
}
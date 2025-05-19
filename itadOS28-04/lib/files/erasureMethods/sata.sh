#!/bin/bash

#
# SATA operations
#


# Check if all sectors are accessible
# Param $1 sector to compare
# Param $2 sector to compare
compareSectors() {
	local sector1="$1"
	local sector2="$2"

	if [[ "$sector1" == "$sector2" ]]; then
		return 0
	else 
		return 1
	fi
	
}

# Get disk sector information
# Param $1 disk to process
# Param $2:
# current - get currently available sectors
# max - get all sectors
# combined - get currentSectors/maxSectors
# dco_max - get DCO sectors
getSataDiskSectors() {
    local disk="$1"
    local sectors="$2"

    case "$sectors" in
        current)
            local current_sectors=$(hdparm -N "/dev/${disk}" | awk '/max/{print $4}' | awk  -F '/' '{print $1}' | tr -d ',')
            echo "$current_sectors"
        ;;
        max)
	        local max_sectors=$(hdparm -N "/dev/${disk}" | awk '/max/{print $4}' | awk  -F '/' '{print $2}' | tr -d ',')
            echo "$max_sectors"
        ;;
        dco_max)
            local dco_max=$(hdparm --dco-identify "/dev/${disk}" |awk '/max sectors/ {print $4}' | xargs | tr -d ',')
            echo "$dco_max"
        ;;
		combined)
            local current_sectors=$(hdparm -N "/dev/${disk}" | awk '/max/{print $4}' | awk  -F '/' '{print $1}' | tr -d ',')
			local max_sectors=$(hdparm -N "/dev/${disk}" | awk '/max/{print $4}' | awk  -F '/' '{print $2}' | tr -d ',')
            echo "${current_sectors}/${max_sectors}"
        ;;
        *)
            echo "Unknown command: $sectors"
            return 1
        ;;
    esac

}

#
# Detect and clear HPA area
# Param $1 disk to check
#
checkAndRemoveHPA() {
	local disk="$1"
	local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	local DISK_FILES="lib/files/tmp/chosenDisks/${disk}/HPA.txt"

	local MESSAGE_HPA

	local current_sectors=$(getSataDiskSectors "$disk" current)
	local max_sectors=$(getSataDiskSectors "$disk" max)

	# If HPA detected then erase, otherwise let user know HPA is not used
	if [[ "$current_sectors" != "$max_sectors" ]]; then
		hdparm --yes-i-know-what-i-am-doing -N"p${max_sectors}" /dev/${disk} > "${TMP_PROGRESS}" 2>&1
		local exit_code=$?

		# Recheck currently available sectors
		current_sectors=$(getSataDiskSectors "$disk" current)

		case "$exit_code" in
			0|16)
				if compareSectors "$current_sectors" "$max_sectors"; then
					MESSAGE_HPA="Erasure SUCCESS"
				else
					MESSAGE_HPA="Erasure FAIL"
				fi
				echo "$MESSAGE_HPA" > "${DISK_FILES}"
				;;
			1|*)
				MESSAGE_HPA="Erasure FAIL"
				echo "$MESSAGE_HPA" > "${DISK_FILES}"
				;;
		esac

	else
		MESSAGE_HPA="Not detected"
		echo "$MESSAGE_HPA" > "${DISK_FILES}"
		return 0
	fi

}


#
# Detect and clear DCO area
# Param $1 disk to check
#
checkAndRemoveDCO() {
	local disk="$1"
	local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	local DISK_FILES="lib/files/tmp/chosenDisks/${disk}/DCO.txt"

	local MESSAGE_DCO

	local max_sectors=$(getSataDiskSectors "$disk" max)
	local dco_max=$(getSataDiskSectors "$disk" dco_max)
	

	# If unreadable or fake DCO value, skip
	if [[ -z "$dco_max" || "$dco_max" == "1" ]]; then
        MESSAGE_DCO="Support not available or unreadable."
		echo "$MESSAGE_DCO" > "${DISK_FILES}"
		return 2
    fi

	# Compare real vs DCO
	if (( max_sectors < dco_max )); then
		sudo hdparm --yes-i-know-what-i-am-doing --dco-restore /dev/"$disk"
		local exit_code=$?

		# Recheck currently available sectors
		local dco_max=$(getSataDiskSectors "$disk" dco_max)

		case "$exit_code" in
			0)	
				if compareSectors "$max_sectors" "$dco_max"; then
        			MESSAGE_DCO="Restore SUCCESS"
					echo "$MESSAGE_DCO" > "${DISK_FILES}"
					return 0
				else
					MESSAGE_DCO="Restore FAIL"
					echo "$MESSAGE_DCO" > "${DISK_FILES}"
        			return 1
				fi
			;;

			*)
        		MESSAGE_DCO="Restore FAIL"
				echo "$MESSAGE_DCO" > "${DISK_FILES}"
        		return 1
				;;
		esac

    else
        MESSAGE_DCO="Not enabled"
		echo "$MESSAGE_DCO" > "${DISK_FILES}"
        return 0
    fi

}


#
# Checks if disk is frozen
# @Param $1 disk to check
# @Returns FROZEN status
#
isDiskFrozen() {
    local disk="$1"

    local frozen=$(hdparm -I /dev/"$disk" | awk '/frozen/{print $1}')
    case "$frozen" in
        frozen)
			echo "yes"
            return 1
            ;;
        not)
			echo "no"
            return 0
            ;;
        *)
			echo "UNKNOWN"
            return 1
            ;;
    esac

}

# 
# Suspends device for X seconds.
# @Param $1 amount of seconds for suspend
#
suspend() {
    local sec=$1
    rtcwake -m mem -s "$sec"
}

#
# Check if disk is frozen. If frozen then automatic suspension and wakes in 10 secs. tries 3 times
# @Param $1 disk to wake
#
wakeFromFrozen() {

    local disk="$1"

    if [[ $(isDiskFrozen "$disk") != "no" ]]; then
        for (( i=0; i<=2; i++ )); do
            suspend 10

            if [[ $(isDiskFrozen "$disk") == "no" ]]; then
                break
            fi
        done
    fi
}

#
# Checks if secure erase is supported
# @Param $1 chosen disk
# @Returns 'yes' if secure erase is supported and 'no' if it is not
#
supportsSecureErase() {
	local disk="$1"

	local supportsCommand=$(hdparm -I /dev/"$disk" | awk '/supported/ {print $1}' | awk 'NR==2 {print}')
	if [[ "$supportsCommand" == "supported:" || "$supportsCommand" == "supported" ]];
	then
		echo "yes"
        return 0
	else
		echo "no"
        return 1
	fi

}

#
# Checks if block erase is supported
# @Param $1 chosen disk
# @Returns 'yes' if block erase is supported and 'no' if it is not
#
supportsBlockErase() {
	local disk="$1"

	local supportsCommand=$(hdparm -I /dev/"$disk" | awk '/BLOCK/ {print}')

	if [[ -z "$supportsCommand" ]];
	then
		echo "no"
        return 1
	else
		echo "yes"
        return 0
	fi


}

#
# Secure erase for HDD and SSD
# @Param $1 disk to erase
#
secureErase() {
	local disk="$1"
	local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

	local pass="erasure"
	echo "Secure Erase in progress... this may take a few hours." > "$TMP_PROGRESS"
	hdparm --user-master u --security-set-pass "$pass" /dev/"$disk"

	hdparm --user-master u --security-erase "$pass" /dev/"$disk"
	local exit_code=$?

	case "$exit_code" in
		0)
			echo "Secure Erase completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "Secure Erase failed." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "Secure Erase failed." > "$TMP_PROGRESS"
			return 1
			;;
	esac
}

#
# block erase SSD
# @Param $1 disk to erase
#
blockErase() {
	local disk="$1"
	local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

	hdparm --yes-i-know-what-i-am-doing --sanitize-block-erase /dev/"$disk"
	local exit_code=$?

	local status
	local percentage

	while [[ "$percentage" != "Operation" ]];
	do
		percentage=$(hdparm --sanitize-status /dev/"$disk" | awk 'NR==6 {gsub(/[\(\)%]/, ""); print $3}')
		status=$(hdparm --sanitize-status /dev/"$disk")
		echo "Erasure in progress.. $percentage" > "$TMP_PROGRESS"
		if [[ "$percentage" == "Operation" ]]
		then
			echo "Disk erased using Block Erase" > "$TMP_PROGRESS"
			echo "$status" > "$TMP_PROGRESS"
			break;
		fi
		sleep 1
	done

	case "$exit_code" in
		0)
			echo "Block Erase completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "Block Erase failed." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "Block Erase failed." > "$TMP_PROGRESS"
			return 1
			;;
	esac
}

#
# Overwrites drive with 2 passes, first pass with random data and second pass zeroes the disk
# @Param $1 disk to erase
#
overwriteRandomZero() {
	local disk="$1"
	local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	local method="Overwrite [Random > Zero]"

	shred -n 1 -z -v /dev/"$disk" 2>&1 | while read -r line; do
        echo "$line" > "$TMP_PROGRESS"
    done

	echo "Erasure completed. (Overwrite [Random > Zero])" > "$TMP_PROGRESS"
}


#
# Overwrites drive with 0
# @Param $1 disk to erase
#
overwriteZero() {
	local disk="$1"
	local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	local method="Overwrite [Zero]"

	shred -n 0 -z -v /dev/"$disk" 2>&1 | while read -r line; do
        echo "$line" > "$TMP_PROGRESS"
    done

	echo "Erasure completed. (Overwrite [Zero])" > "$TMP_PROGRESS"

}


            
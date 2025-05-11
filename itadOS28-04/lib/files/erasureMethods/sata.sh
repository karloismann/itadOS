#!/bin/bash

#
# SATA operations
#


#
# Detect and clear HPA area
# Param $1 disk to check
#
checkAndRemoveHPA() {
	disk="$1"
	TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	TMP_REPORT="lib/files/tmp/reports/"$disk"_tmp_report.txt"

	MESSAGE_HPA=""

	current_sectors=$(hdparm -N /dev/${disk} | awk '/max/{print $4}' | awk  -F '/' '{print $1}' | tr -d ',')
	max_sectors=$(hdparm -N /dev/${disk} | awk '/max/{print $4}' | awk  -F '/' '{print $2}' | tr -d ',')

	# If HPA detected then erase, otherwise let user know HPA is not used
	if [[ "$current_sectors" != "$max_sectors" ]]; then
		hdparm -N "p${max_sectors}" /dev/${disk} > "${TMP_PROGRESS}" 2>&1
		exit_code=$?

		case "$exit_code" in
			0)
				MESSAGE_HPA="HPA erased"
				echo "$MESSAGE_HPA" > "${TMP_PROGRESS}"
				;;
			1)
				MESSAGE_HPA="HPA failed to erase"
				echo "$MESSAGE_HPA" > "${TMP_PROGRESS}"
				;;
			*)
				MESSAGE_HPA="HPA failed to erase"
				echo "$MESSAGE_HPA" > "${TMP_PROGRESS}"
				;;
		esac

	else
		MESSAGE_HPA="HPA not detected"
		echo "$MESSAGE_HPA" > "${TMP_PROGRESS}"
		return 0
	fi

	export MESSAGE_HPA
}


#
# Detect and clear DCO area
# Param $1 disk to check
#
checkAndRemoveDCO() {
	disk="$1"
	TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	TMP_REPORT="lib/files/tmp/reports/"$disk"_tmp_report.txt"

	MESSAGE_DCO=""

	max_sectors=$(hdparm -N /dev/${disk} | awk '/max/{print $4}' | awk  -F '/' '{print $2}' | tr -d ',')
	dco_max=$(hdparm --dco-identify "/dev/${disk}" |awk '/Maximum LBA/ {print $3}' | tr -d ',')

	# If unreadable or fake DCO value, skip
	if [[ -z "$dco_max" || "$dco_max" == "1" ]]; then
        MESSAGE_DCO="DCO support not available or unreadable."
		echo "$MESSAGE_DCO" > "${TMP_PROGRESS}"
		return 1
    fi

	# Compare real vs DCO
	if (( max_sectors < dco_max )); then
		sudo hdparm --yes-i-know-what-i-am-doing --dco-restore /dev/"$disk"
		exit_code=$?

		case "$exit_code" in
			0)
        		MESSAGE_DCO="DCO has been restored."
				echo "$MESSAGE_DCO" > "${TMP_PROGRESS}"
        		return 0
				;;

			*)
        		MESSAGE_DCO="DCO restore failed."
				echo "$MESSAGE_DCO" > "${TMP_PROGRESS}"
        		return 1
				;;
		esac

    else
        MESSAGE_DCO="DCO not enabled."
		echo "$MESSAGE_DCO" > "${TMP_PROGRESS}"
        return 0
    fi

	export MESSAGE_DCO

}


#
# Checks if disk is frozen
# @Param $1 disk to check
# @Returns FROZEN status
#
isDiskFrozen() {
    disk="$1"

    FROZEN=$(hdparm -I /dev/"$disk" | awk '/frozen/{print $1}')
    case "$FROZEN" in
        frozen)
            FROZEN="yes"
            return 1
            ;;
        not)
            FROZEN="no"
            return 0
            ;;
        *)
            FROZEN="UNKNOWN"
            return 1
            ;;
    esac

    export FROZEN
}

# 
# Suspends device for X seconds.
# @Param $1 amount of seconds for suspend
#
suspend() {
    sec=$1
    rtcwake -m mem -s "$sec"
}

#
# Check if disk is frozen. If frozen then automatic suspension and wakes in 10 secs. tries 3 times
# @Param $1 disk to wake
#
wakeFromFrozen() {

    disk="$1"

    if [[ "$FROZEN" != "no" ]]; then
        for (( i=0; i<=2; i++ )); do
            suspend 10

            isDiskFrozen "$disk"
            if [[ "$FROZEN" == "no" ]]; then
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
	disk="$1"

	supportsCommand=$(hdparm -I /dev/"$disk" | awk '/supported/ {print $1}' | awk 'NR==2 {print}')
	if [[ "$supportsCommand" == "supported:" || "$supportsCommand" == "supported" ]];
	then
		SUPPORTS_SECURE_ERASE="yes"
        return 0
	else
		SUPPORTS_SECURE_ERASE="no"
        return 1
	fi

    export SUPPORTS_SECURE_ERASE
}

#
# Checks if block erase is supported
# @Param $1 chosen disk
# @Returns 'yes' if block erase is supported and 'no' if it is not
#
supportsBlockErase() {
	disk="$1"

	supportsCommand=$(hdparm -I /dev/"$disk" | awk '/BLOCK/ {print}')

	if [[ -z "$supportsCommand" ]];
	then
		SUPPORTS_BLOCK_ERASE="no"
        return 1
	else
		SUPPORTS_BLOCK_ERASE="yes"
        return 0
	fi

    export SUPPORTS_BLOCK_ERASE

}

#
# Secure erase for HDD and SSD
# @Param $1 disk to erase
#
secureErase() {
	disk="$1"
	TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

	pass="erasure"
	echo "Secure Erase in progress... this may take a few hours." > "$TMP_PROGRESS"
	hdparm --user-master u --security-set-pass "$pass" /dev/"$disk"

	hdparm --user-master u --security-erase "$pass" /dev/"$disk"
	exit_code=$?

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
	disk="$1"
	TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

	hdparm --yes-i-know-what-i-am-doing --sanitize-block-erase /dev/"$disk"
	exit_code=$?

	status=""
	percentage=""

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
	disk="$1"
	TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	method="Overwrite [Random > Zero]"

	shred -n 1 -z -v /dev/"$disk" 2>&1 | while read -r line; do
        echo "$line" > "$TMP_PROGRESS"
    done

	echo "Erasure completed. (Overwrite [Random > Zero])" > "$TMP_PROGRESS"
}

overwriteZero() {
	disk="$1"
	TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
	method="Overwrite [Zero]"

	shred -n 0 -z -v /dev/"$disk" 2>&1 | while read -r line; do
        echo "$line" > "$TMP_PROGRESS"
    done

	echo "Erasure completed. (Overwrite [Zero])" > "$TMP_PROGRESS"

}


            
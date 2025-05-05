#!/bin/bash
#
# SATA operations
#


#
# Checks if disk is frozen
# @Param $1 disk to check
# @Returns FROZEN status
#
isDiskFrozen() {
    disk="$1"

    FROZEN=$(hdparm -I /dev/"$disk" | awk '/frozen/{print $1}')
    case "$frozen" in
        frozen)
            FROZEN="yes"
            return 0
            ;;
        not)
            FROZEN="no"
            return 1
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
            #suspend 10

            #this is for testing REMOVE. uncomment SUSPEND
            echo "is $disk  frozen? : $FROZEN"
            echo "attempting to unfreeze $i"
            #REMOVE THE ABOVE

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
		SECURE_ERASE="$disk DOES support Secure Erase"
        return 0
	else
		SECURE_ERASE="$disk does NOT support Secure Erase"
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
		SUPPORTS_BLOCK_ERASE="$disk does NOT support Block Erase."
        return 1
	else
		SUPPORTS_BLOCK_ERASE="$disk DOES support Block Erase"
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

	pass="erasure"
	hdparm --user-master u --security-set-pass "$pass" /dev/"$disk"
	hdparm --user-master u --security-erase "$pass" /dev/"$disk"
}

#
# block erase SSD
# @Param $1 disk to erase
#
blockErase() {
	disk="$1"

	hdparm --yes-i-know-what-i-am-doing --sanitize-block-erase /dev/"$disk"
	status=""
	percentage=""

	while [ "$percentage" != "Operation" ];
	do
		percentage=$(hdparm --sanitize-status /dev/"$disk" | awk 'NR==6 {gsub(/[\(\)%]/, ""); print $3}')
		status=$(hdparm --sanitize-status /dev/"$disk" | awk 'NR==6 {print $1}')
		echo "$percentage"
		if [[ "$percentage" == "Operation" ]]
		then
			echo "$disk has been WIPED Block Erase"
			echo "$(hdparm --sanitize-status /dev/"$disk")"
			break;
		fi
		sleep 0.5
	done
}

#
# Overwrites drive with 2 passes, first pass with random data and second pass zeroes the disk
# @Param $1 disk to erase
#
overwrite() {
	disk="$1"

	shred -n 1 -z -v /dev/"$disk"
	method="Overwrite"

}

            
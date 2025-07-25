#!/bin/bash

#
# Gives eMMC drive's total sectors
# @param $1 drive
# @returns sectors
#
getEmmcDiskSectors() {
    disk="$1"

	sectors=$(cat /sys/block/"$disk"/size)
	echo "$sectors"

}

#
# Gives eMMC sector size
# @param $1 drive
# @returns sector size
#
getEmmcDiskSectors() {
    disk="$1"

	sectorSize=$(cat /sys/block/"$disk"/queue/hw_sector_size)
	echo "$sectorSize"

}
# Performs an MMC sanitize operation 
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcSanitize() {
    disk="$1"

	mmc sanitize /dev/"$disk" &
	mmc_pid=$!
	wait "$mmc_pid"

	exit_code=$?

	case "$exit_code" in
		0)
			echo "MMC Sanitize completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Sanitize FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Sanitize FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}

# Performs a secure erase across all sectors 
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcSecureErase() {

	disk="$1"
	mmc erase secure-erase 0 $(getEmmcDiskSectors "$disk") /dev/"$disk" &
	mmc_pid=$!
	wait "$mmc_pid"
	
	exit_code=$?

	case "$exit_code" in
		0)
			echo "MMC Secure Erase completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Secure Erase FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Secure Erase FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}


# Performs a secure trim (method 1) 
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcSecureTrim1() {

	drive="$1"
	mmc erase secure-trim1 0 $(getEmmcDiskSectors "$drive") /dev/"$drive" &
	mmc_pid=$!
	wait "$mmc_pid"
	
	exit_code=$?

	case "$exit_code" in
		0)
			echo "MMC Secure Trim (1) completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Secure Trim (1) FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Secure Trim (1) FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}


# Performs a secure trim (method 2) 
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcSecureTrim2() {

	drive="$1"
	mmc erase secure-trim2 0 $(getEmmcDiskSectors "$drive") /dev/"$drive" &
	mmc_pid=$!
	wait "$mmc_pid"
	
	exit_code=$?

	case "$exit_code" in
		0)
			echo "MMC Secure Trim (2) completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Secure Trim (2) FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Secure Trim (2) FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac
}


# Performs a non-secure trim operation
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcTrim() {

	drive="$1"
	mmc erase trim 0 $(getEmmcDiskSectors "$drive") /dev/"$drive" &
	exit_code=$?
	mmc_pid=$!
	wait "$mmc_pid"
	
	exit_code=$?

	case "$exit_code" in
		0)
			echo "MMC Trim completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Trim FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Trim FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}

# Executes a discard operation 
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcDiscard() {

	drive="$1"
	mmc erase discard 0 $(getEmmcDiskSectors "$drive") /dev/"$drive" &
	exit_code=$?
	mmc_pid=$!
	wait "$mmc_pid"
	
	exit_code=$?

	case "$exit_code" in
		0)
			echo "MMC Discard completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Discard FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Discard FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac
}

# Performs a legacy erase operation
# @Param $1 drive
# @returns 0 Success
# @Returns 1 Fail
mmcLegacy() {

	drive="$1"
	mmc erase legacy 0 $(getEmmcDiskSectors "$drive") /dev/"$drive" &
	mmc_pid=$!
	wait "$mmc_pid"
	
	exit_code=$?

		case "$exit_code" in
		0)
			echo "MMC Erase Legacy completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "MMC Erase Legacy FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "MMC Erase Legacy FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}
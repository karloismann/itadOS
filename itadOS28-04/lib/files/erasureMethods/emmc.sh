#!/bin/bash

#
# Gives eMMC drive's total sectors
# @param $1 drive
# @returns sectors
#
getSectors() {
    disk="$1"

	sectors=$(cat /sys/block/"$disk"/size)
	echo "$sectors"

}

mmcSanitize() {
    disk="$1"

	mmc sanitize /dev/"$disk"

}

mmcSecureErase() {

	disk="$1"
	mmc erase secure-erase 0 $(getSectors "$disk") /dev/"$disk"

}

mmcSecureTrim1() {

	drive="$1"
	mmc erase secure-trim1 0 $(getSectors "$drive") /dev/"$drive"

}

mmcSecureTrim2() {

	drive="$1"
	mmc erase secure-trim2 0 $(getSectors "$drive") /dev/"$drive"
}

mmcTrim() {

	drive="$1"
	mmc erase trim 0 $(getSectors "$drive") /dev/"$drive"

}

mmcDiscard() {

	drive="$1"
	mmc erase discard 0 $(getSectors "$drive") /dev/"$drive"
}

mmcLegacy() {

	drive="$1"
	mmc erase legacy 0 $(getSectors "$drive") /dev/"$drive"

}
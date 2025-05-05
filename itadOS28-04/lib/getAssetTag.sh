#!/bin/bash

#
# Asks user for computer's asset tag
# @returns global asset tag
#
getAssetTag() {

	ASSET_TAG=$(whiptail --title "REMOVE itadOS USB" --inputbox "Enter asset tag:" 0 0 3>&1 1>&2 2>&3 3>&-)
	export ASSET_TAG

}

#
# Asks user for computer's asset tag
# User cannot skip asset tag entry
# @Returns global asset tag
#
getAssetTagRQ() {
	getAssetTag
	while [[ "$ASSET_TAG" == "" ]]; do
		whiptail --msgbox "Please enter an asset tag" 0 0
		getAssetTag
		if [[ "$ASSET_TAG" != "" ]]; then
			break
		fi
	done
}
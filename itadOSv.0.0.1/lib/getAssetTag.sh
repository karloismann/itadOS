#!/bin/bash

# If report exists, Give user options
# Delete existing report
# Transfer existing report to USB
# Change Asset tag
ifReportExists() {
    if [[ -f "lib/files/reports/$ASSET_TAG.pdf" ]]; then

		while true; do
			choice=$(whiptail --title "Menu" --menu "Report for ${ASSET_TAG} exists, choose an option:" 15 60 4 \
				"Delete report" "Deletes existing report." \
				"Transfer report" "Transfer the existing reports." \
				"New asset tag" "Choose a new asset tag." 3>&1 1>&2 2>&3)
				local exit_status=$?

			case "$choice" in
				"Delete report")
					rm "lib/files/reports/$ASSET_TAG.pdf"
					rm "lib/files/reports/$ASSET_TAG.xml"
					break
				;;
				"Transfer report")
					reportToUSB
					break
				;;
				"New asset tag")
					getAssetTag
					if [[ -f "lib/files/reports/$ASSET_TAG.pdf" ]]; then
						whiptail --msgbox "$ASSET_TAG alrady exists, please enter another value." 0 0
					else
						break
					fi
				;;
			esac

			if [[ "$exit_status" == 0 && -z "$choice" ]]; then
				whiptail --msgbox "Please select an option." 0 0
			elif [[ "$exit_status" == 1 ]]; then
				whiptail --msgbox "Unable to cancel. Please select an option." 0 0
			fi
		done
    
    fi
}

#
# Asks user for computer's asset tag
# @returns global asset tag
#
getAssetTag() {

	ASSET_TAG=$(whiptail --title "REMOVE itadOS USB" --inputbox "Enter asset tag:" 10 40 3>&1 1>&2 2>&3 3>&-)
	export ASSET_TAG

}

#
# Asks user for computer's asset tag
# User cannot skip asset tag entry
# @Returns global asset tag
#
getAssetTagRQ() {
	getAssetTag
	while true; do

		ifReportExists

		if [[ -z "$ASSET_TAG" ]]; then
			whiptail --msgbox "Please enter an asset tag" 0 0
			getAssetTag
		elif [[ "$ASSET_TAG" != "" ]]; then
			break
		fi
	done
}
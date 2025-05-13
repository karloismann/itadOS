#/bin/bash

usbDrives="lib/files/tmp/usbDrives.txt"
reports="lib/files/reports/"
choice=""

#
# Move reports to USB drive 
#
saveToUSB() {

    while true; do
        mountpoint="$(lsblk -o NAME,MOUNTPOINT | grep "$choice" | awk 'NR==2 {print $2}')"

        if [ -z "$(ls -A "$reports")" ]; then
             whiptail --msgbox "Report failed to generate.." 0 0
             break
        fi

        mv "$reports"* "$mountpoint"
        exit_status=$?
        sleep 2
        sync
            if [[ "$exit_status" -ne 1 ]]; then
                whiptail --msgbox "Report has been saved" 0 0
                umount "$mountpoint"
                break
            else
                whiptail --msgbox "Error occurred.. try again" 0 0
                getUSBDrives
            fi
    done
}

getUSBDrives() {

    # Clear the file before updating.
    > "$usbDrives"

    # Collect the USB drives' info and write it to the file.
    lsblk -d -o NAME,TRAN,MODEL | awk '/usb/{print $1 " " $3 $4}' > "$usbDrives"

    # Prepare options for whiptail
    options=()
    while IFS= read -r line; do
        # Create options in format of "Name Model".
        name=$(echo "$line" | awk '{print $1}')
        model=$(echo "$line" | awk '{print $2}')
        options+=("$name" "$model" OFF)
    done < "$usbDrives"

    # Display whiptail with dynamically updated options.
    choice=$(whiptail --title "Save report. Press 'OK' to refresh USB list" --radiolist \
        "Choose USB drive" 15 50 4 \
        "${options[@]}" 3>&1 1>&2 2>&3)
    exit_status=$?
    if [[ "$exit_status" != "0" ]]; then
        return 1
    fi
}

#
# Gets USB drives, allows user to choose which drive the reports to save to.
# Mounts the selected USB drive and saves the reports to it.
#
reportToUSB() {
    while true; do

        getUSBDrives
        if [ "$exit_status" -eq 1 ]; then
            break
        fi

        if [ "$choice" != "" ]; then
        # Define partition, assuming 1
        partition="/dev/${choice}1"

        # Check if the USB drive is mounted, if not, mount it
        if ! mount | grep -q "$partition"; then
                # Mount the drive if not mounted
                mkdir -p /media/"$choice"
                mount "$partition" /media/"$choice"
                echo "$partition mounted at /media/$choice"
        else
                echo "$partition is already mounted."
        fi
        saveToUSB
        break
        else
            getUSBDrives
        fi

    done

    reset
}



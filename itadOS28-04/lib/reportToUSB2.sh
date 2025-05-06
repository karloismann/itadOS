#/bin/bash

file="files/tmp/usbDrives.txt"
choice=""
exit_status=""

# Function to move files to the USB
saveToUSB() {
    while true; do
        mountpoint="$(lsblk -o NAME,MOUNTPOINT | grep "$choice" | awk 'NR==2 {print $2}')"
        mv lib/files/reports/* "$mountpoint"
	exit_status=$?
	sleep 2
	sync
        if [[ "$exit_status" -ne 1 ]]; then
            whiptail --msgbox "Report has been saved" 0 0
            unmount "$mountpoint"
            break
        else
            whiptail --msgbox "Error occurred.. try again" 0 0
            getUSBDrives
        fi
    done
}

getUSBDrives() {
    # Clear the file before updating
    > "$file"
    # Collect the USB drives info and write it to the file
    lsblk -d -o NAME,TRAN,MODEL | awk '/usb/{print $1 " " $3 $4}' > "$file"

    # Prepare options for whiptail
    options=()
    while IFS= read -r line; do
        # Create options in the format "name model" for each line from the file
        name=$(echo "$line" | awk '{print $1}')
        model=$(echo "$line" | awk '{print $2}')
        options+=("$name" "$model" OFF)
    done < "$file"

    # Display whiptail with the dynamically updated options
    choice=$(whiptail --title "Save report. Press 'OK' to refresh USB list" --radiolist \
        "Choose USB drive" 15 50 4 \
        "${options[@]}" 3>&1 1>&2 2>&3)
    exit_status=$?
}

reportToUSB() {
    while true; do

        getUSBDrives
        if [ "$exit_status" -eq 1 ]; then
            break
        fi

        if [ "$choice" != "" ]; then
        echo "in choice"
        # Find the partition (assuming the partition is the first one, e.g., sdb1)
        partition="/dev/${choice}1"

        # Check if the USB drive is mounted, if not, mount it
        if ! mount | grep -q "$partition"; then
                # Create mount point if it doesn't exist
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



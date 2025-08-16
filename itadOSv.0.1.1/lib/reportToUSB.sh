#/bin/bash

usbDrives="lib/files/tmp/usbDrives.txt"
reports="lib/files/reports/"

#
# Move reports to USB drive 
#
saveToUSB() {
    choice="$1"

    while true; do
        mountpoint="$(lsblk -o NAME,MOUNTPOINT | grep "$choice" | awk 'NR==2 {print $2}')"

        if [ -z "$(ls -A "$reports")" ]; then
             whiptail --msgbox "Report failed to generate.." 0 0
             break
        fi

        mv "${reports}"* "${mountpoint}"
        exit_status=$?
        sleep 2
        sync
            if [[ "$exit_status" -ne 1 ]]; then
                whiptail --msgbox "Report has been saved" 0 0
                umount "$mountpoint"
                break
            else
                whiptail --yesno "Unable to transfer report to USB.. try again?" 0 0
                retry_status=$?

                if [[ "$retry_status" == 0 ]]; then
                    reportToUSB
                fi

                break
            fi
    done
}


#
# Gets USB drives, allows user to choose which drive the reports to save to.
# Mounts the selected USB drive and saves the reports to it.
#
reportToUSB() {

    while true; do
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
        choice=$(whiptail --title "Save report" --radiolist \
            "Choose USB drive (Press 'OK' to refresh list):" 0 0 0 \
            "${options[@]}" 3>&1 1>&2 2>&3)
        exit_status=$?

        if [[ "$exit_status" == "0" && "$choice" == "" ]]; then

            continue

        elif [[ "$exit_status" == "0" && "$choice" != "" ]]; then

             # Define partition, assuming 1
            partition="/dev/${choice}1"

            # Check if the USB drive is mounted, if not, mount it
            if ! mount | grep -q "$partition"; then
                # Mount the drive if not mounted
                mkdir -p /media/"$choice"
                mount "$partition" /media/"$choice"
                mount_status=$?
                if [[ "$mount_status" == 0 ]]; then
                    echo "$partition mounted at /media/$choice"
                
                # If fails to mount AND mount point exists, ask user to delete mount point and try again
                # If USB is not formatted then format
                else
                    whiptail --msgbox "${choice} failed to mount." 0 0

                    if [[ -z $(blkid /dev/${choice}) ]]; then
                        whiptail --yesno "USB disk is not formatted. Do you wish to format it?" 0 0
                        retry_status=$?

                        if [[ "$retry_status" == 0 ]]; then
                            echo "type=7" | sfdisk /dev/${choice}
                            partition_status=$?

                            if [[ "$partition_status" == 0 || "$partition_status" == 1 ]]; then

                                mkfs.exfat /dev/${choice}1
                                format_status=$?

                            fi

                            if [[ "$format_status" == 0 && "$partition_status" == 0 ]]; then
                                whiptail --msgbox "${choice} has been formated to exFAT." 0 0
                                reportToUSB
                                return
                            else

                                whiptail --msgbox "${choice} failed to format." 0 0
                            
                            fi

                        fi
                    
                    fi

                    if [[ -d /media/${choice} ]]; then
                        whiptail --yesno "Mounting point already exists, delete it and try again?" 0 0
                        retry_status=$?

                        if [[ "$retry_status" == 0 ]]; then
                            rm -r /media/${choice}
                            reportToUSB
                            return
                        fi
                    
                    fi

                fi
            else
                echo "$partition is already mounted."
            fi

            saveToUSB "$choice"
            reset
            break

        elif [[ "$exit_status" == "1" ]]; then

            reset
            break

        fi

    done

}




#/bin/bash

usbDrives="lib/files/tmp/usbDrives.txt"
reports="lib/files/reports/"

#
# Move reports to USB drive 
#
exportToUSB() {
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
                    saveReports
                fi

                break
            fi
    done
}


#
# Gets USB drives, allows user to choose which drive the reports to save to.
# Mounts the selected USB drive and saves the reports to it.
#
saveReports() {

    while true; do
        # Clear the file before updating.
        # Collect the USB drives' info and write it to the file.
        > "$usbDrives"
        lsblk -d -o NAME,TRAN,MODEL | awk '/usb/{print $1 " " $3 $4}' > "$usbDrives"

        # Prepare options for whiptail in format of "Name Model".
        options=()
        while IFS= read -r line; do
            name=$(echo "$line" | awk '{print $1}')
            model=$(echo "$line" | awk '{print $2}')
            options+=("$name" "$model" OFF)
        done < "$usbDrives"

        # Option to rescan USB drives
        options+=("Refresh" "Rescan USB drives" ON)

        # Display USB drives.
        choice=$(whiptail --title "Save report" --radiolist \
            "Select USB drive:" 0 0 0 \
            "${options[@]}" 3>&1 1>&2 2>&3)
        exit_status=$?

        # If user pressed Refresh, continue to refresh the list
        if [[ "$exit_status" == "0" && "$choice" == "Refresh" ]]; then

            continue

        # If user made a choice
        elif [[ "$exit_status" == "0" && "$choice" != "" ]]; then

            partition=$(lsblk -ln -o NAME,TYPE "/dev/${choice}" | awk '/part/{print $1}' | awk 'NR==1')

            # Mount USB if not already mounted
            if ! mount | grep -q "$partition"; then

                mkdir -p /media/"$choice"
                mount /dev/"$partition" /media/"$choice"
                mount_status=$?

                if [[ "$mount_status" == 0 ]]; then
                    echo "$partition mounted at /media/$choice"
                
                # If fails to mount AND mount point exists, ask user to delete mount point and try again
                # If USB is not formatted then format
                else
                    whiptail --msgbox "${choice} failed to mount." 0 0

                    if [[ -z $(blkid /dev/${choice}) ]]; then
                        whiptail --yesno "USB is not formatted. Do you wish to format it?" 0 0
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
                                exportToUSB
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
                            exportToUSB
                            return
                        fi
                    
                    fi

                fi
            else
                echo "$partition is mounted."
            fi

            exportToUSB "$choice"
            reset
            break
        
        # User cancelled
        elif [[ "$exit_status" == "1" ]]; then

            reset
            break

        fi

    done

}




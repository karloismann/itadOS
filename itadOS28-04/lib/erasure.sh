#!/bin/bash

#
# Erasure logic
#
#
erasure() {
    disk="$1"
    TMP_REPORT="lib/files/tmp/reports/"$disk"_tmp_report.txt"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

    case "$DISK_TYPE" in
        sata_ssd)

            # Check if disk is frozen. If frozen then automatic suspension and wakes in 10 secs. tries 3 times
            isDiskFrozen "$disk"
            if [[ "$FROZEN" != "no" ]]; then
                wakeFromFrozen "$disk"
            fi

            # Check for supported erasure methods
            supportsSecureErase "$disk"
            supportsBlockErase "$disk"

            if [ "$SUPPORTS_BLOCK_ERASE" == "yes" ] && [ "$SUPPORTS_SECURE_ERASE" == "yes" ]; then
                # Erasure commands
                blockErase "$disk"
                secureErase "$disk"
                # Information for report
                echo "Method: Block Erase > Secure Erase" >> "$TMP_REPORT"
                echo "Tool: $(hdparm -V)" >> "$TMP_REPORT"
            elif [ "$SUPPORTS_BLOCK_ERASE" == "yes" ]; then
                # Erasure commands
                blockErase "$disk"
                # Information for report
                echo "Method: Block Erase" >> "$TMP_REPORT"
                echo "Tool: $(hdparm -V)" >> "$TMP_REPORT"
            elif [ "$SUPPORTS_SECURE_ERASE" == "yes" ]; then
                # Erasure commands
                secureErase "$disk"
                # Information for report
                echo "Method: Secure Erase" >> "$TMP_REPORT"
                echo "Tool: $(hdparm -V)" >> "$TMP_REPORT"
            else
                # Erasure commands
                #overwrite "$disk"
                #REMOVE THIS
                echo "overwriting $disk which is $DISK_TYPE"
                # Information for report
                echo "Method: Overwrite" >> "$TMP_REPORT"
                echo "Tool:" "$(shred --version | awk 'NR==1{print}')" >> "$TMP_REPORT"
            fi
            ;;
        sata_hdd)

            # Check if disk is frozen. If frozen then automatic suspension and wakes in 10 secs. tries 3 times
            isDiskFrozen "$disk"
            if [[ "$FROZEN" != "no" ]]; then
                wakeFromFrozen "$disk"
            fi

            # Check for supported erasure methods
            supportsSecureErase "$disk"
            if [[ "$SUPPORTS_SECURE_ERASE" == "yes" ]]; then
                # Erasure commands
                secureErase "$disk"
                # Information for report
                echo "Method: Secure Erase" >> "$TMP_REPORT"
                echo "Tool: $(hdparm -V)" >> "$TMP_REPORT"
            else
                # Erasure commands
                #overwrite "$disk"
                #REMOVE THIS
                echo "overwriting $disk which is $DISK_TYPE"
                # Information for report
                echo "Method: Overwrite" >> "$TMP_REPORT"
                echo "Tool:" "$(shred --version | awk 'NR==1{print}')" >> "$TMP_REPORT"

                # Progress for tailwind GUI
                # REPLACE WITH ACTUAL DATA
                for (( i=0; i<=30; i++ )); do
                    echo "$disk $i erasure in progress" > "$TMP_PROGRESS"
                    sleep 0.3
                done
            fi
            return 0
            ;;
        nvme)
            if nvmeSupportsCommand "$disk" "Block Erase Sanitize Operation" "8" && nvmeSupportsCommand "$disk" "Crypto Erase Sanitize Operation" "8"; then
                # Erasure commands
                nvmeCryptoSanitize "$disk"
        	    nvmeSanitize "$disk"
			    nvmeFormatSecure "$disk"
                # Information for report
                echo "Method: Crypto Sanitize > Sanitize > Secure Format" >> "$TMP_REPORT"
                echo "Tool:" "$(nvme --version)" >> "$TMP_REPORT"

            elif nvmeSupportsCommand "$disk" "Format NVM" "6" && (nvmeSupportsCommand "$disk" "Crypto Erase S" "6" || nvmeSupportsCommand "$disk" "Crypto Erase N" "6"); then
                # Erasure commands
                nvmeFormatCrypto "$disk"
        	    nvmeFormatSecure "$disk"
                # Information for report
                echo "Method: Crypto Format > Secure Format" >> "$TMP_REPORT"
                echo "Tool:" "$(nvme --version)" >> "$TMP_REPORT"

            elif supportsCommand "$disk" "Block Erase Sanitize Operation" "8"; then
                # Erasure commands
                nvmeSanitize "$disk"
			    nvmeFormatSecure "$disk"
                # Information for report
                echo "Method: Sanitize > Secure Format" >> "$TMP_REPORT"
                echo "Tool:" "$(nvme --version)" >> "$TMP_REPORT"

            elif supportsCommand "$disk" "Format NVM" "6"; then
                # Erasure commands
                nvmeFormatSecure "$disk"
                # Information for report
                echo "Method: Secure Format" >> "$TMP_REPORT"
                echo "Tool:" "$(nvme --version)" >> "$TMP_REPORT"
                # If format fails, fallback to overwrite. This is common for thinkpads with NVMe drives.
                if [[ $? != 0 ]]; then
                    overwrite "$disk"
                    # Information for report
                    echo "Method: Overwrite" >> "$TMP_REPORT"
                    echo "Tool:" "$(shred --version | awk 'NR==1{print}')" >> "$TMP_REPORT"
                fi
            fi
            ;;
        emmc)
            # Get mmc-utils tool information
            tool=$(apt show mmc-utils | awk '/Package:/ {print $2}')
		    version=$(apt show mmc-utils | awk '/Version:/ {print $2}')
            # Erasure commands
            mmcSanitize "$disk"
		    mmcSecureErase "$disk"
		    mmcDiscard "$disk"
		    mmcSecureTrim1 "$disk"
            # Information for report
            echo "Method: Sanitize > Secure Erase > Discard > Secure Trim" >> "$TMP_REPORT"
            echo "Tool:" "$tool $version" >> "$TMP_REPORT"
            ;;
        *)  
            # Erasure commands
            #overwrite "$disk"
            # Information for report
            echo "Method: Overwrite" >> "$TMP_REPORT"
            echo "Tool:" "$(shred --version | awk 'NR==1{print}')" >> "$TMP_REPORT"
            # Progress for tailwind GUI
            # REPLACE WITH ACTUAL DATA
                for (( i=0; i<=10; i++ )); do
                    echo "$disk $i erasure in progress" > "$TMP_PROGRESS"
                    sleep 0.3
                done
            return 0
            ;;
    esac

}


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

            #Check and remove HPA and DCO
            checkAndRemoveHPA "$disk"
            checkAndRemoveDCO "$disk"

            if [[ "$SUPPORTS_BLOCK_ERASE" == "yes" && "$SUPPORTS_SECURE_ERASE" == "yes" ]]; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                blockErase "$disk"
                block_erase_exit_code=$?

                secureErase "$disk"
                secure_erase_exit_code=$?
                
                # Construct Method message for report
                if [[ "$block_erase_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Block Erase"
                else
                    methodMessage="$methodMessage Block Erase [FAILED]"
                fi

                if [[ "$secure_erase_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Secure Erase"
                else
                    methodMessage="$methodMessage > Secure Erase [FAILED]"
                fi

                # Log hdparm tool used
                toolMessage="$toolMessage $(hdparm -V)"
                
                #Fallback Random > Zero
                if [[ "$block_erase_exit_code" != "0" && "$secure_erase_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi

                # Information for report
                echo "$MESSAGE_HPA" >> "$TMP_REPORT"
                echo "$MESSAGE_DCO" >> "$TMP_REPORT"
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"

            elif [[ "$SUPPORTS_BLOCK_ERASE" == "yes" ]]; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                blockErase "$disk"
                block_erase_exit_code=$?

                # Construct Method message for report
                if [[ "$block_erase_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Block Erase"
                else
                    methodMessage="$methodMessage Block Erase [FAILED]"
                fi

                # Log hdparm tool used
                toolMessage="$toolMessage $(hdparm -V)"

                #Fallback Random > Zero
                if [[ "$block_erase_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi

                # Information for report
                echo "$MESSAGE_HPA" >> "$TMP_REPORT"
                echo "$MESSAGE_DCO" >> "$TMP_REPORT"
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"

            elif [[ "$SUPPORTS_SECURE_ERASE" == "yes" ]]; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                secureErase "$disk"
                secure_erase_exit_code=$?

                # Construct Method message for report
                if [[ "$secure_erase_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Secure Erase"
                else
                    methodMessage="$methodMessage Secure Erase [FAILED]"
                fi

                # Log hdparm tool used
                toolMessage="$toolMessage $(hdparm -V)"

                #Fallback Random > Zero
                if [[ "$secure_erase_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi

                # Information for report
                echo "$MESSAGE_HPA" >> "$TMP_REPORT"
                echo "$MESSAGE_DCO" >> "$TMP_REPORT"
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"
            else
                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                overwriteRandomZero "$disk"
                toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"

                # Information for report
                echo "$MESSAGE_HPA" >> "$TMP_REPORT"
                echo "$MESSAGE_DCO" >> "$TMP_REPORT"
                echo "Method:, Overwrite [Random > Zero]" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"
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

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                secureErase "$disk"
                secure_erase_exit_code=$?

                # Construct Method message for report
                if [[ "$secure_erase_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Secure Erase"
                else
                    methodMessage="$methodMessage Secure Erase [FAILED]"
                fi
                
                # Log hdparm tool used
                toolMessage="$toolMessage $(hdparm -V)"

                #Fallback Random > Zero
                if [[ "$secure_erase_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi


                # Information for report
                echo "$MESSAGE_HPA" >> "$TMP_REPORT"
                echo "$MESSAGE_DCO" >> "$TMP_REPORT"
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"

            else

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                overwriteRandomZero "$disk"
                
                methodMessage="$methodMessage Overwrite [Random > Zero]"
                toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"

                # Information for report
                echo "$MESSAGE_HPA" >> "$TMP_REPORT"
                echo "$MESSAGE_DCO" >> "$TMP_REPORT"
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"
            fi
            return 0
            ;;

        nvme)

            if nvmeSupportsCommand "$disk" "sanitize" && nvmeSupportsCommand "$disk" "cryptoSanitize"; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                nvmeCryptoSanitize "$disk"
                nvmeCrypto_sanitize_exit_code=$?

        	    nvmeSanitize "$disk"
                nvme_sanitize_exit_code=$?

			    nvmeFormatSecure "$disk"
                nvmeFormat_secure_exit_code=$?

                # Construct Method message for report
                if [[ "$nvmeCrypto_sanitize_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Crypto Sanitize"
                else
                    methodMessage="$methodMessage Crypto Sanitize [FAILED]"
                fi

                if [[ "$nvme_sanitize_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Sanitize"
                else
                    methodMessage="$methodMessage > Sanitize [FAILED]"
                fi

                if [[ "$nvmeFormat_secure_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Secure Format"
                else
                    methodMessage="$methodMessage > Secure Format [FAILED]"
                fi

                # Log NVMe cli tool used
                toolMessage="$toolMessage $(nvme --version)"

                #Fallback Random > Zero
                if [[ "$nvmeCrypto_sanitize_exit_code" != "0" && "$nvme_sanitize_exit_code" != "0" && "$nvmeFormat_secure_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi

                # Information for report
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"

                

            elif nvmeSupportsCommand "$disk" "cryptoSanitize"; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                nvmeCryptoSanitize "$disk"
                nvmeCrypto_sanitize_exit_code=$? "$disk"
                
                # Construct Method message for report
                if [[ "$nvmeCrypto_sanitize_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Crypto Sanitize"
                    # Log NVMe cli tool used
                    toolMessage="$toolMessage $(nvme --version)"
                    
                    # Zero pass after Crypto Secure Format
                    overwriteZero "$disk"
                    methodMessage="$methodMessage > Overwrite [Zero]"
                    # Log overwrite tool used
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"

                else

                    methodMessage="$methodMessage Crypto Sanitize [FAILED]"
                    # Log NVMe cli tool used
                    toolMessage="$toolMessage $(nvme --version)"

                fi

                #Fallback Random > Zero
                if [[ "$nvmeCrypto_sanitize_exit_code" != "0" ]]; then

                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"

                fi


                # Information for report
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"



            elif nvmeSupportsCommand "$disk" "secureFormat" && nvmeSupportsCommand "$disk" "cryptoSecureFormat"; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                nvmeFormatCrypto "$disk"
                nvmeFormat_crypto_exit_code=$?

        	    nvmeFormatSecure "$disk"
                nvmeFormat_secure_exit_code=$?
                
                # Construct Method message for report
                if [[ "$nvmeFormat_crypto_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Crypto Format"
                else
                    methodMessage="$methodMessage Crypto Format [FAILED]"
                fi

                if [[ "$nvmeFormat_secure_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Secure Format"
                else
                    methodMessage="$methodMessage > Secure Format [FAILED]"
                fi

                # Log NVMe cli tool used
                toolMessage="$toolMessage $(nvme --version)"

                #Fallback Random > Zero
                if [[ "$nvmeFormat_crypto_exit_code" != "0" && "$nvmeFormat_secure_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi


                # Information for report
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"


            elif nvmeSupportsCommand "$disk" "sanitize"; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                nvmeSanitize "$disk"
                nvme_sanitize_exit_code=$?

			    nvmeFormatSecure "$disk"
                nvmeFormat_secure_exit_code=$?

                # Construct Method message for report
                if [[ "$nvme_sanitize_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Sanitize"
                else
                    methodMessage="$methodMessage Sanitize [FAILED]"
                fi

                if [[ "$nvmeFormat_secure_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Secure Format"
                else
                    methodMessage="$methodMessage > Secure Format [FAILED]"
                fi

                # Log NVMe cli tool used
                toolMessage="$toolMessage $(nvme --version)"

                #Fallback Random > Zero
                if [[ "$nvme_sanitize_exit_code" != "0" && "$nvmeFormat_secure_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi

                # Information for report
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"


                elif nvmeSupportsCommand "$disk" "cryptoSecureFormat"; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                nvmeFormatCrypto "$disk"
                nvmeFormat_crypto_exit_code=$?
                
                # Construct Method message for report
                if [[ "$nvmeFormat_crypto_exit_code" == "0" ]]; then

                    methodMessage="$methodMessage Crypto Format"
                    # Log NVMe cli tool used
                    toolMessage="$toolMessage $(nvme --version)"
                    
                    # Zero pass after Crypto Secure Format
                    overwriteZero "$disk"
                    methodMessage="$methodMessage > Overwrite [Zero]"
                    # Log overwrite tool used
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"

                else

                    methodMessage="$methodMessage Crypto Format [FAILED]"
                    # Log NVMe cli tool used
                    toolMessage="$toolMessage $(nvme --version)"

                fi


                #Fallback Random > Zero
                if [[ "$nvmeFormat_crypto_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi


                # Information for report
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"


            elif nvmeSupportsCommand "$disk" "secureFormat"; then

                methodMessage="Method:, "
                toolMessage="Tool:, "

                # Erasure commands
                nvmeFormatSecure "$disk"
                nvmeFormat_secure_exit_code=$?

                # Construct Method message for report
                if [[ "$nvmeFormat_secure_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Secure Format"
                else
                    methodMessage="$methodMessage Secure Format [FAILED]"
                fi
                
                # Log NVMe cli tool used
                toolMessage="$toolMessage $(nvme --version)"

                #Fallback Random > Zero
                if [[ "$nvmeFormat_secure_exit_code" != "0" ]]; then
                    overwriteRandomZero "$disk"
                    methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                    toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"
                fi

                # Information for report
                echo "$methodMessage" >> "$TMP_REPORT"
                echo "$toolMessage" >> "$TMP_REPORT"
            fi
            ;;

        emmc)

            # Get mmc-utils tool information
            tool=$(apt show mmc-utils | awk '/Package:/ {print $2}')
		    version=$(apt show mmc-utils | awk '/Version:/ {print $2}')
            mmcTool="${tool} ${version}"

            methodMessage="Method:, "
            toolMessage="Tool:, "

            # Erasure commands
            mmcSanitize "$disk"
            mmcSanitize_exit_code=$?

		    mmcSecureErase "$disk"
            mmcSecure_erase_exit_code=$?

		    mmcDiscard "$disk"
            mmcDiscard_exit_code=$?

		    mmcSecureTrim1 "$disk"
            mmcSecure_trim1_exit_code=$?

            # Construct Method message for report
            if [[ "$mmcSanitize_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage Sanitize"
                else
                    methodMessage="$methodMessage Sanitize [FAILED]"
            fi

            if [[ "$mmcSecure_erase_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Secure Erase"
                else
                    methodMessage="$methodMessage > Secure Erase [FAILED]"
            fi

            if [[ "$mmcDiscard_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Discard"
                else
                    methodMessage="$methodMessage > Discard [FAILED]"
            fi

            if [[ "$mmcSecure_trim1_exit_code" == "0" ]]; then
                    methodMessage="$methodMessage > Secure Trim (1)"
                else
                    methodMessage="$methodMessage > Secure Trim (1) [FAILED]"
            fi
            
            # Log mmc-util tool used
            toolMessage="${toolMessage} ${mmcTool}"

            # If the MMC tools succeed, Zero disk, otherwise random + zero
            if [[ "$mmcSecure_erase_exit_code" == "0" ||  "$mmcSanitize_exit_code" == "0" ]]; then
                shredTool=$(shred --version | awk 'NR==1{print}')
                overwriteZero "$disk"

                methodMessage="$methodMessage > Overwrite [Zero]"
                toolMessage="${toolMessage} ${shredTool}"
            else
                shredTool=$(shred --version | awk 'NR==1{print}')
                overwriteRandomZero "$disk"

                methodMessage="$methodMessage > Fallback Overwrite [Random > Zero]"
                toolMessage="${toolMessage} ${shredTool}"
            fi

            # Information for report
            echo "$methodMessage" >> "$TMP_REPORT"
            echo "$toolMessage" >> "$TMP_REPORT"
            ;;

        *)  

            methodMessage="Method:, "
            toolMessage="Tool:, "

            # Erasure commands
            overwriteRandomZero "$disk"
            methodMessage="$methodMessage Overwrite [Random > Zero]"
            toolMessage="$toolMessage $(shred --version | awk 'NR==1{print}')"

            # Information for report
            echo "$methodMessage" >> "$TMP_REPORT"
            echo "$toolMessage" >> "$TMP_REPORT"
            return 0
            ;;
    esac

}




#!/bin/bash

#Information for report if erasure is skipped
# @Param $1: Disk to process
erasureSkip() {

    local disk="$1"

    methodMessage="N/A"
    toolMessage="N/A"
    specMessage="N/A"

    echo "${disk}: Erasure skipped." >> "${DISK_FILES}${disk}/warnings.txt"
    echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

}


#
# Erasure logic
# @Param $1: Disk to process
# @Param $2: Erasure standard, set in config file
#
erasure() {
    local disk="$1"
    local standard="$2"
    local DISK_FILES="lib/files/tmp/chosenDisks/"
    local TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"
    local type="$(cat ${DISK_FILES}${disk}/type.txt | xargs)"

    local methodMessage
    local toolMessage
    local specMessage


    # Warn if verification does not meet standards [ Change if quick sampling implemented ] 
    if [[ ( "$VERIFICATION_CONF" == "skip" || "$VERIFICATION_CONF" == "partial" ) &&  "$ERASURE_SPEC_CONF" != "skip" ]]; then
        echo "${disk}: Full verification required to meet Purge or Clear standards." >> "${DISK_FILES}${disk}/warnings.txt"
    fi

    case "$type" in
        "SATA SSD")
			
            case "$standard" in
				"purge")

					# Add Crypto Erase
					
					
					# Block Erase
					if supportsBlockErase "$disk"; then
						
						# Erasure
						sata_ssd_purge_block_erase "$disk"
						purge_exit_code=$?
						
						# Check if disk is zero filled, if up to Purge standard
						if [[ "$purge_exit_code" == 0 ]]; then
							quickCheckAndOverwrite "$disk"
						fi

                    else

                        methodMessage="N/A"
                        toolMessage="N/A"
                        specMessage="N/A"

                        echo "${disk}: Purge not supported. Erasure not performed." >> "${DISK_FILES}${disk}/warnings.txt"
                        echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
                        echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
                        echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

					fi
					;;
					
				"clear")
					
					if supportsSecureErase "$disk"; then
						if ! sata_ssd_clear_secure_erase "$disk"; then
                            sata_ssd_clear_overwrite "$disk" "two"
                        fi
					else
						sata_ssd_clear_overwrite "$disk" "two"
					fi
					
					# Check if disk is zero filled, if not then fill
					quickCheckAndOverwrite "$disk"
					;;
				
				"auto")
					
					# Block Erase (Purge to Clear)
					if supportsBlockErase "$disk"; then
						
						# Erasure
						sata_ssd_purge_block_erase "$disk"
						purge_exit_code=$?
						
						# Check if disk is zero filled, if up to Purge standard, if not continue to Clear standard
						if [[ "$purge_exit_code" == 0 ]]; then
							quickCheckAndOverwrite "$disk"
							
						else
							if supportsSecureErase "$disk"; then
                                if ! sata_ssd_clear_secure_erase "$disk"; then
                                    sata_ssd_clear_overwrite "$disk" "two"
                                fi
                            else
                                sata_ssd_clear_overwrite "$disk" "two"
                            fi
							
							# Check if disk is zero filled, if not then fill
							quickCheckAndOverwrite "$disk"
						fi
						
					# Clear
					else
                        echo "${disk}: Purge not supported." >> "${DISK_FILES}${disk}/warnings.txt"
                        
						if supportsSecureErase "$disk"; then
                            if ! sata_ssd_clear_secure_erase "$disk"; then
                                sata_ssd_clear_overwrite "$disk" "two"
                            fi
                            else
                                sata_ssd_clear_overwrite "$disk" "two"
                        fi
							
						# Check if disk is zero filled, if not then fill
						quickCheckAndOverwrite "$disk"
					fi
					;;

                "skip")

                    erasureSkip "$disk"

                ;;


            esac
        ;;
					

        "SATA HDD")
                case "$standard" in
                    "purge")

                        # Add Crypto Erase

                        if supportsSecureErase "$disk"; then
                            sata_hdd_purge_secure_erase "$disk"
                        else

                            methodMessage="N/A"
                            toolMessage="N/A"
                            specMessage="N/A"

                            echo "${disk}: Purge not supported. Erasure not performed." >> "${DISK_FILES}${disk}/warnings.txt"
                            echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
                            echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
                            echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"
                        fi

                        # Check if disk is zero filled, if not then fill
					    quickCheckAndOverwrite "$disk"
                    ;;

                    "clear")
                    
						sata_hdd_clear_overwrite "$disk" "two"
					
                        # Check if disk is zero filled, if not then fill
                        quickCheckAndOverwrite "$disk"
                    ;;

                    "auto")

                        if supportsSecureErase "$disk"; then
                            if ! sata_hdd_purge_secure_erase "$disk"; then
                                sata_hdd_clear_overwrite "$disk" "two"
                            fi
					    else
						    sata_hdd_clear_overwrite "$disk" "two"
					    fi
					
                        # Check if disk is zero filled, if not then fill
                        quickCheckAndOverwrite "$disk"
                    ;;

                    "skip")

                        erasureSkip "$disk"
                    
                    ;;
                esac
        ;;
            

        "NVME")
            case "$standard" in
                "purge")

                    local purgeSupport="no"

                    while true; do
                        if nvmeSupportsCommand "$disk" "cryptoSanitize"; then
                            
                            purgeSupport="yes"

                            nvme_purge_crypto_erase "$disk"
                            cryptoErase_exit_code=$?

                            if [[ "$cryptoErase_exit_code" == 0 ]]; then
                                break
                            else
                                continue
                            fi

                        fi

                        if nvmeSupportsCommand "$disk" "cryptoSecureFormat"; then

                            purgeSupport="yes"

                            nvme_purge_crypto_format "$disk"
                            cryptoFormat_exit_code=$?

                            if [[ "$cryptoFormat_exit_code" == 0 ]]; then
                                break
                            else
                                continue
                            fi
                        
                        fi

                        if nvmeSupportsCommand "$disk" "sanitize"; then
                            
                            purgeSupport="yes"

                            nvme_purge_sanitize "$disk"
                            sanitize_exit_code=$?

                            if [[ "$sanitize_exit_code" == 0 ]]; then
                                break
                            else
                                continue
                            fi

                        fi

                        if nvmeSupportsCommand "$disk" "secureFormat"; then
                            purgeSupport="yes"

                            nvme_purge_format "$disk"
                            format_exit_code=$?

                            break


                        fi

                        if [[ "$purgeSupport" == "no" ]]; then
                            
                            methodMessage="N/A"
                            toolMessage="N/A"
                            specMessage="N/A"

                            echo "${disk}: Purge not supported. Erasure not performed." >> "${DISK_FILES}${disk}/warnings.txt"
                            echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
                            echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
                            echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"

                            break

                        else

                            # Check if disk is zero filled, if not then fill
                            quickCheckAndOverwrite "$disk"
                        
                        fi

                    done
                ;;

                "clear")

                    nvme_clear_overwrite "$disk" "two"

                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "auto")

                    local purgeSupport="no"

                    while true; do
                        if nvmeSupportsCommand "$disk" "cryptoSanitize"; then
                            
                            purgeSupport="yes"

                            nvme_purge_crypto_erase "$disk"
                            cryptoErase_exit_code=$?

                            if [[ "$cryptoErase_exit_code" == 0 ]]; then
                                break
                            else
                                continue
                            fi

                        fi

                        if nvmeSupportsCommand "$disk" "cryptoSecureFormat"; then

                            purgeSupport="yes"

                            nvme_purge_crypto_format "$disk"
                            cryptoFormat_exit_code=$?

                            if [[ "$cryptoFormat_exit_code" == 0 ]]; then
                                break
                            else
                                continue
                            fi
                        
                        fi

                        if nvmeSupportsCommand "$disk" "sanitize"; then
                            
                            purgeSupport="yes"

                            nvme_purge_sanitize "$disk"
                            sanitize_exit_code=$?

                            if [[ "$sanitize_exit_code" == 0 ]]; then
                                break
                            else
                                continue
                            fi

                        fi

                        if nvmeSupportsCommand "$disk" "secureFormat"; then
                            purgeSupport="yes"

                            nvme_purge_format "$disk"
                            format_exit_code=$?

                            break


                        fi

                        if [[ "$purgeSupport" == "no" ]]; then

                            echo "${disk}: Purge not supported." >> "${DISK_FILES}${disk}/warnings.txt"

                            nvme_clear_overwrite "$disk" "two"

                            # Check if disk is zero filled, if not then fill
                            quickCheckAndOverwrite "$disk"

                            break

                        else

                            # Check if disk is zero filled, if not then fill
                            quickCheckAndOverwrite "$disk"
                        
                        fi

                    done

                ;;

                "skip")

                    erasureSkip "$disk"
                    
                ;;

            esac
        ;;

        "eMMC")

            case "$standard" in
                "purge")
                
                    methodMessage="N/A"
                    toolMessage="N/A"
                    specMessage="N/A"

                    echo "${disk}: Purge not supported. Erasure not performed." >> "${DISK_FILES}${disk}/warnings.txt"
                    echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
                    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
                    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"
                ;;

                "clear")

                    emmc_clear "$disk" "one"
					
                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "auto")

                    echo "${disk}: Purge not supported." >> "${DISK_FILES}${disk}/warnings.txt"

                    emmc_clear "$disk" "one"
					
                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "skip")

                    erasureSkip "$disk"
                    
                ;;

            esac
        ;;

        "MMC")

            case "$standard" in

                "purge")

                    methodMessage="N/A"
                    toolMessage="N/A"
                    specMessage="N/A"

                    echo "${disk}: Purge not supported. Erasure not performed." >> "${DISK_FILES}${disk}/warnings.txt"
                    echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
                    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
                    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"
                ;;

                "clear")

                    emmc_clear "$disk" "two"
					
                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "auto")

                    echo "${disk}: Purge not supported." >> "${DISK_FILES}${disk}/warnings.txt"

                    emmc_clear "$disk" "two"
					
                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "skip")

                    erasureSkip "$disk"
                    
                ;;

            esac
        ;;

        *)

            case "$standard" in
            
                "purge")

                    echo "${disk}: Disk type is not supported." >> "${DISK_FILES}${disk}/warnings.txt"

                    methodMessage="N/A"
                    toolMessage="N/A"
                    specMessage="N/A"

                    echo "${disk}: Purge not supported. Erasure not performed." >> "${DISK_FILES}${disk}/warnings.txt"
                    echo "$methodMessage" >> "${DISK_FILES}/${disk}/method.txt"
                    echo "$toolMessage" >> "${DISK_FILES}/${disk}/tool.txt"
                    echo "$specMessage" >> "${DISK_FILES}/${disk}/spec.txt"
                ;;

                "clear")

                    echo "${disk}: Disk type is not supported." >> "${DISK_FILES}${disk}/warnings.txt"

                    not_supported_clear "$disk" "two"
					
                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "auto")
                
                    echo "${disk}: Disk type is not supported." >> "${DISK_FILES}${disk}/warnings.txt"
                    echo "${disk}: Purge not supported." >> "${DISK_FILES}${disk}/warnings.txt"

                    not_supported_clear "$disk" "two"
					
                    # Check if disk is zero filled, if not then fill
                    quickCheckAndOverwrite "$disk"
                ;;

                "skip")

                    erasureSkip "$disk"
                    
                ;;

            esac
        ;;

    esac

}




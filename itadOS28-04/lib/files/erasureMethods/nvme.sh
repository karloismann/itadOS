#!/bin/bash


#
# Gives NVME disk sectors
# @param $1 drive
# @returns sectors
#
getNvmeDiskSectors() {
	disk="$1"

	sectors=$(nvme id-ns /dev/${disk} | awk '/nsze/{print $3}')
	sectors=$(($sectors))

	echo "$sectors"
}

# 
# finds support for specific nvme erasure commands
# (sanitize, cryptoSanitize, secureFormat, cryptoSecureFormat)
# @Params $1 device location
# @Params $2 command to look for
# @returns 0 if supported, 1 if not supported
#
nvmeSupportsCommand() {
	disk="$1"
	command="$2"

	case "$command" in

		sanitize)
			commandSupported=$(nvme id-ctrl /dev/"${disk}" | awk '/sanicap/ {print $3}')

			if (( ($commandSupported & 0x6) != 0 )); then
				NVME_SUPPORTS_COMMAND="$disk supports Sanitize"
        		return 0
			else
				NVME_SUPPORTS_COMMAND="$disk does not support Sanitize"
        		return 1
			fi
			;;

		cryptoSanitize)
			commandSupported=$(nvme id-ctrl /dev/"${disk}" | awk '/sanicap/{print $3}')

			if (( ($commandSupported & 0x1) == 1 )); then
				NVME_SUPPORTS_COMMAND="$disk supports Crypto Sanitize"
        		return 0
			else
				NVME_SUPPORTS_COMMAND="$disk does not support Crypto Sanitize"
        		return 1
			fi
			;;

		secureFormat)
			commandSupported=$(nvme id-ctrl /dev/"${disk}" | awk '/fna/{print $3}')

			if (( ($commandSupported & 0x1) == 1 )); then
				NVME_SUPPORTS_COMMAND="$disk supports Secure Format"
        		return 0
			else
				NVME_SUPPORTS_COMMAND="$disk does not Secure Format"
        		return 1
			fi
			;;

		cryptoSecureFormat)
			commandSupported=$(nvme id-ctrl /dev/"${disk}" | awk '/fna/{print $3}')

			if (( ($commandSupported & 0x2) == 2 )); then
				NVME_SUPPORTS_COMMAND="$disk supports Crypto Secure Format"
        		return 0
			else
				NVME_SUPPORTS_COMMAND="$disk does not Crypto Secure Format"
        		return 1
			fi
			;;
		
		*)
			echo "Unknown command sent"
			;;

		esac

    export NVME_SUPPORTS_COMMAND
}

#
# Nvme crypto sanitize
# @Params $1 disk to erase
#
nvmeCryptoSanitize() {
    disk="$1"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

	nvme sanitize /dev/"$disk" -a 4
    exit_code=$?

	while true;
        do
        	sanitizeStatus=$(nvme sanitize-log /dev/"$disk" | awk 'NR==2 {print $5}')
            echo "Erasing, please wait.. "$sanitizeStatus"" > "$TMP_PROGRESS"
            sleep 1
            if [[ "$sanitizeStatus" == "0x1" ]];then
				#echo "Erasure completed. (NVMECryptoSanitize)" > "$TMP_PROGRESS"
                break;
            fi
    done

    case "$exit_code" in
		0)
			echo "NVME Crypto Sanitize completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "NVME Crypto Sanitize FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "NVME Crypto Sanitize FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac
}

#
# Nvme sanitize
# @Params $1 disk to erase
#
nvmeSanitize() {
    disk="$1"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

	nvme sanitize /dev/"$disk" -a 2
    exit_code=$?

	while true; do
        sanitizeStatus=$(nvme sanitize-log /dev/"$disk" | awk 'NR==2 {print $5}')
        echo "Erasing (NVME Sanitize), please wait.. "$sanitizeStatus"" > "$TMP_PROGRESS"
        sleep 1
        if [[ "$sanitizeStatus" == "0x1" ]]; then
            #echo "Erasure completed. (NVMESanitize)" > "$TMP_PROGRESS"
            break;
        fi
    done

    case "$exit_code" in
		0)
			echo "NVME Sanitize completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "NVME Sanitize FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "NVME Sanitize FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac
}

#
# Nvme format -s1
# @Params $1 disk to erase
#
nvmeFormatSecure() {
    disk="$1"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

    echo "Erasing (NVME Format), please wait..." > "$TMP_PROGRESS"

	nvme format /dev/"$disk" -s 1 --force
    exit_code=$?

    case "$exit_code" in
		0)
			echo "NVME Format completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "NVME Format FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "NVME Format FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}

#
# Nvme format -s2
# @Params $1 disk to erase
#
nvmeFormatCrypto() {
    disk="$1"
    TMP_PROGRESS="lib/files/tmp/progress/"$disk"_progress.txt"

    echo "Erasing (NVME Crypto Format), please wait..." > "$TMP_PROGRESS"

	nvme format /dev/"$disk" -s 2 --force
    exit_code=$?

    case "$exit_code" in
		0)
			echo "NVME Crypto Format completed." > "$TMP_PROGRESS"
			return 0
			;;
		1)
			echo "NVME Crypto Format FAILED." > "$TMP_PROGRESS"
			return 1
			;;
		*)
			echo "NVME Crypto Format FAILED." > "$TMP_PROGRESS"
			return 1
			;;
	esac

}
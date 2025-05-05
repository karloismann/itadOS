#!/bin/bash

# 
# finds support for specific nvme erasure commands
# format -s 1: $1 = $disk $2 = Format NVM, $3 = 6
# format -s 2: $1 = $disk $2 = Crypto Erase S, $3 = 6
# sanitize: $1 = $disk $2 = Block Erase Sanitize Operations, $3 = 8
# crypto sanitize: $1 = $disk $2 = Crypto Erase Sanitize Operation, $3 = 8
# @Params $1 device location
# @Params $2 command to look for
# @Params $3 column that contains the desired value
# @returns 0 if supported, 1 if not supported
#
nvmeSupportsCommand() {
	disk="$1"
	command="$2"
	column="$3"

	commandSupported=$(nvme id-ctrl -H /dev/"$disk" | awk -v command="$command" -v column="$column" '$0 ~ command {print $column; exit}')

	if [[ "$commandSupported" == "Supported" ]]
	then
		NVME_SUPPORTS_COMMAND="$disk supports $command"
        return 0
	elif [[ "$commandSupported" == "Not" ]]
	then
		NVME_SUPPORTS_COMMAND="$disk does not support $command"
        return 1
	else
		NVME_SUPPORTS_COMMAND="$disk support for $command is unknown"
        return 1
	fi

    export NVME_SUPPORTS_COMMAND
}

#
# Nvme crypto sanitize
# @Params $1 disk to erase
#
nvmeCryptoSanitize() {
    disk="$1"

	nvme sanitize /dev/"$disk" -a 4
	while true;
        do
        	sanitizeStatus=$(nvme sanitize-log /dev/"$disk" | awk 'NR==2 {print $5}')
            echo "Erasing $disk, please wait.."
            sleep 0.1
            if [[ "$sanitizeStatus" == "0x1" ]];then
				echo "Erasure completed. (NVMECryptoSanitize)"
                break;
            fi
    done       
}

#
# Nvme sanitize
# @Params $1 disk to erase
#
nvmeSanitize() {
    disk="$1"

	nvme sanitize /dev/"$disk" -a 2
	while true; do
        sanitizeStatus=$(nvme sanitize-log /dev/"$disk" | awk 'NR==2 {print $5}')
        echo "Erasing $disk, please wait.."
        sleep 1
        if [[ "$sanitizeStatus" == "0x1" ]]; then
            echo "Erasure completed. (NVMESanitize)"
            break;
        fi
    done
}

#
# Nvme format -s1
# @Params $1 disk to erase
#
nvmeFormatSecure() {
    disk="$1"

	nvme format /dev/"$disk" -s 1 --force
}

#
# Nvme format -s2
# @Params $1 disk to erase
#
nvmeFormatCrypto() {
    disk="$1"

	nvme format /dev/"$disk" -s 2 --force
}
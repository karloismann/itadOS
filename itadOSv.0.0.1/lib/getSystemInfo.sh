#!/bin/bash

getSerialNumber() {
	SERIAL_NUMBER="$(dmidecode -t system | awk '/Serial Number:/ {print $3}' 2>/dev/null)"

	if [[ "$SERIAL_NUMBER" == "" ]]; then
		SERIAL_NUMBER=$(cat /proc/cpuinfo | awk -F ':' '/Serial/{print $2}')
	fi
	
	if [[ "$SERIAL_NUMBER" == "" ]]; then
		SERIAL_NUMBER="UNKNOWN"
	fi

	export SERIAL_NUMBER
}

getModelVendor() {

	SYSTEM_MANUFACTURER="$(dmidecode -s system-manufacturer 2>/dev/null)"

	if [[ "$SYSTEM_MANUFACTURER" == "" ]]; then
		SYSTEM_MANUFACTURER=$(cat /sys/class/dmi/id/sys_vendor)
	fi
	
	if [[ "$SYSTEM_MANUFACTURER" == "" ]]; then
		SYSTEM_MANUFACTURER="UNKNOWN"
	fi

	export SYSTEM_MANUFACTURER

}

getModelName() {

	MODEL_NAME="$(dmidecode -s system-product-name 2>/dev/null)"

	if [[ "$MODEL_NAME" == "" ]]; then
		MODEL_NAME=$(cat /proc/cpuinfo | awk -F ':' '/Model/{print $2}')
	fi
	
	if [[ "$MODEL_NAME" == "" ]]; then
		MODEL_NAME="UNKNOWN"
	fi

	export MODEL_NAME

}

getCPUModel() {

	CPU_MODEL="$(cat /proc/cpuinfo | awk -F ':' '/model name/{print $2; exit}')"

	if [[ "$CPU_MODEL" == "" ]]; then
		CPU_MODEL=$(cat /proc/cpuinfo | awk -F ':' '/Model/{print $2}')
	fi
	
	if [[ "$CPU_MODEL" == "" ]]; then
		CPU_MODEL="UNKNOWN"
	fi

	export CPU_MODEL

}

getRAMSize() {

	RAM_SIZE="$(free --giga -h | awk '/Mem/{print $2}')"

	if [[ "$RAM_SIZE" == "" ]]; then
		RAM_SIZE="UNKNOWN"
	fi

	export RAM_SIZE

}

getGPUModel() {

	GPU_MODEL="$(lspci | awk -F ':' '/VGA/{print $3}')"

	if [[ "$GPU_MODEL" == "" ]]; then
		GPU_MODEL="UNKNOWN"
	fi

	export GPU_MODEL

}

getDGPUModel() {

	DGPU_MODEL="$(lspci | awk -F ':' '/3D/{print $3}')"

	if [[ "$DGPU_MODEL" == "" ]]; then
		DGPU_MODEL="N/A"
	fi

	export DGPU_MODEL

}

getBatteryHealth() {

	if [[ -d /sys/class/power_supply/BAT0 ]]; then

		capacity=$(cat /sys/class/power_supply/BAT0/capacity)
		status=$(cat /sys/class/power_supply/BAT0/status)
		present=$(cat /sys/class/power_supply/BAT0/present)

		if [[ "$capacity" == 0 && "$status" == "Not charging" ]]; then
			batteryPresent="no"
			export BATTERY_HEALTH="Missing battery"
			return

		elif [[ "$present" == 0 ]]; then
			batteryPresent="no"
			export BATTERY_HEALTH="Missing battery"
			return

		else
			batteryPresent="yes"
		fi

		if [[ "$batteryPresent" == "yes" ]]; then

			design=$(cat /sys/class/power_supply/BAT0/charge_full_design)
			full=$(cat /sys/class/power_supply/BAT0/charge_full)
			
			# Fallback if charge_* files are not found
			if [[ -z "$design" ]]; then
				design=$(cat /sys/class/power_supply/BAT0/energy_full_design)
			fi

			if [[ -z "$full" ]]; then
				full=$(cat /sys/class/power_supply/BAT0/energy_full)
			fi

			# If battery is displaying 100% and current capacity is 0, then battery info may be false
			if [[ "$capacity" == 0 && "$design" == "$full" ]]; then

				BATTERY_HEALTH=$(( $full * 100 / $design ))
				
				BATTERY_HEALTH="${BATTERY_HEALTH}% (Battery information may be false)"

			# battery health
			elif [[ "$design" != "" && "$full" != "" ]]; then

				BATTERY_HEALTH=$(( $full * 100 / $design ))

				BATTERY_HEALTH="${BATTERY_HEALTH}%"

			# battery health unknown
			else

				BATTERY_HEALTH="UNKNOWN"

			fi


			export BATTERY_HEALTH
		
		fi

	elif [[ $(ls /sys/class/power_supply/*battery* 2>/dev/null) != "" ]]; then
		BATTERY_HEALTH=$(cat /sys/class/power_supply/*battery*/health)

		if [[ "$BATTERY_HEALTH" == "" ]]; then
			BATTERY_HEALTH="UNKNOWN"
		fi

		export BATTERY_HEALTH
	else

		export BATTERY_HEALTH="N/A"
	fi

}


getDiskInfo() {

	local disk_location
	local MIN_DISKS="lib/files/tmp/minDisks.txt"

	if [[ "$FILTER_BOOT_DISK_CONF" == 'on' ]]; then
		disk_location="lib/files/tmp/attachedDisksFilter.txt"
	elif [[ "$FILTER_BOOT_DISK_CONF" == 'off' ]]; then
		disk_location="lib/files/tmp/attachedDisks.txt"
	fi

	> "$MIN_DISKS"

	
	if [[ ! -s "$disk_location" ]]; then
		echo "    <minDisk>" >> "$MIN_DISKS"

		echo "      <minDiskWarning>Disks not detected.</minDiskWarning>" >> "$MIN_DISKS"

		echo "    </minDisk>" >> "$MIN_DISKS"

	else
		while IFS= read -r line; do

			local name=$(echo "$line" | awk '{print $1}' )
			local size=$(echo "$line" | awk '{print $2}' )
			local type=$(echo "$line" | awk '{print toupper($6)}')
			local model=$(echo "$line" | awk '{for(i=7; i<=NF; i++) printf $i " "; print ""}')

			if [[ "$name" == "" ]]; then
				name="UNKNOWN"
			fi

			if [[ "$size" == "" ]]; then
				size="UNKNOWN"
			fi

			if [[ "$type" == "" ]]; then
				if [[ "${name}" == mmc* && "$(cat /sys/block/${name}/removable)" == "0" ]]; then
					type="eMMC"
				elif [[ "${name}" == mmc* && "$(cat /sys/block/${name}/removable)" == "1" ]]; then
					type="MMC"
				else
					type="UNKNOWN"
				fi
			fi

			if [[ "$model" == "" ]]; then
				model="UNKNOWN"
			fi
	
			echo "    <minDisk>" >> "$MIN_DISKS"

			echo "      <minDiskName>${name}</minDiskName>" >> "$MIN_DISKS"
			echo "      <minDiskSize>${size}</minDiskSize>" >> "$MIN_DISKS"
			echo "      <minDiskType>${type}</minDiskType>" >> "$MIN_DISKS"
			echo "      <minDiskModel>${model}</minDiskModel>" >> "$MIN_DISKS"

			echo "    </minDisk>" >> "$MIN_DISKS"
		done < "$disk_location"
	fi

	export MIN_DISKS
}

GetSystemInfo() {

	getSerialNumber
	getModelName
	getModelVendor
	getCPUModel
	getRAMSize
	getGPUModel
	getDGPUModel
	getBatteryHealth
	
}

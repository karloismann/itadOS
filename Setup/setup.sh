#!/bin/bash

#check dependencies
./checkDependencies.sh
config="./itadOSLiveBuild/config/includes.chroot/itadOSv.0.1.1/config.sh"
#sed -i 's/TECHNICIAN_CONF=".*"/TECHNICIAN_CONF="Test"/' config.sh

######################## FORMAT #########################################

set_ERASURE_NAME_CONF() {

        ERASURE_NAME_CONF=$(whiptail --inputbox "Set Erasure name." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|ERASURE_NAME_CONF=".*"|ERASURE_NAME_CONF=\"$ERASURE_NAME_CONF\"|" "${config}"
                whiptail --msgbox "ERASURE_NAME_CONF set to: ${ERASURE_NAME_CONF}" 0 0
                formatMenu
        fi

}

set_ITADOS_VERSION_CONF() {

        ITADOS_VERSION_CONF=$(whiptail --inputbox "Set itadOS version." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|ITADOS_VERSION_CONF=".*"|ITADOS_VERSION_CONF=\"$ITADOS_VERSION_CONF\"|" "${config}"
                whiptail --msgbox "ITADOS_VERSION_CONF set to: ${ITADOS_VERSION_CONF}" 0 0
                formatMenu
        fi

}

set_ERASURE_LOGO_CONF() {

        ERASURE_LOGO_CONF=$(whiptail --inputbox "Set logo location." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|ERASURE_LOGO_CONF=".*"|ERASURE_LOGO_CONF=\"$ERASURE_LOGO_CONF\"|" "${config}"
                whiptail --msgbox "ERASURE_LOGO_CONF set to: ${ERASURE_LOGO_CONF}" 0 0
                formatMenu
        fi

}

set_SYSTEM_SPEC_CONF() {

        while true; do
                SYSTEM_SPEC_CONF=$(whiptail --radiolist "Set specification list style." 0 0 0 \
                        "full" "Detailed specification list" OFF \
                        "min" "Short main specification list" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$SYSTEM_SPEC_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|SYSTEM_SPEC_CONF=".*"|SYSTEM_SPEC_CONF=\"$SYSTEM_SPEC_CONF\"|" "${config}"
                whiptail --msgbox "SYSTEM_SPEC_CONF set to: ${SYSTEM_SPEC_CONF}" 0 0
                formatMenu
        fi

}

formatMenu() {

	choice=$(whiptail --menu "Format Menu" 0 0 0 \
                "Erasure_name" "'name' Erasure Report" \
                "Version_name" "Version of itadOS" \
                "Logo" "Logo location" \
                "System_specs" "Detail of specifications"  3>&1 1>&2 2>&3)
	exitcode=$?

	if [[ "$exitcode" -ne 0 ]]; then
		configMenu
	fi

	case "$choice" in
		Erasure_name)
                        set_ERASURE_NAME_CONF
		;;
		Version_name)
                        set_ITADOS_VERSION_CONF
		;;
		Logo)
                        set_ERASURE_LOGO_CONF
		;;
		System_specs)
                        set_SYSTEM_SPEC_CONF
		;;
	esac
}

######################## SERVICE #########################################

set_TECHNICIAN_CONF() {

        TECHNICIAN_CONF=$(whiptail --inputbox "Set Technician's name." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|TECHNICIAN_CONF=".*"|TECHNICIAN_CONF=\"$TECHNICIAN_CONF\"|" "${config}"
                whiptail --msgbox "TECHNICIAN_CONF set to: ${TECHNICIAN_CONF}" 0 0
                serviceMenu
        fi

}

set_PROVIDER_CONF() {

        PROVIDER_CONF=$(whiptail --inputbox "Set provider's name." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|PROVIDER_CONF=".*"|PROVIDER_CONF=\"$PROVIDER_CONF\"|" "${config}"
                whiptail --msgbox "PROVIDER_CONF set to: ${PROVIDER_CONF}" 0 0
                serviceMenu
        fi

}

set_LOCATION_CONF() {

        LOCATION_CONF=$(whiptail --inputbox "Set location." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|LOCATION_CONF=".*"|LOCATION_CONF=\"$LOCATION_CONF\"|" "${config}"
                whiptail --msgbox "LOCATION_CONF set to: ${LOCATION_CONF}" 0 0
                serviceMenu
        fi

}

set_CUSTOMER_CONF() {

        CUSTOMER_CONF=$(whiptail --inputbox "Set customer's name." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|CUSTOMER_CONF=".*"|CUSTOMER_CONF=\"$CUSTOMER_CONF\"|" "${config}"
                whiptail --msgbox "CUSTOMER_CONF set to: ${CUSTOMER_CONF}" 0 0
                serviceMenu
        fi

}

set_JOBNR_CONF() {

        JOBNR_CONF=$(whiptail --inputbox "Set job identifier." 0 0 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|JOBNR_CONF=".*"|JOBNR_CONF=\"$JOBNR_CONF\"|" "${config}"
                whiptail --msgbox "JOBNR_CONF set to: ${JOBNR_CONF}" 0 0
                serviceMenu
        fi

}

serviceMenu() {

	choice=$(whiptail --menu "Service Menu" 0 0 0 \
                "Technician" "Technician's name" \
                "Provider" "Provider's name" \
                "Location" "Location of erasure" \
                "Customer" "Customer's name" \
                "Job_ID" "Job identifier" 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
                configMenu
        fi

        case "$choice" in
                Technician)
                        set_PROVIDER_CONF
                ;;
                Provider)
                        set_PROVIDER_CONF
                ;;
                Location)
                        set_LOCATION_CONF
                ;;
                Customer)
                        set_CUSTOMER_CONF
                ;;
		Job_ID)
                        set_JOBNR_CONF
		;;
        esac

}

######################## ERASURE SPEC #########################################

set_ERASURE_SPEC_CONF() {

        while true; do
                ERASURE_SPEC_CONF=$(whiptail --radiolist "Set erasure specification." 0 0 0 \
                        "purge" "Most secure erasure methods; Not supported by all disks" OFF \
                        "clear" "Less secure erasure methods; Supported by majority of disks" OFF \
                        "auto" "If purge fails, falls back to clear" OFF \
                        "skip" "Skip erasure" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$ERASURE_SPEC_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|ERASURE_SPEC_CONF=".*"|ERASURE_SPEC_CONF=\"$ERASURE_SPEC_CONF\"|" "${config}"
                whiptail --msgbox "ERASURE_SPEC_CONF set to: ${ERASURE_SPEC_CONF}" 0 0
                erasureSpecificationMenu
        fi

}

set_VERIFICATION_CONF() {

        while true; do
                VERIFICATION_CONF=$(whiptail --radiolist "Set verification specification." 0 0 0 \
                        "full" "Scans entire disks for zero pattern [NIST]" OFF \
                        "partial" "Scans first and last 10% of disk for zero pattern" OFF \
                        "sampling" "Divides disk into 1000-1500 sections, scans 10-20% each [NIST]" OFF \
                        "skip" "Skip verification" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$VERIFICATION_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|VERIFICATION_CONF=".*"|VERIFICATION_CONF=\"$VERIFICATION_CONF\"|" "${config}"
                whiptail --msgbox "VERIFICATION_CONF set to: ${VERIFICATION_CONF}" 0 0
                erasureSpecificationMenu
        fi

}

erasureSpecificationMenu() {

        choice=$(whiptail --menu "Erasure Specification Menu" 0 0 0 \
                "Erasure" "Type of erasure" \
                "Verification" "Type of verification" 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
                configMenu
        fi

        case "$choice" in
                Erasure)
                        set_ERASURE_SPEC_CONF
                ;;
                Verification)
                        set_VERIFICATION_CONF
                ;;
        esac


}

######################## OTHER #########################################

set_MANUAL_USER_CONF() {

        while true; do
                MANUAL_USER_CONF=$(whiptail --radiolist "Set operational setting option." 0 0 0 \
                        "on" "Show settings on boot" OFF \
                        "off" "Don't allow to change settings in operation" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$MANUAL_USER_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|MANUAL_USER_CONF=".*"|MANUAL_USER_CONF=\"$MANUAL_USER_CONF\"|" "${config}"
                whiptail --msgbox "MANUAL_USER_CONF set to: ${MANUAL_USER_CONF}" 0 0
                otherMenu
        fi

}

set_CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF() {

        while true; do
                CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF=$(whiptail --radiolist "Set pattern setting." 0 0 0 \
                        "on" "If unexpected pattern, over write." OFF \
                        "off" "Do not over write if unexpected pattern." OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF=".*"|CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF=\"$CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF\"|" "${config}"
                whiptail --msgbox "CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF set to: ${CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF}" 0 0
                otherMenu
        fi

}

set_ASSET_CONF() {

        while true; do
                ASSET_CONF=$(whiptail --radiolist "Set asset tag option." 0 0 0 \
                        "asset" "Manually enter an asset tag" OFF \
                        "serial" "Asset tag automatically set to system's serial number" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$ASSET_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|ASSET_CONF=".*"|ASSET_CONF=\"$ASSET_CONF\"|" "${config}"
                whiptail --msgbox "ASSET_CONF set to: ${ASSET_CONF}" 0 0
                otherMenu
        fi

}

set_FILTER_BOOT_DISK_CONF() {

        while true; do
                FILTER_BOOT_DISK_CONF=$(whiptail --radiolist "Set boot filter option. (MAY BE UNRELIABLE)" 0 0 0 \
                        "on" "Shows boot disk as erasable in disk options" OFF \
                        "off" "Doesn't show boot disk as erasable" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$FILTER_BOOT_DISK_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|FILTER_BOOT_DISK_CONF=".*"|FILTER_BOOT_DISK_CONF=\"$FILTER_BOOT_DISK_CONF\"|" "${config}"
                whiptail --msgbox "FILTER_BOOT_DISK_CONF set to: ${FILTER_BOOT_DISK_CONF}" 0 0
                otherMenu
        fi

}

set_SMART_TEST_CONF() {

        while true; do
                SMART_TEST_CONF=$(whiptail --radiolist "Set SMART health option." 0 0 0 \
                        "short" "Quick check, takes up to 2 minutes." OFF \
                        "long" "Comprehensive test, can take hours." OFF \
                        "skip" "Skip health check" OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$SMART_TEST_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|SMART_TEST_CONF=".*"|SMART_TEST_CONF=\"$SMART_TEST_CONF\"|" "${config}"
                whiptail --msgbox "SMART_TEST_CONF set to: ${SMART_TEST_CONF}" 0 0
                otherMenu
        fi

}

set_SUSPEND_CONF() {

        while true; do
                SUSPEND_CONF=$(whiptail --radiolist "Set suspend option." 0 0 0 \
                        "on" "Suspends computer before erasure attempt." OFF \
                        "off" "Doesn't suspend before. Will suspend if frozen detected." OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$SUSPEND_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|SUSPEND_CONF=".*"|SUSPEND_CONF=\"$SUSPEND_CONF\"|" "${config}"
                whiptail --msgbox "SUSPEND_CONF set to: ${SUSPEND_CONF}" 0 0
                otherMenu
        fi

}

set_AUTO_ERASURE_CONF() {

        while true; do
                AUTO_ERASURE_CONF=$(whiptail --radiolist "Set erasure option." 0 0 0 \
                        "on" "Auto erasure of all disks [boot filter setting in effect]." OFF \
                        "off" "Manually select disks to erase." OFF 3>&1 1>&2 2>&3)
                exitcode=$?

                if [[ "$AUTO_ERASURE_CONF" == "" ]]; then
                        whiptail --msgbox "Please make a choice." 0 0
                else
                        break
                fi
        done

        if [[ "$exitcode" -eq 0 ]]; then
                sed -i "s|AUTO_ERASURE_CONF=".*"|AUTO_ERASURE_CONF=\"$AUTO_ERASURE_CONF\"|" "${config}"
                whiptail --msgbox "AUTO_ERASURE_CONF set to: ${AUTO_ERASURE_CONF}" 0 0
                otherMenu
        fi

}

otherMenu() {

        choice=$(whiptail --menu "Other Menu" 0 0 0 \
                "Settings" "Show settings during boot" \
                "Check_pattern" "If not expected pattern, over writes" \
                "Asset" "Asset tag gathering type" \
                "Filter_boot" "Filter boot disk from erasure" \
                "Disk_test" "Type of test performed on disks" \
                "Suspend" "Suspend prior to erasure attemps" \
                "Auto_erasure" "Start erasure automatically" 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
                configMenu
        fi

        case "$choice" in
                Settings)
                        set_MANUAL_USER_CONF
                ;;
                Check_pattern)
                        set_CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF
                ;;
                Asset)
                        set_ASSET_CONF
                ;;
                Filter_boot)
                        set_FILTER_BOOT_DISK_CONF
                ;;
                Disk_test)
                        set_SMART_TEST_CONF
                ;;
                Suspend)
                        set_SUSPEND_CONF
                ;;
                Auto_erasure)
                        set_AUTO_ERASURE_CONF
                ;;
        esac


}

configMenu() {

	choice=$(whiptail --menu "Config Menu" 0 0 0 \
                "Format" "Report formatting" \
                "Service_information" "Information displayed on report" \
                "Erasure_specification" "Erasure and verification settings" \
                "Other" "Various behavioural settings" 3>&1 1>&2 2>&3)
	exitcode=$?

	if [[ "$exitcode" -ne 0 ]]; then
		setupMenu
	fi

	case "$choice" in
		Format)
                        formatMenu
		;;
		Service_information)
                        serviceMenu
		;;
		Erasure_specification)
                        erasureSpecificationMenu
		;;
		Other)
                        otherMenu
		;;
	esac
}

setupMenu() {

        choice=$(whiptail --menu "Setup" 0 0 0 \
                "Generate_ISO" "Generates itadOS ISO" \
                "Modify_settings" "Modify itadOS default settings" 3>&1 1>&2 2>&3)
        exitcode=$?

        if [[ "$exitcode" -ne 0 ]]; then
                return 1
        fi

        case "$choice" in
                Generate_ISO)

                ;;
                Modify_settings)
                        configMenu

                ;;
        esac

}


while true; do

	if ! setupMenu; then
                break
        fi

done

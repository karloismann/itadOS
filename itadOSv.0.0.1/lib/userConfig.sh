#!/bin/bash

# Ask user for technician's name
# If input is given, it will override the TECHNICIAN_CONF variable set in config file
technician() {

    while true; do

        local original="$TECHNICIAN_CONF" 

        TECHNICIAN_CONF=$(whiptail --inputbox "Enter technician's name." 0 0 3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$TECHNICIAN_CONF" != "" ]]; then
            export TECHNICIAN_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$TECHNICIAN_CONF" ]]; then
            whiptail --msgbox "Please enter technician's name." 0 0
            TECHNICIAN_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Technician input cancelled"
            export TECHNICIAN_CONF="$original"
            break
        fi
    done
}

# Ask user for customer's name
# If input is given, it will override the CUSTOMER_CONF variable set in config file
customer() {
    
    while true; do

        local original="$CUSTOMER_CONF" 

        CUSTOMER_CONF=$(whiptail --inputbox "Enter customer's name." 0 0 3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$CUSTOMER_CONF" != "" ]]; then
            export CUSTOMER_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$CUSTOMER_CONF" ]]; then
            whiptail --msgbox "Please enter customer's name." 0 0
            CUSTOMER_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Customer input cancelled"
            export CUSTOMER_CONF="$original"
            break
        fi
    done
}

# Ask user for provider's name
# If input is given, it will override the PROVIDER_CONF variable set in config file
provider() {

    while true; do

        local original="$PROVIDER_CONF" 

        PROVIDER_CONF=$(whiptail --inputbox "Enter provider's name." 0 0 3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$PROVIDER_CONF" != "" ]]; then
            export PROVIDER_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$PROVIDER_CONF" ]]; then
            whiptail --msgbox "Please enter provider's name." 0 0
            PROVIDER_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Provider input cancelled"
            export PROVIDER_CONF="$original"
            break
        fi
    done
}

# Ask user for location
# If input is given, it will override the LOCATION_CONF variable set in config file
location() {

    while true; do

        local original="$LOCATION_CONF" 

        LOCATION_CONF=$(whiptail --inputbox "Enter location." 0 0 3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$LOCATION_CONF" != "" ]]; then
            export LOCATION_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$LOCATION_CONF" ]]; then
            whiptail --msgbox "Please enter location." 0 0
            LOCATION_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Location input cancelled"
            export LOCATION_CONF="$original"
            break
        fi
    done
}

# Ask user for provider's name
# If input is given, it will override the PROVIDER_CONF variable set in config file
job() {
    
    while true; do

        local original="$JOBNR_CONF" 

        JOBNR_CONF=$(whiptail --inputbox "Enter job number." 0 0 3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$JOBNR_CONF" != "" ]]; then
            export JOBNR_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$JOBNR_CONF" ]]; then
            whiptail --msgbox "Please enter job number." 0 0
            JOBNR_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Job number input cancelled"
            export JOBNR_CONF="$original"
            break
        fi
    done

}

# Ask user for erasure specification
# If input is given, it will override the ERASURE_SPEC_CONF variable set in config file
erasure_spec() {
    
    while true; do

        local original="$ERASURE_SPEC_CONF" 

        ERASURE_SPEC_CONF=$(whiptail --radiolist "Choose erasure specification." 0 0 0 \
            "clear" "Less secure methods used, compatible with most devices." OFF \
            "purge" "The most secure methods used, less compatible." OFF \
            "auto" "Attempts purge, fallback to clear if needed." OFF \
            "skip" "Skips erasure." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$ERASURE_SPEC_CONF" != "" ]]; then
            export ERASURE_SPEC_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$ERASURE_SPEC_CONF" ]]; then
            whiptail --msgbox "Please choose erasure specification." 0 0
            ERASURE_SPEC_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Erasure spec input cancelled"
            export ERASURE_SPEC_CONF="$original"
            break
        fi
    done

}

# Ask user for verification specification
# If input is given, it will override the VERIFICATION_CONF variable set in config file
verification_spec() {
    
    while true; do

        local original="$VERIFICATION_CONF" 

        VERIFICATION_CONF=$(whiptail --radiolist "Choose verification specification." 0 0 0 \
            "full" "Scans entire disks for zero pattern." OFF \
            "partial" "Scans first and last 10% of disk for zero pattern." OFF \
            "skip" "Skips verification." OFF 3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$VERIFICATION_CONF" != "" ]]; then
            export VERIFICATION_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$VERIFICATION_CONF" ]]; then
            whiptail --msgbox "Please choose verification specification." 0 0
            VERIFICATION_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Verification specification input cancelled"
            export VERIFICATION_CONF="$original"
            break
        fi
    done

}

# Ask user for asset tag setting
# If input is given, it will override the ASSET_CONF variable set in config file
asset_tag_setting() {
    
    while true; do

        local original="$ASSET_CONF" 

        ASSET_CONF=$(whiptail --radiolist "Choose asset tag option." 0 0 0 \
            "asset" "Enter an asset tag manually" OFF \
            "serial" "Automatically sets asset tag as device's serial number." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$ASSET_CONF" != "" ]]; then
            export ASSET_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$ASSET_CONF" ]]; then
            whiptail --msgbox "Please choose asset tag option." 0 0
            ASSET_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Asset tag option input cancelled"
            export ASSET_CONF="$original"
            break
        fi
    done

}

# Ask user for suspend setting
# If input is given, it will override the SUSPEND_CONF variable set in config file
suspend_setting() {
    
    while true; do

        local original="$SUSPEND_CONF" 

        SUSPEND_CONF=$(whiptail --radiolist "Choose suspend option." 0 0 0 \
            "on" "Automatically suspends device before erasure attempt." OFF \
            "off" "Starts erasure without suspension." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$SUSPEND_CONF" != "" ]]; then
            export SUSPEND_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$SUSPEND_CONF" ]]; then
            whiptail --msgbox "Please choose suspend option." 0 0
            SUSPEND_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Suspend option input cancelled"
            export SUSPEND_CONF="$original"
            break
        fi
    done

}

# Ask user for smart health check setting
# If input is given, it will override the SMART_TEST_CONF variable set in config file
smart_setting() {
    
    while true; do

        local original="$SMART_TEST_CONF" 

        SMART_TEST_CONF=$(whiptail --radiolist "Choose smart health check option." 0 0 0 \
            "short" "Short test, normally takes less than 2 minutes." OFF \
            "long" "Comprehensive test, can take hours to complete." OFF \
            "skip" "Skip disk health check." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$SMART_TEST_CONF" != "" ]]; then
            export SMART_TEST_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$SMART_TEST_CONF" ]]; then
            whiptail --msgbox "Please choose smart health check option." 0 0
            SMART_TEST_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Smart health check option input cancelled"
            export SMART_TEST_CONF="$original"
            break
        fi
    done

}

# Ask user for boot disk setting
# If input is given, it will override the FILTER_BOOT_DISK_CONF variable set in config file
boot_filter_setting() {
    
    while true; do

        local original="$FILTER_BOOT_DISK_CONF" 

        FILTER_BOOT_DISK_CONF=$(whiptail --radiolist "Choose boot filter option." 0 0 0 \
            "on" "Prohibits boot disk to be erased." OFF \
            "off" "Boot disk can be erased." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$FILTER_BOOT_DISK_CONF" != "" ]]; then
            export FILTER_BOOT_DISK_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$FILTER_BOOT_DISK_CONF" ]]; then
            whiptail --msgbox "Please boot filter option." 0 0
            FILTER_BOOT_DISK_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Boot filter option input cancelled"
            export FILTER_BOOT_DISK_CONF="$original"
            break
        fi
    done

}

# Ask user for auto overwrite setting
# If input is given, it will override the CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF variable set in config file
auto_overwrite_setting() {
    
    while true; do

        local original="$CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF" 

        CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF=$(whiptail --radiolist "Choose auto overwrite option." 0 0 0 \
            "on" "Starts overwrite if non zero pattern detected." OFF \
            "off" "Will not overwrite if non zero pattern detected." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF" != "" ]]; then
            export CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF" ]]; then
            whiptail --msgbox "Please boot filter option." 0 0
            CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Boot filter option input cancelled"
            export CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF="$original"
            break
        fi
    done

}

# Ask user for auto erasure setting
# If input is given, it will override the AUTO_ERASURE_CONF variable set in config file
auto_erasure_setting() {
    
    while true; do

        local original="$AUTO_ERASURE_CONF" 

        AUTO_ERASURE_CONF=$(whiptail --radiolist "Choose auto erasure option." 0 0 0 \
            "on" "Automatically starts erasure for all attached disk [ boot filter in effect ]." OFF \
            "off" "Allows users to select disks to erase." OFF \
            3>&1 1>&2 2>&3)
        local exit_status=$?

        if [[ "$exit_status" == 0 && "$AUTO_ERASURE_CONF" != "" ]]; then
            export AUTO_ERASURE_CONF
            break

        elif [[ "$exit_status" == 0 && -z "$AUTO_ERASURE_CONF" ]]; then
            whiptail --msgbox "Please boot filter option." 0 0
            AUTO_ERASURE_CONF="$original"

        elif [[ "$exit_status" == 1 ]]; then
            echo "Boot filter option input cancelled"
            export AUTO_ERASURE_CONF="$original"
            break
        fi
    done

}



# User selects the value to change (Technician, Provider, Customer, Job)
# @Returns 0 and choices made if they chose the options and pressed OK
# @Returns 1 if user pressed cancel
# @Returns 2 if options not chosen but OK pressed
getServiceInfoChoice() {
    choices=$(whiptail --title "Overwrite existing settings" \
            --checklist "Choose options to change:" 0 0 0 \
             "Technician" "Enter the processor's name." OFF \
             "Provider" "Enter the name of the company providing the service." OFF \
             "Location" "Enter the location the service is performed at." OFF \
             "Customer" "Enter the name of the customer." OFF \
             "Job" "Enter the job number." OFF \
        3>&1 1>&2 2>&3)
        local exit_status=$?

	if [[ "$exit_status" == 0 && -z "$choices" ]]; then
        return 2
    elif [[ "$exit_status" == 0 ]]; then
        echo "${choices}"
        return 0
    elif [[ "$exit_status" == 1 ]]; then
        return 1
    fi
}

# User selects the value to change (Spec, Verification)
# @Returns 0 and choices made if they chose the options and pressed OK
# @Returns 1 if user pressed cancel
# @Returns 2 if options not chosen but OK pressed
getErasureSpecChoice() {
    choices=$(whiptail --title "Overwrite existing settings" \
            --checklist "Choose options to change:" 0 0 0 \
             "Spec" "Choose erasure specification." OFF \
             "Verification" "Choose verification specification." OFF \
        3>&1 1>&2 2>&3)
        local exit_status=$?

	if [[ "$exit_status" == 0 && -z "$choices" ]]; then
        return 2
    elif [[ "$exit_status" == 0 ]]; then
        echo "${choices}"
        return 0
    elif [[ "$exit_status" == 1 ]]; then
        return 1
    fi
}

# User selects the value to change (Various settings)
# @Returns 0 and choices made if they chose the options and pressed OK
# @Returns 1 if user pressed cancel
# @Returns 2 if options not chosen but OK pressed
getOtherChoice() {
    choices=$(whiptail --title "Overwrite existing settings" \
            --checklist "Choose options to change:" 0 0 0 \
             "Asset Tag" "Choose asset tag option." OFF \
             "Auto Erasure" "Choose auto erasure option." OFF \
             "Suspend" "Choose automatic suspend option." OFF \
             "Health" "Choose SMART health check option." OFF \
             "Filter" "Choose filter boot disk option." OFF \
             "Auto Ow" "Choose automatic overwrite option" OFF \
        3>&1 1>&2 2>&3)
        local exit_status=$?

	if [[ "$exit_status" == 0 && -z "$choices" ]]; then
        return 2
    elif [[ "$exit_status" == 0 ]]; then
        echo "${choices}"
        return 0
    elif [[ "$exit_status" == 1 ]]; then
        return 1
    fi
}


# Notifies user of the values
# If user presses YES the program will continue
# If user presses NO, the user gets to re enter the values using UserConfig
confirmation() {

	whiptail --title "Confirm the details are correct" --yesno \
		"Service information: \
         \nTechnician: ${TECHNICIAN_CONF} \
         \nProvider: ${PROVIDER_CONF} \
         \nLocation: ${LOCATION_CONF} \
         \nCustomer: ${CUSTOMER_CONF} \
         \nJob Number: ${JOBNR_CONF} \
         \n==================================\
         \nErasure specification: \
         \nErasure Spec: ${ERASURE_SPEC_CONF} \
         \nVerification Spec: ${VERIFICATION_CONF} \
         \n=================================== \
         \nOther: \
         \nAsset tag: ${ASSET_CONF} \
         \nAuto erasure: ${AUTO_ERASURE_CONF} \
         \nSuspend before erasure: ${SUSPEND_CONF} \
         \nSMART health test: ${SMART_TEST_CONF} \
         \nFilter boot disk: ${FILTER_BOOT_DISK_CONF} \
         \nOverwrite if non 0 pattern detected: ${CHECK_ZERO_PATTERN_AND_OVERWRITE_CONF}" \
         0 0
	local exit_status=$?
	
	if [[ "$exit_status" == 1 ]]; then
		menu
	elif [[ "$exit_status" == 0 ]]; then
        CONFIRMED="yes"
        return
    fi

}

# User selects the value to change (Technician, Provider, Customer, Job)
serviceInfoConfig() {
    while true; do

    choices=$(getServiceInfoChoice)
    local exit_status=$?

        if [[ "$exit_status" == 0 ]]; then

            if [[ "$choices" == *"Technician"* ]]; then
                technician
            fi

            if [[ "$choices" == *"Provider"* ]]; then
                provider
            fi

            if [[ "$choices" == *"Location"* ]]; then
                location
            fi

            if [[ "$choices" == *"Customer"* ]]; then
                customer
            fi

            if [[ "$choices" == *"Job"* ]]; then
                job
            fi

            menu
            break
            
        elif [[ "$exit_status" == 2 ]]; then
            whiptail --msgbox "Selection not made, please select an option." 0 0
        
        elif [[ "$exit_status" == 1 ]]; then
            if menu; then
            	break
            fi
        fi
        
    done

}

# User selects the value to change (Technician, Provider, Customer, Job)
erasureSpecChoiceConfig() {
    while true; do

    choices=$(getErasureSpecChoice)
    local exit_status=$?

        if [[ "$exit_status" == 0 ]]; then

            if [[ "$choices" == *"Spec"* ]]; then
                erasure_spec
            fi

            if [[ "$choices" == *"Verification"* ]]; then
                verification_spec
            fi

            menu
            break
            
        elif [[ "$exit_status" == 2 ]]; then
           whiptail --msgbox "Selection not made, please select an option." 0 0
        
        elif [[ "$exit_status" == 1 ]]; then
            if menu; then
            	break
            fi
        fi
        
    done

}

# User selects the value to change (Technician, Provider, Customer, Job)
OtherChoiceConfig() {
    while true; do

    choices=$(getOtherChoice)
    local exit_status=$?

        if [[ "$exit_status" == 0 ]]; then

            if [[ "$choices" == *"Asset Tag"* ]]; then
                asset_tag_setting
            fi

            if [[ "$choices" == *"Auto Erasure"* ]]; then
                auto_erasure_setting
            fi

            if [[ "$choices" == *"Suspend"* ]]; then
                suspend_setting
            fi

            if [[ "$choices" == *"Health"* ]]; then
                smart_setting
            fi

            if [[ "$choices" == *"Filter"* ]]; then
                boot_filter_setting
            fi

            if [[ "$choices" == *"Auto Ow"* ]]; then
                auto_overwrite_setting
            fi

            menu
            break
            
        elif [[ "$exit_status" == 2 ]]; then
            whiptail --msgbox "Selection not made, please select an option." 0 0
        
        elif [[ "$exit_status" == 1 ]]; then
            if menu; then
            	break
            fi
        fi
        
    done

}

menu() {

    while [[ "$CONFIRMED" == "no" ]]; do

        choice=$(whiptail --title "Settings" --menu "Choose an option:" 0 0 0 \
            "Service information" "Modify information e.g. technician's name etc." \
            "Erasure specifications" "Modify erasure verification methods." \
            "Other" "Miscellaneous settings." \
            "Continue" "Continue to erasure" 3>&1 1>&2 2>&3)
        
        local exit_status=$?

        if [[ "$choice" == "Service information" ]]; then
            serviceInfoConfig
        elif [[ "$choice" == "Erasure specifications" ]]; then
            erasureSpecChoiceConfig
        elif [[ "$choice" == "Other" ]]; then
            OtherChoiceConfig
        elif [[ "$choice" == "Continue" ]]; then
            confirmation
        fi

        if [[ "$exit_status" == 0 && -z "$choice" ]]; then
            confirmation
        elif [[ "$exit_status" == 1 ]]; then
            confirmation
        fi
        

    done

}
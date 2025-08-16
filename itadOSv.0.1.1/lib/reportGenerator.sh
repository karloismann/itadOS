#!/bin/bash

DISK_FILES="lib/files/tmp/chosenDisks/"
TMP_VERIFICATION="lib/files/tmp/verificationStatus/"
ATTACHED_DISKS="lib/files/tmp/attachedDisks.txt"

HASH=""
REPORT_NAME=""

#
# Create a PDF report from the xml report
# sytlesheet is at lib/files/stylesheet/reportStyle.xsl
#
reportToPDF() {

    # Generate hash of completed XML file
    hashOfXML

    xsltproc \
        --stringparam generatedAt "$(date '+%d-%m-%Y %H:%M')" \
        --stringparam xmlFileName "$REPORT_NAME" \
        --stringparam xmlFileHash "$HASH" \
        --stringparam logoURL "$ERASURE_LOGO_CONF" \
        --stringparam erasureName "$ERASURE_NAME_CONF" \
        --stringparam itadOSVersion "$ITADOS_VERSION_CONF" \
        --stringparam specConf "$SYSTEM_SPEC_CONF" \
        --stringparam cpuModel "$CPU_MODEL" \
        --stringparam ramSize "$RAM_SIZE" \
        --stringparam gpuModel "$GPU_MODEL" \
        --stringparam dgpuModel "$DGPU_MODEL" \
        --stringparam batteryHealth "$BATTERY_HEALTH" \
        --stringparam disks "$DISKS" \
        --stringparam verification "$VERIFICATION_CONF" \
        lib/files/stylesheet/reportStyle.xsl "lib/files/reports/$ASSET_TAG.xml" > tmp.fo

    fop tmp.fo "lib/files/reports/$ASSET_TAG.pdf"
    rm tmp.fo

}


#
# Get information about processed disks and insert it into the report
# This includes disk name, serial number, model, erasure method, erasure tool, and results of verification.
#
insertDiskInfo() {
    echo "  <disks>" >> "$REPORT"
    for diskDir in "$DISK_FILES"*; do
        disk=$(basename "$diskDir")
        diskSerialNumber=$(cat "${diskDir}/serial.txt")
        diskModel=$(cat "${diskDir}/model.txt")
        diskSectorsBefore=$(awk '/before:/{print $2}' "${diskDir}/sectors.txt")
        diskSectorsAfter=$(awk '/after:/{print $2}' "${diskDir}/sectors.txt")
        diskErasureStart=$(awk '/start:/{print $2}' "${diskDir}/time.txt")
        diskErasureEnd=$(awk '/end:/{print $2}' "${diskDir}/time.txt")
        diskHealth=$(awk -F ':' '{print $2}' "${diskDir}/health.txt")

        # If drive does not report model name, print UNKNOWN
        if [[ -z "$diskModel" ]]; then
            diskModel="UNKNOWN"
        fi

        diskSize=$(cat "${diskDir}/size.txt")
        diskType=$(cat "${diskDir}/type.txt" | xargs)

        # If mmc does not report disk type then assign it
        if [[ "$disk" == mmc* && -z "$diskType" ]]; then
            diskType="eMMC"
        fi

        diskHPA=$(cat "${diskDir}/HPA.txt" | xargs)
        diskDCO=$(cat "${diskDir}/DCO.txt" | xargs)
        erasureMethod=$(cat "${diskDir}/method.txt")
        erasureSpec=$(cat "${diskDir}/spec.txt")
        erasureTool=$(cat "${diskDir}/tool.txt")
        erasureVerification=$(cat "${diskDir}/verification.txt")

        
        # NVME report includes 2 tools and verification is on different line.
        if [[ -z "$erasureVerification" ]]; then
            tool2=$(awk 'NR==4 {print}' "$file")
            erasureTool="${erasureTool} ${tool2}" 
            erasureVerification=$(cat "${diskDir}/verification.txt")
        fi

        echo "  <disk>" >> "$REPORT"
        echo "    <diskName>$disk</diskName>" >> "$REPORT"
        echo "    <diskSerialNumber>$diskSerialNumber</diskSerialNumber>" >> "$REPORT"
        echo "    <diskModel>$diskModel</diskModel>" >> "$REPORT"
        echo "    <diskSize>$diskSize</diskSize>" >> "$REPORT"
        echo "    <diskType>$diskType</diskType>" >> "$REPORT"
        echo "    <diskErasureStart>$diskErasureStart</diskErasureStart>" >> "$REPORT"
        echo "    <diskErasureEnd>$diskErasureEnd</diskErasureEnd>" >> "$REPORT"
        echo "    <diskSectorsBefore>$diskSectorsBefore</diskSectorsBefore>" >> "$REPORT"
        echo "    <diskSectorsAfter>$diskSectorsAfter</diskSectorsAfter>" >> "$REPORT"
        echo "    <diskHealth>$diskHealth</diskHealth>" >> "$REPORT"
        echo "    <diskHPA>$diskHPA</diskHPA>" >> "$REPORT"
        echo "    <diskDCO>$diskDCO</diskDCO>" >> "$REPORT"
        echo "    <erasureMethod>$erasureMethod</erasureMethod>" >> "$REPORT"
        echo "    <erasureSpec>$erasureSpec</erasureSpec>" >> "$REPORT"
        echo "    <erasureTool>$erasureTool</erasureTool>" >> "$REPORT"
        echo "    <erasureVerification>$erasureVerification</erasureVerification>" >> "$REPORT"
        echo "  </disk>" >> "$REPORT"
    done
    echo "  </disks>" >> "$REPORT"
}


#
# Generates the report in XML format.
# Inserts asset tag, serial number of host PC, processing starting date and time (bios)
# processed disk information including specs of erasure and system specifications.
#
reportGenerator() {

    ifReportExists

    REPORT="lib/files/reports/$ASSET_TAG.xml"
    
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$REPORT"
    echo "<report>" >> "$REPORT"
    echo "  <assetTag>${ASSET_TAG}</assetTag>" >> "$REPORT"
    echo "  <serialNumber>${SERIAL_NUMBER}</serialNumber>" >> "$REPORT"
    echo "  <biosTime>${ERASURE_START}</biosTime>" >> "$REPORT"
    echo "  <erasureSpecConf>${ERASURE_SPEC_CONF^^}</erasureSpecConf>" >> "$REPORT"
    echo "  <technician>${TECHNICIAN_CONF}</technician>" >> "$REPORT"
    echo "  <provider>${PROVIDER_CONF}</provider>" >> "$REPORT"
    echo "  <location>${LOCATION_CONF}</location>" >> "$REPORT"
    echo "  <customer>${CUSTOMER_CONF}</customer>" >> "$REPORT"
    echo "  <jobNumber>${JOBNR_CONF}</jobNumber>" >> "$REPORT"

    if [[ -z "$(ls -A "$DISK_FILES")" ]]; then
    
        # IF storage drives not detected then set the status accordingly
        if [[ ! -s "${ATTACHED_DISKS}" ]]; then
            # If boot drive is attached then mention why its not detected
            if [[ "${BOOT_DISK+x}" ]]; then
                echo "  <status>Storage drives NOT detected (Boot drive excluded: ${BOOT_DISK}).</status>" >> "$REPORT"
            else
                echo "  <status>Storage drives NOT detected.</status>" >> "$REPORT"
            fi
        else
            echo "  <status>Erasure cancelled.</status>" >> "$REPORT"
            echo "  <reasonForCancel>${REASON_FOR_CANCEL}</reasonForCancel>" >> "$REPORT"
        fi
        
    else
        
        # If processing less disks than detected, insert warning
        if [[ -n ${CHOSEN_DISK_WARNING} ]]; then
            echo "  <chosenDiskWarning>${CHOSEN_DISK_WARNING}</chosenDiskWarning>" >> "$REPORT"
        fi

        # If Boot disk is attached during wiping then identify the disk
        if [[ -n ${BOOT_DISK_WARNING} ]]; then
            echo "  <bootDiskWarning>${BOOT_DISK_WARNING}</bootDiskWarning>" >> "$REPORT"
        fi

        # If errors encountered then add them
        for dir in "${DISK_FILES}"*/; do

            warning_file="${dir}warnings.txt"

            if [[ -f "$warning_file" ]]; then

                while IFS= read -r line; do
                    echo "  <warning>${line}</warning>" >> "$REPORT"
                done < "$warning_file"
                
            fi
        done

        insertDiskInfo
    fi

    # System Specifications
    echo "  <specifications>" >> "$REPORT"

    echo "    <systemManufacturer>${SYSTEM_MANUFACTURER}</systemManufacturer>" >> "$REPORT"
    echo "    <systemModel>${MODEL_NAME}</systemModel>" >> "$REPORT"

    if [[ "$SYSTEM_SPEC_CONF" == "min" ]]; then
        cat lib/files/tmp/minDisks.txt >> "$REPORT"
    fi

    lshw -short | awk -v report="$REPORT" '/^\// {
        printf "    <entry>\n" >> report
        printf "      <hwPath>%s</hwPath>\n", $1 >> report
        printf "      <device>%s</device>\n", $2 >> report
        printf "      <class>%s</class>\n", $3 >> report
        $1=$2=$3=""; desc=substr($0, index($0,$4));
        printf "      <description>%s</description>\n", desc >> report
        printf "    </entry>\n" >> report
    }'
    echo "  </specifications>" >> "$REPORT"

    echo "</report>" >> "$REPORT"

    reportToPDF

}

# Generate hash of completed XML file
hashOfXML() {
    REPORT="lib/files/reports/$ASSET_TAG.xml"
    REPORT_NAME="${ASSET_TAG}.xml"
    HASH=$(sha256sum "$REPORT" | awk '{print $1}')
}

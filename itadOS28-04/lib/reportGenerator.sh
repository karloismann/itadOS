#!/bin/bash
TMP_REPORTS="lib/files/tmp/reports/"
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
    for file in "$TMP_REPORTS"*; do
        base=$(basename "$file")
        disk=$(echo "$base" | awk -F'_' '{print $1}' | xargs)
        diskSerialNumber=$(awk -F ',' 'NR==1 {print $7}' "$file" | xargs)
        diskModel=$(awk -F ',' 'NR==1 {print $8}' "$file" | xargs)

        # If drive does not report model name, print UNKNOWN
        if [[ -z "$diskModel" ]]; then
            diskModel="UNKNOWN"
        fi

        diskSize=$(awk -F ',' 'NR==1 {print $10}' "$file" | xargs)
        diskType=$(awk -F ',' 'NR==1 {print $9}' "$file" | xargs)

        # If mmc does not report disk type then assign it
        if [[ "$disk" == mmc* && -z "$diskType" ]]; then
            diskType="eMMC"
        fi
        
        # Initiare diskHPA and diskDCO for reporting reasons
        diskHPA=""
        diskDCO=""

        #Add HPA and DCO for sata drives
        if [[ "$diskType" = "sata SSD" || "$diskType" == "sata HDD" ]]; then
            diskHPA=$(awk 'NR==2 {print}' "$file" | xargs)
            diskDCO=$(awk 'NR==3 {print}' "$file" | xargs)
            erasureMethod=$(awk -F ',' 'NR==4 {print $2}' "$file" | xargs)
            erasureTool=$(awk -F ',' 'NR==5 {print $2}' "$file" | xargs)
            erasureVerification=$(awk -F ':' 'NR==6 {print $2}' "$file" | xargs)
        else
            erasureMethod=$(awk -F ',' 'NR==2 {print $2}' "$file" | xargs)
            erasureTool=$(awk -F ',' 'NR==3 {print $2}' "$file" | xargs)
            erasureVerification=$(awk -F ':' 'NR==4 {print $2}' "$file")
        fi
        
        # NVME report includes 2 tools and verification is on different line.
        if [[ -z "$erasureVerification" ]]; then
            #erasureTool=$(awk -F ',' 'NR==3 {print $2}' "$file") # erasureTool returned tool2 only thus I added this here to ensure value
            tool2=$(awk 'NR==4 {print}' "$file")
            erasureTool="${erasureTool} ${tool2}" 
            erasureVerification=$(awk -F ':' 'NR==5 {print $2}' "$file")
        fi

        echo "  <disk>" >> "$REPORT"
        echo "    <diskName>$disk</diskName>" >> "$REPORT"
        echo "    <diskSerialNumber>$diskSerialNumber</diskSerialNumber>" >> "$REPORT"
        echo "    <diskModel>$diskModel</diskModel>" >> "$REPORT"
        echo "    <diskSize>$diskSize</diskSize>" >> "$REPORT"
        echo "    <diskType>$diskType</diskType>" >> "$REPORT"
        if [[ "$diskHPA" != "" || "$diskDCO" != "" ]]; then
             echo "    <diskHPA>$diskHPA</diskHPA>" >> "$REPORT"
             echo "    <diskDCO>$diskDCO</diskDCO>" >> "$REPORT"
        fi
        echo "    <erasureMethod>$erasureMethod</erasureMethod>" >> "$REPORT"
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
    REPORT="lib/files/reports/$ASSET_TAG.xml"
    i=1

    
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$REPORT"
    echo "<report>" >> "$REPORT"
    echo "  <assetTag>$ASSET_TAG</assetTag>" >> "$REPORT"
    echo "  <serialNumber>$(dmidecode -t system | awk '/Serial Number:/ {print $3}')</serialNumber>" >> "$REPORT"
    echo "  <biosTime>$(date +"%d-%m-%Y %H:%M")</biosTime>" >> "$REPORT"

    if [ -z "$(ls -A "$TMP_REPORTS")" ]; then
    
        # IF storage drives not detected then set the status accordingly
        if [ ! -s "${ATTACHED_DISKS}" ]; then
            # If boot drive is attached then mention why its not detected
            if [ "${BOOT_DRIVE+x}" ]; then
                echo "  <status>Storage drives NOT detected (Boot drive excluded: ${BOOT_DRIVE}).</status>" >> "$REPORT"
            else
                echo "  <status>Storage drives NOT detected.</status>" >> "$REPORT"
            fi
        else
            echo "  <status>Erasure cancelled.</status>" >> "$REPORT"
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

        insertDiskInfo
    fi

    echo "  <specifications>" >> "$REPORT"
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
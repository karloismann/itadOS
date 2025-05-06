#!/bin/bash
TMP_REPORTS="lib/files/tmp/reports/"
TMP_VERIFICATION="lib/files/tmp/verificationStatus/"

#
# Create a PDF report from the xml report
#
reportToPDF() {
    xsltproc lib/files/stylesheet/reportStyle.xsl "lib/files/reports/$ASSET_TAG.xml" > tmp.fo
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
        disk=$(echo "$base" | awk -F'_' '{print $1}')
        diskSerialNumber=$(cat "$file" | awk -F ',' 'NR==1 {print $5}')
        diskModel=$(cat "$file" | awk -F ',' 'NR==1 {print $6}')
        erasureMethod=$(cat "$file" | awk -F ',' 'NR==2 {print $2}')
        erasureTool=$(cat "$file" | awk -F ',' 'NR==3 {print $2}')
        erasureVerification=$(cat "$file" | awk -F ':' 'NR==4 {print $2}')

        echo "  <disk>" >> "$REPORT"
        echo "    <diskName>$disk</diskName>" >> "$REPORT"
        echo "    <diskSerialNumber>$diskSerialNumber</diskSerialNumber>" >> "$REPORT"
        echo "    <diskModel>$diskModel</diskModel>" >> "$REPORT"
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
        echo "  <status>Erasure cancelled or no storage drives installed.</status>" >> "$REPORT"
    else
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
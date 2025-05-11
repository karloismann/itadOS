<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:output method="xml" indent="yes"/>

  <!-- PARAMETERS -->
  <xsl:param name="generatedAt"/>

  <xsl:template match="/report">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="A4"
          page-height="29.7cm" page-width="21cm"
          margin-top="1cm" margin-bottom="1cm"
          margin-left="2cm" margin-right="2cm">
        
          <fo:region-body margin-top="2cm" margin-bottom="2cm"/>
          <fo:region-before extent="2cm"/>
          <fo:region-after extent="1cm"/>
        </fo:simple-page-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="A4">

        <!-- HEADER -->
        <fo:static-content flow-name="xsl-region-before">
          <fo:block text-align="center" space-after="2pt">
            <fo:external-graphic src="url('lib/files/stylesheet/logo/itadOS.png')" content-width="100px" content-height="auto"/>
          </fo:block>
        </fo:static-content>

        <!-- FOOTER -->
        <fo:static-content flow-name="xsl-region-after">
          <fo:block text-align="center" font-size="8pt">
            Page <fo:page-number/> of <fo:page-number-citation ref-id="last-page"/>
            | Generated: <xsl:value-of select="$generatedAt"/>
          </fo:block>
        </fo:static-content>
        
        <!-- BODY -->
        <fo:flow flow-name="xsl-region-body">
          <fo:block text-align="left" font-size="12pt" font-weight="bold" space-after="4pt">
            itadOS Erasure Report
          </fo:block>
          <fo:block font-size="10pt">Asset Tag: <xsl:value-of select="assetTag"/></fo:block>
          <fo:block font-size="10pt">Serial Number: <xsl:value-of select="serialNumber"/></fo:block>
          <fo:block font-size="10pt">BIOS Time: <xsl:value-of select="biosTime"/></fo:block>

          <xsl:if test="status">
            <fo:block color="red" font-weight="bold" space-before="10pt">
              Status: <xsl:value-of select="status"/>
            </fo:block>
          </xsl:if>

          <xsl:if test="disks">
            <fo:block font-weight="bold" space-before="10pt">Disks:</fo:block>
            <xsl:for-each select="disks/disk">
              <fo:block font-size="10pt" space-before="5pt">
		            <fo:block>Disk: <xsl:value-of select="diskName"/></fo:block>
                <fo:block>Model: <xsl:value-of select="diskModel"/></fo:block>
                <fo:block>Size: <xsl:value-of select="diskSize"/></fo:block>
                <fo:block>Type: <xsl:value-of select="diskType"/></fo:block>
                <fo:block>Serial: <xsl:value-of select="diskSerialNumber"/></fo:block>
                <!-- Add HPA and DCO for sata drives -->
                <!-- Add colours indicating success (GREEN), fail (RED), not detected (ORANGE) or not set (GREEN) -->
                <xsl:if test="normalize-space(diskType) = 'sata SSD' or normalize-space(diskType) = 'sata HDD'">
                    <fo:block>HPA: <xsl:value-of select="diskHPA"/></fo:block>
                    <fo:block>DCO: <xsl:value-of select="diskDCO"/></fo:block>
                </xsl:if>
                <fo:block>Method: <xsl:value-of select="erasureMethod"/></fo:block>
                <fo:block>Tool: <xsl:value-of select="erasureTool"/></fo:block>
                <xsl:choose>
                  <xsl:when test="contains(erasureVerification, 'FAIL')">
                    <fo:block color="red" font-weight="bold">
                      Verification: <xsl:value-of select="erasureVerification"/>
                    </fo:block>
                  </xsl:when>
                  <xsl:otherwise>
                    <fo:block color="green" font-weight="bold">
                      Verification: <xsl:value-of select="erasureVerification"/>
                    </fo:block>
                  </xsl:otherwise>
                </xsl:choose>
              </fo:block>
            </xsl:for-each>
          </xsl:if>

          <fo:block font-size="10pt" font-weight="bold" space-before="10pt">
            System Specifications:
          </fo:block>

          <fo:table table-layout="fixed" width="100%" font-size="8pt" space-before="5pt">
            <fo:table-column column-width="25%"/>
            <fo:table-column column-width="25%"/>
            <fo:table-column column-width="20%"/>
            <fo:table-column column-width="30%"/>

            <fo:table-body>
              <xsl:for-each select="specifications/entry">
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block><xsl:value-of select="hwPath"/></fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block><xsl:value-of select="device"/></fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block><xsl:value-of select="class"/></fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block><xsl:value-of select="description"/></fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </xsl:for-each>
            </fo:table-body>
          </fo:table>
          <fo:block id="last-page" font-size="0pt" line-height="0pt" visibility="hidden"/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
</xsl:stylesheet>
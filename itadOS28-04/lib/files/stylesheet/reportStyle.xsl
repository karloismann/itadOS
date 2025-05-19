<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:output method="xml" indent="yes"/>

  <!-- PARAMETERS -->
  <xsl:param name="generatedAt"/>
  <xsl:param name="xmlFileName"/>
  <xsl:param name="xmlFileHash"/>

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
          <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-width="70%"/>
            <fo:table-column column-width="30%"/>
            <fo:table-body>
              <fo:table-row>

                <!-- Left column: hash info -->
                <fo:table-cell>
                  <fo:block font-size="8pt" font-style="italic" text-align="left">
                    This report corresponds to XML file: <xsl:value-of select="$xmlFileName"/>
                  </fo:block>
                  <fo:block font-size="8pt" font-style="italic" text-align="left">
                    XML SHA-256 Digest: <xsl:value-of select="$xmlFileHash"/>
                  </fo:block>
                </fo:table-cell>

                <!-- Right column: logo -->
                <fo:table-cell>
                  <fo:block text-align="right" font-size="8pt">
                    Page <fo:page-number/> of <fo:page-number-citation ref-id="last-page"/>
                    | Generated: <xsl:value-of select="$generatedAt"/>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:static-content>
        
        <!-- BODY -->
        <fo:flow flow-name="xsl-region-body">

          <!-- TITLE -->
          <fo:block text-align="left" font-size="12pt" font-weight="bold" space-after="4pt">
            itadOS Erasure Report
          </fo:block>

          <fo:block font-size="10pt">
            <fo:inline font-weight="bold">Asset Tag: </fo:inline>
            <fo:inline><xsl:value-of select="assetTag"/></fo:inline>
          </fo:block>

          <fo:block font-size="10pt">
            <fo:inline font-weight="bold">Serial Number: </fo:inline>
            <fo:inline><xsl:value-of select="serialNumber"/></fo:inline>
          </fo:block>

          <fo:block font-size="10pt">
            <fo:inline font-weight="bold">BIOS Time: </fo:inline>
            <fo:inline><xsl:value-of select="biosTime"/></fo:inline>
          </fo:block>


          <!-- IF NO ERASURE OCCURS -->
          <xsl:if test="status">
            <fo:block color="red" font-weight="bold" space-before="10pt">
              <xsl:value-of select="status"/>
            </fo:block>
          </xsl:if>

          <!-- DISKS -->
          <xsl:if test="disks">
            <fo:block font-weight="bold" space-before="10pt">Disks:</fo:block>

            <!-- WARN IF NOT ALL DETECTED DISKS ERASED -->
            <xsl:if test="chosenDiskWarning">
              <fo:block font-size="8pt" color="red" font-weight="bold" space-before="2pt">
                <xsl:value-of select="chosenDiskWarning"/>
              </fo:block>
            </xsl:if>

            <!-- WARN BOOT DISK IS ATTACHED -->
            <xsl:if test="bootDiskWarning">
              <fo:block font-size="8pt" color="red" font-weight="bold" space-before="2pt">
                <xsl:value-of select="bootDiskWarning"/>
              </fo:block>
            </xsl:if>


            <xsl:for-each select="disks/disk">
              <fo:block font-size="10pt" space-before="5pt">
		            <fo:block>
                <fo:inline font-weight="bold">Disk: </fo:inline>
                <fo:inline><xsl:value-of select="diskName"/></fo:inline>
              </fo:block>

              <fo:block>
                <fo:inline font-weight="bold">Model: </fo:inline>
                <fo:inline><xsl:value-of select="diskModel"/></fo:inline>
              </fo:block>

              <fo:block>
                <fo:inline font-weight="bold">Size: </fo:inline>
                <fo:inline><xsl:value-of select="diskSize"/></fo:inline>
              </fo:block>

              <fo:block>
                <fo:inline font-weight="bold">Type: </fo:inline>
                <fo:inline><xsl:value-of select="diskType"/></fo:inline>
              </fo:block>

              <fo:block>
                <fo:inline font-weight="bold">Serial: </fo:inline>
                <fo:inline><xsl:value-of select="diskSerialNumber"/></fo:inline>
              </fo:block>

                <!-- Add HPA and DCO for sata drives -->
                <!-- Add colours indicating success (GREEN), fail (RED), not detected (ORANGE) or not set (GREEN) -->
                <xsl:if test="normalize-space(diskType) = 'SATA SSD' or normalize-space(diskType) = 'SATA HDD'">
                    <xsl:choose>
                      <xsl:when test="contains(diskHPA, 'FAIL')">
                        <fo:block color="red">
                          <fo:inline font-weight="bold">HPA: </fo:inline>
                          <fo:inline font-weight="bold"><xsl:value-of select="diskHPA"/></fo:inline>
                        </fo:block>
                      </xsl:when>
                      <xsl:when test="contains(diskHPA, 'SUCCESS')">
                        <fo:block color="green">
                          <fo:inline font-weight="bold">HPA: </fo:inline>
                          <fo:inline font-weight="bold"><xsl:value-of select="diskHPA"/></fo:inline>
                        </fo:block>
                      </xsl:when>
                      <xsl:otherwise>
                        <fo:block color="orange">
                          <fo:inline font-weight="bold">HPA: </fo:inline>
                          <fo:inline font-weight="bold"><xsl:value-of select="diskHPA"/></fo:inline>
                        </fo:block>
                      </xsl:otherwise>
                    </xsl:choose>

                    <xsl:choose>
                      <xsl:when test="contains(diskDCO, 'FAIL')">
                        <fo:block color="red">
                          <fo:inline font-weight="bold">DCO: </fo:inline>
                          <fo:inline font-weight="bold"><xsl:value-of select="diskDCO"/></fo:inline>
                        </fo:block>
                      </xsl:when>
                      <xsl:when test="contains(diskDCO, 'SUCCESS') or contains(diskDCO, 'not enabled')">
                        <fo:block color="green">
                          <fo:inline font-weight="bold">DCO: </fo:inline>
                          <fo:inline font-weight="bold"><xsl:value-of select="diskDCO"/></fo:inline>
                        </fo:block>
                      </xsl:when>
                      <xsl:otherwise>
                        <fo:block color="orange">
                          <fo:inline font-weight="bold">DCO: </fo:inline>
                          <fo:inline font-weight="bold"><xsl:value-of select="diskDCO"/></fo:inline>
                        </fo:block>
                      </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>

                <fo:block>
                  <fo:inline font-weight="bold">Method: </fo:inline>
                  <fo:inline><xsl:value-of select="erasureMethod"/></fo:inline>
                </fo:block>

                <fo:block>
                  <fo:inline font-weight="bold">Tool: </fo:inline>
                  <fo:inline><xsl:value-of select="erasureTool"/></fo:inline>
                </fo:block>

                <!-- VERIFICATION -->
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

          <!-- SYSTEM SPECS -->
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
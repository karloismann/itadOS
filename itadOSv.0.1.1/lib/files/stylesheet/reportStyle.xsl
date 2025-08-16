<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:output method="xml" indent="yes"/>

  <!-- PARAMETERS -->
  <xsl:param name="generatedAt"/>
  <xsl:param name="xmlFileName"/>
  <xsl:param name="xmlFileHash"/>
  <xsl:param name="logoURL"/>
  <xsl:param name="erasureName"/>
  <xsl:param name="itadOSVersion"/>
  <xsl:param name="specConf"/>
  <xsl:param name="cpuModel"/>
  <xsl:param name="ramSize"/>
  <xsl:param name="gpuModel"/>
  <xsl:param name="dgpuModel"/>
  <xsl:param name="batteryHealth"/>
  <xsl:param name="disks"/>
  <xsl:param name="verification"/>

  <xsl:template match="/report">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="A4"
          page-height="29.7cm" page-width="21cm"
          margin-top="1cm" margin-bottom="1cm"
          margin-left="2cm" margin-right="2cm">

          <!-- Modify margin-top to push content off logo-->
          <fo:region-body margin-top="3cm" margin-bottom="2cm"/>
          <fo:region-before extent="2cm"/>
          <fo:region-after extent="2cm"/>
        </fo:simple-page-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="A4">

        <!-- HEADER -->
        <fo:static-content flow-name="xsl-region-before">

          <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-width="33%"/>
            <fo:table-column column-width="33%"/>
            <fo:table-column column-width="33%"/>
            <fo:table-body>
              <fo:table-row>
                <!-- ITADOS VERSION -->
                <fo:table-cell display-align="center">
                  <fo:block font-size="8pt">
                    <xsl:value-of select="$itadOSVersion"/>
                  </fo:block>
                </fo:table-cell>
                  
                <!-- LOGO -->
                <fo:table-cell>
                  <fo:block text-align="center" space-after="2pt">
                    <fo:external-graphic src="url('{$logoURL}')" content-width="100px" content-height="auto"/>
                  </fo:block>
                </fo:table-cell>

                <!-- SPACING -->
                <fo:table-cell>
                  <fo:block></fo:block>
                </fo:table-cell>

              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:static-content>

        <!-- FOOTER -->

        <fo:static-content flow-name="xsl-region-after">

          <fo:table space-after="6pt" table-layout="fixed" width="100%">
            <fo:table-column column-width="48%"/>
            <fo:table-column column-width="4%"/>
            <fo:table-column column-width="48%"/>
            <fo:table-body>
              <fo:table-row>
                <!-- TECHNICIAN SIGNATURE -->
                <fo:table-cell>
                  <fo:block font-weight="bold" font-size="9pt">Technician:</fo:block>
                  <fo:block border-bottom="1pt solid black" padding-top="10pt"/>  
                </fo:table-cell>
                
                <!-- SPACING -->
                <fo:table-cell>
                  <fo:block/>
                </fo:table-cell>

                <!-- VALIDATOR SIGNATURE -->
                <fo:table-cell>
                  <fo:block font-weight="bold" font-size="9pt">Validator:</fo:block>
                  <fo:block border-bottom="1pt solid black" padding-top="10pt"/>  
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
                

          <fo:table table-layout="fixed" width="100%">
            <fo:table-column column-width="75%"/>
            <fo:table-column column-width="25%"/>
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
          <fo:block color="white" text-align="left" font-size="12pt" font-weight="bold" space-after="6pt" background-color="#204dc2" padding="4pt">
            <xsl:value-of select="$erasureName"/> Erasure Report
          </fo:block>

          <fo:table table-layout="fixed" width="100%" font-size="10pt" space-after="14pt">
            <fo:table-column column-width="50%"/>
            <fo:table-column column-width="50%"/>
            <fo:table-body>
              <fo:table-row>
              
                <!-- Left column: Asset Tag -->
                <fo:table-cell>
                  <fo:block>
                    <fo:inline font-weight="bold">Asset Tag: </fo:inline>
                    <fo:inline><xsl:value-of select="assetTag"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">Serial Number: </fo:inline>
                    <fo:inline><xsl:value-of select="serialNumber"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">BIOS Time: </fo:inline>
                    <fo:inline><xsl:value-of select="biosTime"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">Erasure Specification: </fo:inline>
                    <fo:inline><xsl:value-of select="erasureSpecConf"/></fo:inline>
                  </fo:block>
                </fo:table-cell>
                
                <!-- Right column: Serial Number and BIOS Time -->
                <fo:table-cell>

                  <fo:block>
                    <fo:inline font-weight="bold">Technician: </fo:inline>
                    <fo:inline><xsl:value-of select="technician"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">Provider: </fo:inline>
                    <fo:inline><xsl:value-of select="provider"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">Location: </fo:inline>
                    <fo:inline><xsl:value-of select="location"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">Customer: </fo:inline>
                    <fo:inline><xsl:value-of select="customer"/></fo:inline><fo:block/>
                    <fo:inline font-weight="bold">Job ID: </fo:inline>
                    <fo:inline><xsl:value-of select="jobNumber"/></fo:inline>
                  </fo:block>

                </fo:table-cell>

              </fo:table-row>
            </fo:table-body>
          </fo:table>



          <fo:block color="white" font-weight="bold" font-size="10pt" space-before="10pt" space-after="4pt" background-color="#204dc2" padding="4pt">Erasure Details:</fo:block>

          <!-- IF NO ERASURE OCCURS -->
          <xsl:if test="status">
            <fo:block color="red" font-size="10pt" font-weight="bold" space-before="10pt" space-after="10pt">
              <xsl:value-of select="status"/>
            </fo:block>
          </xsl:if>

          <xsl:if test="reasonForCancel">
            <fo:block font-size="10pt" space-before="10pt" space-after="10pt">
              <fo:inline font-weight="bold">Reason for cancelling: </fo:inline>
              <fo:inline><xsl:value-of select="reasonForCancel"/></fo:inline>
            </fo:block>
          </xsl:if>

          <!-- DISKS -->
          <xsl:if test="disks">

            <!-- WARNINGS -->
            <!-- WARN IF NOT ALL DETECTED DISKS ERASED -->
            <xsl:if test="chosenDiskWarning">
              <fo:block font-size="8pt" color="red" font-weight="bold" space-before="2pt" space-after="2pt" background-color="#e0e0e0" padding="2pt">
                <xsl:value-of select="chosenDiskWarning"/>
              </fo:block>
            </xsl:if>

            <!-- WARN BOOT DISK IS ATTACHED -->
            <xsl:if test="bootDiskWarning">
              <fo:block font-size="8pt" color="red" font-weight="bold" space-before="2pt" space-after="2pt" background-color="#e0e0e0" padding="2pt">
                <xsl:value-of select="bootDiskWarning"/>
              </fo:block>
            </xsl:if>

            <!-- ANY ERRORS ENCOUNTERED -->
            <xsl:if test="warning">
              <xsl:for-each select="warning">
                <fo:block font-size="8pt" color="red" font-weight="bold" space-before="2pt" space-after="2pt" background-color="#e0e0e0" padding="2pt">
                  <xsl:value-of select="."/>
                </fo:block>
              </xsl:for-each>
            </xsl:if>

            <!-- DISKS -->
            <xsl:for-each select="disks/disk">

              <fo:block font-size="10px" space-after="8pt">
                <fo:table table-layout="fixed" width="100%">
                <fo:table-column column-width="40%"/>
                <fo:table-column column-width="60%"/>
                <fo:table-body>
                  <fo:table-row>

                    <!-- LEFT COLUMN -->
                    <fo:table-cell>
                      <fo:block>
                        <fo:inline font-weight="bold">Disk:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskName"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Model:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskModel"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Size:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskSize"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Type:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskType"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Serial:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskSerialNumber"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Erasure start:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskErasureStart"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Erasure finished:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskErasureEnd"/></fo:inline><fo:block/>

                        <!-- VERIFICATION -->
                        <xsl:choose>
                        <xsl:when test="contains(erasureVerification, 'FAIL') or contains(erasureVerification, 'SKIPPED')">
                          <fo:block color="red" font-weight="bold">
                            Verification: <xsl:value-of select="erasureVerification"/>
                          </fo:block>
                        </xsl:when>
                        <xsl:when test="contains(erasureVerification, 'partial')">
                          <fo:block color="orange" font-weight="bold">
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
                    </fo:table-cell>

                    <!-- RIGHT COLUMN -->
                    <fo:table-cell>
                      <fo:block>
                        <fo:inline font-weight="bold">Sectors before erasure:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskSectorsBefore"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Sectors after erasure:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskSectorsAfter"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Health:</fo:inline>
                        <fo:inline> <xsl:value-of select="diskHealth"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Method:</fo:inline>
                        <fo:inline> <xsl:value-of select="erasureMethod"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Specification:</fo:inline>
                        <fo:inline> <xsl:value-of select="erasureSpec"/></fo:inline><fo:block/>
                        <fo:inline font-weight="bold">Tool:</fo:inline>
                        <fo:inline> <xsl:value-of select="erasureTool"/></fo:inline><fo:block/>

                        <!-- Add HPA and DCO for sata drives -->
                            <xsl:choose>
                              <xsl:when test="contains(diskHPA, 'FAIL') or contains(diskHPA, 'ERROR')">
                                <fo:block color="red">
                                  <fo:inline font-weight="bold">HPA: </fo:inline>
                                  <fo:inline font-weight="bold"><xsl:value-of select="diskHPA"/></fo:inline>
                                </fo:block>
                              </xsl:when>
                              <xsl:when test="contains(diskHPA, 'SUCCESS') or contains(diskHPA, 'Not detected')">
                                <fo:block color="green">
                                  <fo:inline font-weight="bold">HPA: </fo:inline>
                                  <fo:inline font-weight="bold"><xsl:value-of select="diskHPA"/></fo:inline>
                                </fo:block>
                              </xsl:when>
                              <xsl:when test="contains(diskHPA, 'N/A')">
                                <fo:block color="black">
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
                              <xsl:when test="contains(diskDCO, 'SUCCESS') or contains(diskDCO, 'Not enabled')">
                                <fo:block color="green">
                                  <fo:inline font-weight="bold">DCO: </fo:inline>
                                  <fo:inline font-weight="bold"><xsl:value-of select="diskDCO"/></fo:inline>
                                </fo:block>
                              </xsl:when>
                              <xsl:when test="contains(diskDCO, 'N/A')">
                                <fo:block color="black">
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

                      </fo:block>
                    </fo:table-cell>

                  </fo:table-row>

                  <!-- VERIFICATION 
                  <fo:table-row>
                    
                    <fo:table-cell>
                      <xsl:choose>
                        <xsl:when test="contains(erasureVerification, 'FAIL') or contains(erasureVerification, 'SKIPPED')">
                          <fo:block color="red" font-weight="bold">
                            Verification: <xsl:value-of select="erasureVerification"/>
                          </fo:block>
                        </xsl:when>
                        <xsl:when test="contains(erasureVerification, 'partial')">
                          <fo:block color="orange" font-weight="bold">
                            Verification: <xsl:value-of select="erasureVerification"/>
                          </fo:block>
                        </xsl:when>
                        <xsl:otherwise>
                          <fo:block color="green" font-weight="bold">
                            Verification: <xsl:value-of select="erasureVerification"/>
                          </fo:block>
                        </xsl:otherwise>
                      </xsl:choose>
                    </fo:table-cell>
                  </fo:table-row> -->

                </fo:table-body>
              </fo:table>

            </fo:block>

            </xsl:for-each>
          </xsl:if>

          <!-- SYSTEM SPECS -->
          <fo:block color="white" font-size="10pt" font-weight="bold" space-before="10pt" background-color="#204dc2" padding="4pt" >
            System Specifications:
          </fo:block>

          <!-- MIN SPECS -->
          <xsl:if test="$specConf = 'min'">


            <fo:table table-layout="fixed" width="100%" font-size="10pt" space-before="5pt">
              <fo:table-column column-width="30%"/>
              <fo:table-column column-width="70%"/>

              <fo:table-body>

                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">System Manufacturer: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline><xsl:value-of select="specifications/systemManufacturer"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">System Model: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline><xsl:value-of select="specifications/systemModel"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">Processor: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                     <fo:inline><xsl:value-of select="$cpuModel"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">Graphics Card: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                     <fo:inline><xsl:value-of select="$gpuModel"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">Dedicated Graphics Card: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                     <fo:inline><xsl:value-of select="$dgpuModel"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>


                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">RAM Amount: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                     <fo:inline><xsl:value-of select="$ramSize"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                      <fo:inline font-weight="bold">Battery Health: </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-size="10pt" space-before="2pt">
                     <fo:inline><xsl:value-of select="$batteryHealth"/></fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>

              </fo:table-body>

            </fo:table>

            <fo:block font-size="10pt" space-before="10pt">
              <fo:inline font-weight="bold">Disks: </fo:inline>
            </fo:block>
            
            <xsl:choose>
              <xsl:when test="specifications/minDisk[minDiskWarning]">
                  <fo:block ><xsl:value-of select="specifications/minDisk/minDiskWarning"/></fo:block>
              </xsl:when>

              <xsl:otherwise>

                <fo:table table-layout="fixed" width="100%" font-size="10pt" space-before="2pt">
                  <fo:table-column column-width="15%"/>
                  <fo:table-column column-width="15%"/>
                  <fo:table-column column-width="15%"/>
                  <fo:table-column column-width="55%"/>

                  <!-- Table Header -->
                  <fo:table-header>
                    <fo:table-row font-weight="bold" background-color="#e0e0e0">
                      <fo:table-cell>
                        <fo:block>Disk</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block>Size</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block>Type</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block>Model</fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                  </fo:table-header>

                  <fo:table-body>
                    <xsl:for-each select="specifications/minDisk">
                      <fo:table-row>
                        <fo:table-cell>
                          <fo:block space-after="10pt"><xsl:value-of select="minDiskName"/></fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block space-after="10pt"><xsl:value-of select="minDiskSize"/></fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block space-after="10pt"><xsl:value-of select="minDiskType"/></fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block space-after="10pt" ><xsl:value-of select="minDiskModel"/></fo:block>
                        </fo:table-cell>
                      </fo:table-row>
                    </xsl:for-each>
                  </fo:table-body>
                </fo:table>

              </xsl:otherwise>
            </xsl:choose>


          </xsl:if>

          <!-- FULL SPECS -->
          <xsl:if test="$specConf = 'full'">
            
            <fo:block font-size="10pt" space-before="2pt">
              <fo:inline font-weight="bold">System Manufacturer: </fo:inline>
              <fo:inline><xsl:value-of select="specifications/systemManufacturer"/></fo:inline>
            </fo:block>

            <fo:block font-size="10pt" space-before="2pt">
              <fo:inline font-weight="bold">System Model: </fo:inline>
              <fo:inline><xsl:value-of select="specifications/systemModel"/></fo:inline>
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
          </xsl:if>

          <fo:block id="last-page" font-size="0pt" line-height="0pt" visibility="hidden"/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
</xsl:stylesheet>
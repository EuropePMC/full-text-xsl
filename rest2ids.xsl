<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2019 EMBL-EBI/Europe PMC (https://europepmc.org/)
  
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- 
        Script: rest2ids.xsl
        Version: 1.0
        Status: Ready for production
        Summary: Transforms Europe PMC RESTful "search" responses to source/external-id lists, with one-line per record text.
        Notes: Either resulttype=lite or resulttype=core paramater can used
    -->
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:param name="idMode" select="1"/>   <!-- 1 = Format IDs as on the front end, 2 = Format IDs for using Excel to generate External Links data -->
    
    <xsl:variable name="newline" select="'&#13;&#10;'"/>
    
    <xsl:template match="/">
        <xsl:for-each select="/responseWrapper/resultList/result">
            <xsl:choose>
                <xsl:when test="$idMode=1 and source/text()='MED'">
                    <xsl:text>PMID</xsl:text>
                </xsl:when>
                <xsl:when test="$idMode=1 and (source/text()='PMC' or source/text()='UKPMC')">
                    <xsl:text>PMCID</xsl:text>
                </xsl:when>
                <xsl:when test="source/text()='UKPMC'">
                    <xsl:text>PMC</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="source/text()"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$idMode=1">
                    <xsl:text>:</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>  </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="id/text()"/>
            
            <!-- Output PMCID -->
            <xsl:choose>
                <xsl:when test="$idMode=1 and source/text()='MED'">
                    <xsl:if test="pmcid != ''">
                        <xsl:text>,PMCID:</xsl:text>
                        <xsl:value-of select="pmcid/text()"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
            <!-- End of outputting PMCID -->
            
            <xsl:value-of select="$newline"/>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
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
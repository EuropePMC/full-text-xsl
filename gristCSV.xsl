<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:str="xalan://java.lang.String"
    exclude-result-prefixes="xs xalan str"
    version="1.0">
    <xsl:output method="text" encoding="ISO-8859-1"/>
    <xsl:param name="includeHeader" select="'Y'"/>
    <xsl:template match="/">
        <xsl:if test="$includeHeader='Y'">
            <xsl:text>Salutation,Initials,Given Name,Surname,ORCID,Funder,PubMed Search Term,Grant Title,Grant ID,Old Grant ID,Currency,Amount Awarded,Grant Stream,Grant Type,Start Date,End Date,Lay Abstract,Scientific Abstract,Institution Name,Department&#x0A;</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="Response/RecordList/Record"/>
    </xsl:template>
    
    <xsl:template match="Record">
        <xsl:apply-templates select="Person"/>
        <xsl:apply-templates select="Grant"/>
        <xsl:apply-templates select="Institution"/>
        <xsl:text>&#x0A;</xsl:text>
    </xsl:template>
    
    <xsl:template match="Person">
        <xsl:value-of select="concat(Title,',',Initials,',&quot;',GivenName,'&quot;,&quot;',FamilyName,'&quot;,',Alias[@Source='ORCID'],',')"/>
    </xsl:template>
    		
    <xsl:template match="Funder">
        <xsl:value-of select="concat(Name,',',pubMedSearchTerm,',')"/>
    </xsl:template>
    
    <xsl:template match="Grant">
        <xsl:apply-templates select="Funder"/>
        <xsl:apply-templates select="Title"/>
        <!--Old Grant Id?-->
        <xsl:value-of select="concat(',&quot;',Id,'&quot;,')"/>
        <xsl:apply-templates select="Alias[1]"/>
        <xsl:value-of select="concat(',',Amount/@Currency,',',Amount,',')"/>
        <xsl:apply-templates select="Stream"/>
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="Type"/>
        <xsl:value-of select="concat(',',StartDate,',',EndDate,',')"/>
        <xsl:apply-templates select="Abstract[@Type='lay'][1]"/>
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="Abstract[@Type='scientific'][1]"/>
        <xsl:text>,</xsl:text>
    </xsl:template>
    
    <xsl:template match="Title|Stream|Abstract|Type|Name|Department">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="str:replaceAll(str:new(text()),'&quot;','&quot;&quot;')"/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
    <xsl:template match="Alias">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:for-each select="following-sibling::Alias">
            <xsl:text>; </xsl:text>
            <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
    <xsl:template match="Institution">
        <xsl:apply-templates select="Name"/>
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="Department"/>
    </xsl:template>
    
</xsl:stylesheet>
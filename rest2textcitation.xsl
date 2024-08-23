<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2024 EMBL-EBI/Europe PMC (https://europepmc.org/)
  
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
		Script: rest2textcitation.xsl
		Version: 1.1
		Changes since 1.0: Handle preprint servers as journal titles; include notice for retractions, errata and published preprints
		Status: Ready for production
		Summary: Transforms Europe PMC RESTful "search" responses (resulttype=core) to a one-line per record text citation format that is as close as possible to the format=text format that PubMed provides
		Issues: Cannot do book editors (as this field is not in REST core.) Languages not included as that would require a mapping table of ISO 639-2 codes be included in this stylesheet
	-->
	
	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:variable name="newline" select="'&#13;&#10;'"/>
		
	<xsl:template match="/">
		<xsl:for-each select="/responseWrapper/resultList/result">
			<xsl:if test="authorString">
				<xsl:apply-templates select="authorString"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="title"/>
			<xsl:choose>
				<xsl:when test="journalInfo">
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="journalInfo/journal/medlineAbbreviation">
							<xsl:apply-templates select="journalInfo/journal/medlineAbbreviation"/>
						</xsl:when>
						<xsl:when test="journalInfo/journal/ISOAbbreviation">
							<xsl:apply-templates select="journalInfo/journal/ISOAbbreviation"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="journalInfo/journal/title"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="journalInfo/dateOfPublication"/>
					<xsl:if test="journalInfo/volume">
						<xsl:text>;</xsl:text>
						<xsl:apply-templates select="journalInfo/volume"/>
						<xsl:if test="journalInfo/issue">
							<xsl:text>(</xsl:text>
							<xsl:apply-templates select="journalInfo/issue"/>
							<xsl:text>)</xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:text>:</xsl:text>
					<xsl:apply-templates select="pageInfo"/>
					<xsl:text>.</xsl:text>
					<!-- TODO: Add languages here? -->
				</xsl:when>
				<xsl:when test="bookOrReportDetails">
					<xsl:choose>
						<xsl:when test="not(substring(title/text(), string-length(title/text()), 1) = '.')">
							<xsl:text>. </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="bookOrReportDetails/comprisingTitle and not(pubTypeList/pubType[text()='Book']) and not(pubTypeList/pubType[text()='Preprint'])">
						<xsl:text>In: </xsl:text>
						<!-- TODO: List editors here, if/when they are made available in the core web service response, see JIRA ticket CIT-1166 -->
						<xsl:apply-templates select="bookOrReportDetails/comprisingTitle"/>
						<xsl:text>. </xsl:text>
						<xsl:if test="bookOrReportDetails/edition">
							<xsl:apply-templates select="bookOrReportDetails/edition"/>
							<xsl:text> edition. </xsl:text>
						</xsl:if>
						<xsl:if test="bookOrReportDetails/publisher">
							<xsl:apply-templates select="bookOrReportDetails/publisher"/>
							<xsl:text>; </xsl:text>
						</xsl:if>
						<xsl:apply-templates select="bookOrReportDetails/yearOfPublication"/>
						<!-- TODO: Include publication months, if/when they are made available in the core web service response for books/reports, see JIRA ticket CIT-1182 -->
						<xsl:text>. </xsl:text>
						<!-- TODO: Add location labels here, usually a chapter number, if/when they are made availabe in the core web service response see JIRA ticket CIT-1174 -->
						<xsl:if test="fullTextUrlList/fullTextUrl[site/text()='NCBI_Bookshelf']">
							<xsl:text>Available from </xsl:text>
							<xsl:apply-templates select="fullTextUrlList/fullTextUrl[site/text()='NCBI_Bookshelf']/url"/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="pubTypeList/pubType[text()='Preprint']">
						<xsl:apply-templates select="bookOrReportDetails/publisher"/>
						<xsl:text>; </xsl:text>
						<xsl:apply-templates select="bookOrReportDetails/yearOfPublication"/>
						<xsl:text>.</xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>. </xsl:text>
					<!-- It is not really worth adding here for patents or anything else. They'll get the title and authors above, and ID below -->
				</xsl:otherwise>
			</xsl:choose>	
			<xsl:if test="doi">
				<xsl:text> doi: </xsl:text>
				<xsl:apply-templates select="doi[1]"/>
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:for-each select="commentCorrectionList/commentCorrection">
				<xsl:choose>
					<xsl:when test="type/text()='Retraction in' or type/text()='Erratum in' or type/text()='Preprint of'">
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="type"/>
						<xsl:text>: </xsl:text>
						<xsl:apply-templates select="reference"/>
						<xsl:text>.</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="pmid">
					<xsl:text> PMID: </xsl:text>
					<xsl:apply-templates select="pmid"/>
				</xsl:when>
				<xsl:when test="not(source/text()='PMC' or source/text()='UKPMC')">
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="source"/>
					<xsl:text>:</xsl:text>
					<xsl:apply-templates select="id"/>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="pmcid">
				<xsl:if test="pmid">
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:text> PMCID: </xsl:text>
				<xsl:apply-templates select="pmcid"/>
			</xsl:if>
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	
	<!-- 
		Script: rest2delimited.xsl
		Version: 1.1
		Changes since 1.0: Now uses author first names, if available
		Status: Ready for production
		Summary: Transforms Europe PMC RESTful "search" responses (resulttype=core) to a one-line per record containing key fields delimited
		Usage Notes: Set the includeHeader parameter to 'N' after the first page, when transforming multiple pages of RESTful responses, to be concatenated into a single file
		Issues: Very long author lists can exceed Excel's character limit per cell
	-->
	
	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:param name="delimiter" select="'&#x9;'"/>
	<xsl:param name="includeHeader" select="'Y'"/>
	<xsl:param name="maxAuthors"/>
	<xsl:param name="journalMode" select="2"/>	<!-- 1 = Full title, 2 = Abbreviated title, 3 = ISSN -->
	<xsl:param name="authorMode" select="2"/>	<!-- 1 = Surname, Initials, 2 = Surname, Firstnames (where available, if not initials) -->
	
	<xsl:variable name="newline" select="'&#13;&#10;'"/>
		
	<xsl:template match="/">
		<xsl:if test="$includeHeader='Y'">
			<xsl:text>SOURCE</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>EXTERNAL_ID</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>PMCID</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>DOI</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:choose>
				<xsl:when test="$maxAuthors and not(string(number($maxAuthors))='NaN')">
					<xsl:text>FIRST_</xsl:text>
					<xsl:value-of select="$maxAuthors"/>
					<xsl:text>_AUTHORS</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>AUTHORS</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>PUBLICATION_YEAR</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>PUBLICATION_MONTH</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>TITLE</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>JOURNAL</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>VOLUME</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>ISSUE</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>PAGE_INFO</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>TIMES_CITED</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>GRANTS</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>OPEN_ACCESS</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>LICENSE</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>FIRST_PUB_DATE (dd/mm/yyyy)</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>EMBARGO_DATE (dd/mm/yyyy)</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>IN_EPMC</xsl:text>
			<xsl:value-of select="$delimiter"/>
			<xsl:text>EPMC_AUTH_MAN</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
		<xsl:for-each select="/responseWrapper/resultList/result">
			<xsl:choose>
				<xsl:when test="source/text()='UKPMC'">
					<xsl:text>PMC</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="source/text()"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="id"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="pmcid"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="doi[1]"/>
			<xsl:value-of select="$delimiter"/>		
			<xsl:variable name="numAuthors">
				<xsl:choose>
					<xsl:when test="$maxAuthors and not(string(number($maxAuthors))='NaN')">
						<xsl:value-of select="$maxAuthors"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(authorList/author)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:for-each select="authorList/author[position() &lt;= $numAuthors]">
				<xsl:apply-templates select="lastName/text()|collectiveName"/>
				<xsl:choose>
					<xsl:when test="$authorMode=2 and firstName and not(initials/text()=translate(firstName/text(),' ',''))">
						<xsl:text>, </xsl:text>
						<xsl:apply-templates select="firstName/text()"/>
					</xsl:when>
					<xsl:when test="initials">
						<xsl:text>, </xsl:text>
						<xsl:apply-templates select="initials/text()"/>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="not(position()=last())">
					<xsl:text>; </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$delimiter"/>
			<xsl:choose>
				<xsl:when test="journalInfo/yearOfPublication">
					<xsl:apply-templates select="journalInfo/yearOfPublication"/>
				</xsl:when>
				<xsl:when test="bookOrReportDetails/yearOfPublication">
					<xsl:apply-templates select="bookOrReportDetails/yearOfPublication"/>
				</xsl:when>
				<xsl:when test="patentDetails/application/applicationDate">
					<xsl:value-of select="substring(patentDetails/application/applicationDate/text(),1,4)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Cannot find publication year</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delimiter"/>
			<xsl:choose>
				<xsl:when test="journalInfo/monthOfPublication">
					<xsl:if test="not(journalInfo/monthOfPublication/text()='0')">
						<xsl:apply-templates select="journalInfo/monthOfPublication"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="bookOrReportDetails/monthOfPublication">
					<!-- Not currently working, see JIRA ticket: CIT-1182 -->
					<xsl:if test="not(bookOrReportDetails/monthOfPublication/text()='0')">
						<xsl:apply-templates select="bookOrReportDetails/monthOfPublication"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="patentDetails/application/applicationDate">
					<xsl:value-of select="substring(patentDetails/application/applicationDate/text(),6,2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Cannot find publication year</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="title"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:choose>
				<xsl:when test="$journalMode=3 and (journalInfo/journal/ISSN or journalInfo/journal/ESSN)">
					<xsl:for-each select="journalInfo/journal/ISSN|journalInfo/journal/ESSN">
						<xsl:apply-templates/>
						<xsl:if test="not(position()=last())">
							<xsl:text>/</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$journalMode=2 and journalInfo/journal/medlineAbbreviation">
					<xsl:apply-templates select="journalInfo/journal/medlineAbbreviation"/>
				</xsl:when>
				<xsl:when test="$journalMode=2 and journalInfo/journal/ISOAbbreviation">
					<xsl:apply-templates select="journalInfo/journal/ISOAbbreviation"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="journalInfo/journal/title"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="journalInfo/volume"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="journalInfo/issue"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="pageInfo"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="citedByCount"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:for-each select="grantsList/grant">
				<xsl:sort select="orderIn/text()"/>
				<xsl:text>"</xsl:text>
				<xsl:choose>
					<xsl:when test="agency">
						<xsl:apply-templates select="agency"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>AGENCY_NAME_NOT_SUPPLIED</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>":"</xsl:text>
				<xsl:choose>
					<xsl:when test="grantId">
						<xsl:apply-templates select="grantId"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>ID_NOT_SUPPLIED</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>"</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="isOpenAccess"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="license"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="firstPublicationDate"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="embargoDate"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="inEPMC"/>
			<xsl:value-of select="$delimiter"/>
			<xsl:apply-templates select="epmcAuthMan"/>
			<xsl:value-of select="$newline"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="collectiveName">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

</xsl:stylesheet>
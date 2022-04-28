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
SOFTWARE.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	
	<!-- 
		Script: rest2csv.xsl
		Version: 1.2
		Changes since 1.0: Now uses author first names, if available
		Status: Ready for production
		Summary: Transforms Europe PMC RESTful "search" responses (resulttype=core) to a one-line per record containing key fields delimited
		Usage Notes: Set the includeHeader parameter to 'N' after the first page, when transforming multiple pages of RESTful responses, to be concatenated into a single file
		Issues: Very long author lists can exceed Excel's character limit per cell
		Support CSV handling comma-contained titles
	-->
	
	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:param name="includeHeader" select="'Y'"/>
	<xsl:param name="maxAuthors"/>
	<xsl:param name="journalMode" select="2"/>	<!-- 1 = Full title, 2 = Abbreviated title, 3 = ISSN -->
	<xsl:param name="authorMode" select="2"/>	<!-- 1 = Surname, Initials, 2 = Surname, Firstnames (where available, if not initials) -->
	<xsl:param name="formatMode" select="2"/>	<!-- 1 = TSV, 2 = CSV -->
		
	<xsl:variable name="newline" select="'&#13;&#10;'"/>
	
    <xsl:variable name="delimiter" select="'&#x9;'" /> <!-- '&#x9;' = tab, '&#x2c;' = comma -->
	<xsl:variable name="csvdelimiter" select="'&#x2c;'" />
	
	<xsl:template match="/">
		<xsl:if test="$includeHeader='Y'">
			<xsl:text>SOURCE</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>EXTERNAL_ID</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>PMCID</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>DOI</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
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
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>PUBLICATION_YEAR</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>PUBLICATION_MONTH</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>TITLE</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>JOURNAL</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>VOLUME</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>ISSUE</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>PAGE_INFO</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>PUBLISHER</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>TIMES_CITED</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>GRANTS</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>OPEN_ACCESS</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>LICENSE</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>FIRST_PUB_DATE (dd/mm/yyyy)</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>EMBARGO_DATE (dd/mm/yyyy)</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:text>IN_EPMC</xsl:text>
			<xsl:call-template name="outputdelimiter"/>
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
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="id"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="pmcid"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="doi[1]"/>
			<xsl:call-template name="outputdelimiter"/>		
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
			
			<xsl:text>&quot;</xsl:text>
			<xsl:for-each select="authorList/author[position() &lt;= $numAuthors]">
				<xsl:choose>
					<xsl:when test="$formatMode=1">
						<xsl:apply-templates select="lastName/text()|collectiveName"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="doublequotes">
							<xsl:with-param name="text" select="lastName/text()|collectiveName" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				
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
			<xsl:text>&quot;</xsl:text>
			
			<xsl:call-template name="outputdelimiter"/>
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
			<xsl:call-template name="outputdelimiter"/>
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
			<xsl:call-template name="outputdelimiter"/>
			<xsl:choose>
				<xsl:when test="$formatMode=1">
					<xsl:apply-templates select="title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="contains(title/text(), ',')">
							<xsl:text>&quot;</xsl:text>
							<xsl:call-template name="doublequotes">
								<xsl:with-param name="text" select="title/text()" />
							</xsl:call-template>
							<xsl:text>&quot;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="title"/>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="outputdelimiter"/>
			
			<xsl:text>&quot;</xsl:text>
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
					<xsl:choose>
						<xsl:when test="$formatMode=1">
							<xsl:apply-templates select="journalInfo/journal/medlineAbbreviation"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="doublequotes">
								<xsl:with-param name="text" select="journalInfo/journal/medlineAbbreviation" />
							</xsl:call-template>					
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$journalMode=2 and journalInfo/journal/ISOAbbreviation">					
					<xsl:choose>
						<xsl:when test="$formatMode=1">
							<xsl:apply-templates select="journalInfo/journal/ISOAbbreviation"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="doublequotes">
								<xsl:with-param name="text" select="journalInfo/journal/ISOAbbreviation" />
							</xsl:call-template>					
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>					
					<xsl:choose>
						<xsl:when test="$formatMode=1">
							<xsl:apply-templates select="journalInfo/journal/title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="doublequotes">
								<xsl:with-param name="text" select="journalInfo/journal/title" />
							</xsl:call-template>					
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>&quot;</xsl:text>
			
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="journalInfo/volume"/>
			<xsl:call-template name="outputdelimiter"/>
			
			<xsl:text>&quot;</xsl:text>
			<xsl:choose>
				<xsl:when test="$formatMode=1">
					<xsl:apply-templates select="journalInfo/issue"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="doublequotes">
						<xsl:with-param name="text" select="journalInfo/issue" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>&quot;</xsl:text>
			
			<xsl:call-template name="outputdelimiter"/>
			
			<xsl:text>&quot;</xsl:text>
			<xsl:choose>
				<xsl:when test="$formatMode=1">
					<xsl:apply-templates select="pageInfo"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="doublequotes">
						<xsl:with-param name="text" select="pageInfo" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>&quot;</xsl:text>
			
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="bookOrReportDetails/publisher"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="citedByCount"/>
			<xsl:call-template name="outputdelimiter"/>
			
			<xsl:text>&quot;</xsl:text>
			<xsl:for-each select="grantsList/grant">
				<xsl:sort select="orderIn/text()"/>
				<xsl:text>""</xsl:text>
				<xsl:choose>
					<xsl:when test="agency">						
						<xsl:choose>					
							<xsl:when test="$formatMode=1">
								<xsl:apply-templates select="agency"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="doublequotes">
									<xsl:with-param name="text" select="agency" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>AGENCY_NAME_NOT_SUPPLIED</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>"":""</xsl:text>
				<xsl:choose>
					<xsl:when test="grantId">	
						<xsl:choose>					
							<xsl:when test="$formatMode=1">
								<xsl:apply-templates select="grantId"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="doublequotes">
									<xsl:with-param name="text" select="grantId" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>ID_NOT_SUPPLIED</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>""</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>&quot;</xsl:text>
			
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="isOpenAccess"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="license"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="firstPublicationDate"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="embargoDate"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="inEPMC"/>
			<xsl:call-template name="outputdelimiter"/>
			<xsl:apply-templates select="epmcAuthMan"/>
			<xsl:value-of select="$newline"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template name="doublequotes">
		<xsl:param name="text" />
		<xsl:choose>
			<xsl:when test="contains($text, '&quot;')">
				<xsl:value-of select="concat(substring-before($text, '&quot;'), '&quot;&quot;')"/>
				<xsl:call-template name="doublequotes">
					<xsl:with-param name="text"	select="substring-after($text, '&quot;')" />					
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="outputdelimiter">
		<xsl:choose>
			<xsl:when test="$formatMode=1">
				<xsl:value-of select="$delimiter"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$csvdelimiter"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
		  
</xsl:stylesheet>

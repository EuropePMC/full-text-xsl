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
		Script: rest2bibtex.xsl
		Version: 1.1
		Changes since 1.0: Now uses author first names, if available
		Status: Ready for production
		Summary: Transforms Europe PMC RESTful search responses (resulttype=core) to BibTeX format
		Issues: Cannot do book editors (as these are not in core response) and MEDLINE cataloguing of conference proceedings/papers is very patchy
	-->
	
	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:param name="maxAuthors"/>
	<xsl:param name="noAuthorsDefault">Unknown author(s)</xsl:param>
	<xsl:param name="noTitleDefault">Title not supplied</xsl:param>
	<xsl:param name="journalMode" select="1"/>	<!-- 1 = Full title, 2 = Abbreviated title -->
	<xsl:param name="urlMode" select="2"/>	<!-- 1 = EuropePMC metadata page, 2 = Fulltext, if available, otherwise EuropePMC metadata, 3 = Fulltext only -->
	<xsl:param name="authorMode" select="2"/>	<!-- 1 = Surname, Initials, 2 = Surname, Firstnames (where available, if not initials) -->
	
	<xsl:variable name="newline" select="'&#13;&#10;'"/>
		
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="responseWrapper|resultList">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="/responseWrapper/resultList/result">
		<xsl:variable name="bibtexType">
			<xsl:choose>
				<xsl:when test="source/text()='HIR'">
					<xsl:text>techreport</xsl:text>
				</xsl:when>
				<xsl:when test="source/text()='ETH'">
					<xsl:text>phdthesis</xsl:text>
				</xsl:when>
				<xsl:when test="journalInfo">
					<xsl:choose>
						<xsl:when test="pubTypeList/pubType[text()='Congresses']">
							<xsl:text>inproceedings</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Overall']">
							<xsl:text>proceedings</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Poster']">
							<xsl:text>misc</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Academic Dissertations']">
							<xsl:text>phdthesis</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>article</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="patentDetails">
					<!-- The @patent is unofficial, so many renderers will regard this as 
						 a @misc, but a few may recognise this and display it differently -->
					<xsl:text>patent</xsl:text>
				</xsl:when>
				<xsl:when test="bookOrReportDetails">
					<xsl:choose>
						<xsl:when test="pubTypeList/pubType[text()='Book Article']">
							<xsl:text>incollection</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Book']">
							<xsl:text>book</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Dissertation']">
							<!-- Could be a mastersthesis, but there is no way to tell -->
							<xsl:text>phdthesis</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>misc</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Cannot identify record type (<xsl:call-template name="RecordId"/>)</xsl:message>
					<xsl:text>misc</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>@</xsl:text>
		<xsl:value-of select="$bibtexType"/>
		<xsl:text> {</xsl:text>
		<xsl:call-template name="RecordId">
			<xsl:with-param name="resultNode" select="."/>
		</xsl:call-template>
		<xsl:text>,</xsl:text>
		<xsl:value-of select="$newline"/>
		<xsl:choose>
			<xsl:when test="title/text()">
				<xsl:apply-templates select="title"/>
			</xsl:when>
			<xsl:when test="not($bibtexType = 'misc')">
				<xsl:message>Record without title (<xsl:call-template name="RecordId"/>)</xsl:message>
				<xsl:if test="$noTitleDefault">
					<xsl:text>	Title = {</xsl:text>
					<xsl:value-of select="$noTitleDefault"/>
					<xsl:text>},</xsl:text>
					<xsl:value-of select="$newline"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="authorList/author">
				<xsl:apply-templates select="authorList"/>
			</xsl:when>
			<xsl:when test="$bibtexType = 'article' or $bibtexType = 'book' or $bibtexType = 'inbook' or $bibtexType = 'incollection' or $bibtexType = 'inproceedings' or $bibtexType = 'phdthesis' or $bibtexType = 'techreport' or $bibtexType = 'unpublished'">
				<xsl:message>Record without authors (<xsl:call-template name="RecordId"/>)</xsl:message>
				<xsl:if test="$noAuthorsDefault">
					<xsl:text>	Author = {</xsl:text>
					<xsl:value-of select="$noAuthorsDefault"/>
					<xsl:text>},</xsl:text>
					<xsl:value-of select="$newline"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="*[not(self::title|self::authorList)]">
			<xsl:with-param name="bibtexType" select="$bibtexType"/>
		</xsl:apply-templates>
		<xsl:if test="$urlMode=1 or ($urlMode=2 and not(fullTextUrlList/fullTextUrl[not(documentStyle/text()='abs')]))">
			<xsl:text>	URL = {</xsl:text>
			<xsl:call-template name="MetadataUrl">
				<xsl:with-param name="resultNode" select="."/>
			</xsl:call-template>
			<xsl:text>}</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
		<xsl:text>}</xsl:text>
		<xsl:value-of select="$newline"/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
    <xsl:template match="abstractText">
		<xsl:text>	Abstract = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>

	<xsl:template match="title">
		<xsl:text>	Title = {</xsl:text>
		<xsl:apply-templates>
			<xsl:with-param name="removePeriod" select="true()"/>
		</xsl:apply-templates>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="authorList">
		<!-- NOTE: Suffixes (e.g. Jnr) are not included in individual authors in the core web response -->
		<xsl:text>	Author = {</xsl:text>
		<xsl:variable name="numAuthors">
			<xsl:choose>
				<xsl:when test="$maxAuthors and not(string(number($maxAuthors))='NaN')">
					<xsl:value-of select="$maxAuthors"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(author)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="author[position() &lt;= $numAuthors]">
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
				<xsl:text> and </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="count(author) > $numAuthors">
			<xsl:text> and others</xsl:text>
		</xsl:if>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="collectiveName">
		<xsl:text>{</xsl:text>
		<xsl:apply-templates select="text()"/>
		<xsl:text>}</xsl:text>
	</xsl:template>
	
	<xsl:template match="journalInfo|patentDetails|patentDetails/application|journalInfo/journal|bookOrReportDetails">
		<xsl:param name="bibtexType"/>
		<!-- This template is for any container-elements which contain
			 fields matched by the templates below -->
		<xsl:apply-templates select="*[not(self::text())]">
			<xsl:with-param name="bibtexType" select="$bibtexType"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="journalInfo/yearOfPublication">
		<xsl:text>	Year = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/monthOfPublication[not(text()='0')]|bookOrReportDetails/monthOfPublication[not(text()='0')]">
		<!-- Not currently working for books, see JIRA ticket: CIT-1182 -->
		<!-- NOTE: Zero means unknown/imprecise publication month -->
		<xsl:text>	Month = {</xsl:text>
		<xsl:choose>
			<xsl:when test="text()='1'">January</xsl:when>
			<xsl:when test="text()='2'">February</xsl:when>
			<xsl:when test="text()='3'">March</xsl:when>
			<xsl:when test="text()='4'">April</xsl:when>
			<xsl:when test="text()='5'">May</xsl:when>
			<xsl:when test="text()='6'">June</xsl:when>
			<xsl:when test="text()='7'">July</xsl:when>
			<xsl:when test="text()='8'">August</xsl:when>
			<xsl:when test="text()='9'">September</xsl:when>
			<xsl:when test="text()='10'">October</xsl:when>
			<xsl:when test="text()='11'">November</xsl:when>
			<xsl:when test="text()='12'">December</xsl:when>
			<xsl:otherwise>
				<xsl:message>Unrecognized month values (<xsl:call-template name="RecordId"/>)</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="patentDetails/application/applicationDate">
		<xsl:text>	Year = {</xsl:text>
		<xsl:value-of select="substring(text(),1,4)"/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal/title">
		<xsl:if test="$journalMode=1 or not(../medlineAbbreviation or ../ISOAbbreviation)">
			<xsl:text>	Journal = {</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>},</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal/medlineAbbreviation">
		<xsl:if test="$journalMode=2">
			<xsl:text>	Journal = {</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>},</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal[not(medlineAbbreviation)]/ISOAbbreviation">
		<xsl:if test="$journalMode=2">
			<xsl:text>	Journal = {</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>},</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal/ISSN">
		<xsl:text>	ISSN = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal[not(ISSN)]/ESSN">
		<xsl:text>	ISSN = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/volume">
		<xsl:text>	Volume = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/issue">
		<xsl:text>	Number = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="pageInfo">
		<xsl:text>	Pages = {</xsl:text>
		<xsl:call-template name="EscapeCurlyBrackets">
			<xsl:with-param name="stringVal" select="translate(normalize-space(text()), '-', '—')"/>
		</xsl:call-template>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="doi">
		<xsl:text>	DOI = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/comprisingTitle">
		<xsl:param name="bibtexType"/>
		<!-- If statement required because some books have had their titles 
			 repeated in the comprisingTitle field. Can be removed if CIT-1167 is fixed.-->
		<xsl:if test="$bibtexType='incollection'">
			<xsl:text>	Booktitle = {</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>},</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/publisher">
		<xsl:param name="bibtexType"/>
		<xsl:choose>
			<xsl:when test="$bibtexType='techreport'">
				<xsl:text>	Institution = {</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>	Publisher = {</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/yearOfPublication">
		<xsl:text>	Year = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/isbn13">
		<xsl:text>	ISBN = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails[not(isbn13)]/isbn10">
		<xsl:text>	ISBN = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/edition">
		<xsl:text>	Edition = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/seriesName">
		<xsl:text>	Series = {</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>},</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="fullTextUrlList[fullTextUrl[not(documentStyle/text()='abs')]]">
		<xsl:if test="not($urlMode=1)">
			<xsl:text>	URL = {</xsl:text>
			<xsl:choose>
				<xsl:when test="fullTextUrl[site/text()='Europe_PMC' and documentStyle/text()='html']">
					<xsl:apply-templates select="fullTextUrl[site/text()='Europe_PMC' and documentStyle/text()='html'][1]/url/text()"/>
				</xsl:when>
				<xsl:when test="fullTextUrl[site/text()='Europe_PMC' and documentStyle/text()='pdf']">
					<xsl:apply-templates select="fullTextUrl[site/text()='Europe_PMC' and documentStyle/text()='pdf'][1]/url/text()"/>
				</xsl:when>
				<xsl:when test="fullTextUrl[site/text()='PubMedCentral' and documentStyle/text()='html']">
					<xsl:apply-templates select="fullTextUrl[site/text()='PubMedCentral' and documentStyle/text()='html'][1]/url/text()"/>
				</xsl:when>
				<xsl:when test="fullTextUrl[site/text()='PubMedCentral' and documentStyle/text()='pdf']">
					<xsl:apply-templates select="fullTextUrl[site/text()='PubMedCentral' and documentStyle/text()='pdf'][1]/url/text()"/>
				</xsl:when>
				<xsl:when test="fullTextUrl[not(availabilityCode/text()='S') and documentStyle/text()='doi']">
					<xsl:apply-templates select="fullTextUrl[not(availabilityCode/text()='S') and documentStyle/text()='doi'][1]/url/text()"/>
				</xsl:when>
				<xsl:when test="fullTextUrl[not(availabilityCode/text()='S') and not(documentStyle/text()='abs')]">
					<xsl:apply-templates select="fullTextUrl[not(availabilityCode/text()='S') and not(documentStyle/text()='abs')][1]/url/text()"/>
				</xsl:when>
				<xsl:when test="fullTextUrl[not(documentStyle/text()='abs')]">
					<xsl:apply-templates select="fullTextUrl[not(documentStyle/text()='abs')][1]/url/text()"/>
				</xsl:when>
			</xsl:choose>
			<xsl:text>},</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:param name="removePeriod" select="false()"/>
		<xsl:call-template name="EscapeCurlyBrackets">
			<xsl:with-param name="removePeriod" select="$removePeriod"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="*"></xsl:template>

	<!-- Matching templates above, named templates below -->
	
	<xsl:template name="RecordId">
		<xsl:param name="resultNode" select="./ancestor-or-self::result[parent::resultList]"/>
		<xsl:choose>
			<xsl:when test="$resultNode/source/text()='MED'">
				<xsl:text>PMID</xsl:text>
			</xsl:when>
			<xsl:when test="source/text()='PMC' or source/text()='UKPMC'">
				<xsl:text>PMCID</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$resultNode/source/text()"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$resultNode/id/text()"/>
	</xsl:template>
	
	<xsl:template name="MetadataUrl">
		<xsl:param name="resultNode" select="./ancestor-or-self::result[parent::resultList]"/>
		<xsl:text>http://europepmc.org/</xsl:text>
		<xsl:choose>
			<xsl:when test="$resultNode/source/text()='MED' or $resultNode/source/text()='AGR' or $resultNode/source/text()='PMC' or $resultNode/source/text()='UKPMC'">
				<xsl:text>abstract</xsl:text>
			</xsl:when>
			<xsl:when test="$resultNode/source/text()='PAT'">
				<xsl:text>patents</xsl:text>
			</xsl:when>
			<xsl:when test="$resultNode/source/text()='ETH'">
				<xsl:text>theses</xsl:text>
			</xsl:when>
			<xsl:when test="$resultNode/source/text()='HIR'">
				<xsl:text>guidelines</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>abstract</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="$resultNode/source/text()='UKPMC'">
				<xsl:text>PMC</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$resultNode/source/text()"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$resultNode/id/text()"/>
	</xsl:template>

	<xsl:template name="EscapeCurlyBrackets">
		<xsl:param name="stringVal" select="normalize-space(.)"/>
		<xsl:param name="removePeriod" select="false()"/>
		<!-- IF THIS IS TOO SLOW, REPLACE WITH THE NEXT LINE TO JUST STRIP OUT ALL CURLY BRACKETS:
		<xsl:value-of select="translate(normalize-space($stringVal), '{}', '')"/>
		-->
		<xsl:choose>
			<xsl:when test="contains($stringVal, '{')">
				<xsl:choose>
					<xsl:when test="starts-with($stringVal, '{')">
						<xsl:text>\{</xsl:text>
						<xsl:call-template name="EscapeCurlyBrackets">
							<xsl:with-param name="stringVal" select="substring-after($stringVal, '{')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="starts-with($stringVal, '}')">
						<xsl:text>\}</xsl:text>
						<xsl:call-template name="EscapeCurlyBrackets">
							<xsl:with-param name="stringVal" select="substring-after($stringVal, '}')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="substrBeforeOpenBracket" select="substring-before($stringVal, '{')"/>
						<xsl:variable name="substrBeforeCloseBracket" select="substring-before($stringVal, '}')"/>
						<xsl:choose>
							<xsl:when test="string-length($substrBeforeOpenBracket) &lt; string-length($substrBeforeCloseBracket) or string-length($substrBeforeCloseBracket) = 0">
								<xsl:value-of select="$substrBeforeOpenBracket"/>
								<xsl:text>\{</xsl:text>
								<xsl:call-template name="EscapeCurlyBrackets">
									<xsl:with-param name="stringVal" select="substring-after($stringVal, '{')"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$substrBeforeCloseBracket"/>
								<xsl:text>\}</xsl:text>
								<xsl:call-template name="EscapeCurlyBrackets">
									<xsl:with-param name="stringVal" select="substring-after($stringVal, '}')"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($stringVal, '}')">
				<xsl:value-of select="substring-before($stringVal, '}')"/>
				<xsl:text>\}</xsl:text>
				<xsl:call-template name="EscapeCurlyBrackets">
					<xsl:with-param name="stringVal" select="substring-after($stringVal, '}')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$removePeriod and substring($stringVal,string-length($stringVal))='.'">
				<xsl:value-of select="substring($stringVal,1,string-length($stringVal)-1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$stringVal"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	
	<!-- 
		Script: rest2ris.xsl
		Version: 1.0
		Status: Ready for production
		Summary: Transforms Europe PMC RESTful search responses (resulttype=core) to RIS format (compatible with Reference Manager and EndNote)
		Usage Notes: Set the includeHeader parameter to 'N' after the first page, when transforming multiple pages of RESTful responses, to be concatenated into a single file
		Issues: Cannot do book editors or original-language titles (as these are not in core response) and MEDLINE cataloguing of conference proceedings/papers is very patchy. Collectivename authors cause problems when imported into RefMan and EndNote. When ArticleDate is available in the web service, this should replace DA for EJOURs and added in an ET field for JOURs.
	-->
	
	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:param name="includeHeader" select="'Y'"/>
	<xsl:param name="maxAuthors"/>
	<xsl:param name="authorMode" select="2"/>	<!-- 1 = Surname, Initials, 2 = Surname, Firstnames (where available, if not initials) -->
	<xsl:param name="inclAbstracts" select="'N'"/>
	
	<xsl:variable name="newline" select="'&#13;&#10;'"/>
	
	<xsl:template match="/">
		<xsl:if test="$includeHeader='Y'">
			<xsl:text>Provider: Europe PMC</xsl:text>
			<xsl:value-of select="$newline"/>
			<xsl:text>Content: text/plain; charset="UTF-8"</xsl:text>
			<xsl:value-of select="$newline"/>
			<xsl:value-of select="$newline"/>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="responseWrapper|resultList">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="/responseWrapper/resultList/result">
		<xsl:variable name="risType">
			<xsl:choose>
				<xsl:when test="source/text()='HIR'">
					<xsl:text>RPRT</xsl:text>
				</xsl:when>
				<xsl:when test="source/text()='ETH'">
					<xsl:text>THES</xsl:text>
				</xsl:when>
				<xsl:when test="source/text()='CBA'">
					<xsl:text>ABST</xsl:text>
				</xsl:when>
				<xsl:when test="journalInfo">
					<xsl:choose>
						<xsl:when test="pubTypeList/pubType[text()='Congresses']">
							<xsl:text>CPAPER</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Overall']">
							<xsl:text>CONF</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Newspaper Article']">
							<xsl:text>NEWS</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Academic Dissertations']">
							<xsl:text>THES</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Abstract']">
							<xsl:text>ABST</xsl:text>
						</xsl:when>
						<xsl:when test="pubModel/text()='Electronic' or pubModel/text()='Electronic-eCollection'">
							<xsl:text>EJOUR</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>JOUR</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="patentDetails">
					<xsl:text>PAT</xsl:text>
				</xsl:when>
				<xsl:when test="bookOrReportDetails">
					<xsl:choose>
						<xsl:when test="pubTypeList/pubType[text()='Book Article']">
							<xsl:text>CHAP</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Book']">
							<xsl:text>BOOK</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Dissertation']">
							<xsl:text>THES</xsl:text>
						</xsl:when>
						<xsl:when test="pubTypeList/pubType[text()='Report']">
							<xsl:text>RPRT</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>GEN</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Cannot identify record type (<xsl:call-template name="RecordId"/>)</xsl:message>
					<xsl:text>GEN</xsl:text>
				</xsl:otherwise>	
			</xsl:choose>
		</xsl:variable>
		<xsl:text>TY  - </xsl:text>
		<xsl:value-of select="$risType"/>
		<xsl:value-of select="$newline"/>
		<xsl:apply-templates select="*[not(self::fullTextUrlList)]">
			<xsl:with-param name="risType" select="$risType"/>
		</xsl:apply-templates>
		<xsl:text>UR  - </xsl:text>
		<xsl:call-template name="MetadataUrl">
			<xsl:with-param name="resultNode" select="."/>
		</xsl:call-template>
		<xsl:value-of select="$newline"/>
		<xsl:apply-templates select="fullTextUrlList/fullTextUrl"/>
		<xsl:text>ER  - </xsl:text>
		<xsl:value-of select="$newline"/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
    
    <xsl:template match="abstractText">
		<xsl:text>AB  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>

	<xsl:template match="title">
		<xsl:text>TI  - </xsl:text>
		<xsl:apply-templates>
			<xsl:with-param name="removePeriod" select="true()"/>
		</xsl:apply-templates>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="authorList">
		<!-- NOTE: Suffixes (e.g. Jnr) are not included in individual authors in the core web response -->
		<!-- NOTE: If the web service included book editors, they would be output in A3 fields for books, and A2 fields for chapters -->
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
			<xsl:text>AU  - </xsl:text>
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
			<xsl:value-of select="$newline"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="affiliation">
		<xsl:param name="risType"/>
		<xsl:choose>
			<xsl:when test="$risType = 'PAT'">
				<xsl:text>PB  - </xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$newline"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>AD  - </xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$newline"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="id">
		<xsl:text>AN  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="source">
		<xsl:choose>
			<xsl:when test="text()='MED'">
				<xsl:text>DB  - PubMed</xsl:text>
				<xsl:value-of select="$newline"/>
			</xsl:when>
			<xsl:when test="text()='PMC'">
				<xsl:text>DB  - PubMed Central</xsl:text>
				<xsl:value-of select="$newline"/>
				</xsl:when>
			<xsl:when test="text()='AGR'">
				<xsl:text>DB  - AGRICOLA</xsl:text>
				<xsl:value-of select="$newline"/>
				</xsl:when>
			<xsl:when test="text()='CBA'">
				<xsl:text>DB  - Chinese Biological Abstracts</xsl:text>
				<xsl:value-of select="$newline"/>
				</xsl:when>
			<xsl:when test="text()='PAT'">
				<xsl:text>DB  - European Patent Office</xsl:text>
				<xsl:value-of select="$newline"/>
			</xsl:when>
			<xsl:when test="text()='ETH'">
				<xsl:text>DB  - EThOS</xsl:text>
				<xsl:value-of select="$newline"/>
			</xsl:when>
			<xsl:when test="text()='CIT'">
				<xsl:text>DB  - CiteSeer</xsl:text>
				<xsl:value-of select="$newline"/>
			</xsl:when>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="journalInfo|patentDetails|patentDetails/application|journalInfo/journal|bookOrReportDetails|meshHeadingList|meshHeading">
		<xsl:param name="risType"/>
		<!-- This template is for any container-elements which contain
			 fields matched by the templates below -->
		<xsl:apply-templates select="*[not(self::text())]">
			<xsl:with-param name="risType" select="$risType"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="journalInfo/yearOfPublication">
		<xsl:text>PY  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>


	<xsl:template match="journalInfo/monthOfPublication|bookOrReportDetails/monthOfPublication">
		<!-- Not currently working for books, see JIRA ticket: CIT-1182 -->
		<xsl:text>DA  - </xsl:text>
		<xsl:apply-templates select="../yearOfPublication/text()"/>
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="text()='0'">
				<!-- NOTE: Zero means unknown/imprecise publication month -->
				<xsl:text>//</xsl:text>
				<xsl:value-of select="normalize-space(translate(../dateOfPublication/text(), '0123456789', ''))"/>
			</xsl:when>
			<xsl:when test="number(text()) &lt; 10">
				<xsl:text>0</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>//</xsl:text>
			</xsl:when>
			<xsl:when test="number(text()) &lt; 13">
				<xsl:apply-templates/>
				<xsl:text>//</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Unrecognized month values (<xsl:call-template name="RecordId"/>)</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal/title">
		<xsl:param name="risType"/>
		<xsl:choose>
			<xsl:when test="$risType = 'JOUR' or $risType = 'ABST'">
				<!-- Could use T2 here as well, but most people seem to use JO -->
				<xsl:text>JO  - </xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$newline"/>
			</xsl:when>
			<xsl:when test="$risType = 'EJOUR'">
				<xsl:text>T2  - </xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$newline"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal/medlineAbbreviation">
		<xsl:text>J2  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal[not(medlineAbbreviation)]/ISOAbbreviation">
		<xsl:text>J2  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal/ISSN">
		<xsl:text>SN  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/journal[not(ISSN)]/ESSN">
		<xsl:text>SN  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/volume">
		<xsl:text>VL  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="journalInfo/issue">
		<xsl:text>IS  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="pageInfo">
		<xsl:choose>
			<xsl:when test="not(string-length(translate(text(),'0123456789-—', '')) = 0)">
				<!-- Page numbering field contains something other than digits and hyphens.
					 It cannot therefore be reliably parsed, so just output the whole thing -->
				<xsl:text>SP  - </xsl:text>
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains(text(), '-')">
						<xsl:text>SP  - </xsl:text>
						<xsl:value-of select="normalize-space(substring-before(text(), '-'))"/>
						<xsl:value-of select="$newline"/>
						<xsl:text>EP  - </xsl:text>
						<xsl:call-template name="SubstringAfterLast">
							<xsl:with-param name="instring" select="."/>
							<xsl:with-param name="substring" select="'-'"/>
							<xsl:with-param name="normalizespace" select="true()"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="contains(text(), '—')">
						<xsl:text>SP  - </xsl:text>
						<xsl:value-of select="normalize-space(substring-before(text(), '—'))"/>
						<xsl:value-of select="$newline"/>
						<xsl:text>EP  - </xsl:text>
						<xsl:call-template name="SubstringAfterLast">
							<xsl:with-param name="instring" select="."/>
							<xsl:with-param name="substring" select="'—'"/>
							<xsl:with-param name="normalizespace" select="true()"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>SP  - </xsl:text>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$newline"/>
	</xsl:template>

	<xsl:template match="doi">
		<xsl:text>DO  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="language">
		<xsl:text>LA  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<!-- NOTE: Despite what the RIS documentation says, RefMan doesn't seem to support PMCIDs in these fields, and EndNote only imports them
			for electronic journals (yet just because an article has a digital copy in PMC, that doesn't make it an electronically-published article
	<xsl:template match="pmcid">
		<xsl:param name="risType"/>
		<xsl:choose>
			<xsl:when test="$risType = 'JOUR' or $risType = 'ABST'">
				<xsl:text>C2  - </xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$newline"/>
			</xsl:when>
			<xsl:when test="$risType = 'EJOUR'">
				<xsl:text>C3  - </xsl:text>
				<xsl:apply-templates/>
				<xsl:value-of select="$newline"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	-->
	
	<xsl:template match="bookOrReportDetails/comprisingTitle">
		<xsl:param name="risType"/>
		<!-- If statement required because some books have had their titles 
			 repeated in the comprisingTitle field. Can be removed if CIT-1167 is fixed.-->
		<xsl:if test="$risType='CHAP'">
			<xsl:text>T2  - </xsl:text>
			<xsl:apply-templates/>
			<xsl:value-of select="$newline"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/publisher">
		<xsl:param name="risType"/>
		<xsl:text>PB  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/yearOfPublication">
		<xsl:text>PY  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
		<!-- The following is a workaround because monthOfPublication isn't currently available for books, see JIRA ticket: CIT-1182 -->
		<xsl:text>DA  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>///</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/isbn13">
		<xsl:text>SN  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails[not(isbn13)]/isbn10">
		<xsl:text>SN  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/edition">
		<xsl:text>ET  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/seriesName">
		<xsl:param name="risType"/>
		<xsl:choose>
			<xsl:when test="$risType = 'BOOK'">
				<xsl:text>T2  - </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>T3  - </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="bookOrReportDetails/numberOfPages">
		<xsl:text>SP  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="patentDetails/application/applicationDate">
		<xsl:text>PY  - </xsl:text>
		<xsl:value-of select="substring(text(),1,4)"/>
		<xsl:value-of select="$newline"/>
		<xsl:text>DA  - </xsl:text>
		<xsl:value-of select="substring(text(),1,4)"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="substring(text(),6,2)"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="substring(text(),9,2)"/>
		<xsl:text>/Application date</xsl:text>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="patentDetails/application/applicationNumber">
		<xsl:text>M1  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="patentDetails/priorityList/priorityNumber">
		<xsl:text>OP  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="fullTextUrl">
		<xsl:text>UR  - </xsl:text>
		<xsl:apply-templates select="url/text()"/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="meshHeadingList/meshHeading[majorTopic_YN='Y']/descriptorName">
		<xsl:text>KW  - </xsl:text>
		<xsl:apply-templates/>
		<xsl:value-of select="$newline"/>
	</xsl:template>
	
	<xsl:template match="collectiveName">
		<!-- NOTE: Prefixing with an equals sign is a workaround for RefMan, to prevent conversion of corporate author names to Surname, Firstnames pattern on import. 
				The supposed workaround for EndNote, putting a comma at the end, or doubling commas already in the name, does not seem to work on import of RIS files -->
		<xsl:text>=</xsl:text>
		<!-- NOTE: RIS documentation states each author should only be 255 chars long -->
		<xsl:value-of select="normalize-space(substring(text(),1,250))"/>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:param name="removePeriod" select="false()"/>
		<xsl:choose>
			<xsl:when test="$removePeriod and substring(.,string-length(.))='.'">
				<xsl:value-of select="normalize-space(substring(.,1,string-length(.)-1))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
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
	
	<xsl:template name="SubstringAfterLast">
		<xsl:param name="instring" select="."/>
		<xsl:param name="substring"/>
		<xsl:param name="normalizespace" select="false()"/>
		<xsl:choose>
			<xsl:when test="contains($instring, $substring)">
				<xsl:call-template name="SubstringAfterLast">
					<xsl:with-param name="instring" select="substring-after($instring, $substring)"/>
					<xsl:with-param name="substring" select="$substring"/>
					<xsl:with-param name="normalizespace" select="$normalizespace"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$normalizespace">
				<xsl:value-of select="normalize-space($instring)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$instring"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
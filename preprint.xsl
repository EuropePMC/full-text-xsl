<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsi xs xlink mml">

    <xsl:output method="html" indent="no" encoding="utf-8" omit-xml-declaration="yes"/>

    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="allcase" select="concat($smallcase, $uppercase)"/>
    <xsl:template name="month">
        <xsl:param name="num"/>
        <xsl:choose>
            <xsl:when test="$num=1">January</xsl:when>
            <xsl:when test="$num=2">February</xsl:when>
            <xsl:when test="$num=3">March</xsl:when>
            <xsl:when test="$num=4">April</xsl:when>
            <xsl:when test="$num=5">May</xsl:when>
            <xsl:when test="$num=6">June</xsl:when>
            <xsl:when test="$num=7">July</xsl:when>
            <xsl:when test="$num=8">August</xsl:when>
            <xsl:when test="$num=9">September</xsl:when>
            <xsl:when test="$num=10">October</xsl:when>
            <xsl:when test="$num=11">November</xsl:when>
            <xsl:when test="$num=12">December</xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:variable name="pprid" select="//article-meta/article-id[@pub-id-type='archive']"/>
    <xsl:variable name="filebase" select="concat('https://europepmc.org/docs/preprint/', $pprid, '/')"/>
    
    <xsl:template match="/">
      <div id="epmc-fulltext-container">
        <xsl:apply-templates/>
      </div>
    </xsl:template>
    
    <xsl:template match="article">
        <xsl:apply-templates select="front"/>
        <xsl:apply-templates select="body"/>
        <xsl:call-template name="supplementary-material"/>
        <xsl:apply-templates select="back"/>
    </xsl:template>
    
    <xsl:template match="back">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="front">
        <!--<xsl:call-template name="identifiers"/>
        <xsl:call-template name="authors"/>
        <xsl:call-template name="article-info-history"/>-->     
        <xsl:apply-templates select="article-meta"/>
    </xsl:template>
    
    <xsl:template name="identifiers">
        <xsl:variable name="doi" select="//article-meta/article-id[@pub-id-type='doi']"/>
        <div class="citeinfo">
         <p class="identifiers">
             <span class="ppr">
                 <xsl:text>PPRID: </xsl:text>
                 <xsl:value-of select="$pprid"/>
             </span>
             <span class="pubinfo">
                 <xsl:value-of select="//journal-meta/publisher/publisher-name"/>
                 <xsl:text> preprint, posted </xsl:text>
                 <xsl:apply-templates select="//article-meta/pub-date[@pub-type='preprint']"/>
             </span>
             <br/>
             <span class="doi">
                 <xsl:text>doi: </xsl:text>
                 <a href="{concat('https://doi.org/', $doi)}">
                     <xsl:value-of select="$doi"/>
                 </a>
             </span>
         </p>
        </div>
    </xsl:template>
    
    <xsl:template match="pub-date[@pub-type='preprint']">
        <xsl:value-of select="concat(year, ' ')"/>
        <xsl:call-template name="month">
            <xsl:with-param name="num" select="month"/>
        </xsl:call-template>
        <xsl:value-of select="concat(' ', day)"/>
    </xsl:template>
    
    <xsl:template match="article-meta">
    	<div class="preprint-meta">
        <xsl:apply-templates select="contrib-group/contrib[@contrib-type='editor']" mode="article-info-reviewing-editor"/>
        <!--<xsl:apply-templates select="permissions|abstract|kwd-group"/>-->
    	<xsl:apply-templates select="permissions|kwd-group"/>
    	</div>
    </xsl:template>
    
    <xsl:template name="authors">
        <div class="abs_link_metadata"><div><div class="abstract--authors clearfix"><div class="abstract--author-list">
            <div class="abstract--main-authors-list">
                <xsl:for-each select="//article-meta//contrib-group/contrib[@contrib-type='author']">
                    <div class="inline-block">
                        <xsl:if test="descendant::name">                        
                            <div style="display: none;" id="authspan{count(preceding-sibling::contrib)+1}">
                                <div class="author-refine-panel">
                                    <xsl:apply-templates select="." mode="author-refine"/>
                                </div>
                            </div>
                        </xsl:if>
                        <span>
                            <xsl:apply-templates select="*[position()=1]" mode="authorlist"/>                        
                        </span>
                    </div>
                    <xsl:if test="position()!=last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>        
                </div>
            <div class="abstract--author-affiliations">
                <a href="javascript:void(0)" class="abstract--author-affiliations-title" title="Click to toggle affiliation details.">
                    <xsl:text>Affiliations </xsl:text><i id="affiliations_switch" class="fa fa-caret-right"></i>
                </a>                
                <ul class="abstract--author-affiliation-list">
                    <xsl:apply-templates select="//aff" mode="afflist"/>                   
                </ul>
                <div class="abstract--close-affiliation-link">
                    <xsl:text>Close affiliations </xsl:text><i class="fa fa-close"></i>
                </div>
            </div>
        </div></div></div></div>
    </xsl:template>    
    
    <xsl:template match="contrib" mode="author-refine">
        <xsl:variable name="name" select="concat(name/given-names, ' ', name/surname)"/>
        <h3 class="author-refine-title" title="{$name}">
            <xsl:value-of select="$name"/>
        </h3>
        <div class="author-refine-content">
            <xsl:for-each select="//aff[parent::contrib-group]">
                <xsl:variable name="id" select="@id"/>
                <xsl:if test="not(//xref[@rid=$id])">
                    <xsl:apply-templates select="." mode="author-refine"/>
                </xsl:if>
            </xsl:for-each>
            <span class="author-refine-subtitle">
                <xsl:apply-templates select="(aff|xref[@ref-type='aff'])[1]" mode="author-refine"/>
            </span>
            <a class="author-refine-show-more">
                <xsl:text>More </xsl:text><i class="fa fa-caret-right"></i>
            </a>
            <ul class="author-refine-links">
                <xsl:apply-templates select="corresp[descendant::email]|xref[@ref-type='corresp']" mode="author-refine"/>
                <li class="author-refine-link-item">
                    <a href="/search?query=AUTH:%22{translate($name, ' ', '+')}%22&amp;page=1" class="author-refine-href">
                        <i class="fa fa-search author-refine-icon"></i>
                        <xsl:text>Find articles by '</xsl:text>
                        <xsl:value-of select="$name"/>
                        <xsl:text>'</xsl:text>
                    </a>
                </li>
                <!--<li class="author-refine-link-item">
                    <a href="/search?query=" class="author-refine-href">
                        <i class="fa fa-filter author-refine-icon"></i>
                        <xsl:text>Filter current search by '</xsl:text>
                        <xsl:value-of select="$name"/>
                        <xsl:text>'</xsl:text>
                    </a>
                </li>-->
            </ul>
        </div>
    </xsl:template>
    
    <xsl:template match="xref[@ref-type='aff']" mode="author-refine">
        <xsl:variable name="rid" select="@rid"/>
        <xsl:attribute name="title">
            <xsl:apply-templates select="//aff[@id=$rid]" mode="list-affs-title"/>
            <xsl:for-each select="following-sibling::xref[@ref-type='aff']">
                <xsl:variable name="id" select="@rid"/>
                <xsl:text>; </xsl:text>
                <xsl:apply-templates select="//aff[@id=$id]" mode="list-affs-title"/>
            </xsl:for-each>
            <xsl:for-each select="following-sibling::aff">
                <xsl:text>; </xsl:text>
                <xsl:apply-templates select="." mode="list-affs-title"/>
            </xsl:for-each>           
        </xsl:attribute>
        <xsl:apply-templates select="//aff[@id=$rid]" mode="list-affs"/>
        <xsl:for-each select="following-sibling::xref[@ref-type='aff']">
            <xsl:variable name="id" select="@rid"/>
            <xsl:text>; </xsl:text>
            <xsl:apply-templates select="//aff[@id=$id]" mode="list-affs"/>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::aff">
            <xsl:text>; </xsl:text>
            <xsl:apply-templates select="." mode="list-affs"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="aff" mode="author-refine">
        <xsl:attribute name="title">
            <xsl:apply-templates select="." mode="list-affs-title"/>
            <xsl:for-each select="following-sibling::aff">
                <xsl:text>; </xsl:text>
                <xsl:apply-templates select="." mode="list-affs-title"/>
            </xsl:for-each>
            <xsl:for-each select="following-sibling::xref[@ref-type='aff']">
                <xsl:variable name="id" select="@rid"/>
                <xsl:text>; </xsl:text>
                <xsl:apply-templates select="//aff[@id=$id]" mode="list-affs-title"/>
            </xsl:for-each>            
        </xsl:attribute>
        <xsl:apply-templates select="." mode="list-affs"/>
        <xsl:for-each select="following-sibling::aff">
            <xsl:text>; </xsl:text>
            <xsl:apply-templates select="." mode="list-affs"/>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::xref[@ref-type='aff']">
            <xsl:variable name="id" select="@rid"/>
            <xsl:text>; </xsl:text>
            <xsl:apply-templates select="//aff[@id=$id]" mode="list-affs"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="aff" mode="list-affs">
        <xsl:apply-templates select="text()|*[not(self::label)]"/>     
    </xsl:template>
    
    <xsl:template match="aff|*[not(self::label)]" mode="list-affs-title">
        <xsl:apply-templates mode="list-affs-title"/>     
    </xsl:template>
    
    <xsl:template match="label" mode="list-affs-title"/>
    
    <xsl:template match="text()" mode="list-affs-title">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="xref[@ref-type='corresp']" mode="author-refine">
        <xsl:variable name="rid" select="@rid"/>
        <xsl:if test="count(//corresp[@id=$rid]//email) = 1">
            <xsl:apply-templates select="//corresp[@id=$rid]" mode="author-refine"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="corresp" mode="author-refine">
        <li class="author-refine-link-item">
            <a href="mailto:dev@null" class="author-refine-href oemail">
                <xsl:variable name="email">
                    <xsl:call-template name="reverse">
                        <xsl:with-param name="rest" select="descendant::email"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="data-email">
                    <xsl:value-of select="$email"/>
                </xsl:attribute>
                <i class="fa fa-envelope author-refine-icon"></i>                
                <span><xsl:value-of select="$email"/></span>
            </a>
        </li>
    </xsl:template>
    
    <xsl:template match="name" mode="authorlist">
        <a href="{concat('/search?query=AUTH:%22', surname, '+', substring(given-names, 1, 1),'%22')}"
            data-target="authspan{count(parent::contrib/preceding-sibling::contrib)+1}">
            <xsl:attribute name="class">
                <xsl:text>abstract--affiliation-group</xsl:text>
                <xsl:for-each select="following-sibling::xref[@ref-type='aff']">
                    <xsl:variable name="rid" select="@rid"/>
                    <xsl:for-each select="//aff[@id=$rid]">
                        <xsl:text> abstract--affiliation-group-</xsl:text>
                        <xsl:value-of select="count(preceding::aff)"/>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:for-each select="following-sibling::aff">
                    <xsl:text> abstract--affiliation-group-</xsl:text>
                    <xsl:value-of select="count(preceding::aff)"/>
                </xsl:for-each>
                <xsl:for-each select="//aff[parent::contrib-group]">
                    <xsl:variable name="id" select="@id"/>
                    <xsl:if test="not(//xref[@rid=$id])">
                        <xsl:text> abstract--affiliation-group-</xsl:text>
                        <xsl:value-of select="count(preceding::aff)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:attribute>
            <span class="abstract--author-name"><xsl:value-of select="concat(surname, ' ', substring(given-names, 1, 1))"/></span>
            <xsl:for-each select="following-sibling::xref[@ref-type='aff']">
                <xsl:variable name="position">
                    <xsl:if test="position()=last()">
                        <xsl:text>last</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="rid" select="@rid"/>
                <xsl:for-each select="//aff[@id=$rid]">
                    <sup class="abstract--author-affiliation-index inline-block">
                        <xsl:value-of select="count(preceding::aff)+1"/>
                        <xsl:if test="$position!='last'">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </sup>
                </xsl:for-each>
            </xsl:for-each>
        </a>
        <xsl:variable name="corresp" select="following-sibling::xref[@ref-type='corresp']/@rid"/>
        <xsl:choose>
            <xsl:when test="following-sibling::corresp//email">
                <i class="fa fa-envelope author-refine-icon"></i>
            </xsl:when>
           <xsl:when test="//corresp[@id=$corresp]">
            	<xsl:choose>
            		<xsl:when test="count(//corresp[@id=$corresp]//email)=1">
            			<i class="fa fa-envelope author-refine-icon"></i>
            		</xsl:when>
            		<xsl:otherwise>
            			<a href="#author-notes"><i class="fa fa-envelope author-refine-icon"></i></a>
            		</xsl:otherwise>
            	</xsl:choose>            	
            </xsl:when>
            <xsl:when test="following-sibling::corresp">
                <a href="#author-notes"><i class="fa fa-envelope author-refine-icon"></i></a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="collab" mode="authorlist">
        <a href="{concat('/search?query=AUTH:%22', translate(., ' ', '+'), '%22')}">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>  
    
    <xsl:template match="aff" mode="afflist">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="count" select="'1'"/>
        <li class="abstract--author-affiliation-item">
            <div class="abstract--author-affiliation-text">
                <span class="abstract--author-affiliation-index">
                    <xsl:value-of select="count(preceding::aff)+1"/>
                    <xsl:text>.</xsl:text>
                </span>
                <span>
                    <xsl:apply-templates select="*[not(self::label)]|text()"/>
                </span>
            </div>
        </li>
    </xsl:template>

    <xsl:template match="article-meta/title-group/article-title">
        <div id="article-title">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="custom-meta-group">
        <xsl:if test="custom-meta[@specific-use='meta-only']/meta-name[text()='Author impact statement']/following-sibling::meta-value">
            <div id="impact-statement">
                <xsl:apply-templates select="custom-meta[@specific-use='meta-only']/meta-name[text()='Author impact statement']/following-sibling::meta-value/node()"/>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- Author list -->
    <xsl:template match="contrib-group[not(@content-type)]">
        <xsl:apply-templates/>
        <xsl:if test="contrib[@contrib-type='author'][not(@id)]">
            <div id="author-info-group-authors">
                <xsl:apply-templates select="contrib[@contrib-type='author'][not(@id)]"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='author'][not(@id)]">
        <xsl:apply-templates select="collab"/>
    </xsl:template>

    <xsl:template match="contrib//collab">
        <h4 class="equal-contrib-label">
            <xsl:apply-templates/>
        </h4>
        <xsl:variable name="contrib-id">
            <xsl:apply-templates select="../contrib-id"/>
        </xsl:variable>
        <xsl:if test="../../..//contrib[@contrib-type='author non-byline']/contrib-id[text()=$contrib-id]">
            <ul>
                <xsl:for-each
                        select="../../..//contrib[@contrib-type='author non-byline']/contrib-id[text()=$contrib-id]">
                    <li>
                        <xsl:if test="position()=1">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'first'"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="position()=last()">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'last'"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="../name/given-names"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="../name/surname"/>
                        <xsl:text>, </xsl:text>
                        <xsl:for-each select="../aff">
                            <xsl:call-template name="collabaff"/>
                            <xsl:if test="position() != last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template name="collabaff">
        <span class="aff">
            <xsl:for-each select="@* | node()">
                <xsl:choose>
                    <xsl:when test="name() = 'institution'">
                        <span class="institution">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:when>
                    <xsl:when test="name()='country'">
                        <span class="country">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:when>
                    <xsl:when test="name()='addr-line'">
                        <span class="addr-line">
                            <xsl:apply-templates mode="authorgroup"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="name()=''">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="{name()}">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

        </span>
    </xsl:template>

    <xsl:template match="addr-line/named-content" mode="authorgroup">
        <span class="named-content">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ==== FRONT MATTER START ==== -->

    <xsl:template match="surname | given-names | name">
        <span class="nlm-given-names">
            <xsl:value-of select="given-names"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="nlm-surname">
            <xsl:value-of select="surname"/>
        </span>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="name"/>
    </xsl:template>

    <!-- ==== Data set start ==== -->
    <xsl:template match="sec[@sec-type='datasets']">
        <div id="datasets">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="sec[@sec-type='datasets']/title"/>
    <xsl:template match="related-object">
        <span class="{name()}">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/collab">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/name">
        <span class="name">
            <xsl:value-of select="surname"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="given-names"/>
            <xsl:if test="suffix">
                <xsl:text> </xsl:text>
                <xsl:value-of select="suffix"/>
            </xsl:if>
        </span>
    </xsl:template>
    <xsl:template match="related-object/year">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/source">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/x">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/etal">
        <span class="{name()}">
            <xsl:text>et al.</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="related-object/comment">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/object-id">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- funding-group -->
    <xsl:template match="funding-group">
        <div id="author-info-funding">
            <ul class="funding-group">
                <xsl:apply-templates/>
            </ul>
            <xsl:if test="funding-statement">
                <p class="funding-statement">
                    <xsl:value-of select="funding-statement"/>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="funding-group/award-group">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="funding-source">
        <h4 class="funding-source">
            <xsl:apply-templates/>
        </h4>
    </xsl:template>
    <xsl:template match="funding-source/institution-wrap">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="institution">
        <span class="institution">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="award-id">
        <h5 class="award-id">
            <xsl:apply-templates/>
        </h5>
    </xsl:template>

    <xsl:template match="principal-award-recipient">
        <ul class="principal-award-recipient">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template
            match="principal-award-recipient/surname | principal-award-recipient/given-names | principal-award-recipient/name">
        <li class="name">
            <xsl:value-of select="given-names"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="surname"/>
        </li>
        <xsl:value-of select="name"/>
    </xsl:template>

    <xsl:template match="funding-statement" name="funding-statement">
        <p class="funding-statement">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!--  <xsl:template match="funding-statement"/>-->
    
    <!-- fn-group -->
    <!--<xsl:template name="article-info-identification">
        <xsl:variable name="doi" select="//article-meta/article-id[@pub-id-type='doi']"/>
        <div>
            <xsl:attribute name="id"><xsl:value-of select="'article-info-identification'"/></xsl:attribute>
            <div>
                <xsl:attribute name="class"><xsl:value-of select="'elife-article-info-doi'"/></xsl:attribute>
                <h4 class="info-label">DOI</h4> <div class="info-content"><a href="/lookup/doi/{$doi}"><xsl:value-of select="$doi"/></a></div>
            </div>
            <div>
                <xsl:attribute name="class"><xsl:value-of select="'elife-article-info-citeas'"/></xsl:attribute>
                <h4 class="info-label">Cite this as</h4> <div class="info-content"><xsl:call-template name="citation"/></div>
            </div>
        </div>
    </xsl:template>-->
    
    <xsl:template name="article-info-history">
        <div>
            <xsl:attribute name="id"><xsl:value-of select="'article-info-history'"/></xsl:attribute>
            <ul>
                <xsl:attribute name="class"><xsl:value-of select="'publication-history'"/></xsl:attribute>
                <xsl:for-each select="//history/date[@date-type]">
                    <xsl:apply-templates select="." mode="publication-history-item"/>
                </xsl:for-each>
                <xsl:apply-templates select="//article-meta/pub-date[@date-type]" mode="publication-history-item">
                    <xsl:with-param name="date-type" select="'published'"/>
                </xsl:apply-templates>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="date | pub-date" mode="publication-history-item">
        <xsl:param name="date-type" select="string(@date-type)"/>
        <li>
            <xsl:attribute name="class"><xsl:value-of select="$date-type"/></xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="concat($date-type, '-label')"/></xsl:attribute>
                <xsl:call-template name="camel-case-word"><xsl:with-param name="text" select="$date-type"/></xsl:call-template>
            </span>
            <xsl:text> </xsl:text>
            <xsl:call-template name="month">
                <xsl:with-param name="num" select="month"/>
            </xsl:call-template>
            <xsl:value-of select="concat( ' ', day, ', ', year, '.')"/>
        </li>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']">
        <div id="article-info-ethics">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']/fn">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']/title"/>
    <xsl:template match="contrib[@contrib-type='editor']" mode="article-info-reviewing-editor">
        <div id="article-info-reviewing-editor">
            <div>
                <xsl:attribute name="class"><xsl:value-of select="'elife-article-info-reviewingeditor-text'"/></xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="fn-group[@content-type='competing-interest']">
        <div id="author-info-competing-interest">
            <ul class="fn-conflict">
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='competing-interest']/fn">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <!-- permissions -->
    <xsl:template match="permissions">
        <div>
            <xsl:choose>
                <xsl:when test="parent::article-meta">
                    <xsl:attribute name="id">
                        <xsl:value-of select="'article-info-license'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">
                        <xsl:value-of select="'copyright-and-license'"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
            <xsl:if test="parent::article-meta">
                <xsl:apply-templates select="//body//permissions"/>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="permissions/copyright-statement">
        <!--<ul class="copyright-statement">
            <li>
                <xsl:apply-templates/>
            </li>
        </ul>-->
    </xsl:template>

    <xsl:template match="license">
        <div class="license">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="license-p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Affiliations -->
    <xsl:template match="aff[@id]">
        <div id="{@id}">
            <span class="aff">
                <xsl:apply-templates/>
            </span>
        </div>
    </xsl:template>

    <xsl:template match="aff" mode="affiliation-details">
        <span class="aff">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/institution">
        <span class="institution">
            <xsl:if test="@content-type">
                <xsl:attribute name="data-content-type">
                    <xsl:value-of select="@content-type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/addr-line">
        <span class="addr-line">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="addr-line/named-content">
        <span class="named-content">
            <xsl:if test="@content-type">
                <xsl:attribute name="data-content-type">
                    <xsl:value-of select="@content-type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/country">
        <span class="country">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/x">
        <span class="x">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff//bold">
        <span class="bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff//italic">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/email">
        <xsl:variable name="email">
            <xsl:apply-templates/>
        </xsl:variable>
        <!-- if parent contains more than just email then it should have a space before email -->
        <xsl:if test="string(..) != text() and not(contains(string(..), concat(' ', text())))">
            <xsl:text> </xsl:text>
        </xsl:if>
        <a href="mailto:{$email}" class="email">
            <xsl:copy-of select="$email"/>
        </a>
    </xsl:template>

    <!-- ==== FRONT MATTER END ==== -->

    <xsl:template match="abstract">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div data-doi="{$data-doi}">
            <xsl:choose>
                <xsl:when test="./title">
                	<xsl:variable name="id">
                		<xsl:value-of select="translate(translate(./title, $uppercase, $smallcase), ' ', '-')"/>
                	</xsl:variable>
                	<xsl:attribute name="id">
                		<xsl:value-of select="$id"/>
                	</xsl:attribute>
                	<h2 id="{concat($id,'title')}"><xsl:value-of select="title"/></h2>
                </xsl:when>
                <xsl:otherwise>
                	<xsl:variable name="id">
                		<xsl:value-of select="name(.)"/>
                	</xsl:variable>
                	<xsl:attribute name="id">
                		<xsl:value-of select="$id"/>
                	</xsl:attribute>
                	<h2 id="{concat($id,'title')}">Abstract</h2>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="kwd-group">
        <p>
            <strong>Keywords: </strong> 
            <xsl:for-each select="kwd">
                <xsl:apply-templates/>
                <xsl:if test="position()!=last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </p>
    </xsl:template>

    <!-- Start transforming sections to heading levels -->
<!--    <xsl:template match="supplementary-material">
        <xsl:variable name="id">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="supplementary-material" data-doi="{$data-doi}">
            <div class="supplementary-material-expansion" id="{$id}">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>-->

    <!-- No need to proceed sec-type="additional-information", sec-type="supplementary-material" and sec-type="datasets"-->
    <xsl:template match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')]
        [not(@sec-type='supplementary-material')][not(@sec-type='floats-group')]">
        <div>
            <xsl:if test="@sec-type">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('section ', ./@sec-type)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='sec-type'] | node()[not(self::label)]"/>
        </div>
    </xsl:template>

    <xsl:template match="sec/title | boxed-text/caption/title">
        <xsl:if test="node() != ''">
            <xsl:choose>
                <xsl:when test="ancestor::app">
                    <xsl:element name="h{count(ancestor::sec) + 3}">
                        <xsl:apply-templates select="@* | preceding-sibling::*[1][self::label] | node()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="h{count(ancestor::sec)+count(ancestor::abstract)+count(ancestor::boxed-text) + 1}">
                    	<xsl:attribute name="id">
                    		<xsl:value-of select="concat(parent::sec/@id, 'title')"/>
                    	</xsl:attribute>
                        <xsl:apply-templates select="@* | preceding-sibling::*[1][self::label] | node()"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>           
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="sec/label | ack/label | ref-list/label">
        <xsl:value-of select="."/>
        <xsl:text>. </xsl:text>
    </xsl:template>
    
    <xsl:template match="boxed-text/label">
        <xsl:if test="following-sibling::caption/title">
            <xsl:value-of select="."/>
            <xsl:text> </xsl:text>
        </xsl:if>        
    </xsl:template>
    
    <!-- END transforming sections to heading levels -->

    <xsl:template match="p">
        <xsl:if test="not(supplementary-material)">
            <p>
                <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                    <xsl:attribute name="class">
                        <xsl:value-of select="'first-child'"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="parent::list-item and preceding-sibling::*[1][self::label]">
                    <span class="list-label">
                        <xsl:value-of select="preceding-sibling::label"/>
                    </span>               
                </xsl:if>
                <xsl:if test="not(parent::list-item) and preceding-sibling::*[1][self::label]">
                    <span class="p-label">
                        <xsl:value-of select="preceding-sibling::label"/>
                        <xsl:text>: </xsl:text>
                    </span>                                        
                </xsl:if>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
        <xsl:if test="supplementary-material">
            <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                <xsl:attribute name="class">
                    <xsl:value-of select="'first-child'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ext-link">
        <xsl:if test="@ext-link-type = 'uri'">
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(@xlink:href, 'www.')">
                            <xsl:value-of select="concat('http://', @xlink:href)"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@xlink:href, 'doi:')">
                            <xsl:value-of select="concat('https://doi.org/', substring-after(@xlink:href, 'doi:'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@xlink:href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>
        <xsl:if test="@ext-link-type = 'doi'">
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(@xlink:href, '10.7554/')">
                            <xsl:value-of select="concat('/lookup/doi/', @xlink:href)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('https://doi.org/', @xlink:href)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>
    </xsl:template>

    <!-- START handling citation objects -->
    <xsl:template match="xref">
       <xsl:apply-templates select="." mode="testing"/>
    </xsl:template>
    <!-- END handling citation objects -->

    <!-- START Table Handling -->
    <xsl:template match="table-wrap">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="table-wrap" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
        </div>
    </xsl:template>

    <xsl:template match="table-wrap/label" mode="captionLabel">
        <span class="table-label">
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="caption">
        <xsl:choose>
            <!-- if article-title exists, make it as title.
                     Otherwise, make source -->
            <xsl:when test="parent::table-wrap">
                <xsl:if test="following-sibling::graphic">
                    <xsl:variable name="caption" select="parent::table-wrap/label/text()"/>
                    <xsl:variable name="filename" select="substring-before(concat(following-sibling::graphic/@xlink:href, '.'), '.')"/>
                    <xsl:variable name="graphics" select="concat($filebase,'image/',$filename)"/>
                    <!--<div class="fig-inline-img">
                        <img data-img="[graphic-{$filename}-small]" src="{concat($graphics, '-500.jpg')}" class="figure-expand" alt="{$caption}"/>                        
                    </div>-->
                    <a href="{concat($graphics,'.jpg')}" target="_blank" class="figure-expand" title="{$caption} - Click to open full size">
                        <img data-img="[graphic-{$filename}-medium]" src="{concat($graphics, '-700.jpg')}" alt="{$caption}"/>
                    </a>
                </xsl:if>
                <xsl:apply-templates select="parent::table-wrap/label" mode="captionLabel"/>
                <xsl:apply-templates select="title"/>
                <xsl:if test="child::*[not(self::title)]">
                    <div class="table-caption">
                        <xsl:apply-templates select="child::*[not(self::title)]"/>
                    </div>
                </xsl:if>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="table-wrap/table">
    	<div class="table-overflow">
	        <table>
	            <xsl:apply-templates/>
	        </table>
	    </div>
    </xsl:template>

    <!-- Handle other parts of table -->
    <xsl:template match="thead | tr">
        <xsl:copy>
            <xsl:if test="@style">
                <xsl:attribute name="style">
                    <xsl:value-of select="@style"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tbody">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="th | td">
        <xsl:copy>
            <xsl:if test="@rowspan">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rowspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@colspan">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@colspan"/>
                </xsl:attribute>
            </xsl:if>

            <!-- The author-callout-style-b family applies both background and foreground colour. -->
            <xsl:variable name="class">
                <xsl:if test="@align">
                    <xsl:value-of select="concat(' table-', @align)"/>
                </xsl:if>
                <xsl:if test="@style and starts-with(@style, 'author-callout-style-b')">
                    <xsl:value-of select="concat(' ', @style)"/>
                </xsl:if>
            </xsl:variable>

            <xsl:if test="$class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="substring-after($class, ' ')"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:if test="@style and not(starts-with(@style, 'author-callout-style-b'))">
                <xsl:attribute name="style">
                    <xsl:value-of select="@style"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- Handle Table FootNote -->
    <xsl:template match="table-wrap-foot">
        <div class="table-foot">
            <ul class="table-footnotes">
                <xsl:if test="descendant::label">
                    <xsl:attribute name="style">
                        <xsl:text>list-style-type:none;</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="table-wrap-foot/fn">
        <li class="fn">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="named-content">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="name()"/>
                <xsl:if test="@content-type">
                    <xsl:value-of select="concat(' ', @content-type)"/>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="inline-formula">
        <span class="inline-formula">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="disp-formula">
        <div class="disp-formula">
            <xsl:if test="@id">
                <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="label">
                <span class="disp-formula-label">
                    <xsl:value-of select="label/text()"/>
                </span>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="*[local-name()='math']">
        <span class="f mathjax mml-math">
            <xsl:text disable-output-escaping="yes">&lt;math xmlns="http://www.w3.org/1998/Math/MathML"&gt;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text disable-output-escaping="yes">&lt;/math&gt;</xsl:text>
        </span>
    </xsl:template>

    <!-- END Table Handling -->

    <!-- Start Figure Handling -->
    <!-- fig with atrtribute specific-use are supplement figures -->

    <!-- NOTE: PATH/LINK to be replaced -->
    <xsl:template match="fig-group">
        <!-- set main figure's DOI -->
        <xsl:variable name="data-doi" select="child::fig[1]/object-id[@pub-id-type='doi']/text()"/>
        <div class="fig-group" id="{concat('fig-group-', count(preceding::fig-group)+1)}" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
        </div>
    </xsl:template>

    <xsl:template match="fig | table-wrap | boxed-text | supplementary-material | media" mode="dc-description">
        <xsl:param name="doi"/>
        <xsl:variable name="data-dc-description">
            <xsl:if test="caption/title">
                <xsl:value-of select="concat(' ', caption/title)"/>
            </xsl:if>
            <xsl:for-each select="caption/p">
                <xsl:if test="not(ext-link[@ext-link-type='doi']) and not(.//object-id[@pub-id-type='doi'])">
                    <xsl:value-of select="concat(' ', .)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <div data-dc-description="{$doi}">
            <xsl:value-of select="substring-after($data-dc-description, ' ')"/>
        </div>
    </xsl:template>

    <!-- individual fig in fig-group -->

    <xsl:template match="fig">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="fig" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
        </div>
    </xsl:template>

    <!-- fig caption -->
    <xsl:template match="fig//caption">
        <xsl:variable name="graphic-type">
            <xsl:choose>
                <xsl:when test="substring-after(../graphic/@xlink:href, '.') = 'gif'">
                    <xsl:value-of select="'animation'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'graphic'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(parent::supplementary-material)">
                <div class="fig-caption">
                    <xsl:variable name="filename" select="substring-before(concat(following-sibling::graphic/@xlink:href, '.'), '.')"/>
        			<xsl:variable name="graphics" select="concat($filebase,'image/',$filename)"/>
                    <!-- three options -->
                    <span class="elife-figure-links">
                        <!--<span class="elife-figure-link elife-figure-link-download">
                            <a href="[{$graphic-type}-{$filename}-download]"><xsl:attribute name="download"/>Download figure</a>
                        </span>-->
                        <span class="elife-figure-link elife-figure-link-newtab">
                            <a href="{concat($graphics,'.jpg')}" target="_blank">Open in new tab</a>
                        </span>
                    </span>
                    <span class="fig-label">
                        <xsl:value-of select="../label/text()"/>
                        <xsl:if test="title"><xsl:text>:</xsl:text></xsl:if>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="../label" mode="supplementary-material"/>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="supplementary-material/label">
        <xsl:apply-templates select="." mode="supplementary-material"/>
    </xsl:template>

    <xsl:template match="label" mode="supplementary-material">
        <span class="supplementary-material-label">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <xsl:template match="fig//caption/title | supplementary-material/caption/title |  table-wrap/caption/title">
        <span class="caption-title">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- END Figure Handling -->

    <!-- body content -->
    <xsl:template match="body">
        <!--<div class="elife-article-decision-letter">
            <xsl:apply-templates select="*[not(self::supplementary-material)]"/>
        </div>-->
        <div id='main-text'>
            <div class="article fulltext-view">
                <xsl:apply-templates mode="testing" select="*[not(@sec-type='supplementary-material')][not(@sec-type='floats-group')]"/>
                <xsl:for-each select="//floats-group/* | //sec[@sec-type='floats-group']/*">
                    <xsl:variable name="rid" select="@id"/>
                    <xsl:if test="not(//body//xref[@rid=$rid])">                
                        <xsl:apply-templates select="." mode="testing"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:call-template name="appendices-main-text"/>
            </div>
        </div>
        <!--<div id="main-figures">
            <xsl:for-each select=".//fig[not(@specific-use)][not(parent::fig-group)] | .//fig-group">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </div>-->
    </xsl:template>

    <xsl:template
            match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')][not(@sec-type='supplementary-material')]
            [not(@sec-type='floats-group')]" mode="testing">
        <div>
            <xsl:if test="@sec-type">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('section ', translate(./@sec-type, '|', '-'))"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@sec-type)">
                <xsl:attribute name="class">
                    <xsl:value-of select="'subsection'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::label)]" mode="testing"/>
        </div>
    </xsl:template>

    <xsl:template match="p" mode="testing">
        <xsl:if test="not(supplementary-material)">
            <p>
                <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                    <xsl:attribute name="class">
                        <xsl:value-of select="'first-child'"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="testing"/>
            </p>
        </xsl:if>
        <xsl:if test="supplementary-material">
            <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                <xsl:attribute name="class">
                    <xsl:value-of select="'first-child'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:if>
        <xsl:if test="//floats-group or //sec[@sec-type='floats-group']">
	        <xsl:for-each select="descendant::xref[@ref-type='table' or @ref-type='fig' or @ref-type='boxed-text']">
	            <xsl:variable name="rid" select="@rid"/>
	            <xsl:if test="not(preceding::xref[@rid=$rid])">                
	                <xsl:apply-templates select="//*[@id=$rid]" mode="testing"/>
	            </xsl:if>
	        </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xref" mode="testing">
        <xsl:choose>
            <xsl:when test="ancestor::fn">
                <span class="xref-table">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="string">
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::text()[string-length(normalize-space(.)) > 1]">
                            <xsl:value-of select="preceding-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="preceding-sibling::text()[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="end" select="substring($string, string-length($string),1)"/>
                <xsl:variable name="orstring">
                    <xsl:choose>
                        <xsl:when test="following-sibling::text()[string-length(normalize-space(.)) > 1]">
                            <xsl:value-of select="following-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="following-sibling::text()[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="start" select="substring($orstring, 1,1)"/>
                <a>
                    <xsl:attribute name="class"> 
                       <xsl:value-of select="concat('xref-', ./@ref-type)"/>       
                       <xsl:choose>
                           <xsl:when test="($end='[' and $start=']') or ($end='(' and $start=')')"/>
                           <xsl:when test="number(.)=number(.)">
                               <xsl:text> super</xsl:text>
                           </xsl:when>
                       </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <!-- If xref has multiple elements in rid, then the link should points to 1st -->
                        <xsl:choose>
                            <xsl:when test="contains(@rid, ' ')">
                                <xsl:value-of select="concat('#',substring-before(@rid, ' '))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('#',@rid)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()[string-length(.)=1]
        [preceding-sibling::*[1][self::xref][number(.)=number(.)]]
        [following-sibling::*[1][self::xref][number(.)=number(.)]]" 
        mode="testing">
        <xsl:variable name="string">
            <xsl:choose>
                <xsl:when test="preceding-sibling::text()[string-length(normalize-space(.)) > 1]">
                    <xsl:value-of select="preceding-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="preceding-sibling::text()[position()=1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="end" select="substring($string, string-length($string),1)"/>
        <xsl:variable name="orstring">
            <xsl:choose>
                <xsl:when test="following-sibling::text()[string-length(normalize-space(.)) > 1]">
                    <xsl:value-of select="following-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="following-sibling::text()[position()=last()]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="start" select="substring($orstring, 1,1)"/>
        <xsl:choose>
            <xsl:when test="($end='[' and $start=']') or ($end='(' and $start=')')">
                <xsl:copy-of select="."/>                
            </xsl:when>
            <xsl:otherwise>
                <sup>
                    <xsl:copy-of select="."/>
                </sup>
            </xsl:otherwise>
        </xsl:choose>       
    </xsl:template>

    <xsl:template match="table-wrap" mode="testing">
        <div class="table-expansion table-overflow">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="boxed-text" mode="testing">
        <!-- For the citation links, take the id from the boxed-text -->
        <xsl:choose>
            <xsl:when test="child::object-id[@pub-id-type='doi']/text()!=''">
                <div class="boxed-text">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:attribute name="class">
                        <xsl:value-of select="'boxed-text'"/>
                        <xsl:if test="//article/@article-type != 'research-article' and .//inline-graphic">
                            <xsl:value-of select="' insight-image'"/>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="fig" mode="testing">
        <xsl:variable name="caption" select="child::label/text()"/>
        <xsl:variable name="id">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:variable name="graphic-type">
            <xsl:choose>
                <xsl:when test="substring-after(child::graphic/@xlink:href, '.') = 'gif'">
                    <xsl:value-of select="'animation'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'graphic'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="filename" select="substring-before(concat(child::graphic/@xlink:href, '.'), '.')"/>
        <xsl:variable name="graphics" select="concat($filebase,'image/',$filename)"/>
        <div id="{$id}" class="fig-inline-img-set">
            <div class="elife-fig-image-caption-wrapper">	            
                <div>
	                <xsl:attribute name="class">
		                <xsl:text>fig-expansion</xsl:text>
		                <xsl:if test="number(substring-after($id, 'F')) mod 2 = 0">
		                    <xsl:text> even</xsl:text>
		                </xsl:if>
		            </xsl:attribute>
                    <!--<div class="fig-inline-img">
                        <img data-img="[graphic-{$filename}-small]" src="{concat($graphics, '-500.jpg')}" class="figure-expand" alt="{$caption}"/>
                    </div>-->
                    <a href="{concat($graphics,'.jpg')}" target="_blank" class="figure-expand" title="{$caption} - Click to open full size">
                        <img data-img="[graphic-{$filename}-medium]" src="{concat($graphics, '-700.jpg')}" alt="{$caption}"/>
                    </a>
                </div>
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="fig-group" mode="testing">
        <!-- set main figure's DOI -->
        <div class="fig-inline-img-set-carousel">
            <div class="elife-fig-slider-wrapper">
                <div class="elife-fig-slider">
                    <div class="elife-fig-slider-img elife-fig-slider-primary">
                        <!-- use variables to set src and alt -->
                        <xsl:variable name="primaryid" select="concat('#', child::fig[not(@specific-use)]/@id)"/>
                        <xsl:variable name="primarycap" select="child::fig[not(@specific-use)]//label/text()"/>
                        <xsl:variable name="graphichref" select="substring-before(concat(child::fig[not(@specific-use)]/graphic/@xlink:href, '.'), '.')"/>
                        <a href="{$primaryid}">
                            <img src="[graphic-{$graphichref}-small]" alt="{$primarycap}"/>
                        </a>
                    </div>
                    <div class="figure-carousel-inner-wrapper">
                        <div class="figure-carousel">
                            <xsl:for-each select="child::fig[@specific-use]">
                                <!-- use variables to set src and alt -->
                                <xsl:variable name="secondarycap" select="child::label/text()"/>
                                <xsl:variable name="secgraphichref" select="substring-before(concat(child::graphic/@xlink:href, '.'), '.')"/>
                                <div class="elife-fig-slider-img elife-fig-slider-secondary">
                                    <a href="#{@id}">
                                        <img src="[graphic-{$secgraphichref}-small]" alt="{$secondarycap}"/>
                                    </a>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </div>
            </div>
            <div class="elife-fig-image-caption-wrapper">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="media" mode="testing">
        <xsl:choose>
            <xsl:when test="@mimetype != 'video'">
                <xsl:variable name="media-download-href"><xsl:value-of select="concat($filebase, 'media/', @xlink:href)"/></xsl:variable>
                <!-- if mimetype is application -->
                <span class="inline-linked-media-wrapper">
                    <a href="{$media-download-href}">
                        <xsl:attribute name="download"/>
                        Download source data<span class="inline-linked-media-filename">
                            <!--[<xsl:value-of
                                select="translate(translate(preceding-sibling::label, $uppercase, $smallcase), ' ', '-')"/>media-<xsl:value-of
                                select="count(preceding::media[@mimetype = 'application']) + 1"/>.<xsl:value-of
                                select="substring-after(@xlink:href, '.')"/>]-->
                        </span>
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <!-- otherwise -->
                <div class="media video-content">
                    <!-- set attribute -->
                    <xsl:attribute name="id">
                        <!-- <xsl:value-of select="concat('media-', @id)"/>-->
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <div class="media-inline video-inline">
                        <div class="elife-inline-video">
                            <xsl:text> [video-</xsl:text><xsl:value-of select="@id"/><xsl:text>-inline] </xsl:text>

                            <div class="elife-video-links">
                                <span class="elife-video-link elife-video-link-download">
                                    <a href="[video-{@id}-download]"><xsl:attribute name="download"/>Download Video</a>

                                </span>
                            </div>
                        </div>
                    </div>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Acknowledgement -->

    <xsl:template match="ack">
        <div id="ack-1">
            <h2>
                <xsl:apply-templates select="label"/>
                <xsl:choose>
                    <xsl:when test="title">
                        <xsl:value-of select="title"/>
                    </xsl:when>
                    <xsl:otherwise>Acknowledgments</xsl:otherwise>
                </xsl:choose>
            </h2>
            <xsl:apply-templates select="*[not(self::label or self::title)]"/>
            <xsl:for-each select="following-sibling::fn-group/fn[@fn-type='con']">
                <xsl:apply-templates/>
            </xsl:for-each>
            <xsl:if test="following-sibling::fn-group/fn[@fn-type='con'] and (//author-notes/fn[@fn-type='con'] | //author-notes/fn[@fn-type='equal'] | 
                //contrib[@equal-contrib='yes'])">        
                <div id="author-info-equal-contrib">
                    <xsl:apply-templates select="//author-notes/fn[@fn-type='con']"/>
                    <xsl:apply-templates select="//author-notes/fn[@fn-type='equal']"/>
                    <xsl:apply-templates select="//contrib[@equal-contrib='yes'][1]" mode="equal"/>
                </div>
            </xsl:if>                        
        </div>
        <xsl:apply-templates select="//author-notes"/>
        <xsl:if test="not(following-sibling::fn-group/fn[@fn-type='con']) and not(//author-notes)">
            <xsl:apply-templates select="//contrib[@equal-contrib='yes'][1]" mode="equal"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="back/fn-group">
        <xsl:if test="fn[not(@fn-type='con')]">
            <h2>Notes</h2>
            <xsl:apply-templates select="fn[not(@fn-type='con')]"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="back/fn-group/fn">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="back/fn-group/fn/p">
        <xsl:choose>
            <xsl:when test="bold and not(child::text())">
                <h3><xsl:value-of select="."/></h3>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:if test="count(preceding-sibling::*)=0 or preceding-sibling::*[1][self::label]">
                        <xsl:attribute name="id">
                            <xsl:value-of select="parent::fn/@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="preceding-sibling::*[1][self::label]">
                        <span class="fn-label">
                            <xsl:value-of select="preceding-sibling::label"/>
                        </span>
                        <xsl:text> </xsl:text>                                        
                    </xsl:if>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <!-- author-notes -->
    <xsl:template match="author-notes">
        <xsl:if test="fn[(@fn-type!='con' and @fn-type!='equal') or not(@fn-type)]|p|corresp">
            <h2 id="author-notes">Author Information</h2>
            <xsl:apply-templates select="p|corresp"/>
        </xsl:if>       
        <xsl:if test="not(//back/fn-group/fn[@fn-type='con']) and (fn[@fn-type='con'] | fn[@fn-type='equal'] | //contrib[@equal-contrib='yes'])">
            <h3>Author Contributions</h3>            
            <div id="author-info-equal-contrib">
                <xsl:apply-templates select="fn[@fn-type='con']"/>
                <xsl:apply-templates select="fn[@fn-type='equal']"/>
                <xsl:apply-templates select="//contrib[@equal-contrib='yes'][1]" mode="equal"/>
            </div>            
        </xsl:if> 
        <xsl:if test="fn[@fn-type='present-address']">
            <div id="author-info-additional-address">
                <xsl:apply-templates select="fn[@fn-type='present-address'][1]"/>
            </div>
        </xsl:if>
        <xsl:if test="fn[@fn-type='other'] | fn[@fn-type='deceased'] | fn[not(@fn-type)]">            
            <div id="author-info-other-footnotes">
                <xsl:apply-templates select="fn[@fn-type='other']"/>
                <xsl:apply-templates select="fn[@fn-type='deceased']"/>
                <xsl:apply-templates select="fn[not(@fn-type)]"/>
            </div>
        </xsl:if>
        <!--        <div id="author-info-contributions">
            <xsl:apply-templates select="ancestor::article/back//fn-group[@content-type='author-contribution']"/>
        </div>-->
    </xsl:template>
    
    <xsl:template match="fn[@fn-type='equal']">
        <xsl:variable name="contributeid" select="@id"/>
        <section class="equal-contrib">
            <p><xsl:text>The following authors contributed equally: </xsl:text></p>      
            <ul class="equal-contrib-list">
                <xsl:for-each select="../../contrib-group/contrib/xref[@rid=$contributeid]">
                    <li class="equal-contributor">
                        <xsl:value-of select="../name/given-names"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="../name/surname"/>
                    </li>
                </xsl:for-each>
            </ul>
        </section>
    </xsl:template>
    
    <xsl:template match="contrib" mode="equal">
        <xsl:variable name="contributeid" select="@id"/>
        <section class="equal-contrib">
            <p><xsl:text>The following authors contributed equally: </xsl:text></p>      
            <ul class="equal-contrib-list">
                <xsl:for-each select="ancestor::contrib-group/contrib[@equal-contrib='yes']">
                    <li class="equal-contributor">
                        <xsl:value-of select="name/given-names"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="name/surname"/>
                    </li>
                </xsl:for-each>
            </ul>
        </section>
    </xsl:template>
    
    <xsl:template match="fn-group[@content-type='author-contribution']">
        <ul class="fn-con">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="fn-group[@content-type='author-contribution']/fn">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    <xsl:template match="fn-group[@content-type='author-contribution']/fn/p">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="author-notes/fn[@fn-type='con']/p">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="author-notes/fn[@fn-type='other'] | author-notes/fn[@fn-type='deceased'] | author-notes/fn[not(@fn-type)]">
        <div class="foot-note" id="{@id}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="author-notes/fn[@fn-type='other']/p | author-notes/fn[@fn-type='deceased']/p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="author-notes/fn[not(@fn-type)]/p">
        <xsl:variable name="id" select="parent::fn/@id"/>
        <p>
            <xsl:for-each select="//contrib[xref[@rid=$id]]">
                <xsl:variable name="count" select="count(//contrib[xref[@rid=$id]])"/>
                <xsl:if test="$count &gt; 1 and position()=last()">
                    <xsl:text> and </xsl:text>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="name">
                        <xsl:value-of select="concat(name/given-names, ' ', name/surname)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="*[1]"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="position()=last()">
                        <xsl:text>: </xsl:text>
                    </xsl:when>
                    <xsl:when test="$count &gt; 2">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="author-notes/corresp">
        <p class="corresp">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="email[ancestor::corresp or ancestor::author-notes]">
        <xsl:variable name="email">
            <xsl:call-template name="reverse">
                <xsl:with-param name="rest" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <a href="mailto:dev@null" data-email="{$email}" class="oemail">
            <xsl:value-of select="$email"/>
        </a>        
    </xsl:template>    
    
    <xsl:template name="reverse">
        <xsl:param name="str"/>
        <xsl:param name="rest"/>
        <xsl:choose>
            <xsl:when test="$rest != ''">
                <xsl:call-template name="reverse">
                    <xsl:with-param name="str" select="concat($str,substring($rest,string-length($rest),1))"/>
                    <xsl:with-param name="rest" select="substring($rest,1,string-length($rest)-1)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='present-address']">
        <h3>Present Address</h3>
        <xsl:choose>
            <xsl:when test="following-sibling::fn[@fn-type='present-address']">
                <ul class="additional-address-items">
                    <xsl:for-each select="parent::author-notes/fn[@fn-type='present-address']">
                        <li><xsl:apply-templates/></li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:apply-templates/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="author-notes/fn[@fn-type='present-address']/p">
        <xsl:variable name="id" select="parent::fn/@id"/>
        <xsl:for-each select="//xref[@rid=$id]">
            <xsl:if test="parent::contrib/name">
                <strong><xsl:value-of select="concat(parent::contrib/name/given-names, ' ', parent::contrib/name/surname, ': ')"/></strong>
            </xsl:if>            
        </xsl:for-each>
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="author-notes/fn[@fn-type='present-address']/p/text()">
        <xsl:choose>
            <xsl:when test="starts-with(., 'Present address:')">
                <xsl:value-of select="substring-after(., 'Present address:')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- START Reference Handling -->

    <xsl:template match="ref-list">
        <div id="ref-list">
            <h2 id="ref-listtitle">
                <xsl:apply-templates select="label"/>
                <xsl:choose>
                    <xsl:when test="title">
                        <xsl:value-of select="title"/>
                    </xsl:when>
                    <xsl:otherwise>References</xsl:otherwise>
                </xsl:choose>
            </h2>
            <ol class="elife-reflinks-links" id="reference-list">
                <xsl:apply-templates select="*[not(self::label or self::title)]"/>
            </ol>
        </div>
    </xsl:template>

    <xsl:template match="ref">
        <li class="elife-reflinks-reflink" id="{@id}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="ref/element-citation">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="child::article-title">
                    <xsl:apply-templates select="child::article-title/node()"/>
                </xsl:when>
                <xsl:when test="child::source">
                    <xsl:apply-templates select="child::source/node()"/>
                </xsl:when>
                <xsl:when test="child::comment">
                    <xsl:apply-templates select="child::comment/node()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title-type">
            <xsl:choose>
                <xsl:when test="child::article-title">
                    <xsl:value-of select="'article-title'"/>
                </xsl:when>
                <xsl:when test="child::source">
                    <xsl:value-of select="'source'"/>
                </xsl:when>
                <xsl:when test="child::comment">
                    <xsl:value-of select="'comment'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <div class="reflink-main">

            <!-- call authors template -->

            <xsl:if test="person-group[@person-group-type='author']|collab">
                <span class="authors">
                    <xsl:for-each select="person-group[@person-group-type='author']">
                        <xsl:for-each select="name | collab">
                            <xsl:if test="position() != 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="name() = 'name'">
                                    <xsl:variable name="givenname" select="given-names"/>
                                    <xsl:variable name="surname" select="surname"/>
                                    <xsl:variable name="suffix" select="suffix"/>
                                    <xsl:variable name="fullname">
                                        <!--<xsl:choose>
                                            <xsl:when test="string($suffix) != ''">
                                                <xsl:value-of select="concat($surname, ' ', $givenname, ' ', $suffix)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat($surname, ' ', $givenname)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>-->
                                        <xsl:value-of select="concat($surname, ' ', $givenname)"/>
                                    </xsl:variable>
                                    <!--<xsl:variable name="hrefvalue" 
                                        select="concat('http://scholar.google.com/scholar?q=&quot;author:', $fullname, '&quot;')"/>
                                    <span class="elife-reflink-author">
                                        <a href="{$hrefvalue}" target="_blank">
                                            <xsl:value-of select="$fullname"/>
                                        </a>
                                    </span>-->
                                    <span class="reflink-author">
                                        <xsl:value-of select="$fullname"/>
                                    </span>
                                </xsl:when>
                                <xsl:when test="name() = 'collab'">
                                    <span class="reflink-author">
                                        <span class="nlm-collab">
                                            <xsl:apply-templates/>
                                        </span>
                                    </span>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:for-each select="collab">
                            <xsl:value-of select="."/>
                        </xsl:for-each>
                        <xsl:choose>
                            <xsl:when test="etal">
                                <xsl:text>, et al. </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>. </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </span>
            </xsl:if>
            
            <span class="elife-reflink-title">
            	<span class="nlm-{$title-type}">
            		<xsl:copy-of select="$title"/>
            	</span>
                <xsl:if test="not('.'=substring($title, string-length($title) - string-length('.') +1))">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:text> </xsl:text>
            </span>

            <!-- move all other elements into details div
                and comma separate
            -->
            <xsl:variable name="class">
                <xsl:if test="@publication-type">
                    <xsl:value-of select="'elife-reflink-details-journal'"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="includes">
                <xsl:if test="child::article-title and child::source">
                    <xsl:value-of select="'source|'"/>
                </xsl:if>
                <xsl:if test="child::publisher-name">
                    <xsl:value-of select="'publisher-name|'"/>
                </xsl:if>
                <xsl:if test="child::publisher-loc">
                    <xsl:value-of select="'publisher-loc|'"/>
                </xsl:if>
                <xsl:if test="child::year">
                    <xsl:value-of select="'year|'"/>
                </xsl:if>
            	<xsl:if test="child::month">
            		<xsl:value-of select="'month|'"/>
            	</xsl:if>
            	<xsl:if test="child::day">
            		<xsl:value-of select="'day|'"/>
            	</xsl:if>
                <xsl:if test="child::volume">
                    <xsl:value-of select="'volume|'"/>
                </xsl:if>
                <xsl:if test="child::issue">
                    <xsl:value-of select="'issue|'"/>
                </xsl:if>
                <xsl:if test="child::fpage">
                    <xsl:value-of select="'fpage|'"/>
                </xsl:if>
                <xsl:if test="child::lpage">
                    <xsl:value-of select="'lpage|'"/>
                </xsl:if>
            </xsl:variable>
            <xsl:if test="contains($includes, 'source|')">
                <span>
                    <xsl:if test="$class != ''">
                        <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
                    </xsl:if>
                    <span class="nlm-source">
                        <xsl:apply-templates select="child::source/node()"/>
                    </span>
                </span>
            </xsl:if>
            <xsl:if test="contains($includes, 'publisher-name|')">
                <xsl:if test="not(starts-with($includes, 'publisher-name|'))">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <span class="elife-reflink-details-pub-name">
                    <span class="nlm-publisher-name">
                        <xsl:apply-templates select="child::publisher-name/node()"/>
                    </span>
                </span>
            </xsl:if>
            <xsl:if test="contains($includes, 'publisher-loc|')">
                <xsl:if test="not(starts-with($includes, 'publisher-loc|'))">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <span class="elife-reflink-details-pub-loc">
                    <span class="nlm-publisher-loc">
                        <xsl:apply-templates select="child::publisher-loc/node()"/>
                    </span>
                </span>
            </xsl:if>
            <xsl:if test="contains($includes, 'year|')">
                <xsl:if test="not(starts-with($includes, 'year|'))">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <span class="elife-reflink-details-year">
                    <xsl:apply-templates select="child::year/node()"/>
                </span>
            </xsl:if>
        	<xsl:if test="contains($includes, 'month|')">
        		<xsl:if test="not(starts-with($includes, 'month|'))">
        			<xsl:text> </xsl:text>
        		</xsl:if>
        		<span class="reflink-details-month">
        			<xsl:apply-templates select="child::month/node()"/>
        		</span>
        	</xsl:if>
        	<xsl:if test="contains($includes, 'day|')">
        		<xsl:if test="not(starts-with($includes, 'day|'))">
        			<xsl:text> </xsl:text>
        		</xsl:if>
        		<span class="elife-reflink-details-year">
        			<xsl:apply-templates select="child::day/node()"/>
        		</span>
        	</xsl:if>
            <xsl:if test="contains($includes, 'volume|')">
                <xsl:if test="not(starts-with($includes, 'volume|'))">
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <span class="elife-reflink-details-volume">
                    <xsl:apply-templates select="child::volume/node()"/>
                </span>
            </xsl:if>
            <xsl:if test="contains($includes, 'issue|')">
                <xsl:if test="not(starts-with($includes, 'issue|'))">
                    <xsl:text>(</xsl:text>
                </xsl:if>
                <span class="elife-reflink-details-volume">
                    <xsl:apply-templates select="child::issue/node()"/>
                </span>
                <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:if test="contains($includes, 'fpage|')">
                <xsl:if test="not(starts-with($includes, 'fpage|'))">
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <span class="elife-reflink-details-pages">
                    <xsl:apply-templates select="child::fpage/node()"/>
                    <xsl:if test="contains($includes, 'lpage|')">
                        <xsl:text>-</xsl:text>
                        <xsl:apply-templates select="child::lpage/node()"/>
                    </xsl:if>
                </span>
            </xsl:if>
        	<xsl:apply-templates select="pub-id[@pub-id-type='doi']" mode="idlinks"/>
        	<xsl:apply-templates select="pub-id[not(@pub-id-type='doi')]" mode="idlinks"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
	
	<xsl:template match="pub-id" mode="idlinks">
		<xsl:choose>
			<xsl:when test="@pub-id-type='pmid'">
				<xsl:text> </xsl:text>
				<a href="http://europepmc.org/abstract/MED/{.}" target="_blank">
					<xsl:text>[Europe PMC Abstract]</xsl:text>
				</a>
			</xsl:when>
			<xsl:when test="@pub-id-type='doi'">
				<span class="elife-reflink-doi-cited-wrapper">
					<xsl:text> </xsl:text>
					<span class="elife-reflink-details-doi">
						<a href="https://doi.org/{.}" target="_blank">
							<xsl:text>https://doi.org/</xsl:text>
							<xsl:value-of select="."/>
						</a>
					</span>
				</span>
			</xsl:when>
			<xsl:when test="@pub-id-type='pmcid'">
				<xsl:text> </xsl:text>
				<a href="http://europepmc.org/articles/{.}" target="_blank">
					<xsl:text>[Europe PMC Full Text]</xsl:text>
				</a>
			</xsl:when>
			<xsl:when test="@pub-id-type='PPR'">
				<xsl:text> </xsl:text>
				<a href="http://europepmc.org/preprints/{.}" target="_blank">
					<xsl:text>[Europe PMC Preprint]</xsl:text>
				</a>
			</xsl:when>
			<xsl:when test="@pub-id-type='AGR'">
				<xsl:text> </xsl:text>
				<a href="http://europepmc.org/abstract/AGR/{.}" target="_blank">
					<xsl:text>[Europe PMC Abstract]</xsl:text>
				</a>
			</xsl:when>
		</xsl:choose>		
	</xsl:template>

    <!-- START video handling -->

    <xsl:template match="media">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <xsl:choose>
            <xsl:when test="@mimetype = 'video'">
                <div class="media" data-doi="{$data-doi}">
                    <xsl:apply-templates select="." mode="testing"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="testing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- media caption -->
    <xsl:template match="media/caption">
        <div class="media-caption">
            <span class="media-label">
                <xsl:value-of select="preceding-sibling::label"/>
            </span>
            <xsl:text> </xsl:text>

            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="media/caption/title">
        <span class="caption-title">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- END video handling -->

    <!-- START sub-article -->

    <xsl:template match="sub-article">
        <xsl:variable name="data-doi" select="child::front-stub/article-id[@pub-id-type='doi']/text()"/>
        <div data-doi="{$data-doi}">
            <!-- determine the attribute -->
            <xsl:attribute name="id">
                <xsl:if test="@article-type='article-commentary'">
                    <xsl:text>decision-letter</xsl:text>
                </xsl:if>
                <xsl:if test="@article-type='reply'">
                    <xsl:text>author-response</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>

        </div>
        <div class="panel-separator"></div>
    </xsl:template>

    <!-- sub-article body -->
    <xsl:template match="sub-article/body">
        <div>
            <xsl:attribute name="class">
                <xsl:if test="../@article-type='article-commentary'">
                    <xsl:text>elife-article-decision-letter</xsl:text>
                </xsl:if>
                <xsl:if test="../@article-type='reply'">
                    <xsl:text>elife-article-author-response</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <div class="article fulltext-view">
                <xsl:apply-templates/>
            </div>
        </div>
        <div>
            <xsl:attribute name="class">
                <xsl:if test="../@article-type='article-commentary'">
                    <xsl:text>elife-article-decision-letter-doi</xsl:text>
                </xsl:if>
                <xsl:if test="../@article-type='reply'">
                    <xsl:text>elife-article-author-response-doi</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <strong>DOI:</strong>
            <xsl:text> </xsl:text>

            <xsl:variable name="doino" select="preceding-sibling::*//article-id"/>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/lookup/doi/', $doino)"/>
                </xsl:attribute>
                <xsl:value-of select="concat('https://doi.org/', $doino)"/>
            </a>
        </div>
    </xsl:template>

    <!-- START sub-article author contrib information -->

    <xsl:template match="sub-article//contrib-group">
        <div class="elife-article-editors">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="sub-article//contrib-group/contrib">
        <div>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('elife-article-decision-reviewing', @contrib-type)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='editor']/name/given-names | contrib[@contrib-type='editor']/name/surname">
        <span class="nlm-given-names">
            <xsl:value-of select="given-names"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="nlm-surname">
            <xsl:value-of select="surname"/>
        </span>
        <xsl:if test="parent::suffix">
            <xsl:text> </xsl:text>
            <span class="nlm-surname">
                <xsl:value-of select="parent::suffix"/>
            </span>
        </xsl:if>
        <xsl:text>, </xsl:text>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='editor']//aff">
        <xsl:apply-templates select="child::*"/>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='editor']//role | contrib[@contrib-type='editor']//institution | 
        contrib[@contrib-type='editor']//country">
        <span class="nlm-{name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="not(parent::aff) or (parent::aff and following-sibling::*)">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- END sub-article author contrib information -->

    <!-- box text -->
    <xsl:template match="boxed-text">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <xsl:choose>
            <xsl:when test="$data-doi != ''">
                <div class="boxed-text">
                    <xsl:attribute name="data-doi">
                        <xsl:value-of select="$data-doi"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="." mode="testing"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="testing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="inline-graphic">
        <xsl:variable name="ig-variant">
            <xsl:choose>
                <xsl:when test="//article/@article-type = 'research-article'">
                    <xsl:value-of select="'research-'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'nonresearch-'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="ancestor::boxed-text">
                    <xsl:value-of select="'box'"/>
                </xsl:when>
                <xsl:when test="ancestor::fig">
                    <xsl:value-of select="'fig'"/>
                </xsl:when>
                <xsl:when test="ancestor::table-wrap">
                    <xsl:value-of select="'table'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'other'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        [inline-graphic-<xsl:value-of select="@xlink:href"/>-<xsl:value-of select="$ig-variant"/>]
    </xsl:template>

    <xsl:template name="appendices-main-text">
        <xsl:apply-templates select="//back/app-group/app" mode="testing"/>
    </xsl:template>

    <xsl:template match="app" mode="testing">
        <div class="section app">
            <xsl:if test="@id">
                <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="title">
                <h3><xsl:value-of select="title"/></h3>
            </xsl:if>
            <xsl:apply-templates mode="testing"/>
        </div>
    </xsl:template>

    <!-- START - general format -->

    <!-- list elements start-->

    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="@list-type = 'simple' or @list-type = 'bullet'">
                <ul>
                    <xsl:attribute name="style">
                        <xsl:text>list-style-type:</xsl:text>
                        <xsl:choose>
                            <xsl:when test="@list-type = 'simple'">
                                <xsl:text>none</xsl:text>
                            </xsl:when>
                            <xsl:when test="@list-type = 'bullet'">
                                <xsl:text>disc</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <ol>
                    <xsl:attribute name="style">
                        <xsl:text>list-style-type:</xsl:text>
                        <xsl:choose>
                            <xsl:when test="@list-type = 'order'">
                                <xsl:text>decimal</xsl:text>
                            </xsl:when>
                            <xsl:when test="@list-type = 'roman-lower'">
                                <xsl:text>lower-roman</xsl:text>
                            </xsl:when>
                            <xsl:when test="@list-type = 'roman-upper'">
                                <xsl:text>upper-roman</xsl:text>
                            </xsl:when>
                            <xsl:when test="@list-type = 'alpha-lower'">
                                <xsl:text>lower-alpha</xsl:text>
                            </xsl:when>
                            <xsl:when test="@list-type = 'alpha-upper'">
                                <xsl:text>upper-alpha</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </ol>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list-item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="bold">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>

    <xsl:template match="italic">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="underline">
        <span style="text-decoration:underline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="monospace">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>
    
    <xsl:template match="preformat">
        <pre>
            <xsl:apply-templates/>
        </pre>
    </xsl:template>

    <xsl:template match="styled-content">
        <span class="styled-content">
            <xsl:if test="@style">
                <xsl:attribute name="style">
                    <xsl:value-of select="@style"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="sup">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>

    <xsl:template match="sub">
        <sub>
            <xsl:apply-templates/>
        </sub>
    </xsl:template>

    <xsl:template match="break">
        <br/>
    </xsl:template>

    <xsl:template match="disp-quote">
        <xsl:text disable-output-escaping="yes">&lt;blockquote class="disp-quote"&gt;</xsl:text>
            <xsl:apply-templates/>
        <xsl:text disable-output-escaping="yes">&lt;/blockquote&gt;</xsl:text>
    </xsl:template>

    <xsl:template match="code">
        <xsl:choose>
            <xsl:when test="@xml:space = 'preserve'">
                <pre>
                    <code>
                        <xsl:apply-templates/>
                    </code>
                </pre>
            </xsl:when>
            <xsl:otherwise>
                <code>
                    <xsl:apply-templates/>
                </code>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- END - general format -->

    <xsl:template match="sub-article//title-group | sub-article/front-stub | fn-group[@content-type='competing-interest']/fn/p | 
        //history//*[@publication-type='journal']/article-title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="caption | table-wrap/table | table-wrap-foot | fn | bold | italic | underline | preformat | monospace | 
        styled-content | sub | sup | sec/title | ext-link | app/title | disp-formula | inline-formula | list | list-item | disp-quote | code" 
        mode="testing">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <!-- nodes to remove -->
    <xsl:template match="sec[@sec-type='supplementary-material'] | sec[@sec-type='floats-group']"/>
    <xsl:template match="back/fn-group/fn/label"/>
    <xsl:template match="aff/label"/>
    <xsl:template match="list-item/label"/>
    <xsl:template match="disp-formula/label"/>
    <xsl:template match="app/title"/>
    <xsl:template match="fn-group[@content-type='competing-interest']/title"/>
    <xsl:template match="permissions/copyright-year | permissions/copyright-holder"/>
    <xsl:template match="fn-group[@content-type='author-contribution']/title"/>
    <xsl:template match="author-notes/fn[@fn-type='con']/label"/>
    <xsl:template match="author-notes/fn[@fn-type='other']/label"/>
    <xsl:template match="author-notes/fn[not(@fn-type)]/label"/>
    <xsl:template match="author-notes/corresp/label"/>
    <xsl:template match="abstract/title"/>
    <xsl:template match="fig/graphic"/>
    <xsl:template match="fig-group//object-id | fig-group//graphic | fig//label"/>
    <xsl:template match="ack/title"/>
    <xsl:template match="ref-list/title"/>
    <xsl:template match="ref//label | ref//year | ref//article-title | ref//fpage | ref//volume | ref//issue | ref//source | ref//pub-id | 
        ref//lpage | ref//comment | ref//supplement | ref//person-group[@person-group-type='editor'] | ref//edition | ref//publisher-loc | 
        ref//publisher-name | ref//ext-link"/>
    <xsl:template match="person-group[@person-group-type='author'] | collab"/>
    <xsl:template match="media/label"/>
    <xsl:template match="sub-article//article-title"/>
    <xsl:template match="sub-article//article-id"/>
    <xsl:template match="object-id | table-wrap/label"/>
    <xsl:template match="funding-group//institution-wrap/institution-id"/>
    <xsl:template match="table-wrap/graphic"/>
    <xsl:template match="author-notes/fn[@fn-type='present-address']/label"/>
    <xsl:template match="author-notes/fn[@fn-type='deceased']/label"/>
    <xsl:template match="table-wrap-foot//fn/label"/>

    <xsl:template name="camel-case-word">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(substring($text, 1, 1), $smallcase, $uppercase)" />
        <xsl:value-of select="translate(substring($text, 2, string-length($text)-1), $uppercase, $smallcase)" />
    </xsl:template>

    <xsl:template name="citation">
        <xsl:variable name="year"><xsl:call-template name="year"/></xsl:variable>
        <xsl:variable name="citationid"><xsl:call-template name="citationid"/></xsl:variable>
        <xsl:value-of select="concat(//journal-meta/journal-title-group/journal-title, ' ', $year, ';', $citationid)"/>
    </xsl:template>

    <xsl:template name="year">
        <xsl:choose>
            <xsl:when test="//article-meta/pub-date[@date-type='pub']/year">
                <xsl:value-of select="//article-meta/pub-date[@date-type='pub']/year"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="//article-meta/permissions/copyright-year"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="volume">
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="//article-meta/volume">
                    <xsl:value-of select="//article-meta/volume"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="year"><call-template name="year"/></xsl:variable>
                    <xsl:value-of select="$year - 2011"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$value"/>
    </xsl:template>

    <xsl:template name="citationid">
        <xsl:variable name="volume"><xsl:call-template name="volume"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="//article-meta/pub-date[@pub-type='collection']/year">
                <xsl:value-of select="concat($volume, ':', //article-meta/elocation-id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="//article-meta/article-id[@pub-id-type='doi']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="supplementary-material">
        <xsl:if test="//supplementary-material[not(object-id)]">
            <div id="supplementary-material">
                <h2>Supplementary Material</h2>
                <ul class="supplementary-material">
                    <xsl:for-each select="//supplementary-material[not(object-id)]">
                        <li id="{@id}">
                        <xsl:choose>
                            <xsl:when test="ext-link">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('[', ext-link/@xlink:href, ']')"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="download"/>
                                    <xsl:apply-templates/>
                                </a>
                                <xsl:for-each select="../p">
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="label"/>
                                <xsl:if test="caption/title">
                                    <xsl:text>: </xsl:text>
                                </xsl:if>
                                <xsl:apply-templates select="caption/title"/>
                                <xsl:apply-templates select="media"/>
                                <xsl:apply-templates select="caption/*[not(self::title)]"/>                                    
                            </xsl:otherwise>
                        </xsl:choose>  
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="glossary">
        <sec id="glossary">
            <xsl:if test="not(title)">
                <h2>Glossary</h2>
            </xsl:if>
            <xsl:apply-templates/>
        </sec>
    </xsl:template>
    
    <xsl:template match="glossary/title">
        <h2><xsl:value-of select="."/></h2>
    </xsl:template>
    
    <xsl:template match="def-list">
        <dl><xsl:apply-templates/></dl>
    </xsl:template>
    
    <xsl:template match="def-item">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="def-item/term">
        <dt><xsl:value-of select="."/></dt>
    </xsl:template>
    
    <xsl:template match="def">
        <dd><xsl:apply-templates select="p/*|p/text()"/></dd>
    </xsl:template>
    
    <xsl:template match="mml:*">
        <xsl:element name="{local-name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>
    
   <xsl:template match="@* | text()">
        <xsl:copy></xsl:copy>
    </xsl:template>

</xsl:stylesheet>

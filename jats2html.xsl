<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsi xs xlink mml">

  <xsl:output method="html" indent="no" encoding="utf-8" omit-xml-declaration="yes"/>
  <xsl:param name="filelist"/>
  <xsl:param name="msspreview" select="false()"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="allcase" select="concat($smallcase, $uppercase)"/>
  <xsl:template name="month">
    <xsl:param name="num"/>
    <xsl:choose>
      <xsl:when test="$num = 1">January</xsl:when>
      <xsl:when test="$num = 2">February</xsl:when>
      <xsl:when test="$num = 3">March</xsl:when>
      <xsl:when test="$num = 4">April</xsl:when>
      <xsl:when test="$num = 5">May</xsl:when>
      <xsl:when test="$num = 6">June</xsl:when>
      <xsl:when test="$num = 7">July</xsl:when>
      <xsl:when test="$num = 8">August</xsl:when>
      <xsl:when test="$num = 9">September</xsl:when>
      <xsl:when test="$num = 10">October</xsl:when>
      <xsl:when test="$num = 11">November</xsl:when>
      <xsl:when test="$num = 12">December</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="emsid">
    <xsl:if test="//article-meta/article-id[@pub-id-type = 'manuscript']">
      <xsl:value-of select="translate(translate(//article-meta/article-id[@pub-id-type = 'manuscript'], 'ucpak', 'es'), 'ems', 'EMS')"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="pprid">
    <xsl:if test="starts-with(//article-meta/article-id[@pub-id-type='archive'], 'PPR')">
      <xsl:value-of select="//article-meta/article-id[@pub-id-type='archive']"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="ctxid">
    <xsl:choose>
      <xsl:when test="normalize-space($pprid) != ''"/>
      <xsl:when test="//article-meta/article-id[@pub-id-type='archive']">
        <xsl:value-of select="//article-meta/article-id[@pub-id-type='archive']"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="filebase">
    <xsl:if test="normalize-space($ctxid) != ''">
      <xsl:value-of select="concat('https://europepmc.org/docs/micropublications/', $ctxid, '/')"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="siteUrl">
    <xsl:if test="$msspreview">
      <xsl:text>https://europepmc.org</xsl:text>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="fn-symbols" select="'*†‡§‖¶'"/>

  <xsl:template name="get-symbol">
    <xsl:param name="count"/>
    <xsl:param name="current"/>
    <xsl:variable name="times" select="ceiling($count div 6)"/>
    <xsl:variable name="symbol" select="substring($fn-symbols, $count mod 6, 1)"/>
    <xsl:value-of select="$symbol"/>
    <xsl:if test="$current &lt; $times">
      <xsl:call-template name="get-symbol">
        <xsl:with-param name="count" select="$count"/>
        <xsl:with-param name="current" select="$current + 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-filename">
    <xsl:param name="string"/>
    <xsl:choose>
      <xsl:when test="normalize-space($ctxid) != ''">
        <xsl:value-of select="$string"/>
      </xsl:when>
      <xsl:when test="contains($string, '.')">
        <xsl:value-of select="substring-before($string, '.')"/>
        <xsl:if test="contains(substring-after($string, '.'), '.')">
          <xsl:text>.</xsl:text>
          <xsl:call-template name="get-filename">
            <xsl:with-param name="string" select="substring-after($string, '.')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$msspreview">
        <div id="xml-preview-body">
          <xsl:attribute name="class">
            <xsl:text>page_proper</xsl:text>
            <xsl:if test="normalize-space($pprid) != ''">
              <xsl:text> preprint</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <div class="epmc_pageHolder articleContentPage fullPage">
            <div class="epmc_wideLeft">
              <xsl:apply-templates/>
            </div>
          </div>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div id="epmc-fulltext-container">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="article">
    <xsl:apply-templates select="front"/>
    <xsl:apply-templates select="body"/>
    <xsl:call-template name="supplementary-material"/>
    <xsl:apply-templates select="back"/>
    <xsl:apply-templates select="sub-article"/>
  </xsl:template>

  <xsl:template match="front">
    <xsl:choose>
      <xsl:when test="normalize-space($emsid) != '' and normalize-space($pprid) = ''">
        <img src="https://europepmc.org/corehtml/pmc/pmcgifs/logo-wtpa2.gif"/>
        <div class="front-matter">
          <xsl:call-template name="identifiers"/>
          <xsl:apply-templates select="article-meta/title-group"/>
          <xsl:call-template name="authors"/>
          <xsl:apply-templates select="article-meta"/>
          <xsl:if test="not(article-meta/abstract)">
            <xsl:apply-templates select="article-meta/kwd-group"/>
          </xsl:if>
        </div>
        <xsl:if test="following-sibling::sub-article[@article-type='peer-review']">
          <xsl:call-template name="peer-review-summary"/>
        </xsl:if>
        <xsl:apply-templates select="article-meta/abstract"/>
      </xsl:when>
      <xsl:otherwise>
        <div class="front-matter">
          <xsl:call-template name="identifiers"/>
          <xsl:if test="normalize-space($pprid) != ''">
            <xsl:apply-templates select="article-meta/title-group"/>
          </xsl:if>
          <xsl:call-template name="authors"/>
          <xsl:apply-templates select="article-meta"/>
          <xsl:if test="not(following-sibling::back)">
            <xsl:apply-templates select="article-meta/author-notes"/>
            <xsl:apply-templates select="article-meta/contrib-group[@content-type='collab-list']"/>
            <xsl:apply-templates select="article-meta//collab/contrib-group" mode="collab-list-container"/>
          </xsl:if>
          <xsl:if test="not(article-meta/abstract) or normalize-space($ctxid) != ''">
            <xsl:apply-templates select="article-meta/kwd-group"/>
            <hr class="no_abstract"/>
          </xsl:if>
        </div>
        <xsl:if test="following-sibling::sub-article[@article-type='peer-review']">
          <xsl:call-template name="peer-review-summary"/>
        </xsl:if>
        <xsl:if test="normalize-space($ctxid) = ''">
          <xsl:apply-templates select="article-meta/abstract"/>
        </xsl:if>               
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="sub-article">
    <hr class="sub-article-divider"/>
    <div class="sub-article" id="{@id}">
      <xsl:apply-templates select="front-stub"/>
      <xsl:apply-templates select="body"/>
      <xsl:apply-templates select="back"/>
    </div>
  </xsl:template>

  <xsl:template name="identifiers">
    <xsl:variable name="doi">
      <xsl:if test="//article-meta/article-id[@pub-id-type='doi']">
        <span class="doi">
          <xsl:text>doi: </xsl:text>
          <a href="{concat('https://doi.org/', //article-meta/article-id[@pub-id-type='doi'])}" target="_blank">
            <xsl:value-of select="//article-meta/article-id[@pub-id-type='doi']"/>
          </a>
        </span>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($pprid) != ''">
        <div class="citeinfo">
          <p class="identifiers">
            <span class="ppr">
              <xsl:text>PPRID: </xsl:text>
              <xsl:value-of select="$pprid"/>
              <xsl:if test="normalize-space($emsid) != ''">
                <br/>
                <xsl:text>EMSID: </xsl:text>
                <xsl:value-of select="$emsid"/>
              </xsl:if>
            </span>
            <span class="pubinfo">
              <xsl:choose>
                <xsl:when test="//journal-meta/journal-id[@journal-id-type='nlm-ta']">
                  <xsl:value-of select="//journal-meta/journal-id[@journal-id-type='nlm-ta']"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="//journal-meta/journal-title-group/journal-title"/>
                </xsl:otherwise>
              </xsl:choose>              
              <xsl:text> preprint</xsl:text>
              <xsl:if test="//article-meta/article-version">
                <xsl:text>, version </xsl:text>
                <xsl:value-of select="//article-meta/article-version"/>
              </xsl:if>
              <xsl:if test="//article-meta/pub-date[@pub-type='preprint']">
                <xsl:text>,</xsl:text>
                <xsl:text> posted </xsl:text>
                <xsl:apply-templates select="//article-meta/pub-date[@pub-type='preprint']"/>
              </xsl:if>
            </span>
            <br/>
            <xsl:if test="$doi">
              <xsl:copy-of select="$doi"/>
            </xsl:if>
          </p>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <p class="citeinfo">
          <span class="identifiers">
            <span class="ppr">
              <xsl:if test="normalize-space($emsid) != ''">
                <xsl:text>EMSID: </xsl:text>
                <xsl:value-of select="$emsid"/>
              </xsl:if>
              <xsl:if test="normalize-space($ctxid) != ''">
                <xsl:text>CTXID: </xsl:text>
                <xsl:value-of select="$ctxid"/>
              </xsl:if>
              <xsl:apply-templates select="//article-meta/article-id"/>
            </span>
          </span>
          <span>
            <span class="pubinfo">
              <xsl:choose>
                <xsl:when test="//journal-meta/journal-id">
                  <xsl:value-of select="//journal-meta/journal-id"/>
                  <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="//journal-meta//journal-title"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text> </xsl:text>
              <xsl:value-of select="//article-meta/pub-date[1]/year"/>
              <xsl:for-each select="//article-meta[1]">
                <xsl:if test="volume or issue or fpage or elocation-id">
                  <xsl:if test="volume or issue">
                    <xsl:text>; </xsl:text>
                    <xsl:value-of select="volume"/>
                    <xsl:if test="issue">
                      <xsl:value-of select="concat('(', issue, ')')"/>
                    </xsl:if>
                  </xsl:if>
                  <xsl:if test="fpage or elocation-id">
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="elocation-id"/>
                    <xsl:value-of select="fpage"/>
                    <xsl:if test="lpage and lpage != fpage">
                      <xsl:text>-</xsl:text>
                      <xsl:value-of select="lpage"/>
                    </xsl:if>
                  </xsl:if>
                </xsl:if>
              </xsl:for-each>
              <xsl:text>.</xsl:text>
            </span>
            <br/>
            <xsl:for-each select="//article-meta/pub-date[@pub-type='epub' or @publication-format='electronic'][1]">
              <xsl:text>Published online </xsl:text>
              <xsl:value-of select="year"/>
              <xsl:if test="month or season">
                <xsl:text> </xsl:text>
                <xsl:call-template name="month">
                  <xsl:with-param name="num" select="month"/>
                </xsl:call-template>
                <xsl:value-of select="season"/>
                <xsl:if test="day">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="day"/>
                </xsl:if>
              </xsl:if>
              <xsl:text>. </xsl:text>
            </xsl:for-each>
            <xsl:if test="$doi">
              <xsl:copy-of select="$doi"/>
            </xsl:if>
          </span>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="pub-date">
    <xsl:value-of select="concat(year, ' ')"/>
    <xsl:call-template name="month">
      <xsl:with-param name="num" select="month"/>
    </xsl:call-template>
    <xsl:value-of select="concat(' ', day)"/>
  </xsl:template>

  <xsl:template match="article-meta">
    <xsl:apply-templates select="contrib-group/contrib[@contrib-type='reviewer'][1]" mode="article-info-reviewing-editor"/>
    <xsl:apply-templates select="contrib-group/contrib[@contrib-type='editor'][1]" mode="article-info-reviewing-editor"/>
    <xsl:apply-templates select="permissions"/>
  </xsl:template>
  
  <xsl:template match="article-meta/article-id[@pub-id-type='pmcid' or @pub-id-type='pmid']">
    <br/>
    <xsl:value-of select="translate(@pub-id-type, $smallcase, $uppercase)"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="article-meta/article-id[not(@pub-id-type='pmcid' or @pub-id-type='pmid')]"/>

  <xsl:template name="authors">
    <div class="fulltext--author-information">
      <xsl:choose>
        <xsl:when test="normalize-space($ctxid) != ''"/>
        <xsl:otherwise>
          <div>
            <xsl:apply-templates select="//article-meta//contrib-group[not(@content-type = 'collab-list' or parent::collab)][1]" mode="authorlist"/>
          </div>
          <div class="author-affiliations">
            <h2 id="fulltext--author-affiliations-title" role="button" tabindex="0">
              <xsl:if test="not($msspreview)">
                <xsl:attribute name="onclick">
                  <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
                </xsl:attribute>
              </xsl:if>
              <xsl:text>Affiliations</xsl:text>
            </h2>
            <ol class="affiliations">
              <xsl:attribute name="style">
                <xsl:choose>
                  <xsl:when test="normalize-space($pprid) != ''">
                    <xsl:text>list-style-type:none</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>text-indent:0</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:apply-templates select="//article-meta//aff[not(parent::contrib-group[@content-type='collab-list'] or ancestor::collab)][not(. = preceding::aff)]" mode="afflist"/>
            </ol>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="contrib-group" mode="authorlist">
    <xsl:choose>
      <xsl:when test="parent::*/contrib-group/on-behalf-of">
        <xsl:for-each select="parent::*/contrib-group[not(@content-type = 'collab-list' or parent::collab)]">
          <xsl:for-each select="contrib[@contrib-type = 'author']">
            <xsl:apply-templates select="*[position() = 1]" mode="authorlist"/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:if test="position() = last()-1">
              <xsl:text>and </xsl:text>
            </xsl:if>
            <xsl:if test="position() = last()">
              <xsl:apply-templates select="following-sibling::on-behalf-of"/>
            </xsl:if>
          </xsl:for-each>
          <xsl:if test="following-sibling::contrib-group[not(@content-type = 'collab-list')]">
            <xsl:text>. </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="parent::*/contrib-group[not(@content-type = 'collab-list' or parent::collab)]/contrib[@contrib-type = 'author']">
          <xsl:apply-templates select="*[position() = 1]" mode="authorlist"/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:if test="position() = last()-1">
            <xsl:text>and </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="node()" mode="make-url">
    <xsl:value-of select="translate(., ' &#xA;', '+')"/>
  </xsl:template>

  <xsl:template match="name|collab" mode="authorlist">
    <a>
      <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="self::name">
          <xsl:value-of select="concat($siteUrl,'/search?query=AUTH:%22', surname, '+', substring(given-names, 1, 1),'%22')"/>
        </xsl:when>
        <xsl:when test="self::collab">
          <xsl:variable name="collab-url">
            <xsl:apply-templates select="node()[not(self::contrib-group)]" mode="make-url"/>
          </xsl:variable>
          <xsl:value-of select="concat($siteUrl,'/search?query=AUTH:%22', $collab-url, '%22')"/>
        </xsl:when>
      </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="prefix"/>
      <span class="fulltext--author-name">
        <xsl:choose>
          <xsl:when test="self::name">
            <xsl:value-of select="concat(given-names, ' ', surname)"/>
            <xsl:apply-templates select="suffix"/>
          </xsl:when>
          <xsl:when test="self::collab">
            <xsl:apply-templates select="node()[not(self::contrib-group)]"/>
          </xsl:when>
        </xsl:choose>
      </span>
      <xsl:apply-templates select="following-sibling::degrees"/>  
    </a>
    <xsl:for-each select="following-sibling::aff | ancestor::contrib-group/aff[not(@id = //xref/@rid)] | following-sibling::xref[@ref-type='aff']">
      <xsl:variable name="position">
        <xsl:if test="position() = last()">
          <xsl:text>last</xsl:text>
        </xsl:if>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="self::aff">
          <xsl:variable name="current" select="."/>
          <xsl:choose>
            <xsl:when test="ancestor::contrib-group[@content-type='collab-list']/aff or ancestor::collab//aff">
              <xsl:apply-templates select="ancestor::contrib-group[@content-type='collab-list']/aff[not(. = preceding::aff)] | ancestor::collab//aff[not(. = preceding::aff)]" mode="list-xrefs">
                <xsl:with-param name="current" select="$current"/>
                <xsl:with-param name="position" select="$position"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="//article-meta//aff[not(ancestor::contrib-group[@content-type='collab-list'] or ancestor::collab)][not(. = preceding::aff)]" mode="list-xrefs">
                <xsl:with-param name="current" select="$current"/>
                <xsl:with-param name="position" select="$position"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>          
        </xsl:when>
        <xsl:when test="self::xref">
          <xsl:variable name="rid" select="@rid"/>
          <xsl:variable name="current" select="//aff[@id=$rid]"/>
          <xsl:choose>
            <xsl:when test="ancestor::contrib-group[@content-type='collab-list']/aff or ancestor::collab//aff">
              <xsl:apply-templates select="ancestor::contrib-group[@content-type='collab-list']/aff[not(. = preceding::aff)] | ancestor::collab//aff[not(. = preceding::aff)]" mode="list-xrefs">
                <xsl:with-param name="current" select="$current"/>
                <xsl:with-param name="position" select="$position"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="//article-meta//aff[not(ancestor::contrib-group[@content-type='collab-list'] or ancestor::collab)][not(. = preceding::aff)]" mode="list-xrefs">
                <xsl:with-param name="current" select="$current"/>
                <xsl:with-param name="position" select="$position"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>    
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:if test="parent::contrib[@id = //contrib-group[@content-type='collab-list']/contrib/@rid]">
      <xsl:text> </xsl:text>
      <a href="{concat('#', parent::contrib/@id)}">
        <sup class="inline-block">&#9432;</sup>
      </a>
    </xsl:if>
    <xsl:if test="child::contrib-group">
      <a href="{concat('#', 'collab', count(preceding::contrib-group[parent::collab]) + 1)}">
        <sup class="inline-block">&#9432;</sup>
      </a>
    </xsl:if>
    <xsl:if test="parent::contrib[@equal-contrib and @equal-contrib != 'no']">
      <xsl:text> </xsl:text>
      <a href="#author-info-equal-contrib">
        <sup class="inline-block">#</sup>
      </a>
    </xsl:if>
    <xsl:for-each select="following-sibling::xref[@ref-type = 'fn']">
      <xsl:variable name="rid" select="@rid"/>
      <xsl:choose>
        <xsl:when test=".='iD'">
          <xsl:text> </xsl:text>
          <a href="{concat('#', $rid)}"><sup class="inline-block">iD</sup></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="//fn[@id = $rid]">
            <xsl:if test="not(@fn-type) or (@fn-type != 'con' and @fn-type != 'present-address')">
              <xsl:variable name="count" select="count(preceding-sibling::fn[not(@fn-type)] |
                preceding-sibling::fn[(@fn-type != 'con' and @fn-type != 'present-address')]) + 1"/>
              <xsl:text> </xsl:text>
              <a href="{concat('#', $rid)}">
                <sup class="inline-block">
                  <xsl:call-template name="get-symbol">
                    <xsl:with-param name="count" select="$count"/>
                    <xsl:with-param name="current" select="1"/>
                  </xsl:call-template>
                </sup>
              </a>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:variable name="corresp" select="following-sibling::xref[@ref-type='corresp']/@rid"/>
    <xsl:choose>
      <xsl:when test="$msspreview">
        <xsl:choose>
          <xsl:when test="following-sibling::corresp//email">
            <xsl:text> </xsl:text>
            <a href="#{$corresp}">
              <sup class="inline-block"><big>&#9993;</big></sup>
            </a>
          </xsl:when>
          <xsl:when test="//corresp[@id = $corresp]">
            <xsl:text> </xsl:text>
            <a href="#{$corresp}">
              <sup class="inline-block"><big>&#9993;</big></sup>
            </a>
          </xsl:when>
          <xsl:when test="following-sibling::corresp">
            <xsl:text> </xsl:text>
            <a href="#{$corresp}">
              <sup class="inline-block"><big>&#9993;</big></sup>
            </a>
          </xsl:when>
          <xsl:when test="parent::contrib[@corresp and @corresp != 'no'] and //corresp">
            <a href="#{//corresp/@id}">
              <sup class="inline-block"><big>&#9993;</big></sup>
            </a>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="following-sibling::corresp//email">
            <xsl:text> </xsl:text>
            <a href="#author-notes"><sup class="inline-block"><i class="fas fa-envelope author-refine-icon"></i></sup></a>
          </xsl:when>
          <xsl:when test="//corresp[@id=$corresp]">
            <xsl:text> </xsl:text>
            <a href="#author-notes"><sup class="inline-block"><i class="fas fa-envelope author-refine-icon"></i></sup></a>
          </xsl:when>
          <xsl:when test="following-sibling::corresp">
            <xsl:text> </xsl:text>
            <a href="#author-notes"><sup class="inline-block"><i class="fas fa-envelope author-refine-icon"></i></sup></a>
          </xsl:when>
          <xsl:when test="parent::contrib[@corresp and @corresp != 'no'] and //corresp">
            <a href="#author-notes"><sup class="inline-block"><i class="fas fa-envelope author-refine-icon"></i></sup></a>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="following-sibling::on-behalf-of"/>
  </xsl:template>
  
  <xsl:template match="name/prefix">
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="contrib/degrees | name/suffix">
    <xsl:text>, </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="on-behalf-of">
    <xsl:if test="preceding-sibling::contrib">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="aff" mode="list-xrefs">
    <xsl:param name="current"/>
    <xsl:param name="position"/>
    <xsl:if test=". = $current">
      <xsl:text> </xsl:text>
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="@id">
              <xsl:value-of select="concat('#',@id)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('#', 'aff', position())"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:if test="not($msspreview) and normalize-space($pprid) != ''">
          <xsl:attribute name="onclick">
            <xsl:text>document.getElementById('</xsl:text>
            <xsl:choose>
              <xsl:when test="@id">
                <xsl:value-of select="@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('aff', position())"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>').closest('ol').previousElementSibling.classList.add('open')</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <sup class="fulltext--author-affiliation-index inline-block">
          <xsl:choose>
            <xsl:when test="normalize-space($pprid) = '' and label">
              <xsl:variable name="alpha" select="'abcdefghijklmnopqrstuvwxyz'"/>
              <xsl:choose>
                <xsl:when test="label and contains($alpha, label)">
                  <xsl:value-of select="label"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="position()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="position()"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="$position!='last'">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </sup>
      </a>
      <xsl:if test="$position!='last'">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>      
  </xsl:template>
  
  <xsl:template match="aff" mode="afflist">
    <xsl:param name="count"/>
    <xsl:choose>
      <xsl:when test="normalize-space($pprid) != ''">
        <li class="fulltext--author-affiliation-item">
          <xsl:attribute name="id">
            <xsl:choose>
              <xsl:when test="@id">
                <xsl:value-of select="@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('aff', position())"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <div class="fulltext--author-affiliation-text">
            <span class="fulltext--author-affiliation-index">
              <xsl:value-of select="position()"/>
              <xsl:text>.</xsl:text>
            </span><span><xsl:apply-templates select="*[not(self::label)]|text()"/></span>
          </div>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="alpha" select="'abcdefghijklmnopqrstuvwxyz'"/>
        <li>
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
          <xsl:if test="label and contains($alpha, label)">
            <xsl:attribute name="type">a</xsl:attribute>
            <xsl:attribute name="style">list-style-type:lower-alpha</xsl:attribute>
          </xsl:if>
          <xsl:if test="label">
            <xsl:attribute name="value">
              <xsl:choose>
                <xsl:when test="label and contains($alpha, label)">
                  <xsl:value-of select="string-length(substring-before($alpha, label))+1"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="position()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="*[not(self::label)] | text()"/>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="aff/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="aff//xref[@ref-type = 'fn']">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:choose>
      <xsl:when test=".='iD'">
        <xsl:text> </xsl:text>
        <a href="{concat('#', $rid)}">iD</a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="//fn[@id = $rid]">
          <xsl:if test="not(@fn-type) or (@fn-type != 'con' and @fn-type != 'present-address')">
            <xsl:variable name="count" select="count(preceding-sibling::fn[not(@fn-type)] |
              preceding-sibling::fn[(@fn-type != 'con' and @fn-type != 'present-address')]) + 1"/>
            <xsl:text> </xsl:text>
            <a href="{concat('#', $rid)}">
              <xsl:call-template name="get-symbol">
                <xsl:with-param name="count" select="$count"/>
                <xsl:with-param name="current" select="1"/>
              </xsl:call-template>              
            </a>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="meta-value" mode="review-map">
    <xsl:variable name="str" select="translate(., '-', ' ')"/>
    <xsl:value-of select="concat(translate(substring($str, 1, 1), $smallcase, $uppercase), substring($str, 2))"/>
  </xsl:template>
  
  <xsl:template name="peer-review-summary">
    <div id="prs">
      <h2 id="prstitle">Peer Review Summary</h2>
      <table class="peer-review-summary">
        <thead>
          <tr>
            <th>Date</th>
            <th>Reviewer</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="//sub-article[@article-type='peer-review']">
            <tr>
              <td>
                <xsl:apply-templates select="front-stub/pub-date"/>
              </td>
              <td>
                <xsl:apply-templates select="front-stub/contrib-group[1]/contrib[1]/name"/>
              </td>
              <td>
                <a href="{concat('#', @id)}">
                  <xsl:apply-templates
                    select="front-stub/custom-meta-group/custom-meta[meta-name='recommendation']/meta-value"
                    mode="review-map"
                  />
                </a>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
  
  <xsl:template match="front-stub">
    <div class="front-matter">
      <xsl:if test="article-id[@pub-id-type='doi']">
        <div class="citeinfo">
          <p class="identifiers">              
            <span class="doi">
              <xsl:text>doi: </xsl:text>
              <a href="{concat('https://doi.org/', article-id[@pub-id-type='doi'])}" target="_blank">
                <xsl:value-of select="article-id[@pub-id-type='doi']"/>
              </a>
            </span>
          </p>
        </div>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="parent::sub-article/@article-type='peer-review' and custom-meta-group/custom-meta[meta-name='recommendation']">
          <h1 class="sub-article-title">
            <xsl:apply-templates
              select="custom-meta-group/custom-meta[meta-name='recommendation']/meta-value"
              mode="review-map"
            />
          </h1>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title-group"/>
        </xsl:otherwise>
      </xsl:choose>      
      <div class="fulltext--author-information">
        <div>
          <xsl:for-each select="contrib-group/contrib[@contrib-type = 'author']">
            <xsl:apply-templates select="*[position() = 1]" mode="authorlist"/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:if test="position() = last()-1">
              <xsl:text>and </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </div>
        <ol class="affiliations">
          <xsl:if test="normalize-space($pprid) != ''">
            <xsl:attribute name="style">
              <xsl:text>list-style-type:none</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="descendant::aff[not(. = preceding::aff)]" mode="afflist"/>
        </ol>
      </div>
      <xsl:apply-templates select="contrib-group/contrib[@contrib-type='reviewer'][1]" mode="article-info-reviewing-editor"/>
      <xsl:apply-templates select="contrib-group/contrib[@contrib-type='editor'][1]" mode="article-info-reviewing-editor"/>
      <xsl:apply-templates select="permissions"/>
      <xsl:if test="not(following-sibling::back)">
        <xsl:apply-templates select="author-notes"/>
        <xsl:apply-templates select="contrib-group[@content-type='collab-list']"/>
        <xsl:apply-templates select="contrib-group//collab/contrib-group" mode="collab-list-container"/>
      </xsl:if>
      <xsl:if test="not(abstract)">
        <xsl:apply-templates select="kwd-group"/>
      </xsl:if>
    </div>
    <xsl:apply-templates select="abstract"/>
  </xsl:template>
  
  <xsl:template match="front-stub/title-group">
    <div class="sub-article-title-container">
      <xsl:apply-templates select="article-title"/>
      <xsl:apply-templates select="subtitle"/>
    </div>
  </xsl:template>

  <xsl:template match="article-meta/title-group">
    <div id="article-title">
      <xsl:apply-templates select="article-title"/>
      <xsl:apply-templates select="subtitle"/>
    </div>
  </xsl:template>
  
  <xsl:template match="front-stub/title-group/article-title">
    <h1 class="sub-article-title">
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="article-meta/title-group/article-title">
    <h1 class="article-title manuscript-title">
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="title-group/subtitle">
    <div class="article-submtitle manuscript-subtitle">
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
    <xsl:if test="../../..//contrib[@contrib-type = 'author non-byline']/contrib-id[text() = $contrib-id]">
      <ul>
        <xsl:for-each select="../../..//contrib[@contrib-type = 'author non-byline']/contrib-id[text() = $contrib-id]">
          <li>
            <xsl:if test="position() = 1">
              <xsl:attribute name="class">
                <xsl:value-of select="'first'"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="position() = last()">
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
          <xsl:when test="name() = 'country'">
            <span class="country">
              <xsl:value-of select="."/>
            </span>
          </xsl:when>
          <xsl:when test="name() = 'addr-line'">
            <span class="addr-line">
              <xsl:apply-templates mode="authorgroup"/>
            </span>
          </xsl:when>
          <xsl:when test="name() = ''">
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

  <xsl:template match="name">
    <span class="nlm-given-names">
      <xsl:value-of select="given-names"/>
    </span>
    <xsl:text> </xsl:text>
    <span class="nlm-surname">
      <xsl:value-of select="surname"/>
    </span>
  </xsl:template>

  <!-- ==== Data set start ==== -->
  <xsl:template match="sec[@sec-type = 'datasets']">
    <div id="datasets">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="sec[@sec-type = 'datasets']/title"/>
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
  <xsl:template match="principal-award-recipient/surname | principal-award-recipient/given-names | principal-award-recipient/name">
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

  <xsl:template name="article-info-history">
    <div>
      <xsl:attribute name="id">
        <xsl:value-of select="'article-info-history'"/>
      </xsl:attribute>
      <h2>History</h2>
      <ul>
        <xsl:attribute name="class">
          <xsl:value-of select="'publication-history'"/>
        </xsl:attribute>
        <xsl:apply-templates select="//article-meta/history/date[@date-type]" mode="publication-history-item"/>
        <xsl:apply-templates select="//article-meta/pub-date[@date-type]" mode="publication-history-item"/>
        <xsl:for-each select="//article-meta/pub-date[@pub-type and not(@date-type) and not(@pub-type='nihms-submitted')]">
          <xsl:apply-templates select="." mode="publication-history-item">
            <xsl:with-param name="date-type">
              <xsl:choose>
                <xsl:when test="contains(@pub-type, 'preprint')">posted</xsl:when>
                <xsl:when test="starts-with(@pub-type, 'e')">published_online</xsl:when>
                <xsl:when test="@pub-type = 'collection'">issue_date</xsl:when>
                <xsl:otherwise>published</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:for-each>
      </ul>
    </div>    
  </xsl:template>

  <xsl:template match="date | pub-date" mode="publication-history-item">
    <xsl:param name="date-type" select="string(@date-type)"/>
    <li>
      <xsl:attribute name="class">
        <xsl:value-of select="$date-type"/>
      </xsl:attribute>
      <span>
        <xsl:attribute name="class">
          <xsl:value-of select="concat($date-type, '-label')"/>
        </xsl:attribute>
        <xsl:call-template name="camel-case-word">
          <xsl:with-param name="text" select="translate($date-type, '_', ' ')"/>
        </xsl:call-template>
      </span>
      <xsl:text> </xsl:text>
      <xsl:call-template name="month">
        <xsl:with-param name="num" select="month"/>
      </xsl:call-template>
      <xsl:value-of select="concat(' ', day, ', ', year, '.')"/>
    </li>
  </xsl:template>
  <xsl:template match="fn-group[@content-type = 'ethics-information']">
    <div id="article-info-ethics">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="fn-group[@content-type = 'ethics-information']/fn">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="fn-group[@content-type = 'ethics-information']/title"/>
  
  <xsl:template match="contrib" mode="article-info-reviewing-editor">
    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="ancestor::article-meta/abstract">
          <xsl:text>p|b|span</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>div|h2|p</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="type" select="@contrib-type"/>
    <xsl:element name="{substring-before($level,'|')}">
      <xsl:attribute name="id"><xsl:value-of select="concat('article-info-reviewing-', $type)"/></xsl:attribute>
      <xsl:element name="{substring-before(substring-after($level, '|'), '|')}">
        <xsl:choose>
          <xsl:when test="$type = 'reviewer'">
            <xsl:text>Reviewed</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Edited</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> by </xsl:text>
      </xsl:element>
      <xsl:element name="{substring-after(substring-after($level, '|'),'|')}">
        <xsl:apply-templates select="node()"/>
        <xsl:for-each select="following::contrib[@contrib-type=$type]">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="node()"/>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="fn-group[@content-type = 'competing-interest']">
    <div id="author-info-competing-interest">
      <ul class="fn-conflict">
        <xsl:apply-templates/>
      </ul>
    </div>
  </xsl:template>
  <xsl:template match="fn-group[@content-type = 'competing-interest']/fn">
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
      <xsl:if test="not(parent::article-meta/abstract)">
        <h2>Copyright</h2>
      </xsl:if>
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
    <xsl:variable name="data-doi" select="child::object-id[@pub-id-type = 'doi']/text()"/>
    <div data-doi="{$data-doi}">
      <xsl:choose>
        <xsl:when test="./title">
          <xsl:variable name="id">
            <xsl:value-of select="translate(translate(./title, $uppercase, $smallcase), ' ', '-')"/>
          </xsl:variable>
          <xsl:attribute name="id">
            <xsl:value-of select="$id"/>
          </xsl:attribute>
          <h2 id="{concat($id,'title')}">
            <xsl:value-of select="title"/>
          </h2>
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
    <xsl:apply-templates select="parent::article-meta/kwd-group"/>
  </xsl:template>

  <xsl:template match="kwd-group">
    <p>
      <strong>
        <xsl:choose>
          <xsl:when test="title">
            <xsl:value-of select="title"/>
            <xsl:text>: </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Keywords: </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </strong>
      <xsl:for-each select="kwd">
        <xsl:apply-templates/>
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </p>
  </xsl:template>

  <!-- Start transforming sections to heading levels -->
  <!-- No need to proceed sec-type="additional-information", sec-type="supplementary-material" and sec-type="datasets"-->
  <xsl:template match="
      sec[not(@sec-type = 'additional-information')][not(@sec-type = 'datasets')]
      [not(@sec-type = 'supplementary-material')][not(@sec-type = 'floats-group')]">
    <div>
      <xsl:if test="@sec-type">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('section ', ./@sec-type)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="id">
        <xsl:choose>
            <xsl:when test="@id">
                <xsl:value-of select="@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('sec', count(preceding::sec))"/>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="@*[name() != 'sec-type' and name() !='id'] | node()[not(self::label)]"/>
    </div>
  </xsl:template>

  <xsl:template match="sec/title | boxed-text/caption/title">
    <xsl:if test="node() != ''">
      <xsl:choose>
        <xsl:when test="ancestor::app">
          <xsl:element name="h{count(ancestor::sec) + 3}">
            <xsl:apply-templates select="@* | preceding-sibling::*[1][self::label]"/>
            <xsl:apply-templates select="parent::caption/preceding-sibling::*[1][self::label]" mode="label-title"/>
            <xsl:apply-templates select="node()"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="h{count(ancestor::sec)+count(ancestor::abstract)+count(ancestor::boxed-text)+count(ancestor::ack) + 1}">
            <xsl:attribute name="id">
              <!-- marinos: micropubs have secs without @ids. Therefore, the html created
              has elements with the same id (which break the FT navigation menu.
              When there is no @id, I append a number to the 'title' to make it unique.
               -->
              <xsl:choose>
                <xsl:when test="parent::sec/@id">
                  <xsl:value-of select="concat(parent::sec/@id, 'title')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('sec', count(../preceding::sec), 'title')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@* | preceding-sibling::*[1][self::label]"/>
            <xsl:apply-templates select="parent::caption/preceding-sibling::*[1][self::label]" mode="label-title"/>
            <xsl:apply-templates select="node()"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="boxed-text/label"/>

  <xsl:template match="sec/label | ack/label | ref-list/label">
    <xsl:value-of select="."/>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="boxed-text/label" mode="label-title">
    <xsl:if test="following-sibling::caption/title">
      <xsl:value-of select="."/>
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- END transforming sections to heading levels -->

  <xsl:template match="p">
    <xsl:if test="not(supplementary-material)">
      <p>
        <xsl:if test="@id">
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
          <xsl:attribute name="class">
            <xsl:value-of select="'first-child'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="parent::list-item and preceding-sibling::*[1][self::label]">
          <span class="list-label">
            <xsl:apply-templates select="preceding-sibling::*[1][self::label]/node()"/>
          </span>
        </xsl:if>
        <xsl:if test="not(parent::list-item) and preceding-sibling::*[1][self::label]">
          <span class="p-label">
            <xsl:apply-templates select="preceding-sibling::*[1][self::label]/node()"/>
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
    <xsl:choose>
      <xsl:when test="@ext-link-type = 'doi'">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="concat('https://doi.org/', @xlink:href)"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
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
          <xsl:attribute name="target">
            <xsl:value-of select="'_blank'"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- START handling citation objects -->
  <xsl:template match="xref">
    <xsl:apply-templates select="." mode="testing"/>
  </xsl:template>
  <!-- END handling citation objects -->

  <!-- START Table Handling -->
  <xsl:template match="table-wrap">
    <xsl:variable name="data-doi" select="child::object-id[@pub-id-type = 'doi']/text()"/>
    <div class="table-wrap" data-doi="{$data-doi}">
      <xsl:apply-templates select="." mode="testing"/>
    </div>
  </xsl:template>

  <xsl:template match="table-wrap/label" mode="captionLabel">
    <span class="table-label">
      <xsl:apply-templates/>
      <xsl:text>.</xsl:text>
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
          <xsl:variable name="filename">
            <xsl:call-template name="get-filename">
              <xsl:with-param name="string" select="following-sibling::graphic/@xlink:href"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="graphics">
            <xsl:choose>
              <xsl:when test="$msspreview">
                <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($filebase,'image/',$filename, '.jpg')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <a href="{$graphics}" target="_blank" class="figure-expand" title="{$caption} - Click to open full size">
            <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="{$caption}"/>
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
        <xsl:apply-templates select="@rules | @frame | @style"/>
        <xsl:apply-templates/>
      </table>
    </div>
  </xsl:template>

  <!-- Handle other parts of table -->
  <xsl:template match="thead | tr | tbody | col | colgroup">
    <xsl:element name="{local-name()}">
      <xsl:if test="@style">
        <xsl:attribute name="style">
          <xsl:value-of select="@style"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@span">
        <xsl:attribute name="span">
          <xsl:value-of select="@span"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="th | td">
    <xsl:element name="{local-name()}">
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
      <xsl:if test="@style | @align | @valign">
        <xsl:attribute name="style">
          <xsl:if test="@align">
            <xsl:text>text-align:</xsl:text>
            <xsl:value-of select="concat(@align, ';')"/>
          </xsl:if>
          <xsl:if test="@valign">
            <xsl:text>vertical-align:</xsl:text>
            <xsl:value-of select="concat(@valign, ';')"/>
          </xsl:if>
          <xsl:value-of select="@style"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <!-- Handle Table FootNote -->
  <xsl:template match="table-wrap-foot">
    <div class="table-foot">
      <ul class="table-footnotes" style="list-style-type:none;">
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
    <span class="disp-formula">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="label">
        <span class="disp-formula-label">
          <xsl:value-of select="label/text()"/>
        </span>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="*[local-name() = 'math']">
    <span class="f mathjax mml-math">
      <xsl:attribute name="id">
        <xsl:value-of select="concat(parent::node()/@id, '-math')"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$msspreview">
          <xsl:text>&lt;math xmlns="http://www.w3.org/1998/Math/MathML"&gt;</xsl:text>
          <xsl:apply-templates mode="serialize"/>
          <xsl:text>&lt;/math&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text disable-output-escaping="yes">&lt;math xmlns="http://www.w3.org/1998/Math/MathML"&gt;</xsl:text>
          <xsl:apply-templates/>
          <xsl:text disable-output-escaping="yes">&lt;/math&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="mml:*">
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="*" mode="serialize">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="local-name(.)"/>
      <xsl:apply-templates select="@*" mode="serialize" />
      <xsl:choose>
          <xsl:when test="node()">
              <xsl:text>&gt;</xsl:text>
              <xsl:apply-templates mode="serialize" />
              <xsl:text>&lt;/</xsl:text>
              <xsl:value-of select="local-name(.)"/>
              <xsl:text>&gt;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
              <xsl:text> /&gt;</xsl:text>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template match="@*" mode="serialize">
      <xsl:text> </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="text()" mode="serialize">
      <xsl:value-of select="."/>
  </xsl:template>

  <!-- END Table Handling -->

  <!-- Start Figure Handling -->
  <!-- fig with atrtribute specific-use are supplement figures -->

  <!-- NOTE: PATH/LINK to be replaced -->
  <xsl:template match="fig-group">
    <!-- set main figure's DOI -->
    <xsl:variable name="data-doi" select="child::fig[1]/object-id[@pub-id-type = 'doi']/text()"/>
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
        <xsl:if test="not(ext-link[@ext-link-type = 'doi']) and not(.//object-id[@pub-id-type = 'doi'])">
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
    <xsl:variable name="data-doi" select="child::object-id[@pub-id-type = 'doi']/text()"/>
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
          <xsl:variable name="filename">
            <xsl:call-template name="get-filename">
              <xsl:with-param name="string" select="following-sibling::graphic/@xlink:href"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="graphics">
            <xsl:choose>
              <xsl:when test="$msspreview">
                <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($filebase,'image/',$filename)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <span class="elife-figure-links">
            <span class="elife-figure-link elife-figure-link-newtab">
              <a target="_blank">
                <xsl:attribute name="href">
                  <xsl:choose>
                    <xsl:when test="$msspreview">
                      <xsl:value-of select="$graphics"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat($graphics,'.jpg')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:text>Open in new tab</xsl:text>
              </a>
            </span>
          </span>
          <span class="fig-label">
            <xsl:value-of select="../label/text()"/>
            <xsl:if test="../label/text() and title">
              <xsl:text>: </xsl:text>
            </xsl:if>
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

  <xsl:template match="fig//caption/title | supplementary-material/caption/title | table-wrap/caption/title">
    <span class="caption-title">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- END Figure Handling -->

  <!-- body content -->
  <xsl:template match="body">
    <xsl:if test="child::*[position()=1][self::p]">
      <hr />
    </xsl:if>
    <div id="main-text">
      <div class="article fulltext-view">
        <xsl:apply-templates mode="testing" select="*[not(@sec-type = 'supplementary-material')][not(@sec-type = 'floats-group')]"/>
        <xsl:for-each select="//floats-group/* | //sec[@sec-type = 'floats-group']/*">
          <xsl:variable name="rid" select="@id"/>
          <xsl:if test="not(//body//xref[@rid = $rid])">
            <xsl:apply-templates select="." mode="testing"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="appendices-main-text"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="
      sec[not(@sec-type = 'additional-information')][not(@sec-type = 'datasets')][not(@sec-type = 'supplementary-material')]
      [not(@sec-type = 'floats-group')]" mode="testing">
    <div>
      <xsl:if test="@sec-type">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('section ', translate(./@sec-type, '|', '-'))"/>
        </xsl:attribute>
      </xsl:if>
        <xsl:attribute name="id">
            <xsl:choose>
                <xsl:when test="@id">
                    <xsl:value-of select="@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('sec', count(preceding::sec))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
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
    <xsl:if test="not(ancestor::list-item)">
      <xsl:if test="//floats-group or //sec[@sec-type = 'floats-group']">
        <xsl:for-each select="descendant::xref[@ref-type = 'table' or @ref-type = 'fig' or @ref-type = 'boxed-text']">
          <xsl:variable name="rid" select="@rid"/>
          <xsl:if test="not(preceding::xref[@rid = $rid])">
            <xsl:apply-templates select="//*[@id = $rid][@position != 'anchor']" mode="testing"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xref" mode="testing">
    <xsl:choose>
      <xsl:when test="ancestor::fn and ancestor::table">
        <span class="xref-table">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <!--<xsl:variable name="string">
          <xsl:choose>
            <xsl:when test="preceding-sibling::text()[string-length(normalize-space(.)) > 1]">
              <xsl:value-of select="preceding-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="preceding-sibling::text()[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="end" select="substring($string, string-length($string), 1)"/>
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
        <xsl:variable name="start" select="substring($orstring, 1, 1)"/>-->
        <a>
          <!--<xsl:attribute name="class">
            <xsl:value-of select="concat('xref-', ./@ref-type)"/>
            <xsl:choose>
              <xsl:when test="($end = '[' and $start = ']') or ($end = '(' and $start = ')')"/>
              <xsl:when test="number(.) = number(.)">
                <xsl:text> super</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>-->
          <xsl:attribute name="href">
            <!-- If xref has multiple elements in rid, then the link should points to 1st -->
            <xsl:choose>
              <xsl:when test="contains(@rid, ' ')">
                <xsl:value-of select="concat('#', substring-before(@rid, ' '))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('#', @rid)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="
      text()[string-length(.) = 1]
      [preceding-sibling::*[1][self::xref][number(.) = number(.)]]
      [following-sibling::*[1][self::xref][number(.) = number(.)]]" mode="testing">
    <xsl:variable name="string">
      <xsl:choose>
        <xsl:when test="preceding-sibling::text()[string-length(normalize-space(.)) > 1]">
          <xsl:value-of select="preceding-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="preceding-sibling::text()[position() = 1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="end" select="substring($string, string-length($string), 1)"/>
    <xsl:variable name="orstring">
      <xsl:choose>
        <xsl:when test="following-sibling::text()[string-length(normalize-space(.)) > 1]">
          <xsl:value-of select="following-sibling::text()[string-length(normalize-space(.)) > 1][1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="following-sibling::text()[position() = last()]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="start" select="substring($orstring, 1, 1)"/>
    <xsl:choose>
      <xsl:when test="($end = '[' and $start = ']') or ($end = '(' and $start = ')')">
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

  <xsl:template match="fig" mode="testing">
    <xsl:variable name="caption" select="child::label/text()"/>
    <xsl:variable name="id">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <div id="{$id}" class="fig-inline-img-set">
      <div class="elife-fig-image-caption-wrapper">
        <div>
          <xsl:attribute name="class">
            <xsl:text>fig-expansion</xsl:text>
            <xsl:if test="number(substring-after($id, 'F')) mod 2 = 0">
              <xsl:text> even</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <xsl:for-each select="child::graphic">
            <xsl:variable name="filename">
              <xsl:call-template name="get-filename">
                <xsl:with-param name="string" select="@xlink:href"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="graphics">
              <xsl:choose>
                <xsl:when test="$msspreview">
                  <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($filebase,'image/',$filename)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <a target="_blank" class="figure-expand" title="{$caption} - Click to open full size">
              <xsl:choose>
                <xsl:when test="$msspreview">
                  <xsl:attribute name="href">
                    <xsl:value-of select="$graphics"/>
                  </xsl:attribute>
                  <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="{$caption}"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="href">
                    <xsl:value-of select="concat($graphics,'.jpg')"/>
                  </xsl:attribute>
                  <img data-img="[graphic-{$filename}-medium]" src="{concat($graphics, '.jpg')}" alt="{$caption}"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:for-each>
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
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$msspreview">
          <xsl:call-template name="get-filename">
            <xsl:with-param name="string" select="@xlink:href"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@xlink:href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="media-download-href">
      <xsl:choose>
        <xsl:when test="$msspreview">
          <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($filebase,'image/',$filename)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- if mimetype is application -->
    <span class="inline-linked-media-wrapper">
      <a href="{$media-download-href}">
        <xsl:if test="$msspreview">
          <xsl:attribute name="download">
            <xsl:value-of select="concat($filename, '.')"/>
            <xsl:value-of select="substring-after($media-download-href, '.')"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$msspreview">&#x21E9;</xsl:when>
          <xsl:otherwise><i class="fas fa-download"></i></xsl:otherwise>
        </xsl:choose>
        <xsl:text> Download source data</xsl:text>
      </a>
    </span>
  </xsl:template>
  
  <!-- Back -->
  
  <xsl:template match="back">
    <xsl:apply-templates select="ack"/>
    <xsl:apply-templates select="preceding-sibling::*//author-notes"/>
    <xsl:if test="not(preceding-sibling::*//author-notes)">
      <xsl:if test="fn-group/fn[@fn-type = 'con'] | preceding-sibling::*//contrib[@equal-contrib = 'yes']">
        <div id="author-info-equal-contrib">
          <xsl:apply-templates select="fn-group/fn[@fn-type = 'con']"/> 
          <xsl:if test="not(fn-group/fn[@fn-type = 'con'])">
            <h3>Author Contributions</h3>
          </xsl:if>
          <xsl:apply-templates select="preceding-sibling::*//contrib[@equal-contrib = 'yes'][1]" mode="equal"/>
        </div>
      </xsl:if>
      <xsl:if test="preceding-sibling::*//contrib/email">
        <h3>Author Information</h3>
        <xsl:apply-templates select="preceding-sibling::*" mode="list-emails"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="preceding-sibling::*//contrib-group[@content-type='collab-list']"/>
    <xsl:apply-templates select="preceding-sibling::*//contrib-group[parent::collab]" mode="collab-list-container"/>
    <xsl:apply-templates select="*[not(self::ack) and not(self::bio)]"/>
    <xsl:if test="normalize-space($pprid) != ''">
      <xsl:call-template name="article-info-history"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Acknowledgement -->

  <xsl:template match="back/ack">
    <div id="ack-1">
      <h2 id="ack-1title">
        <xsl:apply-templates select="label"/>
        <xsl:choose>
          <xsl:when test="title">
            <xsl:value-of select="title"/>
          </xsl:when>
          <xsl:otherwise>Acknowledgments</xsl:otherwise>
        </xsl:choose>
      </h2>
      <xsl:apply-templates select="*[not(self::label or self::title)]"/>
    </div>
  </xsl:template>
  
  <!-- author-notes -->
  <xsl:template match="author-notes">
    <xsl:if test="fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address') or not(@fn-type)] | p | corresp | bio | ancestor::*[starts-with(name(), 'front')]/following-sibling::back/bio">
      <h2 id="author-notes">Author Information</h2>
      <xsl:apply-templates select="ancestor::*[starts-with(name(), 'front')]/following-sibling::back/bio | bio"/>
      <xsl:apply-templates select="p | corresp"/>
      <xsl:apply-templates select="parent::*" mode="list-emails"/>
    </xsl:if>
    <xsl:if test="ancestor::*[starts-with(name(), 'front')]/following-sibling::back/fn-group/fn[@fn-type = 'con'] | fn[@fn-type = 'con'] | fn[@fn-type = 'equal'] | parent::*//contrib[@equal-contrib = 'yes']">
      <div id="author-info-equal-contrib">
        <xsl:apply-templates select="ancestor::*[starts-with(name(), 'front')]/following-sibling::back/fn-group/fn[@fn-type = 'con']"/> 
        <xsl:apply-templates select="fn[@fn-type = 'con']"/>
        <xsl:if test="not(fn[@fn-type = 'con'] or ancestor::*[starts-with(name(), 'front')]/following-sibling::back/fn-group/fn[@fn-type = 'con'])">
          <h3>Author Contributions</h3>
        </xsl:if>
        <xsl:apply-templates select="fn[@fn-type = 'equal']"/>
        <xsl:apply-templates select="parent::*//contrib[@equal-contrib = 'yes'][1]" mode="equal"/>
      </div>
    </xsl:if>
    <xsl:if test="fn[@fn-type = 'present-address']">
      <div id="author-info-additional-address">
        <xsl:apply-templates select="fn[@fn-type = 'present-address'][1]"/>
      </div>
    </xsl:if>
    <xsl:if test="fn[not(@fn-type)] | fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')]">
      <div id="author-info-other-footnotes">
        <xsl:apply-templates select="fn[not(@fn-type)] | fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')]"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="back/fn-group">
    <xsl:if test="fn[not(@fn-type = 'con')]">
      <div id="notes">
        <h2 id="notestitle">
          <xsl:choose>
            <xsl:when test="title">
              <xsl:apply-templates select="title"/>
            </xsl:when>
            <xsl:otherwise>Notes</xsl:otherwise>
          </xsl:choose>
        </h2>
        <xsl:apply-templates select="fn[not(@fn-type = 'con')]"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="back/fn-group/fn | author-notes/fn[@fn-type = 'con']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="back/fn-group/fn/p | author-notes/fn[@fn-type = 'con']/p">
    <xsl:choose>
      <xsl:when test="*[position()=1][self::bold] and (not(child::text()) or not(child::text()[normalize-space(.) != '']))">
        <h3>
          <xsl:value-of select="bold"/>
        </h3>
        <xsl:apply-templates select="*[not(self::bold)]"></xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:if test="count(preceding-sibling::*) = 0 or preceding-sibling::*[1][self::label]">
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

  <xsl:template match="*" mode="list-emails">
    <xsl:if test="descendant::contrib/email">
      <p>
        <xsl:text>Author emails: </xsl:text>
        <xsl:for-each select="descendant::contrib[email]">
          <xsl:value-of select="name/given-names"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="name/surname"/>
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="email"/>
          <xsl:if test="position() != last()">
            <xsl:text>; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="fn[@fn-type = 'equal']">
    <xsl:variable name="contributeid" select="@id"/>
    <div class="equal-contrib" id="{@id}">    
      <xsl:apply-templates/>
      <ul class="equal-contrib-list">
        <xsl:for-each select="../../contrib-group/contrib/xref[@rid = $contributeid]">
          <li class="equal-contributor">
            <xsl:value-of select="../name/given-names"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="../name/surname"/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="contrib" mode="equal">
    <xsl:variable name="contributeid" select="@id"/>
    <div class="equal-contrib">
      <p>
        <xsl:if test="../../contrib-group//contrib[@equal-contrib and @equal-contrib != 'no']">
          <sup>#</sup>
        </xsl:if>
        <xsl:text> The following authors contributed equally: </xsl:text>
      </p>
      <ul class="equal-contrib-list">
        <xsl:for-each select="ancestor::contrib-group/contrib[@equal-contrib and @equal-contrib != 'no']">
          <li class="equal-contributor">
            <xsl:value-of select="name/given-names"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="name/surname"/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="fn-group[@content-type = 'author-contribution']">
    <ul class="fn-con">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="fn-group[@content-type = 'author-contribution']/fn">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="fn-group[@content-type = 'author-contribution']/fn/p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="author-notes/fn[not(@fn-type)] | author-notes/fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')]">
    <div class="foot-note" id="{@id}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="author-notes/fn[not(@fn-type)]/p | author-notes/fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')]/p">
    <xsl:variable name="id" select="parent::fn/@id"/>
    <xsl:variable name="symbol">
      <xsl:if test="//xref[@rid = $id]">
        <xsl:if test="not(preceding-sibling::p)">
          <xsl:variable name="count" select="count(parent::fn/preceding-sibling::fn[not(@fn-type)] |
            parent::fn/preceding-sibling::fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')]) + 1"/>    
          <xsl:call-template name="get-symbol">
            <xsl:with-param name="count" select="$count"/>
            <xsl:with-param name="current" select="1"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="*[position()=1][self::bold] and (not(child::text()) or not(child::text()[normalize-space(.) != '']))">
        <h3>
          <xsl:value-of select="$symbol"/>
          <xsl:value-of select="bold"/>
        </h3>
        <xsl:apply-templates select="*[not(self::bold)]"></xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:value-of select="$symbol"/>
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="author-notes/corresp">
    <p class="corresp" id="{@id}">
      <xsl:choose>
        <xsl:when test="$msspreview"><sup>&#9993;</sup></xsl:when>
        <xsl:otherwise><i class="fas fa-envelope"></i></xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:if test="count(node()) = 1">
        <xsl:text>Correspondence: </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="email[ancestor::corresp or ancestor::author-notes or ancestor::contrib]">
    <xsl:variable name="email">
      <xsl:call-template name="reverse">
        <xsl:with-param name="rest" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <a href="mailto:dev@null" data-email="{$email}" class="oemail">
      <xsl:value-of select="$email"/>
    </a>
    <xsl:if test="following-sibling::email">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="reverse">
    <xsl:param name="str"/>
    <xsl:param name="rest"/>
    <xsl:choose>
      <xsl:when test="$rest != ''">
        <xsl:call-template name="reverse">
          <xsl:with-param name="str" select="concat($str, substring($rest, string-length($rest), 1))"/>
          <xsl:with-param name="rest" select="substring($rest, 1, string-length($rest) - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="author-notes/fn[@fn-type = 'present-address']">
    <h3>Present Address</h3>
    <xsl:choose>
      <xsl:when test="following-sibling::fn[@fn-type = 'present-address']">
        <ul class="additional-address-items">
          <xsl:for-each select="parent::author-notes/fn[@fn-type = 'present-address']">
            <li>
              <xsl:apply-templates/>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="author-notes/fn[@fn-type = 'present-address']/p">
    <xsl:variable name="id" select="parent::fn/@id"/>
    <xsl:for-each select="//xref[@rid = $id]">
      <xsl:if test="parent::contrib/name">
        <strong>
          <xsl:value-of select="concat(parent::contrib/name/given-names, ' ', parent::contrib/name/surname, ': ')"/>
        </strong>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="author-notes/fn[@fn-type = 'present-address']/p/text()">
    <xsl:choose>
      <xsl:when test="starts-with(., 'Present address:')">
        <xsl:value-of select="substring-after(., 'Present address:')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="contrib-group[@content-type='collab-list']">
    <xsl:for-each select="contrib">
      <xsl:choose>
        <xsl:when test="@rid = preceding::contrib/@rid"/>
        <xsl:otherwise>
          <xsl:apply-templates select="parent::contrib-group" mode="make-collab-list">
            <xsl:with-param name="rid" select="@rid"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <div class="collab-author-affiliations">
      <h4 id="fulltext--collab-author-affiliations-title" class="pmctoggle" role="button" tabindex="0">
        <xsl:if test="not($msspreview)">
          <xsl:attribute name="onclick">
            <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <xsl:text>Affiliations</xsl:text>
      </h4>
      <ol class="affiliations">
        <xsl:attribute name="style">
          <xsl:choose>
            <xsl:when test="normalize-space($pprid) != ''">
              <xsl:text>list-style-type:none</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>text-indent:0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates select="parent::*/contrib-group[@content-type='collab-list']//aff[not(. = preceding::aff)]" mode="afflist"/>
      </ol>
    </div>
  </xsl:template>
  
  <xsl:template match="contrib-group" mode="make-collab-list">
    <xsl:param name="rid"/>
    <div class="fulltext--collab-author-information" id="{$rid}">
      <h3>
        <xsl:apply-templates select="//contrib[@id=$rid]/collab/node()"/>
      </h3>
      <div>
        <xsl:for-each select="contrib[@rid=$rid]">
          <xsl:apply-templates select="*[position() = 1]" mode="authorlist"/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:if test="position() = last()-1">
            <xsl:text>and </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="contrib-group" mode="collab-list-container">
    <div class="fulltext--collab-author-information" id="{concat('collab', count(preceding::contrib-group[parent::collab])+1)}">
      <h3>
        <xsl:apply-templates select="parent::collab/node()[not(self::contrib-group)]"/>
      </h3>
      <div>
        <xsl:for-each select="contrib">
          <xsl:apply-templates select="*[position() = 1]" mode="authorlist"/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:if test="position() = last()-1">
            <xsl:text>and </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </div>
    </div>
    <xsl:if test="descendant::aff">
      <div class="collab-author-affiliations">
        <h4 id="fulltext--collab-author-affiliations-title" class="pmctoggle" role="button" tabindex="0">
          <xsl:if test="not($msspreview)">
            <xsl:attribute name="onclick">
              <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>Affiliations</xsl:text>
        </h4>
        <ol class="affiliations">
          <xsl:attribute name="style">
            <xsl:choose>
              <xsl:when test="normalize-space($pprid) != ''">
                <xsl:text>list-style-type:none</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>text-indent:0</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="descendant::aff[not(. = preceding::aff)]" mode="afflist"/>
        </ol>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- START Reference Handling -->

  <xsl:template match="ref-list">
    <xsl:variable name="id">
      <xsl:text>ref-list</xsl:text>
      <xsl:if test="preceding::ref-list">
        <xsl:value-of select="count(preceding::ref-list)"/>
      </xsl:if>
    </xsl:variable>
    <div id="{$id}">
      <h2 id="{$id}title">
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

  <xsl:template match="ref//person-group|collab" mode="list-ref-people">
    <xsl:for-each select="name | collab | self::collab">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="name() = 'name'">
          <xsl:variable name="givenname" select="given-names"/>
          <xsl:variable name="surname" select="surname"/>
          <xsl:variable name="suffix" select="suffix"/>
          <xsl:variable name="fullname">
            <xsl:value-of select="concat($surname, ' ', $givenname)"/>
          </xsl:variable>
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
    <xsl:choose>
      <xsl:when test="@person-group-type = 'editor'">
        <xsl:if test="etal">
          <xsl:text>, et al</xsl:text>
        </xsl:if>
        <xsl:text>, editor</xsl:text>
        <xsl:if test="count(child::*[self::name | self::collab | self::etal]) > 1">
          <xsl:text>s</xsl:text>
        </xsl:if>
        <xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:when test="etal">
        <xsl:text>, et al. </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ref/element-citation|ref/mixed-citation">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="child::article-title">
          <xsl:apply-templates select="child::article-title/node()"/>
        </xsl:when>
        <xsl:when test="child::source">
          <xsl:apply-templates select="child::source/node()"/>
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
      </xsl:choose>
    </xsl:variable>

    <div class="reflink-main">
      <xsl:if test="label">
        <xsl:value-of select="concat(label, ' ')"/>
      </xsl:if>
      <!-- call authors template -->

      <xsl:if test="person-group[@person-group-type = 'author'] | collab">
        <span class="authors">
          <xsl:apply-templates select="person-group[@person-group-type = 'author'] | collab" mode="list-ref-people"/>
        </span>
      </xsl:if>
      <xsl:if test="$title != ''">
        <span class="elife-reflink-title">
          <span class="nlm-{$title-type}">
            <xsl:copy-of select="$title"/>
          </span>
          <xsl:if test="not('.' = substring($title, string-length($title) - string-length('.') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      <!-- move all other elements into details div
                and comma separate
            -->
      <xsl:variable name="class">
        <xsl:if test="@publication-type = 'journal'">
          <xsl:value-of select="'reflink-details-journal'"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="includes">
        <xsl:if test="child::article-title and child::source">
          <xsl:value-of select="'source|'"/>
        </xsl:if>
        <xsl:if test="child::*[starts-with(name(), 'conf')]">
          <xsl:value-of select="'conference|'"/>
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
      <xsl:if test="child::person-group[@person-group-type = 'editor'] and @publication-type='book'">
        <span>
          <xsl:text>In: </xsl:text>
          <xsl:apply-templates select="person-group[@person-group-type = 'editor']" mode="list-ref-people"/>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'source|')">
        <span>
          <xsl:if test="$class != ''">
            <xsl:attribute name="class">
              <xsl:value-of select="$class"/>
            </xsl:attribute>
          </xsl:if>
          <span class="nlm-source">
            <xsl:apply-templates select="child::source/node()"/>
          </span>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'conference|')">
        <xsl:if test="not(starts-with($includes, 'conference|'))">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <span class="reflink-details-conference">
          <xsl:apply-templates select="child::conf-name/node()"/>
          <xsl:if test="child::conf-name and child::conf-loc">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:apply-templates select="child::conf-loc/node()"/>
          <xsl:if test="(child::conf-name or child::conf-loc) and child::conf-date">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:apply-templates select="child::conf-date/node()"/>
          <xsl:text>.</xsl:text>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'publisher-name|')">
        <xsl:if test="not(starts-with($includes, 'publisher-name|'))">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <span class="reflink-details-pub-name">
          <span class="nlm-publisher-name">
            <xsl:apply-templates select="child::publisher-name/node()"/>
          </span>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'publisher-loc|')">
        <xsl:if test="not(starts-with($includes, 'publisher-loc|'))">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <span class="reflink-details-pub-loc">
          <span class="nlm-publisher-loc">
            <xsl:apply-templates select="child::publisher-loc/node()"/>
          </span>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'year|')">
        <xsl:if test="not(starts-with($includes, 'year|'))">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <span class="reflink-details-year">
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
        <span class="reflink-details-day">
          <xsl:apply-templates select="child::day/node()"/>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'volume|')">
        <xsl:if test="not(starts-with($includes, 'volume|'))">
          <xsl:text>; </xsl:text>
        </xsl:if>
        <span class="reflink-details-volume">
          <xsl:apply-templates select="child::volume/node()"/>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'issue|')">
        <xsl:if test="not(starts-with($includes, 'issue|'))">
          <xsl:text>(</xsl:text>
        </xsl:if>
        <span class="reflink-details-volume">
          <xsl:apply-templates select="child::issue/node()"/>
        </span>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="contains($includes, 'fpage|')">
        <xsl:if test="not(starts-with($includes, 'fpage|'))">
          <xsl:text>: </xsl:text>
        </xsl:if>
        <span class="reflink-details-pages">
          <xsl:apply-templates select="child::fpage/node()"/>
          <xsl:if test="contains($includes, 'lpage|')">
            <xsl:text>-</xsl:text>
            <xsl:apply-templates select="child::lpage/node()"/>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="$includes != ''">
        <xsl:text>.</xsl:text>
      </xsl:if>      
      <xsl:apply-templates select="pub-id[@pub-id-type = 'doi']" mode="idlinks"/>
      <xsl:apply-templates select="pub-id[not(@pub-id-type = 'doi')]" mode="idlinks"/>
      <xsl:apply-templates select="date-in-citation"/>
      <xsl:apply-templates select="comment|annotation"/>
    </div>
  </xsl:template>
  
  <xsl:template match="ref//date-in-citation">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="pub-id" mode="idlinks">
    <xsl:choose>
      <xsl:when test="@pub-id-type = 'pmid'">
        <xsl:text> </xsl:text>
        <a href="{$siteUrl}/abstract/MED/{.}">
          <xsl:if test="$msspreview">
            <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>[Europe PMC Abstract]</xsl:text>
        </a>
      </xsl:when>
      <xsl:when test="@pub-id-type = 'doi'">
        <span class="elife-reflink-doi-cited-wrapper">
          <xsl:text> </xsl:text>
          <span class="reflink-details-doi">
            <a href="https://doi.org/{.}" target="_blank">
              <xsl:text>https://doi.org/</xsl:text>
              <xsl:value-of select="."/>
            </a>
          </span>
        </span>
      </xsl:when>
      <xsl:when test="@pub-id-type = 'pmcid'">
        <xsl:text> </xsl:text>
        <a href="{$siteUrl}/articles/{.}">
          <xsl:if test="$msspreview">
            <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>[Europe PMC Full Text]</xsl:text>
        </a>
      </xsl:when>
      <xsl:when test="@pub-id-type = 'archive' and starts-with(translate(., $uppercase, $smallcase), 'ppr')">
        <xsl:text> </xsl:text>
        <a href="{$siteUrl}/preprints/{.}">
          <xsl:if test="$msspreview">
            <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>[Europe PMC Preprint]</xsl:text>
        </a>
      </xsl:when>
      <xsl:when test="@pub-id-type = 'other' and starts-with(translate(., $uppercase, $smallcase), 'ind')">
        <xsl:text> </xsl:text>
        <a href="{$siteUrl}/abstract/AGR/{.}">
          <xsl:if test="$msspreview">
            <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>[Europe PMC Abstract]</xsl:text>
        </a>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- START video handling -->

  <xsl:template match="media">
    <xsl:variable name="data-doi" select="child::object-id[@pub-id-type = 'doi']/text()"/>
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

  <!-- box text -->
  <xsl:template match="boxed-text">
    <div class="boxed-text">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="inline-graphic|p/graphic">
    <xsl:variable name="filename">
      <xsl:call-template name="get-filename">
        <xsl:with-param name="string" select="@xlink:href"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="graphics">
      <xsl:choose>
        <xsl:when test="$msspreview">
          <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($filebase,'image/',$filename,'.jpg')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="{$graphics}" target="_blank" class="figure-expand" title="Click to open full size">
      <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="inline image"/>
    </a>
  </xsl:template>

  <xsl:template match="inline-graphic" mode="testing">
    <xsl:variable name="filename">
      <xsl:call-template name="get-filename">
        <xsl:with-param name="string" select="@xlink:href"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="graphics">
      <xsl:choose>
        <xsl:when test="$msspreview">
          <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($filebase,'image/',$filename,'.jpg')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="{$graphics}" target="_blank" class="figure-expand" title="Click to open full size">
      <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="inline image"/>
    </a>
  </xsl:template>

  <xsl:template name="appendices-main-text">
    <xsl:apply-templates select="//back/app-group/app" mode="testing"/>
  </xsl:template>

  <xsl:template match="app"/>

  <xsl:template match="app" mode="testing">
    <div class="section app">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="title">
        <h3>
          <xsl:value-of select="title"/>
        </h3>
      </xsl:if>
      <xsl:apply-templates mode="testing"/>
    </div>
  </xsl:template>
  
  <xsl:template match="fn-group[@content-type = 'competing-interest']/fn/p |
    //history//*[@publication-type = 'journal']/article-title">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- START - general format -->

  <!-- list elements start-->

  <xsl:template match="list">
    <xsl:choose>
      <xsl:when test="@list-type = 'simple' or @list-type = 'bullet'">
        <ul id="{@id}">
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
        <ol id="{@id}">
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
          <xsl:if test="@continued-from">
            <xsl:attribute name="start">
              <xsl:call-template name="get-list-start">
                <xsl:with-param name="rid" select="@continued-from"/>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </ol>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(ancestor::p or ancestor::list-item)">
      <xsl:if test="//floats-group or //sec[@sec-type = 'floats-group']">
        <xsl:for-each select="descendant::xref[@ref-type = 'table' or @ref-type = 'fig' or @ref-type = 'boxed-text']">
          <xsl:variable name="rid" select="@rid"/>
          <xsl:if test="not(preceding::xref[@rid = $rid])">
            <xsl:apply-templates select="//*[@id = $rid][@position != 'anchor']" mode="testing"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="get-list-start">
    <xsl:param name="rid"/>
    <xsl:param name="count" select="1"/>
    <xsl:variable name="prevList" select="//list[@id=$rid]"/>
    <xsl:variable name="newCount" select="$count + count($prevList/list-item)"/>
    <xsl:choose>
      <xsl:when test="$prevList/@continued-from">
        <xsl:call-template name="get-list-start">
          <xsl:with-param name="rid" select="$prevList/@continued-from"/>
          <xsl:with-param name="count" select="$newCount"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$newCount"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="list-item">
    <li>
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:attribute name="id">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="count(child::node()) = 1 and child::node()[self::p]">
          <xsl:attribute name="id">
            <xsl:value-of select="child::p/@id"/>
          </xsl:attribute>
          <xsl:apply-templates select="child::p/child::node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>
  
  <xsl:template match="hr">
    <hr/>
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
  
  <xsl:template match="sc">
    <span style="font-variant:small-caps">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="underline">
    <span style="text-decoration:underline">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="monospace">
    <span class="monospace">
      <xsl:apply-templates/>
    </span>
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

  <xsl:template match="disp-quote | verse-group">
    <blockquote class="{local-name(.)}">
    <xsl:apply-templates/>
    </blockquote>
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
  
  <xsl:template match="glossary">
    <sec id="glossary">
      <xsl:if test="not(title)">
        <h2 id="glossarytitle">Glossary</h2>
      </xsl:if>
      <xsl:apply-templates/>
    </sec>
  </xsl:template>
  
  <xsl:template match="glossary/title">
    <h2 id="glossarytitle">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  <xsl:template match="def-list/label">
    <xsl:apply-templates/>
    <xsl:text>. </xsl:text>
  </xsl:template>
  
  <xsl:template match="def-list/title">
    <h3>
      <xsl:apply-templates select="preceding-sibling::label"/>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>
  
  <xsl:template match="def-list">
    <xsl:apply-templates select="title"/>
    <dl>
      <xsl:apply-templates select="term-head|def-head|def-item|def-list"/>
    </dl>
  </xsl:template>
  
  <xsl:template match="term-head">
    <dt><h4>
      <xsl:apply-templates/>
    </h4></dt>
  </xsl:template>

  <xsl:template match="def-head">
    <dd><h4>
      <xsl:apply-templates/>
    </h4></dd>
  </xsl:template>
  
  <xsl:template match="def-item">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="def-item/term">
    <dt>
      <xsl:apply-templates/>
    </dt>
  </xsl:template>
  
  <xsl:template match="def">
    <dd>
      <xsl:apply-templates select="p/* | p/text()"/>
    </dd>
  </xsl:template>
  
  <xsl:template match="bio">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="verse-line">
    <span style="display: block; text-indent: -1em; margin-left: 1em; ">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template name="camel-case-word">
    <xsl:param name="text"/>
    <xsl:value-of select="translate(substring($text, 1, 1), $smallcase, $uppercase)"/>
    <xsl:value-of select="translate(substring($text, 2, string-length($text) - 1), $uppercase, $smallcase)"/>
  </xsl:template>

  <xsl:template name="citation">
    <xsl:variable name="year">
      <xsl:call-template name="year"/>
    </xsl:variable>
    <xsl:variable name="citationid">
      <xsl:call-template name="citationid"/>
    </xsl:variable>
    <xsl:value-of select="concat(//journal-meta/journal-title-group/journal-title, ' ', $year, ';', $citationid)"/>
  </xsl:template>

  <xsl:template name="year">
    <xsl:choose>
      <xsl:when test="//article-meta/pub-date[@date-type = 'pub']/year">
        <xsl:value-of select="//article-meta/pub-date[@date-type = 'pub']/year"/>
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
          <xsl:variable name="year">
            <call-template name="year"/>
          </xsl:variable>
          <xsl:value-of select="$year - 2011"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$value"/>
  </xsl:template>

  <xsl:template name="citationid">
    <xsl:variable name="volume">
      <xsl:call-template name="volume"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="//article-meta/pub-date[@pub-type = 'collection']/year">
        <xsl:value-of select="concat($volume, ':', //article-meta/elocation-id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//article-meta/article-id[@pub-id-type = 'doi']"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="supplementary-material">
    <xsl:if test="//supplementary-material[not(object-id)]">
      <div id="supplementary-material">
        <h2 id="supplementary-materialtitle">
          <xsl:apply-templates select="//sec[@sec-type='supplementary-material'][1]/label"/>
          <xsl:apply-templates select="//sec[@sec-type='supplementary-material'][1]/title/node()"/>
        </h2>
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
  
  <!-- END - general format -->
  
  <xsl:template match="*">
    <xsl:apply-templates select="@* | node()"/>
  </xsl:template>

  <xsl:template match="@* | text()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="
      caption | table-wrap/table | table-wrap-foot | fn | bold | italic | underline | preformat | monospace |
      styled-content | sub | sup | sc | sec/title | boxed-text | ext-link | app/title | disp-formula | inline-formula | list | list-item | hr | disp-quote | code | verse-group" mode="testing">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <!-- nodes to remove -->
  <xsl:template match="@xlink:href"/>
  <xsl:template match="sec[@sec-type = 'supplementary-material'] | sec[@sec-type = 'floats-group']"/>
  <xsl:template match="back/fn-group/fn/label"/>
  <xsl:template match="aff/label"/>
  <xsl:template match="list-item/label"/>
  <xsl:template match="disp-formula/label"/>
  <xsl:template match="app/title"/>
  <xsl:template match="fn-group[@content-type = 'competing-interest']/title"/>
  <xsl:template match="permissions/copyright-year | permissions/copyright-holder"/>
  <xsl:template match="fn-group[@content-type = 'author-contribution']/title"/>
  <xsl:template match="author-notes/fn/label"/>
  <xsl:template match="author-notes/corresp/label"/>
  <xsl:template match="abstract/title"/>
  <xsl:template match="fig/graphic"/>
  <xsl:template match="fig-group//object-id | fig-group//graphic | fig//label"/>
  <xsl:template match="ack/title"/>
  <xsl:template match="ref-list/title"/>
  <xsl:template match="
      ref//label | ref//year | ref//article-title | ref//fpage | ref//volume | ref//issue | ref//source | ref//pub-id |
      ref//lpage | ref//supplement | ref//person-group[@person-group-type = 'editor'] | ref//edition | ref//publisher-loc |
      ref//lpage | ref//supplement | ref//edition | ref//publisher-loc |
      ref//publisher-name | ref//issn | red//month | ref//day | ref//season"/>
  <xsl:template match="person-group[@person-group-type = 'author'] | collab"/>
  <xsl:template match="media/label"/>
  <xsl:template match="object-id | table-wrap/label"/>
  <xsl:template match="funding-group//institution-wrap/institution-id"/>
  <xsl:template match="table-wrap/graphic"/>
  <xsl:template match="table-wrap-foot//fn/label"/>

</xsl:stylesheet>

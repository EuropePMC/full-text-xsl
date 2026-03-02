<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Copyright (c) 2019 EMBL-EBI/Europe PMC (https://europepmc.org/)
  
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
SOFTWARE.
-->
<xsl:stylesheet version="3.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
  exclude-result-prefixes="xsi xs xlink mml ali">
  <xsl:output method="html" indent="no" encoding="utf-8" omit-xml-declaration="yes"/>
  <xsl:include href="lang_map.xsl" />
  <xsl:param name="filelist"/>
  <xsl:param name="msspreview" select="false()"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="allcase" select="concat($smallcase, $uppercase)"/>
  <xsl:variable name="digit" select="'0123456789'"/>
  <xsl:variable name="is-retracted"
  select="boolean(//custom-meta[meta-name='is-retracted' and meta-value='yes'])"/>
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
  <xsl:template name="pmc_month">
    <xsl:param name="num"/>
    <xsl:choose>
      <xsl:when test="$num = 1">Jan</xsl:when>
      <xsl:when test="$num = 2">Feb</xsl:when>
      <xsl:when test="$num = 3">Mar</xsl:when>
      <xsl:when test="$num = 4">Apr</xsl:when>
      <xsl:when test="$num = 5">May</xsl:when>
      <xsl:when test="$num = 6">Jun</xsl:when>
      <xsl:when test="$num = 7">Jul</xsl:when>
      <xsl:when test="$num = 8">Aug</xsl:when>
      <xsl:when test="$num = 9">Sep</xsl:when>
      <xsl:when test="$num = 10">Oct</xsl:when>
      <xsl:when test="$num = 11">Nov</xsl:when>
      <xsl:when test="$num = 12">Dec</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="emsid">
    <xsl:if test="//article-meta/article-id[@pub-id-type = 'manuscript' or @pub-id-type = 'emsid']">
      <xsl:value-of select="translate(translate(//article-meta/article-id[@pub-id-type = 'manuscript' or @pub-id-type = 'emsid'], 'ucpak', 'es'), 'ems', 'EMS')"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="pprid">
    <xsl:if test="starts-with(//article-meta/article-id[@pub-id-type='archive'], 'PPR')">
      <xsl:value-of select="//article-meta/article-id[@pub-id-type='archive']"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="pmid" select="/article/front/article-meta/article-id[@pub-id-type='pmid']/text()"/>
  <xsl:variable name="pmcid">
    <xsl:value-of select="//article-meta/article-id[@pub-id-type='pmcid']"/>
  </xsl:variable>
  <xsl:variable name="ctxid">
    <xsl:choose>
      <xsl:when test="normalize-space($pprid) != ''"/>
      <xsl:when test="//article-meta/article-id[@pub-id-type='archive']">
        <xsl:value-of select="//article-meta/article-id[@pub-id-type='archive']"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="current-version">
    <xsl:choose>
      <xsl:when test="//article-meta/article-version">
        <xsl:value-of select="//article-meta/article-version"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
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

  <xsl:variable name="pdf-file-name" select="/article/front/article-meta/self-uri[@content-type='pmc-pdf']/@xlink:href"/>

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

  <xsl:template name="camel-case-word">
    <xsl:param name="text"/>
    <xsl:value-of select="translate(substring($text, 1, 1), $smallcase, $uppercase)"/>
    <xsl:value-of select="translate(substring($text, 2, string-length($text) - 1), $uppercase, $smallcase)"/>
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
        <xsl:if test="$is-retracted">
          <xsl:attribute name="class">
            <xsl:text>retraction-wm</xsl:text>
          </xsl:attribute>
        </xsl:if>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="article">
    <xsl:apply-templates select="@xml:lang"/>
    <xsl:apply-templates select="front"/>
    <xsl:apply-templates select="body"/>
    <!--no longer needed as its handled separately with associated-data-->
    <!-- <xsl:apply-templates select="body" mode="supplementary-materials"/> -->
    <xsl:apply-templates select="back"/> <!--under review-->
    <xsl:apply-templates select="sub-article"/>
     <!--under review (<pub-history>)-->
    <!-- <xsl:apply-templates select="front" mode="article-info-history"/> -->
    <!-- </xsl:if> -->
  </xsl:template>

  <!-- *** FRONT MATTER START *** -->

  <xsl:template match="front">
    <xsl:param name="isSub"/>
    <!--global variables declaration-->
    <xsl:variable name="doi">
      <xsl:if test="article-meta/article-id[@pub-id-type='doi']">
        <span class="doi">
          <a href="{concat('https://doi.org/', article-meta/article-id[@pub-id-type='doi'])}" target="_blank">
            <xsl:text>https://doi.org/</xsl:text>
            <xsl:value-of select="article-meta/article-id[@pub-id-type='doi']"/>
          </a>
        </span>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="pmcid" select="article-meta/article-id[@pub-id-type='pmcid']"/>
    <xsl:variable name="emsid" select="article-meta/article-id[@pub-id-type='emsid']"/>
    <xsl:variable name="pmid" select="article-meta/article-id[@pub-id-type='pmid']"/>
    <xsl:variable name="ctxid" select="article-meta/article-id[@pub-id-type='archive']"/>
    <div class="front-matter">
      <xsl:apply-templates select="." mode="identifiers">
        <xsl:with-param name="doi" select="$doi"/>
        <xsl:with-param name="pmcid" select="$pmcid"/>
        <xsl:with-param name="emsid" select="$emsid"/>
        <xsl:with-param name="pmid" select="$pmid"/>
        <xsl:with-param name="ctxid" select="$ctxid"/>
        <xsl:with-param name="isSub" select="$isSub"/>
      </xsl:apply-templates>
      <!-- Language switcher for abstracts -->
      <xsl:call-template name="multi-lang-switcher"/>
      <xsl:apply-templates select="article-meta/title-group"/>
      <xsl:apply-templates select="article-meta" mode="authors"/>
      <xsl:apply-templates select="article-meta"/>
      <xsl:if test="not(following-sibling::back)">
        <!-- <xsl:apply-templates select="article-meta/author-notes"/> -->
        <xsl:apply-templates select="article-meta/contrib-group[@content-type='collab-list']"/>
        <xsl:apply-templates select="article-meta//collab[contrib-group]" mode="collab-list-container"/>
      </xsl:if>
      <!--under review, need to check where the keyword group might be if abstract is not present-->
      <!-- <xsl:if test="not(article-meta/abstract or article-meta/trans-abstract) or normalize-space($ctxid) != ''">
        <xsl:apply-templates select="article-meta/kwd-group"/>
      </xsl:if> -->
      </div>
      <xsl:if test="following-sibling::sub-article[@article-type='peer-review']">
        <xsl:call-template name="peer-review-summary"/>
      </xsl:if>
      <!--Abstract section-->
      <xsl:if test="article-meta/abstract and normalize-space($ctxid) = ''">
        <xsl:apply-templates select="article-meta/abstract"/>
        <xsl:apply-templates select="article-meta/trans-abstract"/>
      </xsl:if>
      <!-- </xsl:otherwise> -->
    <!-- </xsl:choose> -->
  </xsl:template>

  <xsl:template match="sub-article">
    <div class="sub-article-divider"/>
    <div class="sub-article" id="{@id}">
      <xsl:apply-templates select="front">
        <xsl:with-param name="isSub" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="body"/>
      <!--no longer needed as its handled separately with associated-data-->
      <!-- <xsl:apply-templates select="body" mode="supplementary-materials"/> -->
      <xsl:apply-templates select="back"/>
    </div>
  </xsl:template>

  <xsl:template match="front" mode="identifiers">
      <xsl:param name="doi"/>
      <xsl:param name="pmcid"/>
      <xsl:param name="emsid"/>
      <xsl:param name="pmid"/>
      <xsl:param name="ctxid"/>
      <xsl:param name="isSub"/>
      <xsl:variable name="hasPubInfo"
        select="
          article-meta/article-version
          or journal-meta/journal-title-group/abbrev-journal-title
          or journal-meta/journal-title-group/journal-title
          or article-meta/pub-date
          or article-meta/volume
          or article-meta/issue
          or article-meta/page-range
          or article-meta/elocation-id
      "/>
      <xsl:if test="$hasPubInfo">
        <div class="pmc-citeinfo">
          <div class="pmc-identifiers float-right">
              <xsl:apply-templates select="article-meta/article-id"/>
              <xsl:if test="normalize-space($emsid) != ''">
                <xsl:text>EMSID: </xsl:text>
                <!-- <xsl:when test="$pmid"> -->
                  <a href="https://europepmc.org/article/MED/{$pmid}" target="_blank">
                    <xsl:value-of select="$emsid"/>
                  </a>
                <!-- </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$emsid"/>
                </xsl:otherwise> -->
                <br/>
              </xsl:if>
              <xsl:if test="normalize-space($ctxid) != ''">
                <xsl:text>CTXID: </xsl:text>
                <xsl:value-of select="$ctxid"/>
                <br/>
              </xsl:if>
            </div>
          <div class="pmc-metadata">
            <span class="pubinfo">
              <xsl:if test="article-meta/article-version">
                <xsl:text>Version </xsl:text>
                <xsl:value-of select="article-meta/article-version"/>
                <xsl:text>. </xsl:text>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="journal-meta/journal-title-group/abbrev-journal-title">
                  <xsl:value-of select="journal-meta/journal-title-group/abbrev-journal-title"/>
                    <xsl:text>.</xsl:text>
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="journal-meta/journal-title-group/journal-title">
                    <xsl:value-of select="journal-meta/journal-title-group/journal-title"/>
                    <xsl:text>.</xsl:text>
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="article-meta/pub-date[1]/year"/>
              <xsl:if test="article-meta/pub-date[1]/season">
                <xsl:text> </xsl:text>
                <xsl:value-of select="article-meta/pub-date[1]/season"/>
              </xsl:if>
              <!-- <xsl:if test="normalize-space($pmcid) != ''"> -->
                <xsl:if test="article-meta/pub-date[1]/month">
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="pmc_month">
                    <xsl:with-param name="num" select="article-meta/pub-date[1]/month"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$isSub">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="article-meta/pub-date[1]/day"/>
                </xsl:if>
              <!-- </xsl:if> -->
              <xsl:for-each select="article-meta[1]">
                <xsl:if test="volume or issue or fpage or elocation-id">
                  <xsl:if test="volume or issue">
                    <xsl:text>; </xsl:text>
                    <xsl:value-of select="volume"/>
                    <xsl:if test="issue">
                      <xsl:value-of select="concat('(', issue, ')')"/>
                    </xsl:if>
                  </xsl:if>
                  <!-- <xsl:choose> -->
                    <!-- <xsl:when test="normalize-space($pmcid) != ''"> -->
                      <xsl:if test="page-range">
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="page-range"/>
                      </xsl:if>
                    <!-- </xsl:when> -->
                    <!-- <xsl:otherwise>
                      <xsl:if test="fpage or elocation-id">
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="elocation-id"/>
                        <xsl:value-of select="fpage"/>
                        <xsl:if test="lpage and lpage != fpage">
                          <xsl:text>-</xsl:text>
                          <xsl:value-of select="lpage"/>
                        </xsl:if>
                      </xsl:if>
                    </xsl:otherwise> -->
                  <!-- </xsl:choose> -->
                </xsl:if>
              </xsl:for-each>
              <xsl:text>.</xsl:text>
            </span>
            <br/>
            <!-- <xsl:choose> -->
              <!-- snnexlite - publication date fix-->
              <!-- <xsl:when test="normalize-space($pmcid) != ''"> -->
              <xsl:if test="not($isSub)">
                <xsl:for-each select="article-meta/pub-date[1]">
                  <xsl:text>Published online </xsl:text>
                  <xsl:value-of select="year"/>
                  <xsl:if test="month or season">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="pmc_month">
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
              <!-- </xsl:when> -->
              <!-- <xsl:otherwise>
                <xsl:for-each select="article-meta/pub-date[@pub-type='epub' or @publication-format='electronic'][1]">
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
              </xsl:otherwise>
            </xsl:choose> -->
            <br/>
          </xsl:if>

            <xsl:if test="article-meta/pub-history/event[@event-type='original-publication']">
              <xsl:text>Originally Published </xsl:text>
              <xsl:call-template name="format-version-date">
                <xsl:with-param name="d" select="article-meta/pub-history/event[@event-type='original-publication']/date"/>
              </xsl:call-template>
              <xsl:text>. </xsl:text>
            </xsl:if>

            <xsl:if test="$doi">
              <xsl:copy-of select="$doi"/>
            </xsl:if>
          </div>
        </div>
      </xsl:if>
      <!-- </xsl:otherwise> -->
    <!-- </xsl:choose> -->
</xsl:template>

  <xsl:template match="pub-date">
    <xsl:value-of select="concat(year, ' ')"/>
    <xsl:call-template name="pmc_month">
      <xsl:with-param name="num" select="month"/>
    </xsl:call-template>
    <xsl:value-of select="concat(' ', day)"/>
  </xsl:template>

  <xsl:template match="article-meta">
    <!-- <xsl:apply-templates select="contrib-group/contrib[@content-type='reviewer'][1]" mode="article-info-reviewing-editor"/>
    <xsl:apply-templates select="contrib-group/contrib[@content-type='editor'][1]" mode="article-info-reviewing-editor"/> -->

    <!-- section contributor information-->
    <xsl:apply-templates select="ancestor::*[self::article or self::sub-article][1]
            /body//sec[@sec-type='contrib-info']" mode="contrib-info"/>
    <!-- author and contributor roles-->
      <xsl:if test=".//contrib[role]">
        <div id="author-and-contributor-roles">
          <xsl:element name="h2">
            <xsl:attribute name="id">fulltext--author-and-contributor-roles</xsl:attribute>
            <xsl:attribute name="class">pmctoggle</xsl:attribute>
            <xsl:attribute name="role">button</xsl:attribute>
            <xsl:attribute name="tabindex">0</xsl:attribute>
            <xsl:if test="not($msspreview)">
              <xsl:attribute name="onclick">
                <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Author and contributor roles</xsl:text>
          </xsl:element>
          <xsl:apply-templates select=".//contrib[role]" mode="display-roles"/>
        </div>
      </xsl:if>
    <!-- article notes-->
  <xsl:apply-templates select="../notes[@notes-type='article-notes']"/>
  <!--permissions-->
  <xsl:choose>
    <xsl:when test="permissions">
      <xsl:apply-templates select="permissions"/>
    </xsl:when>
        <!-- fallback only for top-level article -->
    <xsl:when test="not(ancestor::sub-article[@article-type='associated-data'])">
      <xsl:call-template name="permissions">
        <xsl:with-param name="top" select="1"/>
      </xsl:call-template>
    </xsl:when>
  </xsl:choose>
  <xsl:apply-templates select="related-article"/>
  <xsl:apply-templates mode="associated-data" select="ancestor::*[self::article or self::sub-article][1]
      /body//sec[@sec-type='associated-data']"/>
  <xsl:apply-templates select="../notes[@notes-type='front-sections']" mode="testing"/>
</xsl:template>

  <!-- related article-->
  <xsl:template match="related-article">
    <div class="links-box">
      <div class="fm-panel">
         <xsl:apply-templates/>
      </div>
    </div>
  </xsl:template>
  <!-- associated data-->
   <xsl:template match="sec[@sec-type = 'associated-data']"  mode="associated-data">
    <xsl:if test="sec[@sec-type='supplementary-materials']">
      <div>
        <xsl:if test="@sec-type">
          <xsl:attribute name="class">
            <xsl:value-of select="@sec-type"/>
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
        <h2 id="fulltext--associated-datatitle">Associated Data</h2>
        <xsl:element name="h2">
          <xsl:attribute name="id">fulltext--suppl-info</xsl:attribute>
            <xsl:attribute name="class">pmctoggle</xsl:attribute>
            <xsl:attribute name="role">button</xsl:attribute>
            <xsl:attribute name="tabindex">0</xsl:attribute>
            <xsl:if test="not($msspreview)">
              <xsl:attribute name="onclick">
                <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:text>Supplementary Materials</xsl:text>
          </xsl:element>
          <xsl:apply-templates select="sec[@sec-type='supplementary-materials']" mode="associated-data"/>
      </div>
    </xsl:if>
  </xsl:template>

<!--handle supplementary-materials in associated data section-->
  <xsl:template match="sec[@sec-type='supplementary-materials']" mode="associated-data">
    <div class="supplementary-section">
      <ul style="list-style-type: none;" class="supplementary-material-list">
          <xsl:for-each select="supplementary-material">
            <li id="{@id}">
              <xsl:if test="label">
                <h5><strong><xsl:apply-templates select="label"/></strong></h5>
              </xsl:if>
              <xsl:if test="caption/title">
                <span>: <xsl:apply-templates select="caption/title"/></span>
              </xsl:if>
              <xsl:apply-templates select="media"/>
              <xsl:apply-templates select="caption/*[not(self::title)]"/>
            </li>
          </xsl:for-each>
        </ul>
    </div>
  </xsl:template>

<!--handle supplementary-materials in results section-->
  <xsl:template match="supplementary-material" mode="testing">
    <div class="supplementary-material table-expansion table-group whole_rhythm" id="{@id}">
      <xsl:if test="label">
        <h4><xsl:apply-templates select="label"/></h4>
      </xsl:if>
      <xsl:if test="caption/title">
        <span>: <xsl:apply-templates select="caption/title"/></span>
      </xsl:if>
      <xsl:apply-templates select="media"/>
      <xsl:apply-templates select="caption/*[not(self::title)]"/>
    </div>
  </xsl:template>

  <xsl:template match="inline-supplementary-material" mode="testing">
    <span class="inline-supplementary-material">
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="$current-version!= ''">
              <xsl:value-of select="concat('https://europepmc.org/api/fulltextRepo?pmcId=', $pmcid, '&amp;type=FILE&amp;fileName=', @xlink:href, '&amp;version=', $current-version, '&amp;mimeType=application/vnd.openxmlformats-officedocument.wordprocessingml.document', '&amp;pmc_pageType=supp')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('https://europepmc.org/api/fulltextRepo?pmcId=', $pmcid, '&amp;type=FILE&amp;fileName=', @xlink:href, '&amp;mimeType=application/pdf', '&amp;pmc_pageType=supp')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <!-- <xsl:attribute name="download"/> -->
        <xsl:apply-templates/>
      </a>
    </span>
  </xsl:template>

  <xsl:template match="sec[@sec-type='contrib-info']" mode="contrib-info">
    <div class="contrib-info" id="{@id}">
      <xsl:element name="h2">
        <xsl:attribute name="id">fulltext--contrib-info</xsl:attribute>
          <xsl:attribute name="class">pmctoggle</xsl:attribute>
          <xsl:attribute name="role">button</xsl:attribute>
          <xsl:attribute name="tabindex">0</xsl:attribute>
          <xsl:if test="not($msspreview)">
            <xsl:attribute name="onclick">
              <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>Contributor information</xsl:text>
        </xsl:element>
      <div class="section-contrib">
        <xsl:apply-templates select="p"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="contrib" mode="display-roles">
      <div class="roles whole_rhythm">
        <strong>
          <xsl:value-of select="name/given-names"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="name/surname"/>
          <xsl:text>: </xsl:text>
         </strong>
        <xsl:value-of select="role"/>
      </div>
  </xsl:template>

  <!-- Front matter article notes-->
  <xsl:template match="notes[@notes-type='article-notes']">
    <div class="article-notes p" id="article-notes">
      <xsl:element name="h2">
        <xsl:attribute name="id">fulltext--article-notes</xsl:attribute>
        <xsl:attribute name="class">pmctoggle</xsl:attribute>
        <xsl:attribute name="role">button</xsl:attribute>
        <xsl:attribute name="tabindex">0</xsl:attribute>
        <xsl:if test="not($msspreview)">
          <xsl:attribute name="onclick">
            <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <xsl:text>Article notes</xsl:text>
      </xsl:element>
        <div class="article-notes-content">
          <xsl:apply-templates select="sec" mode="article-notes"/>
        </div>
    </div>
  </xsl:template>

  <xsl:template match="sec" mode="article-notes">
    <div class="section {@sec-type}" id="{@id}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="article-meta/article-id[@pub-id-type='pmcid' or @pub-id-type='pmid' or @pub-id-type='nihmsid']">
      <xsl:value-of select="translate(@pub-id-type, $smallcase, $uppercase)"/>
      <xsl:text>: </xsl:text>
      <!-- Conditionally add a link for PMID if $pmcid is not empty -->
      <xsl:choose>
        <xsl:when test="(@pub-id-type = 'pmid' or @pub-id-type = 'nihmsid') and normalize-space($pmcid) != ''">
              <a href="https://europepmc.org/article/MED/{$pmid}" target="_blank">
                  <xsl:value-of select="."/>
              </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
      <br/>
      <!-- Version history block: Only for PMCID -->
      <xsl:if test="@pub-id-type = 'pmcid'">
        <xsl:call-template name="version-history"/>
      </xsl:if>
  </xsl:template>

  <xsl:template name="version-history">
    <xsl:variable name="versions" select="/article/front/article-meta/pub-history/event[@event-type='pmc-published-version']"/>
    <xsl:if test="count($versions) > 1">
      <div class="version-history-toggle">
        <xsl:element name="h2">
          <xsl:attribute name="id">fulltext--version-history-title</xsl:attribute>
          <xsl:attribute name="class">pmctoggle</xsl:attribute>
          <xsl:attribute name="role">button</xsl:attribute>
          <xsl:attribute name="tabindex">0</xsl:attribute>
          <xsl:if test="not($msspreview)">
            <xsl:attribute name="onclick">
              <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
            </xsl:attribute>
          </xsl:if>
          <xsl:text>Other versions</xsl:text>
        </xsl:element>
        <div class="version-history-content">
          <ul class="version-history-list">
            <xsl:for-each select="$versions">
              <xsl:sort select="date/year" data-type="number"/>
              <xsl:sort select="date/month" data-type="number"/>
              <xsl:sort select="date/day" data-type="number"/>
              <li>
                <xsl:variable name="ver-id" select="article-id"/>
                <xsl:choose>
                  <xsl:when test="substring-after($ver-id, '.') = $current-version">
                    <xsl:attribute name="class">current a_label</xsl:attribute>
                    <div class="inline_block a_label">&#x27A4;</div>
                    <xsl:value-of select="$ver-id"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <!-- <a href="https://europepmc.org/article/PMC/{$ver-id}/"> -->
                     <a class="int-reflink" data-id="{$pmcid}" data-version="{$current-version}">
                        <xsl:value-of select="$ver-id"/>
                      </a>
                    <xsl:text>  </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text>; </xsl:text>
                <xsl:call-template name="format-version-date">
                  <xsl:with-param name="d" select="date"/>
                </xsl:call-template>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="format-version-date">
    <xsl:param name="d"/>
    <xsl:variable name="months" select="'JanFebMarAprMayJunJulAugSepOctNovDec'"/>
    <xsl:variable name="month-num" select="number($d/month)"/>
    <xsl:variable name="month-abbr" select="substring($months, ($month-num - 1) * 3 + 1, 3)"/>
    <xsl:value-of select="concat($d/year, ' ', $month-abbr, ' ', $d/day)"/>
  </xsl:template>

  <xsl:template match="article-meta/article-id[not(@pub-id-type='pmcid' or @pub-id-type='pmid' or @pub-id-type='nihmsid')]"/>

  <xsl:template match="article-meta" mode="authors">
    <div class="fulltext--author-information whole_rhythm">
      <xsl:choose>
        <xsl:when test="normalize-space($ctxid) != ''"/>
        <xsl:otherwise>
          <div>
            <xsl:apply-templates select=".//contrib-group[not(@content-type = 'collab-list' or parent::collab)][1]" mode="authorlist"/>
            <xsl:apply-templates select=".//contrib-group[@content-type='editor']"/>
          </div>
          <xsl:if test=".//aff[not(parent::contrib-group[@content-type='collab-list'] or ancestor::collab)][not(. = preceding::aff)]">
            <div class="author-affiliations-and-information">
              <h2 role="button" tabindex="0">
                <xsl:choose>
                  <xsl:when test="self::article-meta">
                    <xsl:attribute name="id">fulltext--author-affiliations-title</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="id">
                      <xsl:text>fulltext--sub</xsl:text>
                      <xsl:value-of select="ancestor::sub-article/@id"/>
                      <xsl:text>-author-affiliations-title</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class">pmctoggle</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not($msspreview)">
                  <xsl:attribute name="onclick">
                    <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
                  </xsl:attribute>
                </xsl:if>
                <xsl:text>Author affiliations &amp; information</xsl:text>
              </h2>
              <div class="author-content">
                <ol class="pmc-affiliations">
                  <xsl:apply-templates select=".//aff[not(parent::contrib-group[@content-type='collab-list'] or ancestor::collab)][not(. = preceding::aff)]" mode="afflist"/>
                </ol>
                <!-- List only labeled notes -->
                <ol class="author-notes">
                  <xsl:for-each select=".//author-notes/fn">
                    <li id="{@id}">
                      <xsl:if test="label">
                        <sup>
                          <xsl:value-of select="label"/>
                          <xsl:text> </xsl:text>
                        </sup>
                      </xsl:if>
                      <xsl:apply-templates select="p/node()"/>
                    </li>
                  </xsl:for-each>
                </ol>
                <!-- Render unlabeled notes as paragraphs outside the list -->
                <!-- <xsl:for-each select="//author-notes/fn[not(label)]">
                  <p id="{@id}">
                    <xsl:apply-templates select="p"/>
                  </p>
                </xsl:for-each> -->
              </div>
            </div>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="contrib-group[@content-type='editor']">
    <div class="fulltext--editor-information" style="margin: 8px" />
    <xsl:choose>
      <xsl:when test="normalize-space($ctxid) != ''"/>
      <xsl:otherwise>
        <xsl:for-each select="parent::*/contrib-group[@content-type = 'editor' and not(@content-type = 'collab-list' or parent::collab)]/contrib">
          <span class="fulltext--editor-name">
            <xsl:value-of select="name/given-names"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="name/surname"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="role"/>
            <!-- Superscripted xrefs -->
            <xsl:if test="xref[@ref-type='aff' or @ref-type='author-notes']">
                <xsl:for-each select="xref[@ref-type='aff' or @ref-type='author-notes']">
                  <xsl:text> </xsl:text>
                    <a>
                      <xsl:attribute name="href">
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="@rid"/>
                      </xsl:attribute>
                      <xsl:if test="not($msspreview)">
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
                          <xsl:text>').closest('.author-content').previousElementSibling.classList.add('open')</xsl:text>
                        </xsl:attribute>
                      </xsl:if>
                      <sup class="inline-block">
                        <xsl:value-of select="."/>
                      </sup>
                    </a>
                </xsl:for-each>
            </xsl:if>
          </span>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="contrib-group" mode="authorlist">
    <xsl:choose>
      <xsl:when test="parent::*/contrib-group/on-behalf-of">
        <xsl:for-each select="parent::*/contrib-group[not(@content-type = 'collab-list' or parent::collab)]">
          <xsl:for-each select="contrib[@contrib-type = 'author']">
            <xsl:apply-templates select="*[self::name or self::collab][1]" mode="authorlist"/>
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
      </xsl:when>  <!--under review -->
      <xsl:otherwise>
      <!-- Example of the above -->
      <!-- <article-meta>
        <contrib-group>
          <contrib>Author A</contrib>
        </contrib-group>
        <contrib-group>
          <on-behalf-of>Consortium XYZ</on-behalf-of>
        </contrib-group>
      </article-meta> -->
        <xsl:for-each select="parent::*/contrib-group[@content-type = 'author' and not(@content-type = 'collab-list' or parent::collab)]/contrib">
          <xsl:apply-templates select="*[self::name or self::name-alternatives or self::collab][1]" mode="authorlist"/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <!-- <xsl:if test="position() = last()-1">
            <xsl:text>and </xsl:text>
          </xsl:if> -->
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()" mode="make-url">
    <xsl:choose>
      <xsl:when test="self::contrib-group or preceding-sibling::contrib-group or parent::contrib-group"/>
      <xsl:when test="following-sibling::contrib-group">
        <xsl:value-of select="translate(., ' &#xA;', '+')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-initials">
    <xsl:param name="string"/>
    <xsl:value-of select="substring($string, 1, 1)"/>
    <xsl:if test="contains($string, ' ')">
      <xsl:call-template name="get-initials">
        <xsl:with-param name="string">
          <xsl:value-of select="substring-after($string, ' ')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="name-alternatives" mode="authorlist">
    <xsl:apply-templates select="name[1]" mode="authorlist"/>
    <xsl:for-each select="name[position() > 1]|string-name">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>)</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="name|collab" mode="authorlist"> <!-- used for author list at beginning-->
    <!-- <xsl:param name="peer-review-summary" select="'false'"/> -->
    <a>
      <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="self::name">
          <xsl:variable name="initials">
            <xsl:call-template name="get-initials">
              <xsl:with-param name="string" select="given-names"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="concat($siteUrl,'/search?query=AUTH:%22', surname, '+', $initials,'%22')"/>
        </xsl:when>
        <xsl:when test="self::collab">
          <xsl:variable name="collab-url">
            <xsl:apply-templates select="child::node()" mode="make-url"/>
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
            <xsl:apply-templates select="node()[not(self::contrib-group or self::author-comment or self::aff)]"/>
          </xsl:when>
        </xsl:choose>
      </span>
      <xsl:apply-templates select="following-sibling::degrees"/>
    </a><!-- used for author list at beginning-->
   <!-- following-sibling::xref[@ref-type='aff'] - used for author list at beginning-->
    <!--exclude this for sub-article - peer-review-info if needed-->
    <!-- <xsl:if test="$peer-review-summary != 'true'"> -->
      <xsl:for-each select="following-sibling::aff | ancestor::contrib-group/aff[not(@id = //xref/@rid)] | following-sibling::xref[@ref-type='aff']">
        <xsl:variable name="position">
          <xsl:if test="position() = last()">
            <xsl:text>last</xsl:text>
          </xsl:if>
        </xsl:variable>
        <xsl:choose>
          <!--not used for author list at beginning-->
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
          <!-- used for author list at beginning -->
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
              <xsl:otherwise>  <!-- used for author list at beginning -->
                <xsl:apply-templates select="//article-meta//aff[not(ancestor::contrib-group[@content-type='collab-list'] or ancestor::collab)][not(. = preceding::aff)]" mode="list-xrefs">
                  <xsl:with-param name="current" select="$current"/>
                  <xsl:with-param name="position" select="$position"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    <!-- </xsl:if> -->
    <!-- not used for author list at beginning-->
    <xsl:if test="parent::contrib[@id = //contrib-group[@content-type='collab-list']/contrib/@rid]">
      <xsl:text> </xsl:text>
      <a href="{concat('#', parent::contrib/@id)}">
        <sup class="inline-block">&#9432;</sup>
      </a>
    </xsl:if>
    <!-- not used for author list at beginning-->
    <xsl:if test="child::contrib-group">
      <a href="{concat('#', 'collab', count(preceding::contrib-group[parent::collab]) + 1)}">
        <sup class="inline-block">&#9432;</sup>
      </a>
    </xsl:if>
    <!-- <xsl:if test="parent::contrib[@equal-contrib and @equal-contrib != 'no']">
      <xsl:text> </xsl:text>
      <a href="#author-info-equal-contrib">
        <sup class="inline-block">#</sup>
      </a>
    </xsl:if> -->
    <!-- corresponding author/ euqal contributor - used for author list at beginning-->
    <xsl:for-each select="following-sibling::xref[@ref-type = 'author-notes']">
      <xsl:text> </xsl:text>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@rid"/>
        </xsl:attribute>
        <xsl:if test="not($msspreview)">
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
            <xsl:text>').closest('.author-content').previousElementSibling.classList.add('open')</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <sup class="inline-block">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="."/>
        </sup>
      </a>
    </xsl:for-each>
    <!-- not used for author list at beginning-->
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
          <xsl:if test="@id">
            <xsl:value-of select="concat('#',@id)"/>
          </xsl:if>
        </xsl:attribute>
        <!-- <xsl:if test="not($msspreview) and normalize-space($pprid) != ''"> -->
        <xsl:if test="not($msspreview)">
          <xsl:attribute name="onclick">
            <xsl:text>document.getElementById('</xsl:text>
              <xsl:if test="@id">
                <xsl:value-of select="@id"/>
              </xsl:if>
            <xsl:text>').closest('.author-content').previousElementSibling.classList.add('open')</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <sup class="fulltext--author-affiliation-index inline-block">
          <xsl:if test="label">
            <xsl:value-of select="label"/>
          </xsl:if>
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
    <li class="fulltext--author-affiliation-item">
        <xsl:attribute name="id">
           <xsl:if test="@id">
              <xsl:value-of select="@id"/>
           </xsl:if>
        </xsl:attribute>
          <div class="p">
            <sup>
              <xsl:if test="label">
                <xsl:value-of select="label"/>
                <xsl:text> </xsl:text>
              </xsl:if>
            </sup>
            <xsl:apply-templates select="*[not(self::label)]|text()"/>
          </div>
        </li>
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

  <xsl:template match="p" mode="review-map">
    <xsl:variable name="afterRec" select="normalize-space(substring-after(., 'Recommendation:'))"/>
    <xsl:variable name="str" select="translate($afterRec, '-', ' ')"/>
    <xsl:value-of select="concat(translate(substring($str, 1, 1), $smallcase, $uppercase), substring($str, 2))"/>
  </xsl:template>

  <xsl:template name="peer-review-summary">
    <div class="peer-review-summary" id="prs">
      <h2 id="prstitle" class="head">Peer Review Summary</h2>
      <table class="align_center small">
        <thead>
          <tr>
            <th>Review date</th>
            <th>Reviewer name(s)</th>
            <th>Review Status</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="//sub-article[@article-type='peer-review']">
            <tr>
              <td>
                <a href="{concat('#', @id)}">
                  <xsl:apply-templates select="front/article-meta/pub-date"/>
                </a>
              </td>
              <td>
                <xsl:apply-templates select="front/article-meta/contrib-group[not(@content-type = 'collab-list' or parent::collab)][1]" mode="authorlist"/>
                <!--<xsl:apply-templates select="front/article-meta/contrib-group[1]/contrib[1]/name"/>-->
              </td>
              <td>
                <!-- <a href="{concat('#', @id)}"> -->
                  <xsl:apply-templates
                    select="front/notes/sec/p"
                    mode="review-map"
                  />
                <!-- </a> -->
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="article-meta/title-group">
    <div id="title-group">
      <xsl:apply-templates select="article-title | subtitle"/>
      <xsl:apply-templates select="trans-title-group"/>
   </div>
  </xsl:template>

  <xsl:template match="trans-title-group">
    <xsl:apply-templates select="trans-title | trans-subtitle"/>
  </xsl:template>

  <!-- Title -->
  <xsl:template match="article-title | trans-title">
    <h1>
      <xsl:call-template name="title-elment">
        <xsl:with-param name="has_trans">
          <xsl:choose>
            <xsl:when test="ancestor::title-group/trans-title-group">
              <xsl:value-of select="'true'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </h1>
  </xsl:template>

 <xsl:template name="title-elment">
    <xsl:param name="has_trans" select="'false'"/>
    <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang" />
      <xsl:if test="$has_trans='true'" >
        <xsl:if test="self::trans-title | self::trans-subtitle">
          <xsl:attribute name="hidden">true</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="class">
          <xsl:value-of select="'trans'"/>
        </xsl:attribute>
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:if>
    <xsl:apply-templates/>
   </xsl:template>

  <!-- Subtitle -->
   <xsl:template match="subtitle | trans-subtitle">
    <p>
      <xsl:call-template name="title-elment">
        <xsl:with-param name="has_trans">
          <xsl:choose>
            <xsl:when test="ancestor::title-group/trans-title-group">
              <xsl:value-of select="'true'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </p>
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
    <xsl:apply-templates select="collab" mode="contrib-collab"/>
  </xsl:template>

  <xsl:template match="contrib//collab" mode="contrib-collab">
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

  <xsl:template match="name">
    <span class="nlm-given-names">
      <xsl:value-of select="given-names"/>
    </span>
    <xsl:text> </xsl:text>
    <span class="nlm-surname">
      <xsl:value-of select="surname"/>
    </span>
  </xsl:template>

  <xsl:template match="string-name | collab">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="front" mode="article-info-history">
    <div>
      <xsl:attribute name="id">
        <xsl:value-of select="'article-info-history'"/>
      </xsl:attribute>
      <h2 class="head">History</h2>
      <ul>
        <xsl:attribute name="class">
          <xsl:value-of select="'publication-history'"/>
        </xsl:attribute>
        <xsl:apply-templates select="article-meta/history/date[@date-type]" mode="publication-history-item"/>
        <xsl:apply-templates select="article-meta/pub-date[@date-type]" mode="publication-history-item"/>
        <xsl:for-each select="article-meta/pub-date[@pub-type and not(@date-type) and not(@pub-type='nihms-submitted')]">
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
        <xsl:apply-templates select="." mode="edlist"/>
        <xsl:for-each select="following::contrib[@contrib-type=$type]">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="." mode="edlist"/>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="contrib" mode="edlist">
    <xsl:apply-templates select="descendant::name[1]|string-name|collab"/>
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
  <xsl:template match="permissions" name="permissions">
    <xsl:param name="top" as="xs:integer" select="0"/>
    <xsl:variable name="head">
      <xsl:choose>
        <xsl:when test="parent::article-meta or $top">h2</xsl:when>
        <xsl:otherwise>b</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
          <div>
            <xsl:choose>
              <xsl:when test="parent::article-meta or $top">
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
            <xsl:element name="{$head}">
              <xsl:attribute name="id">fulltext--permissions-title</xsl:attribute>
              <xsl:attribute name="class">pmctoggle</xsl:attribute>
              <xsl:attribute name="role">button</xsl:attribute>
              <xsl:attribute name="tabindex">0</xsl:attribute>
              <xsl:if test="not($msspreview)">
                <xsl:attribute name="onclick">
                  <xsl:text>this.classList.toggle('open'); this.blur()</xsl:text>
                </xsl:attribute>
              </xsl:if>
              <xsl:text>Copyright and license information</xsl:text>
            </xsl:element>
            <div class="permissions">
              <xsl:choose>
                <xsl:when test="$emsid != ''">
                  <p><a href="https://europepmc.org/pmc/about/copyright/">
                    <xsl:if test="$msspreview">
                      <xsl:attribute name="target">_blank</xsl:attribute>
                    </xsl:if>
                    <xsl:text>Copyright notice</xsl:text>
                  </a></p>
                </xsl:when>
                <xsl:otherwise>
                  <!-- This block handles when $emsid is empty or not set -->
                  <xsl:choose>
                    <xsl:when test="self::permissions">
                      <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                      <p><a href="https://europepmc.org/pmc/about/copyright/">
                        <xsl:if test="$msspreview">
                          <xsl:attribute name="target">_blank</xsl:attribute>
                        </xsl:if>
                        <xsl:text>EPMC Copyright notice</xsl:text>
                      </a></p>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="$top != 1">
                <p>
                  <a href="https://europepmc.org/pmc/about/copyright/">
                    <xsl:text>EPMC Copyright notice</xsl:text>
                  </a>
                </p>
              </xsl:if>
            </div>
      </div>
  </xsl:template>

  <xsl:template match="permissions/copyright-statement">
    <p class="copyright"><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="license">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="license-p">
    <p class="license">
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
  <xsl:template match="etal">
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

  <!-- ==== FRONT MATTER END ==== -->

  <!-- ==== ABSTRACT ==== -->

  <xsl:template match="abstract | trans-abstract">
    <xsl:variable name="has-trans" select="ancestor::article-meta/trans-abstract"/>
    <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
    <div>
      <xsl:attribute name="class">
        <xsl:text>abstract</xsl:text>
      </xsl:attribute>
      <xsl:variable name="id">
        <xsl:value-of select="@id"/>
      </xsl:variable>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$has-trans">
          <xsl:if test="$lang">
            <xsl:attribute name="lang">
              <xsl:value-of select="$lang"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:attribute name="class">
            <xsl:text>abstract trans</xsl:text>
          </xsl:attribute>
          <xsl:if test="self::trans-abstract">
            <xsl:attribute name="hidden">true</xsl:attribute>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">abstract</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <h2 id="{concat($id,'title')}" class="head">
        <xsl:apply-templates select="label"/>
        <xsl:apply-templates select="title/node()"/>
      </h2>
      <xsl:apply-templates select="node()[not(self::label or self:: title)]" mode="testing"/>
    </div>
  </xsl:template>

  <!-- <xsl:template match="kwd-group">
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
  </xsl:template> -->

  <!-- ==== BODY ==== -->
  <xsl:template match="body">
    <xsl:if test="child::*[position()=1][self::p]">
      <hr />
    </xsl:if> <!-- leave a line break if starts with p tag-->
    <div id="main-text">
      <div class="article fulltext-view">
        <xsl:apply-templates mode="testing" select="*[not(@sec-type = 'associated-data')][not(@sec-type = 'supplementary-materials') or ancestor::sub-article][not(@sec-type = 'floats-group')][not(@sec-type = 'contrib-info')]"/>
        <xsl:for-each select="//floats-group/* | //sec[@sec-type = 'floats-group']/*">
          <xsl:variable name="rid" select="@id"/>
          <xsl:if test="not(//body//xref[@rid = $rid])">
            <xsl:apply-templates select="." mode="display"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="appendices-main-text"/>
      </div>
    </div>
  </xsl:template>

  <!--no longer needed as its handled separately with associated-data-->
  <!-- <xsl:template match="body" mode="supplementary-materials"> -->
  <!--This will never be applied as there is no direct <supplementary-materials> tag in the ssnexlite xml, so changed to supplementary-material check-->
    <!-- <xsl:if test="descendant::supplementary-material[not(object-id)]">
      <div id="supplementary-material">
        <h2 id="supplementary-materialtitle" class="head">
          <xsl:apply-templates select="descendant::sec[@sec-type='supplementary-materials'][1]/label"/>
          <xsl:apply-templates select="descendant::sec[@sec-type='supplementary-materials'][1]/title/node()"/>
        </h2> -->
        <!-- <xsl:apply-templates select="descendant::sec[@sec-type='supplementary-materials']/*[not(self::supplementary-material or self::label or self::title)]"/> -->
        <!-- <ul class="supplementary-material">
          <xsl:for-each select="descendant::supplementary-material[not(object-id)]">
            <li id="{@id}">
              <xsl:choose>
                <xsl:when test="ext-link">
                  <a>
                    <xsl:attribute name="href">
                      <xsl:value-of select="concat('[', ext-link/@xlink:href, ']')"/>
                    </xsl:attribute> -->
                    <!-- <xsl:attribute name="download"/> -->
                    <!-- <xsl:apply-templates/>
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
  </xsl:template> -->

  <!-- Start transforming sections to heading levels -->
  <!-- No need to proceed sec-type="additional-information", sec-type="supplementary-material" and sec-type="datasets"-->
  <xsl:template match="
      sec[not(@sec-type = 'additional-information')][not(@sec-type = 'datasets')]
      [not(@sec-type = 'supplementary-materials')][not(@sec-type = 'floats-group')]">
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
      <xsl:choose>
        <xsl:when test="@sec-type = 'fn-group'">
          <xsl:apply-templates select="." mode="fn-group"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Apply templates for other children and attributes -->
          <xsl:apply-templates select="@*[name() != 'sec-type' and name() !='id'] | node()[not(self::label)]"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- footnotes-->
  <xsl:template match="sec[@sec-type='fn-group']" mode="fn-group">
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="fn-group/fn" mode="fn-group"/>
  </xsl:template>

  <xsl:template match="fn" mode="fn-group">
    <div class="fn p" id="{@id}">
      <xsl:apply-templates select="p"/>
    </div>
  </xsl:template>

  <xsl:template match="sec/title">
    <xsl:if test="node() != ''">
      <xsl:choose>
        <xsl:when test="ancestor::app">
          <xsl:variable name="headerLevel" select="count(ancestor::sec) + 3"/>
          <xsl:element name="h{ $headerLevel }">
            <xsl:if test="$headerLevel = 2">
              <xsl:attribute name="class">head</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@* | preceding-sibling::*[1][self::label]"/>
            <xsl:apply-templates select="node()"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="headerLevel" select="count(ancestor::sec) + count(ancestor::abstract) + count(ancestor::trans-abstract) + count(ancestor::boxed-text) + count(ancestor::ack) + 1"/>
          <xsl:element name="h{ $headerLevel }">
            <xsl:if test="$headerLevel = 2">
              <xsl:attribute name="class">head</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="id">
            <xsl:choose>
              <xsl:when test="ancestor::sub-article">
                <xsl:choose>
                  <xsl:when test="parent::sec/@id">
                    <xsl:value-of select="concat('SA-', parent::sec/@id, 'title')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of
                      select="concat('SA-sec', count(../preceding::sec), 'title')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="parent::sec/@id">
                    <xsl:value-of select="concat(parent::sec/@id, 'title')"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="concat('sec', count(../preceding::sec), 'title')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@* | preceding-sibling::*[1][self::label]"/>
            <xsl:apply-templates select="node()"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="." mode="add-floats"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="boxed-text" mode="label-title">
    <xsl:param name="heading-el"/>
    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="$heading-el and not(child::sec)">
          <xsl:choose>
            <xsl:when test="ancestor::app">
              <xsl:value-of select="count($heading-el/ancestor::sec) + 3"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="count($heading-el/ancestor::sec)+count($heading-el/ancestor::abstract)+count($heading-el/ancestor::ack) + 2"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="ancestor::app">
              <xsl:value-of select="count(ancestor::sec) + 3"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="count(ancestor::sec)+count(ancestor::abstract)+count(ancestor::ack) + 2"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="node() != ''">
      <xsl:element name="h{$level}">
        <xsl:attribute name="id">
          <xsl:choose>
            <xsl:when test="parent::sec/@id">
              <xsl:value-of select="concat(parent::sec/@id, 'title')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('sec', count(../preceding::sec), 'title')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="label"/>
        <xsl:if test="label and caption/title">
          <xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="caption/title/node()"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- <xsl:template match="sec/label | ack/label | ref-list/label | abstract/label"> -->
   <xsl:template match="sec/label | ack/label | ref-list/label">
    <xsl:value-of select="."/>
    <xsl:choose>
      <xsl:when test="substring(., string-length(.), 1) = '.'">
        <xsl:text> </xsl:text> <!-- already ends with period: just add space -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="
    sec[not(@sec-type = 'additional-information')][not(@sec-type = 'datasets')][not(@sec-type = 'supplementary-materials')]
    [not(@sec-type = 'floats-group')][not(@sec-type = 'scanned-pages')][not(@sec-type = 'ref-list')]" mode="testing">
    <div>
      <xsl:if test="@sec-type">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('section ', translate(./@sec-type, '|', '-'))"/>
        </xsl:attribute>
        <xsl:if test="@sec-type = 'kwd-group'">
          <xsl:apply-templates select="@xml:lang"/>
        </xsl:if>
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
      <xsl:choose>
        <xsl:when test="@sec-type = 'fn-group'">
          <xsl:apply-templates select="." mode="fn-group"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Apply templates for other children and attributes -->
        <xsl:apply-templates select="*[not(self::label)][not(self::ref-list)]" mode="testing"/>        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- END transforming sections to heading levels -->

  <!-- body content -->

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
        <xsl:if test="not(parent::list-item) and preceding-sibling::*[1][self::label]">
          <span class="p-label">
            <xsl:apply-templates select="preceding-sibling::*[1][self::label]/node()"/>
            <xsl:text>: </xsl:text>
          </span>
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
    <xsl:if test="not(ancestor::list-item or ancestor::fig or ancestor::table or ancestor::boxed-text)">
      <xsl:apply-templates select="." mode="add-floats"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ext-link">
    <xsl:variable name="type" select="@ext-link-type"/>
    <xsl:variable name="href" select="@xlink:href"/>
    <a>
    <xsl:choose>
      <xsl:when test="$type = 'doi'">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('https://doi.org/', $href)"/>
        </xsl:attribute>
      </xsl:when>
      <!-- pdf-only CIT-10507-->
      <xsl:when test="$type = 'pmc-pdf'">
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="$current-version!= ''">
              <xsl:value-of select="concat('https://europepmc.org/api/fulltextRepo?pmcId=', $pmcid, '&amp;type=FILE&amp;fileName=', $href, '&amp;version=', $current-version, '&amp;mimeType=application/pdf', '&amp;pmc_pageType=pdf')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('https://europepmc.org/api/fulltextRepo?pmcId=', $pmcid, '&amp;type=FILE&amp;fileName=', $href, '&amp;mimeType=application/pdf', '&amp;pmc_pageType=pdf')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <!--handle external link from related-article etc with type pmcid-->
      <xsl:when test="$type = 'pmcid'">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('/articles/', $href)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="starts-with($href, 'www.')">
              <xsl:value-of select="concat('http://', $href)"/>
            </xsl:when>
            <xsl:when test="starts-with($href, 'doi:')">
              <xsl:value-of select="concat('https://doi.org/', substring-after($href, 'doi:'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$href"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="target">
          <xsl:value-of select="'_blank'"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </a>
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

  <!-- list elements start-->

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
          <xsl:if test="@list-type = 'simple'">
            <xsl:attribute name="class">list_with_labels</xsl:attribute>
          </xsl:if>
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
      <xsl:apply-templates select="." mode="add-floats"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="list-item">
    <li>
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="(count(child::*) = 1 and child::*[self::p]) or
          (count(child::*) = 2 and child::*[1][self::label] and child::*[2][self::p])">
          <xsl:apply-templates select="child::p" mode="list-single-p"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="label" mode="list-label"/>
          <div>
            <xsl:apply-templates/>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template match="p" mode="list-single-p">
    <xsl:if test="preceding-sibling::*[1][self::label]">
      <xsl:apply-templates select="preceding-sibling::*[1][self::label]" mode="list-label"/>
    </xsl:if>
    <span class="p-content">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="testing"/>
    </span>
  </xsl:template>

  <xsl:template match="label" mode="list-label">
    <span class="list_label">
      <xsl:apply-templates/>
      <xsl:if test="not(child::*)">
        <xsl:variable name="punc" select="translate(normalize-space(translate(., $allcase, '')), $digit, '')"/>
        <xsl:if test="string-length($punc) = 0">
          <xsl:text>.</xsl:text>
        </xsl:if>
      </xsl:if>
    </span>
  </xsl:template>

  <!-- START handling citation objects -->

  <xsl:template match="*" mode="add-floats">
    <xsl:if test="//floats-group or //sec[@sec-type = 'floats-group'] or //*[@position = 'float']">
      <xsl:for-each select="descendant::xref[@ref-type = 'table' or @ref-type = 'fig' or @ref-type = 'boxed-text']">
        <xsl:variable name="rid" select="@rid"/>
        <xsl:if test="not(preceding::xref[@rid = $rid] or ancestor-or-self::*[@id = $rid])">
          <xsl:apply-templates select="//*[@id = $rid][@position = 'float']" mode="display">
            <xsl:with-param name="heading-el" select="."/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xref">
    <xsl:apply-templates select="." mode="testing"/>
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

  <!-- END handling citation objects -->

  <!-- box text -->
  <xsl:template match="boxed-text" mode="display">
    <xsl:param name="heading-el"/>
    <div class="boxed-text">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="label-title">
        <xsl:with-param name="heading-el" select="$heading-el"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="testing"/>
    </div>
  </xsl:template>

  <!-- START Table Handling -->
  <xsl:template match="table-wrap-group" mode="display">
    <div class="table-expansion table-group whole_rhythm">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="label" mode="captionLabel"/>
      <xsl:apply-templates select="caption"/>
      <xsl:apply-templates select="node()[not(self::label or self::caption)]" mode="display"/>
    </div>
  </xsl:template>

  <xsl:template match="table-wrap" mode="display">
    <div class="table-expansion table-overflow whole_rhythm">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="graphic">
        <xsl:variable name="caption" select="label/text()"/>
        <xsl:variable name="filename">
          <xsl:call-template name="get-filename">
            <xsl:with-param name="string" select="graphic/@xlink:href"/>
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
        <xsl:variable name="alt">
          <xsl:choose>
            <xsl:when test="descendant::alt-text">
              <xsl:value-of select="descendant::alt-text"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$caption"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <a href="{$graphics}" target="_blank" class="figure-expand" title="{$caption} - Click to open full size">
          <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="{$alt}"/>
        </a>
      </xsl:if>
      <xsl:apply-templates select="label" mode="captionLabel"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="table-wrap/label|table-wrap-group/label" mode="captionLabel">
    <span class="table-label">
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="table-wrap/caption|table-wrap-group/caption">
    <xsl:apply-templates select="p"/>
    <xsl:if test="child::*[not(self::p)]">
      <div class="table-caption">
        <xsl:apply-templates select="child::*[not(self::p)]"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="table-wrap/table">
    <div class="table-overflow">
      <table>
        <xsl:apply-templates select="@rules | @frame | @style"/>
        <xsl:apply-templates/>
      </table>
    </div>
    <div class="largeobj-link table-link-align_right">
      <a href="/article/view/{$pmcid}/table/{../@id}/version/{$current-version}" target="object">
            Open in a separate window
      </a>
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
          <xsl:if test="contains(@style, 'vertical-rl')">
            <xsl:text>inline-size: max-content; block-size: max-content; min-width:</xsl:text>
            <xsl:variable name="multiplier" select="count(break) + 1"/>
            <xsl:value-of select="$multiplier + ($multiplier * .65)"/>
            <xsl:text>em;</xsl:text>
          </xsl:if>
          <xsl:value-of select="@style"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="table-wrap-foot">
    <div class="table-foot">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="@rules | @frame | @style">
    <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- END Table Handling -->

  <!-- START Figure Handling -->
  <!-- fig with atrtribute specific-use are supplement figures -->

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

  <!-- fig caption -->
  <xsl:template match="fig" mode="caption">
    <xsl:variable name="id">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <xsl:variable name="graphic-type">
      <xsl:choose>
        <xsl:when test="substring-after(alternatives/graphic/@xlink:href, '.') = 'gif'">
          <xsl:value-of select="'animation'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'graphic'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(supplementary-material)">
        <!-- <xsl:apply-templates/> --> <!--Fix imagethumb issue - CIT-9220-->
         <div class="fig-caption">
          <xsl:variable name="filename">
            <xsl:call-template name="get-filename">
              <xsl:with-param name="string" select="alternatives/graphic[@content-type='image']/@xlink:href"/>
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
                  <xsl:value-of select="concat('/article/view/', $pmcid, '/figure/', $id, '/version/', $current-version)"/>
                </xsl:attribute>
                <xsl:text>Open in a separate window</xsl:text>
              </a>
            </span>
          </span>
          <span class="fig-label">
            <a class="figpopup">
              <xsl:attribute name="href">
                <xsl:value-of select="concat('/article/view/', $pmcid, '/figure/', $id, '/version/', $current-version)"/>
              </xsl:attribute>
              <xsl:value-of select="label/text()"/>
            </a>
          </span>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="descendant::caption/node()"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="label" mode="supplementary-materials"/>
        <xsl:apply-templates select="descendant::caption/node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="supplementary-material/label">
    <xsl:apply-templates select="." mode="supplementary-materials"/>
  </xsl:template>

  <xsl:template match="label" mode="supplementary-materials">
    <span class="supplementary-material-label">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="fig-group//caption/title | fig//caption/title | supplementary-material/caption/title | table-wrap/caption/p | table-wrap-group/caption/p">
    <span class="caption-title">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="caption">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="fig-group" mode="display">
    <div class="elife-fig-image-caption-wrapper" id="{@id}">
      <div class="fig-caption fig-group">
        <span class="fig-label">
          <xsl:value-of select="label/text()"/>
          <xsl:if test="label/text() and caption/title">
            <xsl:text>: </xsl:text>
          </xsl:if>
        </span>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="caption/node()"/>
      </div>
      <xsl:apply-templates select="fig" mode="display"/>
    </div>
  </xsl:template>

  <xsl:template match="fig" mode="display">
    <xsl:variable name="caption" select="child::label/text()"/>
    <xsl:variable name="id">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <div id="{$id}" class="fig-inline-img-set">
      <div class="elife-fig-image-caption-wrapper whole_rhythm">
        <div>
          <xsl:attribute name="class">
            <xsl:text>fig-expansion</xsl:text>
            <xsl:if test="number(substring-after($id, 'F')) mod 2 = 0">
              <xsl:text> even</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <xsl:for-each select="child::alternatives/graphic[@content-type='image']">
            <xsl:variable name="filename">
              <xsl:value-of select="@xlink:href"/>
              <!-- <xsl:call-template name="get-filename">
                <xsl:with-param name="string" select="@xlink:href"/>
              </xsl:call-template> -->
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
            <xsl:variable name="alt">
              <xsl:choose>
                <xsl:when test="descendant::alt-text">
                  <xsl:value-of select="descendant::alt-text"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$caption"/>
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
                    <!-- <xsl:value-of select="concat($graphics,'.jpg')"/> -->
                    <!-- <xsl:value-of select="$graphics"/> -->
                    <xsl:value-of select="concat('/article/view/', $pmcid, '/figure/', $id, '/version/', $current-version)"/>
                  </xsl:attribute>
                  <!-- <img data-img="[graphic-{$filename}-medium]" src="{concat($graphics, '.jpg')}" alt="{$alt}"/> -->
                  <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="{$alt}"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:for-each>
        </div>
        <xsl:apply-templates select="." mode="caption"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="inline-graphic | graphic[not(ancestor::fig)][not(ancestor::sec[@sec-type='scanned-pages'])]">
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
    <xsl:variable name="alt">
      <xsl:choose>
        <xsl:when test="alt-text">
          <xsl:value-of select="alt-text"/>
        </xsl:when>
        <xsl:otherwise>inline image</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="{$graphics}" target="_blank" class="figure-expand" title="Click to open full size">
      <img data-img="[graphic-{$filename}-medium]" src="{$graphics}" alt="{$alt}"/>
    </a>
  </xsl:template>

  <!-- END Figure Handling -->

  <!-- START Math Handling -->

  <xsl:template match="inline-formula">
    <span class="inline-formula">
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id"/>
          </xsl:when>
          <xsl:when test="descendant::*[local-name() = 'math']/@id">
            <xsl:value-of select="concat(descendant::*[local-name() = 'math']/@id, '-inline')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
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
      <!--new-->
      <xsl:apply-templates select="mml:math" />
      <xsl:if test="label">
        <span class="disp-formula-label">
          <xsl:value-of select="label/text()"/>
        </span>
      </xsl:if>
    </span>
  </xsl:template>

 <!--works only in firefox-->
  <!-- <xsl:template match="mml:math">
    <span class="f mathjax mml-math">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="." />
    </span>
  </xsl:template>
  <xsl:template match="mml:mglyph/@src">
    <xsl:variable name="filename">
      <xsl:call-template name="get-filename">
        <xsl:with-param name="string" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="src">
      <xsl:value-of select="concat($filebase,'image/',$filename,'.jpg')"/>
    </xsl:attribute>
  </xsl:template>  -->

  <xsl:template match="mml:math">
    <span class="f mathjax mml-math">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$msspreview">
          <xsl:text>&lt;math xmlns="http://www.w3.org/1998/Math/MathML"&gt;</xsl:text>
          <xsl:apply-templates mode="serialize"/>
          <xsl:text>&lt;/math&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:for-each select="@*[local-name() != 'id']">
              <xsl:attribute name="{name()}">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
          </math>
          </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template match="mml:*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>

<!--  <xsl:template match="text()">-->
<!--    <xsl:copy-of select="."/>-->
<!--  </xsl:template>-->

  <xsl:template match="mml:mglyph/@src">
    <xsl:variable name="filename">
      <xsl:call-template name="get-filename">
        <xsl:with-param name="string" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:attribute name="src">
      <xsl:value-of select="concat($filebase,'image/',$filename,'.jpg')"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mml:mglyph/@src" mode="serialize">
    <xsl:variable name="filename">
      <xsl:call-template name="get-filename">
        <xsl:with-param name="string" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="substring-before(substring-after($filelist, concat($filename,':')), ';')"/>
    <xsl:text>"</xsl:text>
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

  <!-- END Math Handling -->

  <!-- ==== BACK ==== -->

  <xsl:template match="back">
    <xsl:apply-templates select="ack"/>
    <xsl:apply-templates select="preceding-sibling::*//author-notes"/>
    <xsl:if test="not(preceding-sibling::*//author-notes) and (fn-group/fn[@fn-type = 'con'] | preceding-sibling::*//contrib[@equal-contrib = 'yes'] | preceding-sibling::*//contrib/email | bio | fn-group/fn[@fn-type = 'conflict'] | preceding-sibling::*//contrib-group[@content-type='collab-list'] | preceding-sibling::*//contrib-group/parent::collab)">
      <h2 id="author-notes" class="head">Author Information</h2>
      <xsl:if test="preceding-sibling::*//contrib/email">
        <xsl:apply-templates select="preceding-sibling::*" mode="list-emails"/>
      </xsl:if>
      <xsl:apply-templates select="bio"/>
      <xsl:if test="fn-group/fn[@fn-type = 'con'] | preceding-sibling::*//contrib[@equal-contrib = 'yes']">
        <div id="author-info-equal-contrib">
          <xsl:apply-templates select="fn-group/fn[@fn-type = 'con']"/>
          <xsl:if test="not(fn-group/fn[@fn-type = 'con'])">
            <h3>Author Contributions</h3>
          </xsl:if>
          <xsl:apply-templates select="preceding-sibling::*//contrib[@equal-contrib = 'yes'][1]" mode="equal"/>
        </div>
      </xsl:if>
      <xsl:apply-templates select="preceding-sibling::*//contrib-group[@content-type='collab-list']"/>
      <xsl:apply-templates select="preceding-sibling::*//contrib-group/parent::collab" mode="collab-list-container"/>
      <xsl:apply-templates select="fn-group/fn[@fn-type = 'conflict']"/>
    </xsl:if>
    <xsl:apply-templates select="*[not(self::ack) and not(self::bio)]"/>
  </xsl:template>

  <!-- Acknowledgement -->

  <xsl:template match="back/ack">
    <div id="ack-1">
      <h2 id="ack-1title" class="head">
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

  <!-- Back footnotes -->

  <!-- author-notes -->
  <xsl:template match="author-notes">
    <xsl:if test="fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address') or not(@fn-type)] | p | corresp | bio | ancestor::*[starts-with(name(), 'front')]/following-sibling::back/bio">
      <!-- <h2 id="author-notes" class="head">Author Information</h2> -->
      <xsl:apply-templates select="p | corresp"/>
      <xsl:apply-templates select="parent::*" mode="list-emails"/>
      <xsl:apply-templates select="ancestor::*[starts-with(name(), 'front')]/following-sibling::back/bio | bio"/>
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
    <xsl:apply-templates select="preceding-sibling::*//contrib-group[@content-type='collab-list']"/>
    <xsl:apply-templates select="preceding-sibling::*//contrib-group/parent::collab" mode="collab-list-container"/>
    <xsl:if test="fn[@fn-type = 'present-address']">
      <div id="author-info-additional-address">
        <xsl:apply-templates select="fn[@fn-type = 'present-address'][1]"/>
      </div>
    </xsl:if>
    <xsl:if test="fn[not(@fn-type)] | fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')] | ancestor::*[starts-with(name(), 'front')]/following-sibling::back/fn-group/fn[@fn-type = 'conflict']">
      <div id="author-info-other-footnotes">
        <xsl:apply-templates select="fn[not(@fn-type)] | fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address')] | ancestor::*[starts-with(name(), 'front')]/following-sibling::back/fn-group/fn[@fn-type = 'conflict']"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="back/fn-group">
    <xsl:if test="fn[not(@fn-type = 'con' or @fn-type = 'conflict')]">
      <div id="notes">
        <h2 id="notestitle" class="head">
          <xsl:choose>
            <xsl:when test="title">
              <xsl:apply-templates select="title"/>
            </xsl:when>
            <xsl:otherwise>Notes</xsl:otherwise>
          </xsl:choose>
        </h2>
        <xsl:apply-templates select="fn[not(@fn-type = 'con' or @fn-type = 'conflict')]"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="boxed-text/fn-group" mode="testing">
    <xsl:if test="fn[not(@fn-type = 'con' or @fn-type = 'conflict')]">
      <div id="notes">
        <h2 id="notestitle" class="head">
          <xsl:choose>
            <xsl:when test="title">
              <xsl:apply-templates select="title"/>
            </xsl:when>
            <xsl:otherwise>Notes</xsl:otherwise>
          </xsl:choose>
        </h2>
        <xsl:apply-templates select="fn[not(@fn-type = 'con' or @fn-type = 'conflict')]"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="boxed-text/fn-group/fn | back/fn-group/fn | author-notes/fn[@fn-type = 'con' or @fn-type = 'conflict']">
    <xsl:apply-templates select="p" mode="testing"/>
  </xsl:template>

  <xsl:template match="table-wrap-foot/fn">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Template for fn/p, mode = testing -->
  <xsl:template match="boxed-text/fn-group/fn/p | back/fn-group/fn/p | author-notes/fn[@fn-type = 'con' or @fn-type = 'conflict']/p" mode="testing">
    <xsl:choose>
      <xsl:when test="*[position()=1][self::bold] and (not(child::text()) or not(child::text()[normalize-space(.) != '']))">
        <h3>
          <xsl:attribute name="id">
            <xsl:value-of select="parent::fn/@id"/>
          </xsl:attribute>
          <xsl:value-of select="bold"/>
        </h3>
        <xsl:apply-templates select="*[not(self::bold)]"></xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template for fn/p, default mode -->
  <xsl:template match="boxed-text/fn-group/fn/p | back/fn-group/fn/p | author-notes/fn[@fn-type = 'con' or @fn-type = 'conflict']/p | table-wrap-foot/fn/p">
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
      <xsl:apply-templates mode="testing"/>
    </p>
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
        <xsl:for-each select="../../contrib-group/contrib[xref[@rid = $contributeid]]">
          <li class="equal-contributor">
            <xsl:apply-templates select="descendant::name[1]|string-name|collab"/>
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
            <xsl:apply-templates select="descendant::name[1]|string-name|collab"/>
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

  <!-- Template for fn/p under fn-group with content-tyep = author-contribution -->
  <xsl:template match="fn-group[@content-type = 'author-contribution']/fn/p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="author-notes/fn[not(@fn-type)] | author-notes/fn[(@fn-type != 'con' and @fn-type != 'equal' and @fn-type != 'present-address' and @fn-type != 'conflict')]">
    <div class="foot-note" id="{@id}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="author-notes/fn[not(@fn-type)]/p | author-notes/fn[(@fn-type != 'con' and @fn-type != 'present-address')]/p">
    <xsl:variable name="id" select="parent::fn/@id"/>
    <xsl:variable name="symbol">
      <xsl:if test="//xref[@rid = $id]">
        <xsl:if test="not(preceding-sibling::p)">
          <xsl:variable name="count" select="count(parent::fn/preceding-sibling::fn[not(@fn-type)] |
            parent::fn/preceding-sibling::fn[(@fn-type != 'con' and @fn-type != 'present-address')]) + 1"/>
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

  <xsl:template match="email">
    <xsl:variable name="email">
      <xsl:call-template name="reverse">
        <xsl:with-param name="rest" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <a href="mailto:dev@null" data-email="{$email}" class="oemail">
      <xsl:value-of select="$email"/>
    </a>
    <xsl:if test="ancestor::contrib and following-sibling::email">
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
    <xsl:if test="parent::*/contrib-group[@content-type='collab-list']//aff[not(. = preceding::aff)]">
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
    </xsl:if>
  </xsl:template>

  <xsl:template match="contrib-group" mode="make-collab-list">
    <xsl:param name="rid"/>
    <div class="fulltext--collab-author-information" id="{$rid}">
      <h3>
        <xsl:apply-templates select="//contrib[@id=$rid]/collab/node()"/>
      </h3>
      <div>
        <xsl:for-each select="contrib[@rid=$rid]">
          <xsl:apply-templates select="*[self::name or self::collab][1]" mode="authorlist"/>
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

  <xsl:template match="collab" mode="collab-list-container">
    <div class="fulltext--collab-author-information" id="{concat('collab', count(preceding::collab[contrib-group])+1)}">
      <h3>
        <xsl:apply-templates select="node()[not(self::contrib-group or self::author-comment or self::aff)]"/>
      </h3>
      <xsl:apply-templates select="author-comment[following-sibling::contrib-group]/node()"/>
      <div>
        <xsl:for-each select="contrib-group/contrib">
          <xsl:apply-templates select="name|collab" mode="authorlist"/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:if test="position() = last()-1">
            <xsl:text>and </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </div>
    </div>
    <xsl:apply-templates select="author-comment[preceding-sibling::contrib-group]/node()"/>
    <xsl:if test="contrib-group/aff or contrib-group/contrib/aff">
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

  <!--Scanned pages handling-->
  <xsl:template match="sec[@sec-type='scanned-pages']" mode="testing">
    <xsl:variable name="id">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <div id="{$id}">
      <h2 id="{concat($id,'title')}" class="head">Full text</h2>
      <h6>
        Full text is available as a scanned copy of the original print version. Get a printable copy (PDF file) of the
        <a class="api-link" href="/{$pdf-file-name}"><strong>complete article</strong></a> (1.2M), or click on a page image below to browse page by page. Links to PubMed are also available for
        <a href="#ref-list"><strong>Selected References</strong></a>.
      </h6>
      <div class="scanned-pages-wrapper">
        <xsl:apply-templates select="//graphic" mode="scanned-page-graphic"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="graphic" mode="scanned-page-graphic">
  <div class="scanned-page">
    <xsl:variable name="png" select="@xlink:href"/>
    <xsl:variable name="gif">
      <xsl:value-of select="concat(substring-before($png, '.png'), '.gif')"/>
    </xsl:variable>
    <xsl:variable name="label" select="label"/>
    <a class="link" href="/article/view/{$pmcid}/scanned/{$label}/version/{$current-version}">
      <img src="/{$gif}" alt="Scanned page {$label}" />
      <div class="page-label">
        <xsl:value-of select="$label"/>
      </div>
    </a>
  </div>
</xsl:template>

<!--data citations-->
<xsl:template match="sec[@sec-type='data-citations']" mode="testing">
  <xsl:apply-templates/>
</xsl:template>

  <!-- START Reference Handling -->

  <xsl:template match="sec[@sec-type='ref-list']" mode="testing">
    <xsl:variable name="id">
     <!--handling sub article [TOC removal]-->
      <xsl:choose>
        <xsl:when test="ancestor::sub-article">
          <xsl:text>SA-ref-list</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>ref-list</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div id="{$id}">
      <xsl:element name="h2">
        <xsl:attribute name="class">head</xsl:attribute>
        <xsl:attribute name="id"><xsl:value-of select="concat($id,'title')"/></xsl:attribute>
        <xsl:choose>
          <xsl:when test="title">
            <xsl:value-of select="title"/>
          </xsl:when>
          <xsl:when test="count(.//ref-list/ref) = 1">
            <xsl:text>Reference</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>References</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:apply-templates select="p" mode="pmc-reference"/>
      <ol>
        <xsl:attribute name="id">
          <xsl:text>reference-list</xsl:text>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="sec/ref-list/ref/label">
            <xsl:attribute name="class">list_with_labels elife-reflinks-links</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select="descendant::ref" mode="pmc-reference"/>
      </ol>
    </div>
  </xsl:template>

  <xsl:template match="p" mode="pmc-reference">
      <h6>
          <xsl:apply-templates/>
      </h6>
  </xsl:template>
  <xsl:template match="ref" mode="pmc-reference">
    <li style="list-style-type: none" class="elife-reflinks-reflink" id="{@id}">
      <xsl:if test="not(label) and parent::ref-list/ref/label">
        <span class="list_label"/>
      </xsl:if>
      <xsl:if test="count(ancestor::ref-list//mixed-citation) > 1">
        <xsl:apply-templates select="label"/>
      </xsl:if>
      <xsl:apply-templates select="mixed-citation" mode="pmc-reference"/>
    </li>
  </xsl:template>

  <xsl:template match="mixed-citation" mode="pmc-reference">
    <span class="reflink-main">
      <xsl:apply-templates select="named-content" mode="pmc-reference"/>
      <xsl:for-each select="
        ext-link[@ext-link-type = 'doi' or
         @ext-link-type = 'pmcid' or
         @ext-link-type = 'pmid' or
         @ext-link-type = 'google-scholar']
        | related-article">
        <xsl:choose>
        <xsl:when test="self::ext-link[@ext-link-type='doi']">
            <xsl:call-template name="ext-link-doi">
              <xsl:with-param name="href"  select="@xlink:href"/>
              <xsl:with-param name="label" select="'[DOI]'"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:when test="self::ext-link[@ext-link-type='pmcid']">
            <xsl:call-template name="ext-link-pmcid">
              <xsl:with-param name="href"  select="@xlink:href"/>
              <xsl:with-param name="label" select="'[Europe PMC free article]'"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:when test="self::ext-link[@ext-link-type='pmid']">
            <xsl:call-template name="ext-link-pmid">
              <xsl:with-param name="href"  select="@xlink:href"/>
              <xsl:with-param name="label" select="'[Abstract]'"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:when test="self::ext-link[@ext-link-type='google-scholar']">
            <xsl:call-template name="ext-link-google-scholar">
              <xsl:with-param name="href"  select="@xlink:href"/>
              <xsl:with-param name="label" select="'[Google Scholar]'"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:when test="self::related-article">
            <xsl:apply-templates select="." mode="mixed-citation"/>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </span>
  </xsl:template>

  <xsl:template match="related-article" mode="mixed-citation">
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="@related-article-type = 'retraction-forward'">[Retracted]</xsl:when>
        <xsl:when test="@related-article-type = 'retraction-republication'">[Retracted republished]</xsl:when>
        <xsl:when test="@related-article-type = 'statement-of-misconduct'">[Research Misconduct Found]</xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="normalize-space($label) != ''">
      <xsl:variable name="css-class">text-red</xsl:variable>
      <xsl:variable name="href" select="@xlink:href"/>
      <xsl:choose>
        <xsl:when test="@ext-link-type = 'pmcid'">
          <xsl:call-template name="ext-link-pmcid">
            <xsl:with-param name="href"      select="$href"/>
            <xsl:with-param name="label"     select="$label"/>
            <xsl:with-param name="css-class" select="$css-class"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@ext-link-type = 'pmid'">
          <xsl:call-template name="ext-link-pmid">
            <xsl:with-param name="href"      select="$href"/>
            <xsl:with-param name="label"     select="$label"/>
            <xsl:with-param name="css-class" select="$css-class"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@ext-link-type = 'doi'">
          <xsl:call-template name="ext-link-doi">
            <xsl:with-param name="href"      select="$href"/>
            <xsl:with-param name="label"     select="$label"/>
            <xsl:with-param name="css-class" select="$css-class"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <!-- fallback: plain text label -->
          <span class="text-red">
            <xsl:value-of select="$label"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Generic DOI link -->
  <xsl:template name="ext-link-doi">
    <xsl:param name="href"/>
    <xsl:param name="label"/>
    <xsl:param name="css-class" select="''"/>

    <a href="https://doi.org/{$href}" target="_blank">
      <xsl:if test="$css-class != ''">
        <xsl:attribute name="class">
          <xsl:value-of select="$css-class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$label"/>
    </a>
  </xsl:template>

  <!-- Generic PMCID link -->
  <xsl:template name="ext-link-pmcid">
    <xsl:param name="href"/>
    <xsl:param name="label"/>
    <xsl:param name="css-class" select="''"/>

    <a href="https://europepmc.org/articles/{$href}" target="_blank">
      <xsl:if test="$css-class != ''">
        <xsl:attribute name="class">
          <xsl:value-of select="$css-class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$label"/>
    </a>
  </xsl:template>

  <!-- Generic PMID link -->
  <xsl:template name="ext-link-pmid">
    <xsl:param name="href"/>
    <xsl:param name="label"/>
    <xsl:param name="css-class" select="''"/>

    <a href="https://europepmc.org/article/MED/{$href}" target="_blank">
      <xsl:if test="$css-class != ''">
        <xsl:attribute name="class">
          <xsl:value-of select="$css-class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$label"/>
    </a>
  </xsl:template>

  <!-- Google Scholar link -->
  <xsl:template name="ext-link-google-scholar">
    <xsl:param name="href"/>
    <xsl:param name="label"/>

    <a href="https://scholar.google.com/scholar_lookup?{$href}" target="_blank">
      <xsl:value-of select="$label"/>
    </a>
  </xsl:template>

  <xsl:template match="named-content" mode="pmc-reference">
    <!-- Extract everything before 'doi:' -->
    <xsl:choose>
        <xsl:when test="contains(., 'doi:')">
            <xsl:value-of select="substring-before(., 'doi:')"/>
        </xsl:when>
        <xsl:otherwise>
            <!-- Output entire content if 'doi:' is not present -->
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

  <xsl:template match="ref-list">
    <xsl:variable name="id">
      <xsl:text>ref-list</xsl:text>
      <xsl:if test="preceding::ref-list">
        <xsl:value-of select="count(preceding::ref-list)"/>
      </xsl:if>
    </xsl:variable>
    <div id="{$id}">
      <xsl:if test="title">
        <xsl:element name="h{count(ancestor::ref-list)+2}">
          <xsl:attribute name="id"><xsl:value-of select="concat($id,'title')"/></xsl:attribute>
          <xsl:apply-templates select="label"/>
          <!-- <xsl:choose>
            <xsl:when test="title"> -->
              <xsl:value-of select="title"/>
            <!-- </xsl:when> -->
            <!-- <xsl:otherwise>References</xsl:otherwise> --> <!--problem for references under data-citations for sub-article-->
          <!-- </xsl:choose> -->
        </xsl:element>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::label or self::title or self::ref)]"/>
      <ol style="list-style-type: none">
        <xsl:attribute name="id">
          <xsl:text>reference-list</xsl:text>
          <xsl:if test="preceding::ref-list">
            <xsl:value-of select="count(preceding::ref-list)"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="ref/label">
            <xsl:attribute name="class">list_with_labels elife-reflinks-links</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">hanging_indent_list elife-reflinks-links</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="ref"/>
      </ol>
    </div>
  </xsl:template>

  <xsl:template match="ref">
    <li class="elife-reflinks-reflink" id="{@id}">
      <xsl:if test="not(label) and parent::ref-list/ref/label">
        <span class="list_label"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(descendant::element-citation) + count(descendant::mixed-citation) > 1">
          <xsl:apply-templates select="label"/>
          <ol>
            <xsl:choose>
              <xsl:when test="descendant::element-citation/label or descendant::mixed-citation/label">
                <xsl:attribute name="style">list-style-type: none</xsl:attribute>
                <xsl:attribute name="class">list_with_labels elife-reflinks-links</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="style">list-style-type: lower-alpha</xsl:attribute>
                <xsl:attribute name="class">elife-reflinks-links</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()[not(self::label)]"/>
          </ol>
        </xsl:when>
        <xsl:when test="note">
          <xsl:apply-templates select="label"/>
          <div class="reflink-with-note">
            <xsl:apply-templates select="node()[not(self::label)]"/>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template match="ref/label">
    <xsl:apply-templates select="." mode="list-label"/>
  </xsl:template>

  <xsl:template match="ref/note">
    <span class="reflink-note">
      <xsl:apply-templates select="p"/>
    </span>
  </xsl:template>

  <xsl:template match="ref/note/p">
    <xsl:apply-templates mode="testing"/>
    <xsl:if test="not(ancestor::list-item or ancestor::fig or ancestor::table or ancestor::boxed-text)">
      <xsl:apply-templates select="." mode="add-floats"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="element-citation/person-group | element-citation/collab" mode="list-ref-people">
    <xsl:for-each select="name | collab | self::collab">
      <xsl:if test="position() != 1">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="name() = 'name'">
          <span class="reflink-author">
            <xsl:value-of select="concat(surname, ' ', given-names)"/>
            <xsl:if test="suffix">
              <xsl:text> </xsl:text>
              <xsl:value-of select="suffix"/>
            </xsl:if>
          </span>
        </xsl:when>
        <xsl:when test="name() = 'collab'">
          <span class="reflink-author">
            <span class="nlm-collab">
              <xsl:apply-templates/>
            </span>
          </span>
        </xsl:when>
        <xsl:when test="name() = 'string-name'">
          <span class="reflink-author">
            <xsl:apply-templates/>
          </span>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="@person-group-type = 'editor' or @person-group-type = 'translator'">
        <xsl:if test="etal">
          <xsl:text>, et al</xsl:text>
        </xsl:if>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="@person-group-type"/>
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

  <xsl:template match="ref//element-citation|ref//mixed-citation">
    <xsl:choose>
      <xsl:when test="ancestor::ref[count(descendant::element-citation) + count(descendant::mixed-citation) > 1]">
        <li>
          <xsl:apply-templates select="." mode="display"/>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="display"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="element-citation" mode="display">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="child::article-title">
          <xsl:apply-templates select="child::article-title/node()"/>
        </xsl:when>
        <xsl:when test="child::chapter-title">
          <xsl:apply-templates select="child::chapter-title/node()"/>
        </xsl:when>
        <xsl:when test="child::source">
          <xsl:apply-templates select="child::source/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title-type">
      <xsl:choose>
        <xsl:when test="child::article-title or child::chapter-title">
          <xsl:value-of select="'article-title'"/>
        </xsl:when>
        <xsl:when test="child::source">
          <xsl:value-of select="'source'"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="label" mode="list-label"/>
    <span class="reflink-main">
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
          <xsl:if test="not('.' = substring($title, string-length($title) - string-length('.') + 1)) and
            not('?' = substring($title, string-length($title) - string-length('?') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      <!-- move all other elements into details -->
      <xsl:variable name="class">
        <xsl:if test="@publication-type = 'journal'">
          <xsl:value-of select="'reflink-details-journal'"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="includes">
        <xsl:if test="child::person-group[@person-group-type = 'editor' or @person-group-type = 'translator']">
          <xsl:value-of select="'edlist|'"/>
        </xsl:if>
        <xsl:if test="(child::article-title or child::chapter-title) and child::source">
          <xsl:value-of select="'source|'"/>
        </xsl:if>
        <xsl:if test="child::edition">
          <xsl:value-of select="'edition|'"/>
        </xsl:if>
        <xsl:if test="child::version">
          <xsl:value-of select="'version|'"/>
        </xsl:if>
        <xsl:if test="child::series">
          <xsl:value-of select="'series|'"/>
        </xsl:if>
        <xsl:if test="child::*[starts-with(name(), 'conf')]">
          <xsl:value-of select="'conference|'"/>
        </xsl:if>
        <xsl:if test="child::patent">
          <xsl:value-of select="'patent|'"/>
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
        <xsl:if test="child::elocation-id">
          <xsl:value-of select="'elocation|'"/>
        </xsl:if>
      </xsl:variable>
      <xsl:if test="contains($includes, 'edlist|') and @publication-type != 'journal'">
        <xsl:if test="contains($includes, 'source|')">
          <xsl:text>In: </xsl:text>
        </xsl:if>
        <span>
          <xsl:apply-templates select="person-group[@person-group-type = 'editor']" mode="list-ref-people"/>
          <xsl:apply-templates select="person-group[@person-group-type = 'translator']" mode="list-ref-people"/>
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
          <xsl:if test="contains($includes, 'patent|')">
            <xsl:text> </xsl:text>
            <span class="reflink-details-patent">
              <xsl:apply-templates select="child::patent/node()"/>
            </span>
          </xsl:if>
          <xsl:if test="not('.' = substring(source, string-length(source) - string-length('.') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'conference|')">
        <span class="reflink-details-conference">
          <xsl:apply-templates select="child::conf-name/node()"/>
          <xsl:if test="child::conf-name and (child::conf-date)">
            <xsl:if test="not('.' = substring(conf-name, string-length(conf-name) - string-length('.') + 1))">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:if>
          <xsl:apply-templates select="child::conf-date/node()"/>
          <xsl:if test="(child::conf-name or child::conf-date) and child::conf-loc">
            <xsl:text>; </xsl:text>
          </xsl:if>
          <xsl:apply-templates select="child::conf-loc/node()"/>
          <xsl:if test="not('.' = substring(conf-loc, string-length(conf-loc) - string-length('.') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="child::conf-sponsor/node()"/>
          <xsl:if test="(child::conf-name or child::conf-loc) and child::conf-sponsor">
            <xsl:text>. </xsl:text>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'edition|')">
        <span class="nlm-edition">
          <xsl:apply-templates select="child::edition/node()"/>
          <xsl:if test="not('.' = substring(edition, string-length(edition) - string-length('.') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'version|')">
        <span class="nlm-version">
          <xsl:apply-templates select="child::version/node()"/>
          <xsl:if test="not('.' = substring(version, string-length(version) - string-length('.') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'series|')">
        <span class="nlm-version">
          <xsl:apply-templates select="child::series/node()"/>
          <xsl:if test="not('.' = substring(series, string-length(series) - string-length('.') + 1))">
            <xsl:text>.</xsl:text>
          </xsl:if>
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="contains($includes, 'publisher-loc|')">
          <xsl:apply-templates select="child::publisher-loc" mode="publisher-pair">
            <xsl:with-param name="includes"><xsl:value-of select="$includes"/></xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="contains($includes, 'publisher-name|')">
          <span class="reflink-details-pub-name">
            <span class="nlm-publisher-name">
              <xsl:apply-templates select="child::publisher-name/node()"/>
            </span>
            <xsl:if test="contains($includes, 'year|')">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </span>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="contains($includes, 'year|')">
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
      <xsl:if test="contains($includes, 'fpage|') or contains($includes, 'elocation|')">
        <xsl:if test="not(starts-with($includes, 'fpage|') or starts-with($includes, 'elocation|'))">
          <xsl:choose>
            <xsl:when test="@publication-type='book'">
              <xsl:text>. p. </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>: </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:if>
      <xsl:if test="contains($includes, 'fpage|')">
        <span class="reflink-details-pages">
          <xsl:apply-templates select="child::fpage/node()"/>
          <xsl:if test="contains($includes, 'lpage|')">
            <xsl:text>-</xsl:text>
            <xsl:apply-templates select="child::lpage/node()"/>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="contains($includes, 'elocation|')">
        <xsl:if test="contains($includes, 'fpage|')">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <span class="reflink-details-pages">
          <xsl:apply-templates select="child::elocation-id/node()"/>
        </span>
      </xsl:if>
      <xsl:if test="$includes != ''">
        <xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="comment|annotation|ext-link"/>
      <xsl:apply-templates select="date-in-citation"/>
      <xsl:apply-templates select="pub-id[@pub-id-type = 'doi']" mode="idlinks"/>
      <xsl:apply-templates select="pub-id[not(@pub-id-type = 'doi')]" mode="idlinks"/>
    </span>
  </xsl:template>

  <xsl:template match="element-citation/comment|mixed-citation/comment">
    <span>
      <xsl:for-each select="@*">
       <xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates select="text()"/>
    </span>
  </xsl:template>

  <xsl:template match="mixed-citation" mode="display">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="child::article-title">
          <xsl:apply-templates select="child::article-title/node()"/>
        </xsl:when>
        <xsl:when test="child::chapter-title">
          <xsl:apply-templates select="child::chapter-title/node()"/>
        </xsl:when>
        <xsl:when test="child::source">
          <xsl:apply-templates select="child::source/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title-type">
      <xsl:choose>
        <xsl:when test="child::article-title or child::chapter-title">
          <xsl:value-of select="'article-title'"/>
        </xsl:when>
        <xsl:when test="child::source">
          <xsl:value-of select="'source'"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="label" mode="list-label"/>
    <span class="reflink-main">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="mixed-citation/person-group[@person-group-type = 'author'] | mixed-citation/collab">
    <span class="authors">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="mixed-citation//name">
    <span class="reflink-author">
      <xsl:value-of select="concat(surname, ' ', given-names)"/>
      <xsl:if test="suffix">
        <xsl:text> </xsl:text>
        <xsl:value-of select="suffix"/>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="mixed-citation//string-name">
    <span class="reflink-author"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="mixed-citation//etal">
    <xsl:text>et al</xsl:text>
  </xsl:template>

  <xsl:template match="mixed-citation//article-title | mixed-citation//chapter-title">
    <span class="elife-reflink-title">
      <span class="nlm-article-title">
        <xsl:apply-templates/>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="mixed-citation//source">
    <xsl:choose>
      <xsl:when test="not(ancestor::mixed-citation/article-title or ancestor::mixed-citation/chapter-title)">
        <span class="elife-reflink-title">
          <span class="nlm-source">
            <xsl:apply-templates/>
          </span>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="nlm-source"><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mixed-citation//pub-id">
    <xsl:apply-templates select="." mode="idlinks"/>
  </xsl:template>

  <xsl:template match="mixed-citation//*/@*"/>

  <xsl:template match="element-citation//publisher-loc" mode="publisher-pair">
  <xsl:param name="includes"/>
    <span class="reflink-details-pub-loc">
      <span class="nlm-publisher-loc">
        <xsl:apply-templates select="node()"/>
      </span>
      <xsl:if test="contains($includes, 'publisher-name|')">
        <xsl:text>: </xsl:text>
      </xsl:if>
    </span>
    <xsl:if test="contains($includes, 'publisher-name|')">
      <span class="reflink-details-pub-name">
        <span class="nlm-publisher-name">
          <xsl:choose>
            <xsl:when test="following-sibling::publisher-name">
              <xsl:apply-templates select="following-sibling::publisher-name[1]/node()"/>
            </xsl:when>
            <xsl:when test="preceding-sibling::publisher-name">
              <xsl:apply-templates select="preceding-sibling::publisher-name[1]/node()"/>
            </xsl:when>
          </xsl:choose>
        </span>
        <xsl:if test="contains($includes, 'year|') or following-sibling::publisher-loc">
          <xsl:text>; </xsl:text>
        </xsl:if>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="element-citation//date-in-citation">
    <xsl:text> </xsl:text>
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
      <xsl:when test="@pub-id-type = 'pmcid' or @pub-id-type = 'pmc'">
        <xsl:variable name="pmcid">
          <xsl:choose>
            <xsl:when test="starts-with(translate(., $uppercase, $smallcase), 'pmc')">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('PMC', .)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:text> </xsl:text>
        <a href="{$siteUrl}/articles/{$pmcid}">
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

  <!-- END reference handling -->

  <!-- START video handling -->

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

  <!-- Appendices -->

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
        <h2 id="glossarytitle" class="head">Glossary</h2>
      </xsl:if>
      <xsl:apply-templates/>
    </sec>
  </xsl:template>

  <xsl:template match="glossary/title">
    <h2 id="glossarytitle" class="head">
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

  <xsl:template match="bio/title">
    <h3 id="{parent::bio/@id}"><xsl:apply-templates/></h3>
  </xsl:template>

  <xsl:template match="verse-line">
    <span style="display: block; text-indent: -1em; margin-left: 1em; ">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template name="multi-lang-switcher">
    <xsl:if test="article-meta/trans-abstract">
      <div class="whole_rythm lang-switcher">
        <label>Language: </label>
        <ul class="lang-switcher-list">
          <xsl:for-each select="article-meta/abstract | article-meta/trans-abstract">
            <xsl:call-template name="multi-lang-switcher-item"/>
          </xsl:for-each>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="multi-lang-switcher-item">
    <xsl:variable name="lang">
      <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
    </xsl:variable>
    <li class="lang-switcher-item">
      <a role="button">
      <xsl:attribute name="class">
        <xsl:text>lang-sw</xsl:text>
        <xsl:if test="self::abstract"> <xsl:text> selected</xsl:text> </xsl:if>
      </xsl:attribute>
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
        <xsl:call-template name="get-language-name">
          <xsl:with-param name="code" select="$lang"/>
        </xsl:call-template>
      </a>
      <xsl:if test="position() != last()">
        <xsl:text> | </xsl:text>
      </xsl:if>
    </li>
  </xsl:template>


  <!-- Override the default template, create copies for attributes and text nodes, instead of output the text values -->
  <!-- <xsl:template match="*"><xsl:apply-templates select="@* | node()"/></xsl:template>
  <xsl:template match="@* | text()"><xsl:copy/></xsl:template> -->

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*"><xsl:copy/></xsl:template>
  <xsl:template match="text()"><xsl:copy/></xsl:template>

  <!-- END - general format -->

  <!-- send through testing -->
  <xsl:template match="
      caption | table-wrap/table | table-wrap-foot | fn | bold | italic | underline | preformat | monospace | styled-content |
      sub | sup | sc | email | sec/title | boxed-text/label | boxed-text/caption/title | ext-link | app/title | disp-formula |
      inline-formula | list | list-item | hr | disp-quote | code | verse-group | def-list | inline-graphic | p" mode="testing">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="element-citation|mixed-citation">
    <xsl:if test="not(ancestor::ref)">
      <xsl:apply-templates select="." mode="display"/>
    </xsl:if>
  </xsl:template>

  <!-- Nodes to skip, continue with its child nodes-->
  <!-- Note: If nodes to skip apears in the document with attributes but the nodes
    are not listed here, the attributes will be copied to the parent element,
    which will cause problem if nodes has been generated under the parent element.
    We will get an XTDE0410 error. Add the nodes here will prevent the attribugtes to
   processed. -->
  <xsl:template match="floats-group//fig | floats-group//table-wrap | fn//table-wrap">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="table-wrap | boxed-text | fig | fig-group | table-wrap-group" mode="testing">
    <xsl:if test="@position='anchor'">
      <xsl:apply-templates select="." mode="display"/>
    </xsl:if>
  </xsl:template>

  <!-- nodes to remove -->
  <xsl:template match="ali:license_ref | ali:free_to_read"/>
  <xsl:template match="author-comment | article-version | subj-group"/>
  <xsl:template match="@xlink:href"/>
  <xsl:template match="sec[@sec-type = 'supplementary-materials'] | sec[@sec-type = 'floats-group']"/>
  <xsl:template match="back/fn-group/fn/label"/>
  <xsl:template match="boxed-text/fn-group/fn/label"/>
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
  <xsl:template match="boxed-text/caption/title | boxed-text/label"/>
  <xsl:template match="fig/graphic | fig/label | fig/caption"/>
  <xsl:template match="fig-group"/>
  <xsl:template match="ack/title"/>
  <xsl:template match="ref-list/title"/>
  <xsl:template match="element-citation//year | element-citation//article-title | element-citation//fpage | element-citation//volume
    | element-citation//issue | element-citation//source | element-citation//pub-id | element-citation//fpage
    | element-citation//supplement | element-citation//person-group[@person-group-type = 'editor'] | element-citation//collab
    | element-citation//edition | element-citation//publisher-loc |  element-citation//publisher-name | element-citation//elocation-id
    | element-citation//issn | element-citation//month | element-citation//day | element-citation//season"/>
  <xsl:template match="media/label"/>
  <xsl:template match="object-id | table-wrap/label | table-wrap-group/label"/>
  <xsl:template match="funding-group//institution-wrap/institution-id"/>
  <xsl:template match="table-wrap/graphic"/>
  <xsl:template match="table-wrap-foot//fn/label"/>

<!-- Attributes-->
  <xsl:template match="@xml:lang">
    <xsl:attribute name="lang">
        <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
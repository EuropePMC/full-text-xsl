<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
  exclude-result-prefixes="xsi xs xlink mml ali">

  <xsl:output method="html" indent="no" encoding="utf-8" omit-xml-declaration="yes"/>
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
  <xsl:variable name="pmid" select="/article/front/article-meta/article-id[@pub-id-type='pmid']/text()"/>
  <xsl:variable name="emsid">
    <xsl:if test="//article-meta/article-id[@pub-id-type = 'manuscript' or @pub-id-type = 'emsid']">
      <xsl:value-of select="translate(translate(//article-meta/article-id[@pub-id-type = 'manuscript' or @pub-id-type = 'emsid'], 'ucpak', 'es'), 'ems', 'EMS')"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="pmcid">
    <xsl:value-of select="//article-meta/article-id[@pub-id-type='pmcid']"/>
  </xsl:variable>
  <xsl:variable name="pageStart">
    <xsl:choose>
      <xsl:when test="$elementType = 'scanned'">
        <xsl:value-of select="substring-before(//article-meta/page-range, '–')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="pageEnd">
    <xsl:choose>
      <xsl:when test="$elementType = 'scanned'">
        <xsl:value-of select="substring-after(//article-meta/page-range, '–')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="pdf-file-name" select="//article-meta/self-uri[@content-type='pmc-pdf']/@xlink:href"/>
  <xsl:variable name="current-version">
    <xsl:choose>
      <xsl:when test="//article-meta/article-version">
        <xsl:value-of select="//article-meta/article-version"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="article">
    <xsl:apply-templates select="front"/>
    <xsl:apply-templates select="body"/>
  </xsl:template>

  <xsl:template match="front">
    <div class="front-matter half_rhythm">
      <table>
        <tbody>
          <tr>
            <td class="header">
              PMC full text:
            </td>
            <td class="citation-info">
              <div>
                <div>
                  <a href="https://europepmc.org/articles/{$pmcid}" target="_blank">
                    <xsl:if test="//article-meta/article-version">
                      <xsl:text>Version </xsl:text>
                      <xsl:value-of select="//article-meta/article-version"/>
                      <xsl:text>. </xsl:text>
                    </xsl:if> 
                    <xsl:choose>
                      <xsl:when test="journal-meta/journal-id">
                        <xsl:choose>
                          <!-- ssnexlite - journal name fix; check if journal-id has an attribute journal-id-type='pmc-domain-id' -->
                          <xsl:when test="journal-meta/journal-id[@journal-id-type='pmc-domain-id']">
                            <xsl:choose>
                              <xsl:when test="journal-meta/journal-title-group/abbrev-journal-title">
                                <xsl:value-of select="journal-meta/journal-title-group/abbrev-journal-title"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="journal-meta/journal-title-group/journal-title"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>
                          <!-- Otherwise, display the journal-id -->
                          <xsl:otherwise>
                            <xsl:value-of select="journal-meta/journal-id"/>
                          </xsl:otherwise>
                        </xsl:choose>
                        <!-- Add period after the journal-id or title -->
                        <xsl:text>.</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="journal-meta//journal-title"/>
                      </xsl:otherwise>
                    </xsl:choose>  
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="article-meta/pub-date[1]/year"/>  
                    <xsl:if test="article-meta/pub-date[1]/month">
                      <xsl:text> </xsl:text>
                      <xsl:call-template name="pmc_month">
                        <xsl:with-param name="num" select="article-meta/pub-date[1]/month"/>
                      </xsl:call-template>          
                    </xsl:if> 
                    <xsl:for-each select="article-meta[1]">
                      <xsl:if test="volume or issue or fpage or elocation-id">
                        <xsl:if test="volume or issue">
                          <xsl:text>; </xsl:text>
                          <xsl:value-of select="volume"/>
                          <xsl:if test="issue">
                            <xsl:value-of select="concat('(', issue, ')')"/>
                          </xsl:if>
                        </xsl:if>
                        <xsl:if test="page-range">
                          <xsl:text>: </xsl:text>
                          <xsl:value-of select="page-range"/>
                        </xsl:if>
                      </xsl:if>
                    </xsl:for-each>
                    <xsl:text>.</xsl:text> 
                  </a>    
                </div>
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
                <xsl:if test="article-meta/article-id[@pub-id-type='doi']">
                  <span class="doi">
                    <xsl:text>doi: </xsl:text>
                    <a href="{concat('https://doi.org/', article-meta/article-id[@pub-id-type='doi'])}" target="_blank">
                      <xsl:value-of select="article-meta/article-id[@pub-id-type='doi']"/>
                    </a>
                  </span>
                </xsl:if>
              </div>
              <xsl:apply-templates select="article-meta"/>
            </td>
            <xsl:if test="$elementType = 'figure'">
              <td class="figure-nav">
                <xsl:variable name="allFigs" select="//fig" />
                <xsl:variable name="currentFig" select="//fig[@id=$elementId]" />
                <xsl:variable name="currentPos" select="count($currentFig/preceding::fig) + 1" />
                <xsl:variable name="totalFigs" select="count($allFigs)" />
                <xsl:choose>
                  <xsl:when test="$currentPos &gt; 1">
                    <a class="nav-link prev"
                      href="{concat('/article/view/', $pmcid, '/figure/', $allFigs[$currentPos - 1]/@id, '/version/', $current-version)}"
                      >&lt;&lt; Prev</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="nav-link disabled">&lt;&lt; Prev</span>
                  </xsl:otherwise>
                </xsl:choose>

                <span class="fig-label">Figure <xsl:value-of select="$currentPos"/>.</span>

                <xsl:choose>
                  <xsl:when test="$currentPos &lt; $totalFigs">
                    <a class="nav-link next"
                      href="{concat('/article/view/', $pmcid, '/figure/', $allFigs[$currentPos + 1]/@id, '/version/', $current-version)}"
                      >Next &gt;&gt;</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="nav-link disabled">Next &gt;&gt;</span>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </xsl:if>
          </tr>
        </tbody>
      </table>
      <xsl:apply-templates select="article-meta/related-article"/>
    </div>
  </xsl:template>

  <xsl:template match="article-meta/related-article">
    <xsl:if test="@related-article-type='retraction-forward'">
    <div class="retraction-note">
      <span class="alert-mark"></span>
      <span class="notice">
        <xsl:apply-templates/>
      </span>
    </div>
  </xsl:if>
  </xsl:template>

  <xsl:template match="article-meta">
    <xsl:choose>
      <xsl:when test="permissions">
        <xsl:apply-templates select="permissions"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="permissions">
          <xsl:with-param name="top" select="1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="permissions" name="permissions">
    <xsl:param name="top"/>
    <xsl:variable name="head">
      <xsl:choose>
        <xsl:when test="parent::article-meta or $top">h2</xsl:when>
        <xsl:otherwise>b</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="fulltext-permissions">
      <div class="permissions-header">
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
            <xsl:attribute name="onclick">
              <xsl:text>
              this.classList.toggle('open'); 
              this.closest('.fulltext-permissions').classList.toggle('open');
              this.blur();
              </xsl:text>
            </xsl:attribute>
            <xsl:text>Copyright and license information</xsl:text>
          </xsl:element>
        </div>  
        <!-- <span class="request-permissions-title">
          <a href="https://europepmc.org/pmc/about/copyright/">
            <xsl:text>Request permission to reuse</xsl:text>
          </a>
        </span>      -->
      </div>
      <div class="permissions">
        <!-- <xsl:choose> -->
           <!--This need to be commented for PMC5500185-->
          <!-- <xsl:when test="$emsid != ''">
            <p><a href="https://europepmc.org/pmc/about/copyright/">
              <xsl:text>Copyright notice</xsl:text>
            </a></p>
          </xsl:when> -->
          <!-- <xsl:otherwise> -->
            <xsl:choose>
              <xsl:when test="self::permissions">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:otherwise>
                <p><a href="https://europepmc.org/pmc/about/copyright/">
                  <xsl:text>EPMC Copyright notice</xsl:text>
                </a></p>
              </xsl:otherwise>
            </xsl:choose>
          <!-- </xsl:otherwise> -->
        <!-- </xsl:choose> -->
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
    <p class="copyright">
    <xsl:apply-templates/>
  </p>  
  </xsl:template>
  <xsl:template match="license">
    <xsl:apply-templates/>    
  </xsl:template>

  <xsl:template match="license-p">
    <p class="license">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="body">
    <xsl:choose>
      <xsl:when test="$elementType = 'figure'">
        <xsl:apply-templates select="//fig[@id=$elementId]"/>
      </xsl:when>
      <xsl:when test="$elementType = 'table'">
        <xsl:apply-templates select="//table-wrap[@id=$elementId]"/>
      </xsl:when>
      <xsl:when test="$elementType = 'scanned'">
        <xsl:apply-templates select="sec[@sec-type='scanned-pages']"/>
      </xsl:when>
    </xsl:choose>
    </xsl:template>

  <xsl:template match="fig">
    <div class="fig whole_rhythm" id="{@id}">
      <h1 class="fig-label">
        <xsl:value-of select="label"/>
      </h1>
      <xsl:apply-templates select="alternatives/graphic[@content-type='image']"/>
      <xsl:apply-templates select="caption"/>
      <div class="figure-list">
        <h2 class="title"> Images in this article </h2>
        <ul class="fig-thumbs">
          <xsl:for-each select="//fig"> 
            <li>
              <xsl:choose>
                <xsl:when test="@id = $elementId">
                  <span class="thumb selected-thumb">
                    <xsl:apply-templates select="alternatives/graphic[@content-type='thumb']"/>
                  </span>
                </xsl:when>             
                <xsl:otherwise>
                <a target="_blank"
                  href="{concat('/article/view/', $pmcid, '/figure/', @id, '/version/', $current-version)}">
                  <xsl:apply-templates select="alternatives/graphic[@content-type='thumb']"/>
                </a>
                </xsl:otherwise>
              </xsl:choose>
            </li>
          </xsl:for-each>
        </ul>
        <div class="click-instruction">
          Click on the image to see a larger version.
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="alternatives/graphic[@content-type='image']">
      <div class="figure">
        <xsl:variable name="filename">
          <xsl:value-of select="@xlink:href"/>
        </xsl:variable>
        <xsl:variable name="graphics">
          <xsl:value-of select="concat('image/', $filename)" />
        </xsl:variable>
        <img 
          src="{$graphics}" 
          data-img="[graphic-{$filename}-large]" 
          alt="{../../label}" />
      </div>
  </xsl:template>

  <xsl:template match="alternatives/graphic[@content-type='thumb']">
    <xsl:variable name="filename">
      <xsl:value-of select="@xlink:href"/>
    </xsl:variable>
    <xsl:variable name="graphics">
      <xsl:value-of select="concat('image/', $filename)" />
    </xsl:variable>
    <img src="{$graphics}" 
      alt="{../../label}" class="thumb-img" />
  </xsl:template>

  <xsl:template match="caption">
      <div class="caption">
        <strong><xsl:value-of select="title"/></strong>
        <xsl:for-each select="p">
          <p>
            <xsl:if test="@id">
              <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="."/>
          </p>
        </xsl:for-each>
      </div>
  </xsl:template>

  <xsl:template match="table-wrap">
    <div class="table-wrap whole_rhythm" id="{@id}">
      <h1 class="table-label">
        <xsl:value-of select="label"/>
      </h1>
      <div class="table-caption">
        <strong>
          <xsl:value-of select="caption/title"/>
        </strong>
        <xsl:if test="caption/p">
          <p>
            <xsl:value-of select="caption/p"/>
          </p>
        </xsl:if>
      </div>
      <div class="table-container">
        <xsl:apply-templates select="table"/>
      </div>
      <xsl:if test="table-wrap-foot">
        <div class="table-foot">
          <xsl:apply-templates select="table-wrap-foot"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="table-wrap-foot">
    <div class="table-footnote">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="table">
    <table>
        <xsl:apply-templates select="@rules | @frame | @style"/>
        <xsl:apply-templates/>
    </table>
  </xsl:template>
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
  <xsl:template match="@rules | @frame | @style">
    <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>


  <!-- scanned pages-->
  <xsl:template match="sec[@sec-type='scanned-pages']">
    <div class="scanned-container">
      <div class="scanned-header">
        <h2>Scanned pages</h2>
        <a href="/{$pdf-file-name}" class="download-link">
          <i class="fas fa-download"></i>
          <span>Download PDF</span>
        </a>
      </div>
      <xsl:call-template name="scanned-navigation"/>
      <xsl:apply-templates select="graphic[label=$elementId]"/>
      <xsl:call-template name="scanned-navigation"/>
    </div>
  </xsl:template>

  <xsl:template name="scanned-navigation">
    <div class="scanned-pagination">
      <xsl:choose>
        <xsl:when test="$elementId &gt; $pageStart">
          <a class="nav-link prev" href="{concat('/article/view/', $pmcid, '/scanned/', $elementId - 1 , '/version/', $current-version)}">
          <!-- &lt; Previous -->
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M15 18L9 12L15 6"/>
          </svg>
          Previous
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span class="nav-link disabled">
          <!-- &lt; Previous -->
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M15 18L9 12L15 6"/>
          </svg>
          Previous
          </span>
        </xsl:otherwise>
      </xsl:choose>
      <ul class="page-tabs">
        <xsl:call-template name="page-loop">
          <xsl:with-param name="i" select="$pageStart"/>
          <xsl:with-param name="end" select="$pageEnd"/>
        </xsl:call-template>
      </ul>
      <xsl:choose>
        <xsl:when test="$elementId &lt; $pageEnd">
          <a class="nav-link next" href="{concat('/article/view/', $pmcid, '/scanned/', $elementId + 1, '/version/', $current-version)}">
          <!-- Next &gt; -->
          Next
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M9 6L15 12L9 18"/>
          </svg>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span class="nav-link disabled">
          <!-- Next &gt; -->
          Next
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M9 6L15 12L9 18"/>
          </svg>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="page-loop">
    <xsl:param name="i"/>
    <xsl:param name="end"/>
    <xsl:if test="$i &lt;= $end">
      <li>
        <xsl:choose>
          <xsl:when test="$i = $elementId">
            <span class="page-link current"><xsl:value-of select="$i"/></span>
          </xsl:when>
          <xsl:otherwise>
            <a class="page-link" href="{concat('/article/view/', $pmcid, '/scanned/', $i, '/version/', $current-version)}">
              <xsl:value-of select="$i"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <xsl:call-template name="page-loop">
        <xsl:with-param name="i" select="$i + 1"/>
        <xsl:with-param name="end" select="$end"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="graphic">
    <div class="scanned-content">
      <img src="image/{@xlink:href}" alt="Page {label}"/>
    </div>
  </xsl:template>

  <!-- Start General Format-->
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
              <xsl:value-of select="concat('https://europepmc.org/api/fulltextRepo?pmcId=', $pmcid, '&amp;type=FILE&amp;fileName=', $href, '&amp;version=', $current-version, '&amp;mimeType=application/pdf')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('https://europepmc.org/api/fulltextRepo?pmcId=', $pmcid, '&amp;type=FILE&amp;fileName=', $href, '&amp;mimeType=application/pdf')"/>
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
  <!-- <xsl:template match="*"><xsl:apply-templates select="@* | node()"/></xsl:template> -->
  <!-- End General Format-->
</xsl:stylesheet>

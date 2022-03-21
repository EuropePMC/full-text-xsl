<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!-- 
Copyright (c) 2022 EMBL-EBL/Europe PMC (https://europepmc.org/)

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
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" xmlns:ali="http://www.niso.org/schemas/ali/1.0" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">

  <!-- ************************************************ -->
  <!-- XSL version of epmc.sch, transformed with Oxygen -->
  <!-- ************************************************ -->

  <!--PHASES-->


  <!--PROLOG-->
  <xsl:output xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions" method="xml"/>

  <!--KEYS-->


  <!--DEFAULT RULES-->


  <!--MODE: SCHEMATRON-FULL-PATH-->
  <!--This mode can be used to generate an ugly though full XPath for locators-->
  <xsl:template match="*" mode="schematron-get-full-path">
    <xsl:variable name="sameUri">
      <xsl:value-of select="saxon:system-id() = parent::node()/saxon:system-id()" use-when="function-available('saxon:system-id')"/>
      <xsl:value-of select="true()" use-when="not(function-available('saxon:system-id'))"/>
    </xsl:variable>
    <xsl:if test="$sameUri = 'true'">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
    </xsl:if>
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="namespace-uri() = ''">
        <xsl:value-of select="name()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*:</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>[namespace-uri()='</xsl:text>
        <xsl:value-of select="namespace-uri()"/>
        <xsl:text>']</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$sameUri = 'true'">
      <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name() = local-name(current()) and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1 + $preceding"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*" mode="schematron-get-full-path">
    <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="namespace-uri() = ''">@<xsl:value-of select="name()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>@*[local-name()='</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>' and namespace-uri()='</xsl:text>
        <xsl:value-of select="namespace-uri()"/>
        <xsl:text>']</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="schematron-get-full-path">
    <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
    <xsl:text>/</xsl:text>
    <xsl:text>text()</xsl:text>
    <xsl:variable name="preceding" select="count(preceding-sibling::text())"/>
    <xsl:text>[</xsl:text>
    <xsl:value-of select="1 + $preceding"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="comment()" mode="schematron-get-full-path">
    <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
    <xsl:text>/</xsl:text>
    <xsl:text>comment()</xsl:text>
    <xsl:variable name="preceding" select="count(preceding-sibling::comment())"/>
    <xsl:text>[</xsl:text>
    <xsl:value-of select="1 + $preceding"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="processing-instruction()" mode="schematron-get-full-path">
    <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
    <xsl:text>/</xsl:text>
    <xsl:text>processing-instruction()</xsl:text>
    <xsl:variable name="preceding" select="count(preceding-sibling::processing-instruction())"/>
    <xsl:text>[</xsl:text>
    <xsl:value-of select="1 + $preceding"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!--MODE: SCHEMATRON-FULL-PATH-2-->
  <!--This mode can be used to generate prefixed XPath for humans-->
  <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:if test="preceding-sibling::*[name(.) = name(current())]">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*[name(.) = name(current())]) + 1"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="not(self::*)">
      <xsl:text/>/@<xsl:value-of select="name(.)"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!--MODE: GENERATE-ID-FROM-PATH -->
  <xsl:template match="/" mode="generate-id-from-path"/>
  <xsl:template match="text()" mode="generate-id-from-path">
    <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
    <xsl:value-of select="concat('.text-', 1 + count(preceding-sibling::text()), '-')"/>
  </xsl:template>
  <xsl:template match="comment()" mode="generate-id-from-path">
    <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
    <xsl:value-of select="concat('.comment-', 1 + count(preceding-sibling::comment()), '-')"/>
  </xsl:template>
  <xsl:template match="processing-instruction()" mode="generate-id-from-path">
    <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
    <xsl:value-of select="concat('.processing-instruction-', 1 + count(preceding-sibling::processing-instruction()), '-')"/>
  </xsl:template>
  <xsl:template match="@*" mode="generate-id-from-path">
    <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
    <xsl:value-of select="concat('.@', name())"/>
  </xsl:template>
  <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
    <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
    <xsl:text>.</xsl:text>
    <xsl:choose>
      <xsl:when test="count(. | ../namespace::*) = count(../namespace::*)">
        <xsl:value-of select="concat('.namespace::-', 1 + count(namespace::*), '-')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('.', name(), '-', 1 + count(preceding-sibling::*[name() = name(current())]), '-')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--MODE: GENERATE-ID-2 -->
  <xsl:template match="/" mode="generate-id-2">U</xsl:template>
  <xsl:template match="*" mode="generate-id-2" priority="2">
    <xsl:text>U</xsl:text>
    <xsl:number level="multiple" count="*"/>
  </xsl:template>
  <xsl:template match="node()" mode="generate-id-2">
    <xsl:text>U.</xsl:text>
    <xsl:number level="multiple" count="*"/>
    <xsl:text>n</xsl:text>
    <xsl:number count="node()"/>
  </xsl:template>
  <xsl:template match="@*" mode="generate-id-2">
    <xsl:text>U.</xsl:text>
    <xsl:number level="multiple" count="*"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="string-length(local-name(.))"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="translate(name(), ':', '.')"/>
  </xsl:template>
  <!--Strip characters-->
  <xsl:template match="text()" priority="-1"/>

  <!--SCHEMA METADATA-->
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="M7"/>
    <xsl:apply-templates select="/" mode="M8"/>
    <xsl:apply-templates select="/" mode="M9"/>
    <xsl:apply-templates select="/" mode="M10"/>
    <xsl:apply-templates select="/" mode="M11"/>
    <xsl:apply-templates select="/" mode="M12"/>
    <xsl:apply-templates select="/" mode="M13"/>
    <xsl:apply-templates select="/" mode="M14"/>
    <xsl:apply-templates select="/" mode="M15"/>
    <xsl:apply-templates select="/" mode="M16"/>
    <xsl:apply-templates select="/" mode="M17"/>
    <xsl:apply-templates select="/" mode="M18"/>
    <xsl:apply-templates select="/" mode="M19"/>
    <xsl:apply-templates select="/" mode="M20"/>
  </xsl:template>

  <!--SCHEMATRON PATTERNS-->


  <!--PATTERN article-type-errors-->


  <!--RULE -->
  <xsl:template match="article" priority="101" mode="M7">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="@article-type = 'article-commentary' or @article-type = 'correction' or @article-type = 'reply' or @article-type = 'research-article' or @article-type = 'retraction' or @article-type = 'preprint' or @article-type = 'preprint-removal' or @article-type = 'preprint-withdrawal'"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text> The @article-type "</xsl:text>
          <xsl:value-of select="@article-type"/>
          <xsl:text>" is invalid. The @article-type should be "preprint" for preprints or "research-article" for author manuscripts. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="processing-instruction('origin') and processing-instruction('origin') = 'ukpmcpa'"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text> The &lt;?origin ukpmcpa?&gt; processing instruction should be included. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--REPORT error-->
    <xsl:if test="not(starts-with(@article-type, 'preprint')) and not(processing-instruction('properties'))">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> Author manuscripts should contain the &lt;?properties manuscript?&gt; processing instruction. </xsl:text>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="@article-type = 'preprint' and processing-instruction('properties')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> Preprints should not contain the &lt;?properties manuscript?&gt; processing instruction. Please delete it. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT -->
    <xsl:if test="not(starts-with(@article-type, 'preprint')) and front/article-meta/article-id/@pub-id-type = 'archive'">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text> The document has a preprint ID but the @article-type is "</xsl:text>
        <xsl:value-of select="@article-type"/>
        <xsl:text>". Preprints should have @article-type="preprint". </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT -->
    <xsl:if test="starts-with(@article-type, 'preprint') and not(front/article-meta/article-id/@pub-id-type = 'archive')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text> The @article-type is "</xsl:text>
        <xsl:value-of select="@article-type"/>
        <xsl:text>", but there is no preprint ID. Author manuscripts should have @article-type="research-article". </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M7"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M7"/>
  <xsl:template match="@* | node()" priority="-2" mode="M7">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M7"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M7"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN corresp-author-warning-->


  <!--RULE -->
  <xsl:template match="corresp" priority="101" mode="M8">
    <xsl:variable name="id" select="@id"/>

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="//xref[@rid = $id] or //contrib[@corresp = 'yes']"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text>A &lt;corresp&gt; element is present, but no author is marked as @corresp="yes"</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M8"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M8"/>
  <xsl:template match="@* | node()" priority="-2" mode="M8">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M8"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M8"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN url-errors-->


  <!--RULE -->
  <xsl:template match="ext-link" priority="102" mode="M9">

    <!--REPORT error-->
    <xsl:if test="matches(@xlink:href, '%[\D][\D]')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> URL contains invalid URL escaping: </xsl:text>
        <xsl:value-of select="@xlink:href"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="ends-with(@xlink:href, '.')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>URL should not end in a dot: </xsl:text>
        <xsl:value-of select="@xlink:href"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="scheme" select="substring-before(@xlink:href, '://')"/>
    <xsl:variable name="authstring" select="
        if (contains(@xlink:href, '://')) then
          substring-after(@xlink:href, '://')
        else
          @xlink:href"/>
    <xsl:variable name="authority" select="
        if (contains($authstring, '/')) then
          substring-before($authstring, '/')
        else
          $authstring"/>
    <xsl:variable name="pathstring" select="substring-after(@xlink:href, $authority)"/>
    <xsl:variable name="path" select="
        if (contains($pathstring, '#')) then
          substring-before($pathstring, '#')
        else
          if (contains($pathstring, '?')) then
            substring-before($pathstring, '?')
          else
            $pathstring"/>
    <xsl:variable name="querystring" select="substring-after(@xlink-href, '?')"/>
    <xsl:variable name="query" select="
        if (contains($querystring, '#')) then
          substring-before($querystring, '#')
        else
          $querystring"/>
    <xsl:variable name="fragment" select="substring-after(@xlink:href, '#')"/>

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="not($scheme) or matches($scheme, '([a-z][a-z0-9+\-.]*)')"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>URL scheme is not valid: </xsl:text>
          <xsl:value-of select="@xlink:href"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="not($authority) or matches($authority, '([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})')"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>URL authority is not valid: </xsl:text>
          <xsl:value-of select="@xlink:href"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--REPORT error-->
    <xsl:if test="$path and (not(starts-with($path, '/')) or matches($path, '//|&lt;|&gt;|\{|\}|`|\^|\[|\]'))">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>URL path is not valid: </xsl:text>
        <xsl:value-of select="@xlink:href"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="$fragment and contains($fragment, '#')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>URL fragment is not valid: </xsl:text>
        <xsl:value-of select="@xlink:href"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M9"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="email" priority="101" mode="M9">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="contains(., '@')"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>Emails without @ are invalid: </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--REPORT error-->
    <xsl:if test="ends-with(., '.')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>Ending dot should be moved outside the &lt;email&gt; element: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M9"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M9"/>
  <xsl:template match="@* | node()" priority="-2" mode="M9">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M9"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M9"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN email-warning-->


  <!--RULE -->
  <xsl:template match="text()[matches(., '(\W|^)[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}(\W|$)')]" priority="101" mode="M10">

    <!--REPORT warning-->
    <xsl:if test="not(parent::email)">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>All email addresses should be inside an &lt;email&gt; element.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M10"/>
  <xsl:template match="@* | node()" priority="-2" mode="M10">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M10"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M10"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN xref-correspondence-warnings-->


  <!--RULE -->
  <xsl:template match="xref[@ref-type = 'fig' or @ref-type = 'table']" priority="103" mode="M11">
    <xsl:variable name="ridnum" select="translate(@rid, translate(@rid, '0123456789', ''), '')"/>

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="matches(., concat('(^|\D)', $ridnum, '($|\D)'))"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text>The number value in the &lt;xref&gt; @rid: </xsl:text>
          <xsl:value-of select="@rid"/>
          <xsl:text> , does not match the text: </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[sS][\d]') or matches(., '[sS]up')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>The &lt;xref&gt; links to a table or figure but the text indicates it should link to a supplemental file: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M11"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="xref[@ref-type = 'aff' or @ref-type = 'fn' or @ref-type = 'table-fn']" priority="102" mode="M11">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:variable name="point" select="//*[@id = $rid]"/>

    <!--REPORT warning-->
    <xsl:if test="$point/label and . != $point/label">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>The label of the element pointed to: </xsl:text>
        <xsl:value-of select="$point/label"/>
        <xsl:text> , does not match the &lt;xref&gt; content: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M11"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="xref[@ref-type = 'bibr']" priority="101" mode="M11">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:variable name="point" select="//*[@id = $rid]"/>
    <xsl:variable name="collabmatch" select="matches($point//collab, normalize-space(replace(., '[\W-[\s]]|\d', ''))) or matches(replace($point//collab, '[^A-Z]', ''), replace(., '[^A-Z]', ''))"/>

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test=". = $point/label or ($point//person-group/name and contains(., $point//person-group/name[1]/surname)) or ($point//collab and $collabmatch)"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text>The reference pointed to: </xsl:text>
          <xsl:value-of select="$point/label"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="
              if ($point//collab) then
                $point//collab
              else
                $point/*/person-group/name[1]/surname"/>
          <xsl:text> , does not match the &lt;xref&gt; content: </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M11"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M11"/>
  <xsl:template match="@* | node()" priority="-2" mode="M11">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M11"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M11"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN attribute-space-errors-->


  <!--RULE -->
  <xsl:template match="@id | @rid | @ref-type | @fn-type | @pub-id-type | @pub-type | @date-type" priority="101" mode="M12">

    <!--REPORT error-->
    <xsl:if test="matches(., '\s')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>@</xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:text> attribute should not contain whitespace.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M12"/>
  <xsl:template match="@* | node()" priority="-2" mode="M12">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M12"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M12"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN formula-content-errors-->


  <!--RULE -->
  <xsl:template match="inline-formula | disp-formula" priority="102" mode="M13">

    <!--REPORT error-->
    <xsl:if test="mml:math and normalize-space(text())">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>Formula has untagged text content. Check for typos or missing math tags.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M13"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="mml:math" priority="101" mode="M13">

    <!--REPORT error-->
    <xsl:if test="normalize-space(text())">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>Math element has untagged text content. Check for typos or missing math tags.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="mml:mfenced">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>MathMl 'mfenced' element has been deprecated. Please use &lt;mml:mrow&gt; and &lt;mo&gt; elements instead.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M13"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M13"/>
  <xsl:template match="@* | node()" priority="-2" mode="M13">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M13"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M13"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN position-errors-->


  <!--RULE -->
  <xsl:template match="floats-group/*[not(self::title)]" priority="104" mode="M14">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="@position and @position = 'float'"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>Children of &lt;floats-group&gt; should have @position="float"</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M14"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="boxed-text | fig-group | table-wrap-group" priority="103" mode="M14">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="parent::floats-group or @position = 'anchor'"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>Floatable element outside &lt;floats-group&gt; must have @position="anchor"</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M14"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="fig" priority="102" mode="M14">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="parent::fig-group or parent::floats-group or @position = 'anchor'"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>Fig outside &lt;floats-group&gt; must have @position="anchor"</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M14"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="table-wrap" priority="101" mode="M14">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="parent::table-wrap-group or parent::floats-group or @position = 'anchor'"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>Table outside &lt;floats-group&gt; must have @position="anchor"</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M14"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M14"/>
  <xsl:template match="@* | node()" priority="-2" mode="M14">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M14"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M14"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN fn-group-error-->


  <!--RULE -->
  <xsl:template match="back//fn-group" priority="101" mode="M15">

    <!--REPORT error-->
    <xsl:if test="parent::sec">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>Back footnotes should be directly inside the &lt;back&gt; element, not inside child &lt;sec&gt;.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M15"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M15"/>
  <xsl:template match="@* | node()" priority="-2" mode="M15">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M15"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M15"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN name-errors-->


  <!--RULE surname-errors-->
  <xsl:template match="name/surname" priority="103" mode="M16">

    <!--REPORT error-->
    <xsl:if test="matches(., '^\p{Zs}')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>surname starts with a space, which cannot be correct - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="matches(., '\p{Zs}$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>surname ends with a space, which cannot be correct - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M16"/>
  </xsl:template>

  <!--RULE given-names-errors-->
  <xsl:template match="name/given-names" priority="102" mode="M16">

    <!--REPORT error-->
    <xsl:if test="matches(., '^[\p{L}]{1}\.$|^[\p{L}]{1}\.\p{Zs}?[\p{L}]{1}\.\p{Zs}?$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>given-names contains initialised full stop(s) which is incorrect - </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="matches(., '^\p{Zs}')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>given-names starts with a space, which cannot be correct - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="matches(., '\p{Zs}$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text>given-names ends with a space, which cannot be correct - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M16"/>
  </xsl:template>

  <!--RULE suffix-tests-->
  <xsl:template match="name/suffix" priority="101" mode="M16">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test=". = ('Jr', 'Jnr', 'Sr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text>suffix can only have one of these values - 'Jr', 'Jnr', 'Sr', 'Snr', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'.</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M16"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M16"/>
  <xsl:template match="@* | node()" priority="-2" mode="M16">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M16"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M16"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN name-warnings-->


  <!--RULE surname-warnings-->
  <xsl:template match="name/surname" priority="102" mode="M17">

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="matches(., &#34;^[\p{L}\p{M}\s'’-]*$&#34;)"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text>surname should usually only contain letters, spaces, or hyphens. </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text> contains other characters.</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--REPORT warning-->
    <xsl:if test="matches(., '^\p{Ll}') and not(matches(., '^de[rn]? |^van |^von |^el |^te[rn] '))">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>surname doesn't begin with a capital letter - </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>. Is this correct?</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '^[A-Z]{1,2}\p{Zs}') and (string-length(.) gt 3)">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>surname looks to start with initial - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'. Should '</xsl:text>
        <xsl:value-of select="substring-before(., ' ')"/>
        <xsl:text>' be placed in the given-names field?</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[\(\)\[\]]')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>surname contains brackets - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'. Should the bracketed text be placed in the given-names field instead?</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '\p{Zs}(III?|I?V)$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>surname ends with what might be roman numerals - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'. Should these be placed in a suffix element instead?</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M17"/>
  </xsl:template>

  <!--RULE given-names-warnings-->
  <xsl:template match="name/given-names" priority="101" mode="M17">

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="matches(., &#34;^[\p{L}\p{M}\(\)\s'’-]*$&#34;)"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text>given-names should usually only contain letters, spaces, or hyphens. </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text> contains other characters.</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="matches(., '^\p{Lu}')"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text>given-names doesn't begin with a capital letter - '</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>'. Is this correct?</xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[A-Za-z] [Dd]e[rn]?$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[A-Za-z] [Vv]an$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[A-Za-z] [Vv]on$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[A-Za-z] [Ee]l$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(., '[A-Za-z] [Tt]e[rn]?$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT warning-->
    <xsl:if test="matches(normalize-space(.), '[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text>given-names contains initials with spaces. Ensure that the space(s) is removed between initials - '</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'.</xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M17"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M17"/>
  <xsl:template match="@* | node()" priority="-2" mode="M17">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M17"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M17"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN abstract-errors-->


  <!--RULE -->
  <xsl:template match="article-meta" priority="105" mode="M18">

    <!--REPORT error-->
    <xsl:if test="count(abstract[not(@abstract-type or @xml:lang or @specific-use)]) gt 1">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> If there are multiple abstracts then each abstract, other than the main abstract, must have at least one of the following attributes: abstract-type, xml:lang, or specific-use. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M18"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="abstract | trans-abstract" priority="104" mode="M18">

    <!--REPORT error-->
    <xsl:if test="not(p) and count(sec) = 1">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt; has no child &lt;p&gt; elements, but it has only 1 &lt;sec&gt; element. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="@abstract-type = 'graphical' and not(descendant::fig[descendant::graphic])">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> abstract-type="graphical"&gt; has no descendant &lt;fig&gt; elements. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="(not(@abstract-type) or not(@abstract-type = ('video', 'audio'))) and descendant::media">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt; has descendant &lt;media&gt; element(s), but it does not have an abstract-type attribute with a value of either "video" or "audio". </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="@abstract-type = 'video' and not(descendant::fig[descendant::media[@mimetype = 'video']])">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> abstract-type="video"&gt; has no descendant &lt;fig&gt; elements containing &lt;media mimetype="video"&gt;. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="@abstract-type = 'audio' and not(descendant::fig[descendant::media[@mimetype = 'audio']])">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> abstract-type="audio"&gt; has no descendant &lt;fig&gt; elements containing &lt;media mimetype="audio"&gt;. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>

    <!--REPORT error-->
    <xsl:if test="name() = 'trans-abstract' and not(@xml:lang)">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Error:</xsl:text>
        <xsl:text> Missing xml:lang attribute. &lt;trans-abstract&gt; must have an xml:lang attribute, whose value indicates the language. This one does not. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M18"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="abstract//sec" priority="103" mode="M18">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="title"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text> Missing &lt;title&gt;. Every &lt;sec&gt; within &lt;abstract&gt; must have a &lt;title&gt;, this one does not. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M18"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="graphic[ancestor::abstract or ancestor::trans-abstract]" priority="102" mode="M18">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="parent::fig or parent::alternatives/parent::fig"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text> &lt;graphic&gt; within &lt;abstract&gt; must be a child of &lt;fig&gt; or a child of &lt;alternatives&gt;, which in turn is a child of &lt;fig&gt;. This one is not. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M18"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="media[ancestor::abstract or ancestor::trans-abstract]" priority="101" mode="M18">

    <!--ASSERT error-->
    <xsl:choose>
      <xsl:when test="parent::fig or parent::alternatives/parent::fig"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Error:</xsl:text>
          <xsl:text> &lt;media&gt; within &lt;abstract&gt; must be a child of &lt;fig&gt; or a child of &lt;alternatives&gt;, which in turn is a child of &lt;fig&gt;. This one is not. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M18"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M18"/>
  <xsl:template match="@* | node()" priority="-2" mode="M18">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M18"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M18"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN abstract-warnings-1-->


  <!--RULE -->
  <xsl:template match="abstract | trans-abstract" priority="101" mode="M19">
    <xsl:variable name="recommended-values" select="('teaser', 'extract', 'editor-summary', 'executive-summary', 'interpretive-summary', 'summary', 'plain-language-summary', 'graphical', 'simple', 'structured', 'video', 'audio')"/>

    <!--REPORT warning-->
    <xsl:if test="(not(@abstract-type) or @abstract-type != 'graphical') and descendant::fig[descendant::graphic]">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt; does not have the attribute abstract-type="graphical" but it has a descendant &lt;fig&gt; with a graphic. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M19"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M19"/>
  <xsl:template match="@* | node()" priority="-2" mode="M19">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M19"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M19"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--PATTERN auths-aff-warnings-->


  <!--RULE -->
  <xsl:template match="/article/front/article-meta[descendant::contrib]" priority="103" mode="M20">

    <!--REPORT warning-->
    <xsl:if test="not(descendant::contrib[@contrib-type = 'author'])">
      <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
        <xsl:text>Warning:</xsl:text>
        <xsl:text> Articles should have authors included as &lt;contrib contrib-type="author"&gt;. </xsl:text>
        <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M20"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="contrib[@contrib-type = 'author']/xref[@ref-type = 'aff' and (* or normalize-space(.) != '')]" priority="102" mode="M20">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:variable name="aff" select="//*[@id = $rid]"/>

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="$aff/label"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text> &lt;xref&gt; which contains content, but the &lt;aff&gt; that it points to does not have a label. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M20"/>
  </xsl:template>

  <!--RULE -->
  <xsl:template match="contrib[@initials]" priority="101" mode="M20">

    <!--ASSERT warning-->
    <xsl:choose>
      <xsl:when test="matches(@initials, '^[\p{L}]\.?[\p{L}]?\.?[\p{L}]?\.?[\p{L}]?\.?[\p{L}]?\.?$')"/>
      <xsl:otherwise>
        <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:osf="http://www.oxygenxml.com/sch/functions">
          <xsl:text>Warning:</xsl:text>
          <xsl:text> &lt;xref&gt; which contains content, but the &lt;aff&gt; that it points to does not have a label. </xsl:text>
          <xsl:apply-templates select="." mode="schematron-get-full-path-2"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="@* | * | comment() | processing-instruction()" mode="M20"/>
  </xsl:template>
  <xsl:template match="text()" priority="-1" mode="M20"/>
  <xsl:template match="@* | node()" priority="-2" mode="M20">
    <xsl:choose>
      <!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
      <xsl:when test="not(@*)">
        <xsl:apply-templates select="node()" mode="M20"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@* | node()" mode="M20"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

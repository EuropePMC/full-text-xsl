<?xml version="1.0" encoding="UTF-8"?>
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

<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
  <ns prefix="ali" uri="http://www.niso.org/schemas/ali/1.0"/>
  <ns prefix="mml" uri="http://www.w3.org/1998/Math/MathML"/>
  <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
  <ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  
  <phase id="errors">
    <active pattern="article-type-errors"/>
    <active pattern="abstract-errors"/>
    <active pattern="name-errors"/>
    <active pattern="url-errors"/>
    <active pattern="attribute-space-errors"/>
    <active pattern="formula-content-errors"/>
    <active pattern="position-errors"/>
    <active pattern="fn-group-error"/>
  </phase>
  
  <phase id="warnings">
    <active pattern="corresp-author-warning"/>
    <active pattern="auths-aff-warnings"/>
    <active pattern="abstract-warnings-1"/>
    <active pattern="email-warning"/>
    <active pattern="name-warnings"/>
    <active pattern="xref-correspondence-warnings"/>
  </phase>
  
  <pattern id="article-type-errors">
    <rule context="article">
      <assert test="@article-type='article-commentary' or @article-type='correction' or @article-type='reply' or @article-type='research-article' or @article-type='retraction' or @article-type='preprint' or @article-type='preprint-removal' or @article-type='preprint-withdrawal'" role="error">
        The @article-type "<value-of select="@article-type"/>" is invalid. The @article-type should be "preprint" for preprints or "research-article" for author manuscripts.
      </assert>
      <assert test="processing-instruction('origin') and processing-instruction('origin')='ukpmcpa'" role="error">
        The &lt;?origin ukpmcpa?&gt; processing instruction should be included.
      </assert>
      <report test="not(starts-with(@article-type, 'preprint')) and not(processing-instruction('properties'))" role="error">
        Author manuscripts should contain the &lt;?properties manuscript?&gt; processing instruction.
      </report>
      <report test="@article-type='preprint' and processing-instruction('properties')" role="error">
        Preprints should not contain the &lt;?properties manuscript?&gt; processing instruction. Please delete it.
      </report>
      <report test="not(starts-with(@article-type, 'preprint')) and front/article-meta/article-id/@pub-id-type='archive'" role="error">
        The document has a preprint ID but the @article-type is "<value-of select="@article-type"/>". Preprints should have @article-type="preprint".
      </report>
      <report test="starts-with(@article-type, 'preprint') and not(front/article-meta/article-id/@pub-id-type='archive')" role="error">
        The @article-type is "<value-of select="@article-type"/>", but there is no preprint ID. Author manuscripts should have @article-type="research-article".
      </report>
    </rule>
  </pattern>
  
  <pattern id="corresp-author-warning">
    <rule context="corresp">
      <let name="id" value="@id"/>
      <assert test="//xref[@rid=$id] or //contrib[@corresp='yes']" role="warning">A &lt;corresp&gt; element is present, but no author is marked as @corresp="yes"</assert>
    </rule>
  </pattern>
  
  <pattern id="url-errors">
    <rule context="ext-link">
      <!-- Full URL tests -->
      <report test="matches(@xlink:href, '%[\D][\D]')" role="error">URL contains invalid URL escaping: <value-of select="@xlink:href"/></report>
      <report test="ends-with(@xlink:href, '.')" role="error">URL should not end in a dot: <value-of select="@xlink:href"/></report>
      
      <!-- Pull apart scheme, authority, path, query, and fragment -->
      <let name="scheme" value="substring-before(@xlink:href, '://')"/>
      <let name="authstring" value="if (contains(@xlink:href, '://')) then substring-after(@xlink:href, '://') else @xlink:href"/>
      <let name="authority" value="if (contains($authstring, '/')) then substring-before($authstring, '/') else $authstring"/>
      <let name="pathstring" value="substring-after(@xlink:href, $authority)"/>
      <let name="path" value="if (contains($pathstring, '#')) then substring-before($pathstring,'#') else if (contains($pathstring, '?')) then substring-before($pathstring,'?') else $pathstring"/>
      <let name="querystring" value="substring-after(@xlink-href, '?')"/>
      <let name="query" value="if (contains($querystring, '#')) then substring-before($querystring,'#') else $querystring"/>
      <let name="fragment" value="substring-after(@xlink:href, '#')"/>
      
      <!-- Test validity of scheme, authority, path, and fragment -->
      <assert test="not($scheme) or matches($scheme, '([a-z][a-z0-9+\-.]*)')" role="error">URL scheme is not valid: <value-of select="@xlink:href"/></assert>
      <assert test="not($authority) or matches($authority, '([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})')" role="error">URL authority is not valid: <value-of select="@xlink:href"/></assert>
      <report test="$path and (not(starts-with($path, '/')) or matches($path, '&lt;|&gt;|\{|\}|`|\^|\[|\]'))" role="error">URL path is not valid: <value-of select="@xlink:href"/></report>
      <report test="$fragment and contains($fragment, '#')" role="error">URL fragment is not valid: <value-of select="@xlink:href"/></report>      
    </rule>
    
    <rule context="email">
      <assert test="contains(., '@')" role="error">Emails without @ are invalid: <value-of select="."/></assert>
      <report test="matches(., '[\W]$')" role="error">The &lt;email&gt; element contains end punctuation: <value-of select="."/></report>
    </rule>
  </pattern>
  
  <pattern id="email-warning">
    <rule context="text()[matches(., '(\W|^)[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}(\W|$)')]">
      <report test="not(parent::email)" role="warning">All email addresses should be inside an &lt;email&gt; element</report>
    </rule>
  </pattern>
  
  <pattern id="xref-correspondence-warnings">
    <rule context="xref[@ref-type='fig' or @ref-type='table']">
      <let name="ridnum" value="translate(@rid, translate(@rid, '0123456789', ''), '')"/>
      <assert test="matches(., concat('(^|\D)', $ridnum, '($|\D)'))" role="warning">The number value in the &lt;xref&gt; @rid: <value-of select="@rid"/> , does not match the text: <value-of select="."/></assert>
      <report test="matches(., '[sS][\d]') or matches(., '[sS]up')" role="warning">The &lt;xref&gt; links to a table or figure but the text indicates it should link to a supplemental file: <value-of select="."/></report>
    </rule>
    
    <rule context="xref[@ref-type='aff' or @ref-type='fn' or @ref-type='table-fn']">
      <let name="rid" value="@rid"/>
      <let name="point" value="//*[@id=$rid]"/>
      <report test="$point/label and .!=$point/label" role="warning">The label of the element pointed to: <value-of select="$point/label"/> , does not match the &lt;xref&gt; content: <value-of select="."/></report>
    </rule>
    
    <rule context="xref[@ref-type='bibr']">
      <let name="rid" value="@rid"/>
      <let name="point" value="//*[@id=$rid]"/>
      <let name="labelmatch" value=".=$point/label or matches($point/label, concat('(^|\W)', replace(., '([\.\(\)\[\]\?])',''), '($|\W)'))"/>
      <let name="collabmatch" value="matches($point//collab, normalize-space(replace(., '[\W-[\s]]|\d', ''))) or 
        matches(replace($point//collab, '[^A-Z]',''), replace(., '[^A-Z]',''))"/>
      <let name="namematch" value="($point//person-group[1]/name and contains(., $point//person-group[1]/name[1]/surname)) or ($point//collab and $collabmatch)"/>
      <assert test="if (matches(., '[\D]+')) then $namematch or $labelmatch else $labelmatch" role="warning">The reference pointed to: <value-of select="$point/label"/> <value-of select="if ($point//collab) then $point//collab else $point/*/person-group[1]/name[1]/surname"/> , does not match the &lt;xref&gt; content: <value-of select="."/></assert>
    </rule>
  </pattern>
  
  <pattern id="attribute-space-errors">
    <rule context="@id|@rid|@ref-type|@fn-type|@pub-id-type|@pub-type|@date-type">
      <report test="matches(., '\s')" role="error">@<value-of select="name(.)"/> attribute should not contain whitespace.</report>
    </rule>
  </pattern>
  
  <pattern id="formula-content-errors">
    <rule context="inline-formula|disp-formula">
      <let name="text" value="string-join(text(), ' ')"/>
      <report test="mml:math and normalize-space($text)" role="error">Formula has untagged text content. Check for typos or missing math tags.</report>
    </rule>
    
    <rule context="mml:math">
      <let name="text" value="string-join(text(), ' ')"/>
      <report test="normalize-space($text)" role="error">Math element has untagged text content. Check for typos or missing math tags.</report>
      <report test="mml:mfenced" role="error">MathMl 'mfenced' element has been deprecated. Please use &lt;mml:mrow&gt; and &lt;mo&gt; elements instead.</report>
    </rule>
  </pattern>
  
  <pattern id="position-errors">
    <rule context="floats-group/*[not(self::title)]">
      <assert test="@position and @position='float'" role="error">Children of &lt;floats-group&gt; should have @position="float"</assert>
    </rule>
    
    <rule context="boxed-text|fig-group|table-wrap-group">
      <assert test="parent::floats-group or @position='anchor'" role="error">Floatable element outside &lt;floats-group&gt; must have @position="anchor"</assert>
    </rule>
    
    <rule context="fig">
      <assert test="parent::fig-group or parent::floats-group or @position='anchor'" role="error">Fig outside &lt;floats-group&gt; must have @position="anchor"</assert>
    </rule>
    
    <rule context="table-wrap">
      <assert test="parent::table-wrap-group or parent::floats-group or @position='anchor'" role="error">Table outside &lt;floats-group&gt; must have @position="anchor"</assert>
    </rule>
  </pattern>
  
  <pattern id="fn-group-error">
    <rule context="back//fn-group">
      <report test="parent::sec" role="error">Back footnotes should be directly inside the &lt;back&gt; element, not inside child &lt;sec&gt;.</report>
    </rule>
  </pattern>
  
  
  <include href="elife-name-errors.sch"/>
  <include href="elife-name-warnings.sch"/>
  <include href="jats-abstract-errors.sch"/>
  <include href="jats-abstract-warnings-1.sch"/>
  <include href="jats-auths-affs-warnings.sch"/>  
</schema>
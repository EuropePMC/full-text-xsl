<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Copyright (c) 2022 EMBL-EBI/Europe PMC (https://europepmc.org/)

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

<pattern id="xref-correspondence-warnings" xmlns="http://purl.oclc.org/dsdl/schematron">
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
    <let name="labelmatch" value=".=$point/label or matches($point/label[1], concat('(^|\W)', replace(., '([\.\(\)\[\]\?])',''), '($|\W)'))"/>
    <let name="collabmatch" value="matches($point/descendant::collab[1], normalize-space(replace(., '[\W-[\s]]|\d', ''))) or 
      matches(replace($point/descendant::collab[1], '[^A-Z]',''), replace(., '[^A-Z]',''))"/>
    <let name="namematch" value="($point/descendant::person-group[1]/name and contains(., $point/descendant::person-group[1]/name[1]/surname)) or ($point/descendant::collab and $collabmatch)"/>
    <assert test="if (matches(., '[\D]+')) then $namematch or $labelmatch else $labelmatch" role="warning">The reference pointed to: <value-of select="$point/label"/> <value-of select="if ($point/descendant::person-group[1]/name) then $point/descendant::person-group[1]/name[1]/surname else $point//collab"/> , does not match the &lt;xref&gt; content: <value-of select="."/></assert>
  </rule>
</pattern>
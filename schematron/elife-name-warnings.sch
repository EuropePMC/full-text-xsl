<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  From: https://github.com/elifesciences/eLife-JATS-schematron
  
  MIT License
    
  Copyright (c) 2019 eLife Sciences Publications Ltd
  
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

<pattern id="name-warnings" xmlns="http://purl.oclc.org/dsdl/schematron">
  <rule context="name/surname" id="surname-warnings">
    <assert test="matches(., &quot;^[\p{L}\p{M}\s'’-]*$&quot;)" role="warning" id="surname-test-4">surname should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
    
    <report test="matches(., '^\p{Ll}') and not(matches(., '^de[rn]? |^van |^von |^el |^te[rn] '))" role="warning" id="surname-test-5">surname doesn't begin with a capital letter - <value-of select="."/>. Is this correct?</report>
    
    <report test="matches(., '^[A-Z]{1,2}\p{Zs}') and (string-length(.) gt 3)" role="warning" id="surname-test-8">surname looks to start with initial - '<value-of select="."/>'. Should '<value-of select="substring-before(., ' ')"/>' be placed in the given-names field?</report>
    
    <report test="ancestor::person-group and matches(., '[\(\)\[\]]')" role="warning" id="surname-test-9">surname contains brackets - '<value-of select="."/>'. Should the bracketed text be placed in the citation label field instead?</report>
    
    <report test="matches(., '\p{Zs}(III?|I?V)$')" role="warning" id="surname-test-10">surname ends with what might be roman numerals - '<value-of select="."/>'. Should these be placed in a suffix element instead?</report>
  </rule>
  
  <rule context="name/given-names" id="given-names-warnings">
    <assert test="if (ancestor::person-group) then matches(., &quot;^[\p{L}\p{M}\s'’-]*$&quot;) else matches(., &quot;^[\p{L}\p{M}\s.'’-]*$&quot;)" role="warning" id="given-names-test-5">given-names should usually only contain letters, spaces, or hyphens. <value-of select="."/> contains other characters.</assert>
    
    <assert test="matches(., '^\p{Lu}')" role="warning" id="given-names-test-6">given-names doesn't begin with a capital letter - '<value-of select="."/>'. Is this correct?</assert>    
    
    <report test="matches(., '[A-Za-z] [Dd]e[rn]?$')" role="warning" id="given-names-test-10">given-names ends with de, der, or den - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
    
    <report test="matches(., '[A-Za-z] [Vv]an$')" role="warning" id="given-names-test-11">given-names ends with ' van' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
    
    <report test="matches(., '[A-Za-z] [Vv]on$')" role="warning" id="given-names-test-12">given-names ends with ' von' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
    
    <report test="matches(., '[A-Za-z] [Ee]l$')" role="warning" id="given-names-test-13">given-names ends with ' el' - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
    
    <report test="matches(., '[A-Za-z] [Tt]e[rn]?$')" role="warning" id="given-names-test-14">given-names ends with te, ter, or ten - should this be captured as the beginning of the surname instead? - '<value-of select="."/>'.</report>
    
    <report test="matches(normalize-space(.), '[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]|[A-Za-z]\p{Zs}[A-za-z]\p{Zs}[A-za-z]$|^[A-za-z]\p{Zs}[A-za-z]$')" role="warning" id="given-names-test-15">given-names contains initials with spaces. Ensure that the space(s) is removed between initials - '<value-of select="."/>'.</report>
  </rule>
</pattern>

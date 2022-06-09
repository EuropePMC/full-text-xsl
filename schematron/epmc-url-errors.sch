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

<pattern id="url-errors" xmlns="http://purl.oclc.org/dsdl/schematron">
  <rule context="ext-link">
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
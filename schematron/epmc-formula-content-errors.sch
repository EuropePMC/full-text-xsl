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

<pattern id="formula-content-errors" xmlns="http://purl.oclc.org/dsdl/schematron">
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
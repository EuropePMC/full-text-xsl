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

<pattern id="article-type-errors" xmlns="http://purl.oclc.org/dsdl/schematron">
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
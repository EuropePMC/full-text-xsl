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
    <active pattern="formula-errors"/>
    <active pattern="math-errors"/>
    <active pattern="position-errors"/>
    <active pattern="display-object-errors"/>
    <active pattern="fn-group-error"/>
  </phase>
  
  <phase id="warnings">
    <active pattern="corresp-author-warning"/>
    <active pattern="auths-aff-warnings"/>
    <active pattern="abstract-warnings-1"/>
    <active pattern="email-warning"/>
    <active pattern="name-warnings"/>
    <active pattern="xref-warnings"/>
    <active pattern="display-object-warnings-1"/>
    <active pattern="display-object-warnings-2"/>
  </phase>

  <include href="epmc-article-type-errors.sch"/>
  <include href="jats-abstract-errors.sch"/>
  <include href="elife-name-errors.sch"/>
  <include href="epmc-url-errors.sch"/>
  <include href="epmc-attribute-space-errors.sch"/>
  <include href="epmc-formula-errors.sch"/>
  <include href="jats-math-errors.sch"/>
  <include href="epmc-position-errors.sch"/>
  <include href="jats-display-object-errors.sch"/> 
  <include href="epmc-fn-group-error.sch"/>
  <include href="epmc-corresp-author-warning.sch"/> 
  <include href="jats-auths-affs-warnings.sch"/>
  <include href="jats-abstract-warnings-1.sch"/>
  <include href="epmc-email-warning.sch"/>
  <include href="elife-name-warnings.sch"/>
  <include href="epmc-xref-warnings.sch"/>   
  <include href="jats-display-object-warnings-1.sch"/>  
  <include href="jats-display-object-warnings-2.sch"/>
  <include href="empc-rights-retention.sch"/>
  
</schema>
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

<pattern id="name-errors" xmlns="http://purl.oclc.org/dsdl/schematron">
  <rule context="name/surname" id="surname-errors">
    <report test="matches(., '^\p{Zs}')" role="error" id="surname-test-6">surname starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
    
    <report test="matches(., '\p{Zs}$')" role="error" id="surname-test-7">surname ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
  </rule>
  
  <rule context="name/given-names" id="given-names-errors">    
    <report test="matches(., '^\p{Zs}')" role="error" id="given-names-test-8">given-names starts with a space, which cannot be correct - '<value-of select="."/>'.</report>
    
    <report test="matches(., '\p{Zs}$')" role="error" id="given-names-test-9">given-names ends with a space, which cannot be correct - '<value-of select="."/>'.</report>
  </rule>
</pattern>
  

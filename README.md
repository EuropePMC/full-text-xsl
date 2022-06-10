# epmc-article-xsl

XSL (EXtensible Stylesheet) files used by EBI Literature Services/Europe PMC.

## JATS 

### jats2html.xsl

An XSL for transforming JATS article full text (https://jats.nlm.nih.gov/) into three kinds of HTML displays, depending on source type: PPR (Preprint), CTX (Published article full text), or EMS (Europe PMC Funder Author Manuscript Collection). Used on https://europepmc.org/.

Additionally it operates specially within the Manuscript Submission System ([xpub-epmc project](https://gitlab.ebi.ac.uk/literature-services/development/xpub-epmc)), based on and using parameter settings.

### schematron

A collection of schematron tests for JATS XML files submitted to the Europe PMC plus MSS (https://plus.europepmc.org/). 

epmc.sch is the main file. Files are taken from the following projects:

 * https://github.com/JATS4R/jats-schematrons
 * https://github.com/elifesciences/eLife-JATS-schematron

## REST

XSLs for transforming the [Europe PMC article REST API](https://europepmc.org/RestfulWebService) XML response (see samplerestxml.xml) to various citation formats.

 * rest2bibtex.xsl
 * rest2csv.xsl
 * rest2delimited.xsl
 * rest2ids.xsl
 * rest2ris.xsl
 * rest2textcitation.xsl

## Deprecated

 * preprint.xsl
 * gristCSV.xsl
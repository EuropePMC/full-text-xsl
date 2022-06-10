# EBI Literature Services/Europe PMC Schematron

A collection of schematron tests for JATS (https://jats.nlm.nih.gov/) XML files submitted to the Europe PMC plus MSS (https://plus.europepmc.org/). 

epmc.sch is the main file. Running this file against an XML file will run all the included test patterns (found in the individual prefixed files).
 
epmc-schematron.xsl is the XSL version of the schematron. It will produce the schema errors and warnings as XSL messages.

Test pattern files prefixed with 'jats-' and 'elife-' are taken from the following projects, respectively:

 * https://github.com/JATS4R/jats-schematrons
 * https://github.com/elifesciences/eLife-JATS-schematron
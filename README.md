An XSL for transforming JATS article full text into three kinds of HTML displays, depending on source type: PPR (Preprint), CTX (Published article full text), or EMS (Europe PMC Funder Author Manuscript Collection)

Additionally it operates specially within the Manuscript Submission System ([xpub-epmc project](https://gitlab.ebi.ac.uk/literature-services/development/xpub-epmc)), based on and using parameter settings.

## Working with epmc or xpub-epmc
When making changes to the *full-text-xsl* project, if you want to apply the changes into the *epmc* or *xpub-epmc* project, you can copy the changes to the same file in *epmc* or *xpub-epmc*

If you want to avoid too many copy/paste, you can do the following
1. In the root dir of *full-text-xsl*, create a file named *.env*, add the following lines:

`src=[dir of the full-text-xsl repo]`

`dist=[dir of the xsl file in the epmc or xpub-epmc repo]`

`watch=true`

An example of the env file is:

`src=/Users/zhanhuang/Desktop/full-text-xsl/`

`dist=/Users/zhanhuang/Desktop/epmc/public/xsl/`

`watch=true`

2. run `npm install` only for the first time full-text-xsl is cloned from gitlab

3. run `npm run sync`

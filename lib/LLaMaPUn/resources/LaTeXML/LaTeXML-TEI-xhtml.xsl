<?xml version="1.0" encoding="utf-8"?>
<!--
/=====================================================================\ 
|  LaTeXML-xhtml.xsl                                                  |
|  Stylesheet for converting LaTeXML documents to xhtml               |
|=====================================================================|
| Part of LaTeXML:                                                    |
|  Public domain software, produced as part of work done by the       |
|  United States Government & not subject to copyright in the US.     |
|=====================================================================|
| Bruce Miller <bruce.miller@nist.gov>                        #_#     |
| http://dlmf.nist.gov/LaTeXML/                              (o o)    |
\=========================================================ooo==U==ooo=/
-->
<xsl:stylesheet
    version     = "1.0"
    xmlns:xsl   = "http://www.w3.org/1999/XSL/Transform"
    xmlns:ltx   = "http://dlmf.nist.gov/LaTeXML"
    exclude-result-prefixes = "ltx">

  <!-- Include all LaTeXML to xhtml modules -->
  <xsl:import href="urn:x-LaTeXML:XSLT:LaTeXML-all-xhtml.xsl"/>
  
  <xsl:template match="/" mode="footer-generator-identifier"/>

  <xsl:template match="ltx:sentence">
    <xsl:element name="span" namespace="{$html_ns}">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:call-template name="add_attributes"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ltx:word">
    <xsl:element name="span" namespace="{$html_ns}">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:call-template name="add_attributes"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ltx:formula">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ltx:token">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ltx:punct">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:output method="xml"
	      doctype-public = "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN"
	      doctype-system = "http://www.w3.org/Math/DTD/mathml2/xhtml-math11-f.dtd"
	      media-type     = 'application/xhtml+xml'
	      encoding       = 'utf-8'/>
  <!-- Note: If you want namespace prefixes (eg. for MathML & SVG),
       Redefine the root template ("/") and add prefixed namespace declarations
       (eg.xmlns:m="http://www.w3.org/1998/Math/MathML") -->
</xsl:stylesheet>

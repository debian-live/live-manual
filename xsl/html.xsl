<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/chunk.xsl" />

	<xsl:param name="chunk.first.sections" select="1" />
	<xsl:param name="chunk.section.depth">1</xsl:param>
	<xsl:param name="chunker.output.indent" select="'yes'" />
	<xsl:param name="section.autolabel">1</xsl:param>
	<xsl:param name="section.label.includes.component.label">1</xsl:param>
	<xsl:param name="use.id.as.filename">1</xsl:param>
</xsl:stylesheet>

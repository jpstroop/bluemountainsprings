<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:json="http://cwulfman.org/ns/json" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="text/x-json"/>
    <xsl:strip-space elements="*"/><!-- 
    A simplified xml-to-json stylesheet, based on the
    non-normative schema at W3C that describes the XML representation of JSON used
    as the target of the function fun:json-to-xml().
    
    The elements are:
        - map
        - array
        - string
        - number
        - boolean (not handled yet)
        - null    (not handled yet)
    -->
    <xsl:function name="json:escape-string" as="xs:string*">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$input">
                <xsl:variable name="input" as="xs:string">
                    <xsl:copy-of select="$input"/>
                </xsl:variable>
                <xsl:variable name="sub1" select="replace($input, '\\', '\\\\')"/>
                <xsl:value-of select="replace($sub1, '&#34;', '\\&#34;')"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="json:quote-string" as="xs:string">
        <xsl:param name="input"/>
        <xsl:value-of select="concat('&#34;', $input, '&#34;')"/>
    </xsl:function>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="map">
        <xsl:if test="@key">
            <xsl:value-of select="json:quote-string(@key)"/>
            <xsl:text> : </xsl:text>
        </xsl:if>
        <xsl:text>{ </xsl:text>
        <xsl:for-each select="child::*">
            <xsl:apply-templates select="current()"/>
            <xsl:if test="position() &lt; last()">
                <xsl:text>,
	      </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text> }</xsl:text>
    </xsl:template>
    <xsl:template match="array">
        <xsl:value-of select="json:quote-string(@key)"/>
        <xsl:text> : [ 
        </xsl:text>
        <xsl:for-each select="child::*">
            <xsl:apply-templates select="current()"/>
            <xsl:if test="position() &lt; last()">
                <xsl:text>,
                </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text> ]
        </xsl:text>
    </xsl:template>
    <xsl:template match="number[not(@key)]">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="number">
        <xsl:variable name="key">
            <xsl:value-of select="json:quote-string(xs:string(@key))"/>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:value-of select="string-join(($key, $value), ' : ')"/>
    </xsl:template>
    <xsl:template match="string[not(@key)]">
        <xsl:value-of select="json:quote-string(json:escape-string(./text()))"/>
    </xsl:template>
    <xsl:template match="string">
        <xsl:variable name="key">
            <xsl:value-of select="json:quote-string(xs:string(@key))"/>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:value-of select="json:quote-string(json:escape-string(./text()))"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$key">
                <xsl:value-of select="string-join(($key, $value), ' : ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
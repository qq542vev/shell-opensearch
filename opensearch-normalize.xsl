<?xml version="1.0" encoding="UTF-8"?>
<!-- Document: opensearch-normalize.xsl

	OpenSearch description document の正規化を行う

	Metadata:

		id - 0a4fc3b0-7960-403f-bb0d-c1a09ebdb349
		author - <qq542vev at https://purl.org/meta/me/>
		version - 0.1.1
		date - 2022-11-19
		since - 2022-11-13
		copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
		license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
		package - shell-opensearch

	See Also:

		* <Project homepage at https://github.com/qq542vev/shell-opensearch>
		* <Bag report at https://github.com/qq542vev/shell-opensearch/issues>
-->
<xsl:stylesheet
	version="1.0"
	xmlns="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:moz="http://www.mozilla.org/2006/browser/search/"
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:parameters="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="os moz"
>
	<xsl:output
		method="xml" version="1.0" indent="no" encoding="UTF-8"
		media-type="application/opensearchdescription+xml"
		omit-xml-declaration="no"
	/>

	<xsl:strip-space elements="os:OpenSearchDescription os:Url os:Query"/>

	<xsl:template match="os:OpenSearchDescription">
		<xsl:copy>
			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="node() | @*"/>

			<xsl:if test="not(os:LongName)">
				<LongName>
					<xsl:value-of select="os:ShortName"/>
				</LongName>
			</xsl:if>

			<xsl:if test="not(os:SyndicationRight)">
				<SyndicationRight>open</SyndicationRight>
			</xsl:if>

			<xsl:if test="not(os:AdultContent)">
				<AdultContent>false</AdultContent>
			</xsl:if>

			<xsl:if test="not(os:Language)">
				<Language>*</Language>
			</xsl:if>

			<xsl:if test="not(os:InputEncoding)">
				<InputEncoding>UTF-8</InputEncoding>
			</xsl:if>

			<xsl:if test="not(os:OutputEncoding)">
				<OutputEncoding>UTF-8</OutputEncoding>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="os:Url">
		<xsl:copy>
			<xsl:if test="not(@rel)">
				<xsl:attribute name="rel">results</xsl:attribute>
			</xsl:if>

			<xsl:if test="not(@indexOffset)">
				<xsl:attribute name="indexOffset">1</xsl:attribute>
			</xsl:if>

			<xsl:if test="not(@pageOffset)">
				<xsl:attribute name="pageOffset">1</xsl:attribute>
			</xsl:if>

			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="os:Url[translate(normalize-space(@method), 'POST', 'post') = 'post']/os:Param">
		<parameters:Parameter>
			<xsl:apply-templates select="node() | @*"/>
		</parameters:Parameter>
	</xsl:template>

	<xsl:template match="os:Query">
		<xsl:copy>
			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="os:SyndicationRight">
		<xsl:copy>
			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="@*"/>

			<xsl:value-of select="translate(normalize-space(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="os:AdultContent">
		<xsl:variable name="value" select="normalize-space()"/>

		<xsl:copy>
			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="@*"/>

			<xsl:choose>
				<xsl:when test="$value = 'false' or $value = 'FALSE' or $value = '0' or $value = 'no' or $value = 'NO'">false</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="os:ShortName | os:Description | os:LongName | os:Developer | os:Attribution">
		<xsl:copy>
			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="@*"/>

			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="
		os:Contact | os:Tags | os:Image | os:Language
		| os:InputEncoding | os:OutputEncoding | moz:SearchForm
	">
		<xsl:copy>
			<xsl:call-template name="namespace_copy"/>
			<xsl:apply-templates select="@*"/>

			<xsl:value-of select="normalize-space()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="os:*"/>

	<xsl:template match="os:Url/@method[translate(normalize-space(), 'POST', 'post') = 'post']">
		<xsl:attribute name="parameters:method">POST</xsl:attribute>
	</xsl:template>

	<xsl:template match="
		os:Url/@indexOffset | os:Url/@pageOffset | os:Image/@width | os:Image/@height
		| os:Query/@totalResults | os:Query/@count | os:Query/@startIndex | os:Query/@startPage
	">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="translate(normalize-space(), '+', '')"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="
		os:Url/@template | os:Url/@type | os:Url/@rel | os:Image/@type
		| os:Query/@role | os:Query/@language | os:Query/@inputEncoding | os:Query/@outputEncoding
	">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="normalize-space()"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="os:Param/@name | os:Param/@value | os:Query/@title | os:Query/@searchTerms">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="os:*/@*[namespace-uri() = ''] | @os:*"/>

	<xsl:template match="node() | @*">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template name="namespace_copy">
		<xsl:for-each select="namespace::*">
			<xsl:copy/>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!-- Document: opensearch-show.xsl

	OpenSearch description document をテキストに変換する

	Metadata:

		id - ff68a9ee-63b4-4d79-925a-237542d63289
		author - <qq542vev at https://purl.org/meta/me/>
		version - 0.1.0
		date - 2022-11-28
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
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="text" encoding="UTF-8" media-type="text/plain"/>

	<xsl:param name="match"/>

	<xsl:variable name="self" select="document('')/xsl:stylesheet"/>
	<xsl:variable name="list" select="$self/xhtml:ol"/>

	<xhtml:ol id="OpenSearchDescription">
		<xhtml:li>ShortName</xhtml:li>
		<xhtml:li>Description</xhtml:li>
		<xhtml:li>Url</xhtml:li>
		<xhtml:li>Contact</xhtml:li>
		<xhtml:li>Tags</xhtml:li>
		<xhtml:li>LongName</xhtml:li>
		<xhtml:li>Image</xhtml:li>
		<xhtml:li>Query</xhtml:li>
		<xhtml:li>Developer</xhtml:li>
		<xhtml:li>Attribution</xhtml:li>
		<xhtml:li>SyndicationRight</xhtml:li>
		<xhtml:li>AdultContent</xhtml:li>
		<xhtml:li>Language</xhtml:li>
		<xhtml:li>InputEncoding</xhtml:li>
		<xhtml:li>OutputEncoding</xhtml:li>
	</xhtml:ol>

	<xhtml:ol id="Url">
		<xhtml:li>template</xhtml:li>
		<xhtml:li>type</xhtml:li>
		<xhtml:li>rel</xhtml:li>
		<xhtml:li>indexOffset</xhtml:li>
		<xhtml:li>pageOffset</xhtml:li>
	</xhtml:ol>

	<xhtml:ol id="Query">
		<xhtml:li>role</xhtml:li>
		<xhtml:li>title</xhtml:li>
		<xhtml:li>totalResults</xhtml:li>
		<xhtml:li>searchTerms</xhtml:li>
		<xhtml:li>startIndex</xhtml:li>
		<xhtml:li>startPage</xhtml:li>
		<xhtml:li>language</xhtml:li>
		<xhtml:li>inputEncoding</xhtml:li>
		<xhtml:li>outputEncoding</xhtml:li>
	</xhtml:ol>

	<xhtml:ol id="Image">
		<xhtml:li>width</xhtml:li>
		<xhtml:li>height</xhtml:li>
		<xhtml:li>type</xhtml:li>
	</xhtml:ol>

	<xsl:template match="/os:OpenSearchDescription">
		<xsl:apply-templates select="$list[@id = 'OpenSearchDescription']/xhtml:li">
			<xsl:with-param name="current" select="os:*"/>
			<xsl:with-param name="match" select="$match"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="
		os:ShortName | os:Description | os:Contact | os:Tags | os:LongName
		| os:Developer | os:Attribution | os:SyndicationRight | os:AdultContent
		| @template | @type | @rel | @indexOffset | @pageOffset
		| @role | @title | @totalResults | @searchTerms | @startIndex
		| @startPage | @language | @inputEncoding | @outputEncoding
		| @width | @height | @type
	">
		<xsl:value-of select="concat(' ', normalize-space(), '&#xA;')"/>
	</xsl:template>

	<xsl:template match="os:Url | os:Query">
		<xsl:if test="position() = 1">
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>

		<xsl:apply-templates select="$list[@id = local-name(current())]/xhtml:li">
			<xsl:with-param name="current" select="@*"/>
			<xsl:with-param name="first" select="'  - '"/>
			<xsl:with-param name="indent" select="'    '"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="os:Image">
		<xsl:if test="position() = 1">
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>

		<xsl:value-of select="concat('  - url: ', ., '&#xA;')"/>

		<xsl:apply-templates select="$list[@id = 'Image']/xhtml:li">
			<xsl:with-param name="current" select="@*"/>
			<xsl:with-param name="indent" select="'    '"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="os:Language | os:InputEncoding | os:OutputEncoding">
		<xsl:if test="position() = 1">
			<xsl:text> [ </xsl:text>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="normalize-space() = '*'">
				<xsl:value-of select="concat(&quot;'&quot;, normalize-space(), &quot;'&quot;)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space()"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="position() = last()">
				<xsl:text> ]&#xA;</xsl:text>
			</xsl:when>
			<xsl:otherwise>, </xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xhtml:li">
		<xsl:param name="current" select="."/>
		<xsl:param name="first" select="false()"/>
		<xsl:param name="indent"/>
		<xsl:param name="match"/>

		<xsl:if test="(not($match) or $match = .) and $current[local-name() = current()]">
			<xsl:choose>
				<xsl:when test="$first and position() = 1">
					<xsl:value-of select="concat($first, ., ':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($indent, ., ':')"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="$current[local-name() = current()]"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
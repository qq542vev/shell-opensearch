#!/usr/bin/env sh

set -eu

configDir="${HOME}/.config/shellopensearch/opensearch"
namespaceUri='http://a9.com/-/spec/opensearch/1.1/'
nsFilter="[namespace-uri()='${namespaceUri}']"
xpathRootElement="/*[local-name()='OpenSearchDescription']${nsFilter}"
xpathUrlElement="${xpathRootElement}/*[local-name()='Url']${nsFilter}"

getOutputEncoding () (
	case "${LANG#*.}" in
		'C')
			printf 'ISO-8859-1\n'
			;;
		*)
			printf "%s\n" "${LANG#*.}"
			;;
	esac
)

getInputEncoding () (
	xmlFile="${1}"
	xpathIEElement="${xpathRootElement}/*[local-name()='InputEncoding']${nsFilter}"
	systemEncoding="${LANG#*.}"

	if xmllint --xpath "${xpathIEElement}[.='${systemEncoding}']" "${xmlFile}" >'/dev/null' 2>&1; then
		printf '%s\n' "${systemEncoding}"
	elif (
		xmllint --xpath "${xpathIEElement}[.='UTF-8']" "${xmlFile}" ||
		[ "$(xmllint --xpath "count(${xpathIEElement})" "${xmlFile}")" -eq 0 ]
	) >'/dev/null' 2>&1; then
		printf 'UTF-8\n'
	else
		xmllint --xpath "string(${xpathIEElement})" "${xmlFile}"
	fi
)

getLanguage () (
	xmlFile="${1}"
	xpathLanguageElement="${xpathRootElement}/*[local-name()='Language']${nsFilter}"
	case "${LANG%%.*}" in
		'C')
			systemLang='en-US'
			;;
		*)
			systemLang=$(printf '%s' "${LANG%%.*}" | tr '_' '-')
			;;
	esac

	if (
		xmllint --xpath "${xpathLanguageElement}[.='*' or .='${systemLang}']" "${xmlFile}" ||
		[ -n "$(xmllint --xpath "count(${xpathLanguageElement})" "${xmlFile}")" ]
	) >'/dev/null' 2>&1; then
		language="${systemLang}"
	else
		{
			language=$(xmllint --xpath "string(${xpathLanguageElement}[starts-with(., '${systemLang}')])" "${xmlFile}")
			[ -n "${language}" ]
		} || {
			language=$(xmllint --xpath "string(${xpathLanguageElement}[starts-with(., '${systemLang%%-*}')])" "${xmlFile}")
			[ -n "${language}" ]
		} || language='*'
	fi

	printf '%s' "${language}"
)

opensearch_search () (
	xmlFile="${configDir}/${1}.xml"
	shift

	base="${xpathUrlElement}[not(@rel) or contains(concat(' ', @rel, ' '), ' results ')][1]"
	template=$(xmllint --xpath "string($base/@template)" "${xmlFile}")
	count='10'
	indexOffset=$(xmllint --xpath "string($base/@indexOffset)" "${xmlFile}")
	pageOffset=$(xmllint --xpath "string($base/@pageOffset)" "${xmlFile}")
	: ${indexOffset:=1}
	: ${pageOffset:=1}
	language=$(getLanguage "${xmlFile}")
	inputEncoding=$(getInputEncoding "${xmlFile}")
	outputEncoding=$(getOutputEncoding)
 	searchTerms=$(printf '%s' "${*}" | iconv -cs -t "${outputEncoding}")

for param in $(printf '%s' "${template}" | sed -e 's/[^{]*\({[:a-z]*}\)[^{]*/\1 /g'); do
	case "${param}" in
		*:*)
			paramNS=$(xmllint --xpath "string($base/namespace::*[name()='$(printf '%s' "${param}" | cut -d ':' -f 1)'])" "${xmlFile}")
			if [ -z "${paramNS}" ]; then
				exit 1
			fi
			localName=$(printf '%s' "${param}" | cut -d ':' -f 2)
			;;
		*)
			paramNS="${namespaseUri}"
			localName="${param}"
			;;
	esac

	#index='0'
	#while [ ]; do
	#	case "${argParamKey}" in "{${paramNS}}${localName}")
	#		template=$(printf '%s' "${template}" | fsed "${param}" "${argParamValue}")
	#		;;
	#	esac
	#done
done

	printf '%s' "${template}" | sed -e "
		s/{count\{0,1\}}/${count}/g;
		s/{indexOffset?\{0,1\}}/${indexOffset}/g;
		s/{pageOffset?\{0,1\}}/${pageOffset}/g;
		s/{language?\{0,1\}}/${language}/g;
		s/{inputEncoding?\{0,1\}}/${inputEncoding}/g;
		s/{outputEncoding?\{0,1\}}/${outputEncoding}/g;
		s/{searchTerms?\{0,1\}}/${searchTerms}/g;
	" | sed -e "s/{[0-9A-Za-z._~%!$&'()*+,;=-]\\{1,\\}:[0-9A-Za-z._~%!$&'()*+,;=-]\\{1,\\}//g"
)

quoteEscape () (
	printf "'%s'" "$(sed -e "s/'/'\\\\&'/g")"
)

argCount='0'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		-p)
			eval "argParamName${argCount}='$(expr "${2}" : '^\(\({[^}]*}\)\{0,1\}[^=]*\)=.*$')'"
			eval "argParamValue${argCount}='$(expr 'substr' "${2}" "$(($(eval printf "'%d'" "\${#argParamName${argCount}}") + 2))" "${#2}")'"
			shift 2
			argCount=$((argCount + 1))
			;;
		*)
			args="${args} $(printf '%s' "${1}" | quoteEscape)"
			shift
			;;
	esac
done

echo "${args}"
set | grep  "argParam"
exit

eval set "${args}"

case "${1}" in
	'example' | 'contact' | 'info' | 'search' | 'suggestion' | 'update')
		command="${1}"
		shift
		"opensearch_${command}" "${@}"
		;;
	*)
		;;
esac
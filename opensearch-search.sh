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

	eval "argParamName${argCount}='{${namespaceUri}}count'"
	eval "argParamValue${argCount}='10'"
	eval "argParamName$((argCount + 1))='{${namespaceUri}}indexOffset'"
	eval "argParamValue$((argCount + 1))='$(xmllint --xpath "string($base/@indexOffset)" "${xmlFile}")'"
	eval "argParamName$((argCount + 2))='{${namespaceUri}}pageOffset'"
	eval "argParamValue$((argCount + 2))=$(xmllint --xpath "string($base/@pageOffset)" "${xmlFile}")"
	eval ':' "\${argParamValue$((argCount + 1)):=1}"
	eval ':' "\${argParamValue$((argCount + 2)):=1}"

	eval "argParamName$((argCount + 3))='{${namespaceUri}}language'"
	eval "argParamValue$((argCount + 3))='$(getLanguage "${xmlFile}")'"
	eval "argParamName$((argCount + 4))='{${namespaceUri}}inputEncoding'"
	eval "argParamValue$((argCount + 4))='$(getInputEncoding "${xmlFile}")'"
	eval "argParamName$((argCount + 5))='{${namespaceUri}}outputEncoding'"
	eval "argParamValue$((argCount + 5))='$(getOutputEncoding "${xmlFile}")'"
	eval "argParamName$((argCount + 6))='{${namespaceUri}}searchTerms'"
	eval "argParamValue$((argCount + 6))='$(printf '%s' "${*}" | iconv -cs -t "UTF-8" | ./urlencode)'"

	argCount=$((argCount + 7))

	for param in $(printf '%s' "${template}" | sed -e 's/^[^{]*//; s/}[^{]\{1,\}/ /g; s/[{}?]//g'); do
		case "${param}" in
			*:*)
				paramNS=$(xmllint --xpath "string($base/namespace::*[name()='${param%%:*}'])" "${xmlFile}")
				if [ -z "${paramNS}" ]; then
					exit 1
				fi
				localName="${param#*:}"
				;;
			*)
				paramNS="${namespaceUri}"
				localName="${param}"
				;;
		esac

		index='0'
		while [ "${index}" -lt "${argCount}" ]; do
			paramName=$(eval printf '%s' "\"\${argParamName${index}}\"")
			paramValue=$(eval printf '%s' "\"\${argParamValue${index}}\"")

			case "${paramName}" in "{${paramNS}}${localName}")
				template=$(printf '%s' "${template}" | ./fsed "{${param}}" "${paramValue}" | ./fsed "{${param}?}" "${paramValue}")
				;;
			esac

			index=$((index + 1))
		done
	done

	printf '%s' "${template}" | sed -e "s/{[^}]*?}//g"
)

quoteEscape () (
	printf "'%s'" "$(sed -e "s/'\{1,\}/'\"&\"'/g")"
)

argCount='0'
args=''

while [ 1 -le "${#}" ]; do
	case "${1}" in
		'-p'|'--param')
			tmpParamName=$(expr "${2}" : '^\(\({[^}]*}\)\{0,1\}[^=]*\)=.*$')
			eval "argParamValue${argCount}='$(expr 'substr' "${2}" "$((${#tmpParamName} + 2))" "${#2}" | ./urlencode)'"

			if expr "${tmpParamName}" : '^[^{}]' >'/dev/null'; then
				tmpParamName="{${namespaceUri}}${tmpParamName}"
			fi

			eval "argParamName${argCount}='${tmpParamName}'"

			argCount=$((argCount + 1))
			shift 2
			;;
		'--param='*)
			tmpParam="${1}"
			shift
			set '-p' "${tmpParam#--param=}" "${@}"
			;;
		'--')
			while [ 1 -le "${#}" ]; do
				args="${args}${args:+ }$(printf '%s' "${1}" | quoteEscape)"
				shift
			done
			;;
		*)
			args="${args}${args:+ }$(printf '%s' "${1}" | quoteEscape)"
			shift
			;;
	esac
done

eval set -- "${args}"

opensearch_search "${@}"
#!/usr/bin/env sh

### File: opensearch-list_spec.sh
##
## opensearch list のテスト。
##
## Usage:
##
## ------ Text ------
## shellspec opensearch-list_spec.sh
## ------------------
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-11-23
##   since - 2022-11-23
##   copyright - Copyright (C) 2022 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - shell-opensearch
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/shell-opensearch>
##   * Bag report - <https://github.com/qq542vev/shell-opensearch/issues>

eval "$(shellspec - -c) exit 1"

Describe 'opensearch list test'
	name_check() {
		eval "set -- ${1}"

		printf '%s' "${line_check}" | awk -- "$(
			cat <<-'__EOF__'
			BEGIN {
				split("", arguments)

				for(i = 1; i < ARGC; i++) {
					arguments[i] = ": " ARGV[i]
					delete ARGV[i]
				}
			}

			!arguments[NR] || substr($0, length($0) - length(arguments[NR]) + 1) != arguments[NR] {
				exit 1
			}
			__EOF__
		)" ${@+"${@}"}
	}

	setup() {
		configDir='./spec/.shell-opensearch'
		name="'Web Search'"
	}

	BeforeAll 'setup'

	Example 'オプション -h のテスト'
		When call ./opensearch list -h
		The length of stdout should not eq 0
		The length of stderr should eq 0
		The status should eq 0
	End

	Example 'オプション --nil のテスト'
		When call ./opensearch list --nil
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Example '2個以上の引数をテスト'
		When call ./opensearch list simple detailed
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Describe 'OpenSearch ファイルを指定'
		Parameters:block
			'simple'   "${name}" ''  '0'
			'detailed' "${name}" ''  '0'
			'empty'    ''        '1' '65'
			'draft2'   ''        '1' '65'
			'nil'      ''        '1' '65'
			'success/' "${name} ${name}" ''  '0'
			'failure/' ''                '1' '65'
			'empty/'   ''                ''  '0'
			'nil/'     ''                ''  '0'
			'simple,detailed'   "${name} ${name}" ''  '0'
			'simple,nil'        "${name}"         '1' '65'
			'draft2,nil'        ''                '1' '65'
			'draft2,nil,simple' "${name}"         '1' '65'
			'./spec/.shell-opensearch/simple.xml'   "${name}" ''  '0'
			'./spec/.shell-opensearch/detailed.xml' "${name}" ''  '0'
			'./spec/.shell-opensearch/empty.xml'    ''        '1' '65'
			'./spec/.shell-opensearch/draft2.xml'   ''        '1' '65'
			'./spec/.shell-opensearch/nil.xml'      ''        '1' '65'
		End

		Example "オプションなしのテスト: '${1}'"
			When run source ./opensearch -c "${configDir}" list "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The stdout should satisfy name_check "${2}"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End

		Example "オプション -p のテスト: '${1}'"
			path_check() {
				printf '%s' "${path_check}" | awk -- 'index($0, "/") != 1 && index($0, "./") != 1 { exit 1; }'
			}

			When run source ./opensearch -c "${configDir}" list -p "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The stdout should satisfy name_check "${2}"
			The stdout should satisfy path_check
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End
	End
End

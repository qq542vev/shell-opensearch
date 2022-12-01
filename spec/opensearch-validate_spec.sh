#!/usr/bin/env sh

### File: opensearch-validate_spec.sh
##
## opensearch validate のテスト。
##
## Usage:
##
## ------ Text ------
## shellspec opensearch-validate_spec.sh
## ------------------
##
## Metadata:
##
##   id - 80818086-1537-4dc5-8987-8b199d55c6b7
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-11-21
##   since - 2022-11-21
##   copyright - Copyright (C) 2022 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - shell-opensearch
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/shell-opensearch>
##   * Bag report - <https://github.com/qq542vev/shell-opensearch/issues>

eval "$(shellspec - -c) exit 1"

Describe 'opensearch validate test'
	message_check() {
		eval "set -- ${1}"

		printf '%s' "${message_check}" | awk -- "$(
			cat <<-'__EOF__'
			BEGIN {
				split("", arguments)

				for(i = 1; i < ARGC; i++) {
					arguments[i] = ": " ARGV[i]
					delete ARGV[i]
				}
			}

			!(NR in arguments) && $3 != arguments[NR] {
				exit 1
			}
			__EOF__
		)" ${@+"${@}"}
	}

	setup() {
		configDir="${PWD}/spec/.shell-opensearch"
	}

	BeforeAll 'setup'

	Example 'オプション -h のテスト'
		When call ./opensearch validate -h
		The length of stdout should not eq 0
		The length of stderr should eq 0
		The status should eq 0
	End

	Example 'オプション --nil のテスト'
		When call ./opensearch validate --nil
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Example '2個以上の引数をテスト'
		When call ./opensearch validate simple detailed
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Describe 'OpenSearch ファイルを指定'
		Parameters:block
			'simple'   'valid'   ''  '0'
			'detailed' 'valid'   ''  '0'
			'empty'    'invalid' '1' '65'
			'draft2'   'invalid' '1' '65'
			'nil'      'invalid' '1' '65'
			'success/' 'valid   valid'   ''  '0'
			'failure/' 'invalid invalid' '1' '65'
			'empty/'   ''                ''  '0'
			'nil/'     ''                ''  '0'
			'simple,detailed'   'valid   valid'         ''  '0'
			'simple,nil'        'valid   invalid'       '1' '65'
			'draft2,nil'        'invalid invalid'       '1' '65'
			'draft2,nil,simple' 'invalid invalid valid' '1' '65'
			'./spec/.shell-opensearch/simple.xml'   'valid'   ''  '0'
			'./spec/.shell-opensearch/detailed.xml' 'valid'   ''  '0'
			'./spec/.shell-opensearch/empty.xml'    'invalid' '1' '65'
			'./spec/.shell-opensearch/draft2.xml'   'invalid' '1' '65'
			'./spec/.shell-opensearch/nil.xml'      'invalid' '1' '65'
		End

		Example "オプションなしのテスト: '${1}'"
			When call ./opensearch -c "${configDir}" validate "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The stdout should satisfy message_check "${2}"
			The length of stderr should eq 0
			The status should eq "${4}"
		End

		Example "オプション --err のテスト: '${1}'"
			When call ./opensearch -c "${configDir}" validate --err "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The stdout should satisfy message_check "${2}"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End

		Example "オプション --quiet のテスト: '${1}'"
			When call ./opensearch -c "${configDir}" validate --quiet "${1}"
			The length of stdout should eq 0
			The length of stderr should eq 0
			The status should eq "${4}"
		End

		Example "オプション --err --quiet のテスト: '${1}'"
			When call ./opensearch -c "${configDir}" validate --err --quiet "${1}"
			The length of stdout should eq 0
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End
	End
End

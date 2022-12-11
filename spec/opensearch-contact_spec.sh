#!/usr/bin/env sh

### File: opensearch-contact_spec.sh
##
## opensearch contact の検証。
##
## Usage:
##
## ------ Text ------
## shellspec opensearch-contact_spec.sh
## ------------------
##
## Metadata:
##
##   id - 043438cc-6314-4ea0-a726-a65a58fe275e
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-12-11
##   since - 2022-11-23
##   copyright - Copyright (C) 2022 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - shell-opensearch
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/shell-opensearch>
##   * <Bag report at https://github.com/qq542vev/shell-opensearch/issues>

eval "$(shellspec - -c) exit 1"

Describe 'opensearch contact の検証'
	email_check() {
		eval "set -- ${1}"

		printf '%s' "${email_check}" | awk -- "$(
			cat <<-'__EOF__'
			BEGIN {
				split("", arguments)

				for(i = 1; i < ARGC; i++) {
					arguments[i] = ARGV[i]
					delete ARGV[i]
				}
			}

			!(NR in arguments) || $0 != arguments[NR] {
				exit 1
			}
			__EOF__
		)" ${@+"${@}"}
	}

	setup() {
		configDir='./spec/.shell-opensearch'
		email="'admin@example.com'"
	}

	BeforeAll 'setup'

	Example 'ヘルプの検証: -h'
		When call ./opensearch contact -h
		The length of stdout should not eq 0
		The length of stderr should eq 0
		The status should eq 0
	End

	Example '無効なオプションの検証: --nil'
		When call ./opensearch contact --nil
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Example '2個以上の引数の検証'
		When call ./opensearch contact simple detailed
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Describe '各種 OpenSearch ファイルによる検証'
		Parameters:block
			'minimum' ''           '1' '65'
			'simple'  "${email}"   ''  '0'
			'empty'    ''          '1' '65'
			'draft2'   ''          '1' '65'
			'nil'      ''          '1' '65'
			'success/' "${email} ${email}" ''  '0'
			'failure/' ''                   '1' '65'
			'empty/'   ''                   ''  '0'
			'nil/'     ''                   ''  '0'
			'simple,detailed' "${email} ${email}" ''  '0'
			'simple,minimum'  ''                    '1' '65'
			'simple,nil'      ''                    '1' '65'
			'draft2,nil'      ''                    '1' '65'
			'./spec/.shell-opensearch/simple.xml'  "${email}" ''  '0'
			'./spec/.shell-opensearch/minimul.xml' ''         '1' '65'
			'./spec/.shell-opensearch/empty.xml'   ''         '1' '65'
			'./spec/.shell-opensearch/nil.xml'     ''         '1' '65'
		End

		Example "オプションなしの検証: '${1}'"
			When call ./opensearch -c "${configDir}" contact "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The stdout should satisfy email_check "${2}"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End

		Example "--extarnal の検証: '${1}'"
			When call env 'MAILER=echo' ./opensearch -c "${configDir}" contact -e "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "$((1 <= ${#}))")"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End

		Example "--extarnal のテスト: '${1}'"
			When call ./opensearch -c "${configDir}" contact -e'awk "BEGIN { for(i = 1; i < ARGC; i++) { printf(\"Email: %s\\n\", ARGV[i]) } }"' "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End
	End

	Describe '--skip-error を有効にして各種 OpenSearch ファイルを検証'
		email='admin@example.com'
		Parameters:block
			'success/' "${email} ${email}" ''  '0'
			'failure/' ''                  '1' '65'
			'empty/'   ''                  ''  '0'
			'nil/'     ''                  ''  '0'
			'simple,detailed' "${email} ${email}" ''  '0'
			'simple,minimum'  "${email}"          '1' '65'
			'simple,nil'      "${email}"          '1' '65'
			'draft2,nil'      ''                  '1' '65'
		End

		Example "--skip-error の検証: '${1}'"
			When call ./opensearch -c "${configDir}" contact -s "${1}"
			The lines of stdout should eq "$(eval "set -- ${2}"; printf '%d' "${#}")"
			The stdout should satisfy email_check "${2}"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End
	End
End

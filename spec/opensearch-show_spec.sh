#!/usr/bin/env sh

### File: opensearch-show_spec.sh
##
## opensearch show のテスト。
##
## Usage:
##
## ------ Text ------
## shellspec opensearch-show_spec.sh
## ------------------
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-11-26
##   since - 2022-11-26
##   copyright - Copyright (C) 2022 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - shell-opensearch
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/shell-opensearch>
##   * Bag report - <https://github.com/qq542vev/shell-opensearch/issues>

eval "$(shellspec - -c) exit 1"

Describe 'opensearch show test'
	setup() {
		configDir='./spec/.shell-opensearch'
	}

	BeforeAll 'setup'

	Example 'Option: -h'
		When call ./opensearch show -h
		The length of stdout should not eq 0
		The length of stderr should eq 0
		The status should eq 0
	End

	Example 'Option: --nil'
		When call ./opensearch show --nil
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Example '2個以上の引数'
		When call ./opensearch show simple detailed
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Example "オプション -f nil のテスト: '${1}'"
		When call ./opensearch -c "${configDir}" show -f nil
		The length of stdout should eq 0
		The length of stderr should not eq 0
		The status should eq 64
	End

	Describe '基本となるテスト'
		Parameters:block
			'simple'   'simple'   ''  '0'
			'detailed' 'detailed' ''  '0'
			'empty'    ''         '1' '65'
			'draft2'   ''         '1' '65'
			'nil'      ''         '1' '65'
			'empty/'   ''         ''  '0'
			'nil/'     ''         ''  '0'
			'simple,detailed' 'simple-detailed' ''  '0'
			'simple,nil'      ''                    '1' '65'
			'draft2,nil'      ''                    '1' '65'
			'./spec/.shell-opensearch/simple.xml'   'simple'   ''  '0'
			'./spec/.shell-opensearch/detailed.xml' 'detailed' ''  '0'
			'./spec/.shell-opensearch/empty.xml'    ''         '1' '65'
			'./spec/.shell-opensearch/nil.xml'      ''         '1' '65'
		End

		Example "オプションなしのテスト: '${1}'"
			When call ./opensearch -c "${configDir}" show "${1}"
			The stdout should eq "$(cd -- 'spec/show-text'; : | eval "cat -- ${2}")"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End

		Example "オプション -f xml のテスト: '${1}'"
			When call ./opensearch -c "${configDir}" show -f xml "${1}"
			The stdout should eq "$(cd -- 'spec/show-xml'; : | eval "cat -- ${2}")"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End

		Example "オプション -f normalized-xml のテスト: '${1}'"
			When call ./opensearch -c "${configDir}" show -f normalized-xml "${1}"
			The stdout should eq "$(cd -- 'spec/show-normalized-xml'; : | eval "cat -- ${2}")"
			The length of stderr should ${3:+'not'} eq 0
			The status should eq "${4}"
		End
	End
End

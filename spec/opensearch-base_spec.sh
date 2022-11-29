#!/usr/bin/env sh

### File: opensearch-base_spec.sh
##
## opensearch のテスト。
##
## Usage:
##
## ------ Text ------
## shellspec opensearch-base_spec.sh
## ------------------
##
## Metadata:
##
##   author - qq542vev <https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2022-11-20
##   since - 2022-11-20
##   copyright - Copyright (C) 2022 qq542vev. Some rights reserved.
##   license - CC-BY <https://creativecommons.org/licenses/by/4.0/>
##   package - shell-opensearch
##
## See Also:
##
##   * Project homepage - <https://github.com/qq542vev/shell-opensearch>
##   * Bag report - <https://github.com/qq542vev/shell-opensearch/issues>

eval "$(shellspec - -c) exit 1"

Describe 'opensearch base test'
	Parameters:block
		''      '1' ''  '0'
		'-c ./spec/.shell-opensearch' '1' ''  '0'
		'-c'    ''  '1' '64'
		'-h'    '1' ''  '0'
		'-v'    '1' ''  '0'
		'--nil' ''  '1' '64'
		'nil'   ''  '1' '64'
	End

	Example "./openseaarch '${1}'"
		When call ./opensearch ${1}
		The length of stdout should ${2:+'not'} eq 0
		The length of stderr should ${3:+'not'} eq 0
		The status should eq "${4}"
	End
End

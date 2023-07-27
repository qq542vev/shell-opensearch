#!/usr/bin/env sh

### File: specfile_spec.sh
##
## Spec File を検証する。
##
## Usage:
##
## ------ Text ------
## shellspec specfile_spec.sh
## ------------------
##
## Metadata:
##
##   id - 34741e76-3def-41a2-80b7-0e459d2ac810
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2023-07-25
##   since - 2023-07-25
##   copyright - Copyright (C) 2023-2023 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - shell-opensearch
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/shell-opensearch>
##   * <Bag report at https://github.com/qq542vev/shell-opensearch/issues>

eval "$(shellspec - -c) exit 1"

Describe 'Spec File の検証'
	Example 'shellspec --syntax-check'
		When call shellspec --syntax-check
		The length of stdout should not equal 0
		The length of stderr should equal 0
		The status should equal 0
	End
End

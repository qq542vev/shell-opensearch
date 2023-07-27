#!/usr/bin/env sh

### File: xml_spec.sh
##
## XML を検証する。
##
## Usage:
##
## ------ Text ------
## shellspec xml_spec.sh
## ------------------
##
## Metadata:
##
##   id - bbc3cce8-7641-4e85-97bc-63039cc18557
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

% TESTFILES: 'opensearch.rng opensearch-normalize.xsl opensearch-show.xsl'

Describe 'XMLStarlet による検証'
	Parameters:value ${TESTFILES}

	Example "xml validate --quiet ${1}"
		When call xml validate --quiet "${1}"
		The length of stdout should equal 0
		The length of stderr should equal 0
		The status should equal 0
	End
End

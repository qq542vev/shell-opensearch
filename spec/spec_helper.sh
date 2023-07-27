### File: spec_helper.sh
##
## ShellSpec 用の共通ヘルパーファイル。
##
## Metadata:
##
##   id - 3bcb54f2-246b-4ac3-a6cd-8b07f9bfcf3f
##   author - <qq542vev at https://purl.org/meta/me/>
##   version - 1.0.0
##   date - 2023-07-27
##   since - 2023-07-27
##   copyright - Copyright (C) 2023-2023 qq542vev. Some rights reserved.
##   license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
##   package - convert-it-passport
##
## See Also:
##
##   * <Project homepage at https://github.com/qq542vev/shell-opensearch>
##   * <Bag report at https://github.com/qq542vev/shell-opensearch/issues>

set -efu

if command xmlstarlet --help >'/dev/null' 2>&1; then
	xml() {
		command xmlstarlet ${@+"${@}"}
	}
fi

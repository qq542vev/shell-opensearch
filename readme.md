<!-- Document: readme.md

	Shell OpenSearch のマニュアル

	Metadata:

		id - 27b7cd63-6bcd-4043-a037-f8114f36f387
		author - <qq542vev at https://purl.org/meta/me/>
		version - 0.1.0
		date - 2022-12-01
		since - 2022-11-30
		copyright - Copyright (C) 2022-2022 qq542vev. Some rights reserved.
		license - <CC-BY at https://creativecommons.org/licenses/by/4.0/>
		package - shell-opensearch

	See Also:

		* <Project homepage at https://github.com/qq542vev/shell-opensearch>
		* <Bag report at https://github.com/qq542vev/shell-opensearch/issues>
-->

# Shell OepnSearch

Shell OepnSearch は [POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/) 準拠の ShellScript で作成された OepnSearch 対応の検索クライアントです。[OpenSearch 1.1](https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md) の仕様に準拠した OpenSearch description documents (以下 OSDD に省略) を利用して端末環境から検索などを行えます。

# インストール

Shell OepnSearch を利用するためには、お使いのコンピューターに [XMLStarlet](https://xmlstar.sourceforge.net/) がインストールされている必要があります。また `opensearch add` と `opensearch update` を利用する際には [GNU Wget](https://www.gnu.org/software/wget/) または [curl](https://curl.se/) もインストールされている必要があります。

[GitHub Releases](https://github.com/qq542vev/shell-opensearch/releases) から最新版の opensearch をダウンロードして、任意の場所に設置してください。`opensearch` を実行し、コマンドのヘルプが表示されたら完了です。

~~~
opensearch --help
~~~

# 使用方法

## 検索エンジンを追加する

検索を行うには任意の OSDD を追加する必要があります。`opensearch add` で追加が可能です。例として以下のコマンドで http://www.example.com/opensearch.xml にある OSDD を example という識別子で追加を行います。

~~~
opensearch add example 'http://www.example.com/opensearch.xml'
~~~

追加した OSDD はデフォルトでは、`~/.shell-opensearch` 内に配置されます。URL は OSDD だけではなく、OSDD へのリンクが記載されている HTML / XHTML の指定も可能です。

~~~
opensearch add example 'http://www.example.com/index.html'
~~~

階層的な識別子も可能です。以下の場合は、 `~/.shell-opensearch/example/ja.xml` に配置されます。

~~~
opensearch add example/ja 'http://www.example.com/ja/opensearch.xml'
~~~

## 検索を行う

任意の OSDD を使用して検索を行えます。例えば以下のコマンドは example という識別子の検索エンジンで検索を行います。

~~~
opensearch search example keyword1 keyword2 ...
~~~

この場合には、`~/.shell-opensearch/example.xml` が利用されます。Shell OpenSearch では 0個以上の keyword を渡せますが、OSDD によっては1個以上の keyword が必要です。検索エンジンの識別子は `,` (カンマ)で区切ることにより、複数の指定も可能です。

~~~
opensearch search example1,example2
~~~

この場合には、`~/.shell-opensearch/example1.xml` と `~/.shell-opensearch/example2.xml` が利用されます。

`~/.shell-opensearch` 内のディレクトリを指定することも可能です。ディレクトリを指定するには末尾が `/` (スラッシュ)で終了する必要があります。ディレクトリ以下の全ての `*.xml` ファイルが利用されます。

~~~
opensearch search example/
~~~

任意の OSDD を利用する場合は、識別子の引数をファイルパスに置き換えてください。ただしファイルパスは、`/`, `./`, .`./` の何れかで開始する必要があります。複数のファイルを指定することは不可能です。

~~~
opensearch search ./example.xml
~~~

## Web ブラウザーで開く

デフォルトでは検索結果の URL を表示するのみですが、URL を Web ブラウザーなどを開いて検索結果を表示するには `-e`, `--extarnal` オプションを使用します。`--extarnal` のみで環境変数 `BROWSER` の値に、`--extarnal=COMMAND` で任意のコマンドに URL を引数として渡します。

~~~
export BROWSER=firefox
opensearch search example --extarnal
~~~

~~~
opensearch search example --extarnal=firefox
~~~

### MIME Type を指定する

OSDD によっては検索リクエストが複数定義されている場合があり、受容する MIME Type を変更することで検索リクエストの MIME Type を変更が可能です。デファルトでは `text/html` と `application/xhtml+xml` の優先度が高く設定しています。受容する MIME Type と優先度を変更するには `-t`, `--accept-type` オプションを使用します。

`,` (カンマ)で区切り複数の MIME Type を指定が可能です。MIME Typeを記述する MIME Type の順番によって優先度が変化します。最初に記述した MIME Type の優先度が最も高く、最後に記述した MIME Type の優先度が最も低いです。OSDD 内に受容する MIME Type に一致する検索リクエストが定義されていない場合は、エラーです。

例として RSS の検索リクエストを指定するのは以下のコマンドです。

~~~
opensearch search example --accept-type 'application/rss+xml,application/rdf+xml'
~~~

`*` (アスタリスク)を指定することで任意レスポンスタイプにマッチします。例として `text/*` は全てのテキストメディアに、`*/*` で全てのメディアにマッチします。

~~~
opensearch search example --accept-type '*/*'
~~~

### 検索パラメータを指定する

OSDD によっては検索リクエストが特定の検索パラメータに対応している場合があります。特定の検索パラメータを指定するには `-p`, `--template-parameter` を使用します。OpenSearch 1.1 で定義されているコアセットの検索パラメータ(無修飾パラメータ)を指定するコマンドは以下です。

~~~
opensearch search example --template-parameter 'count=100'
~~~

拡張されたパラメータ(完全修飾パラメータ)を指定する場合は、検索パラメータの名前空間を指定する必要があります。

~~~
opensearch search example --template-parameter '{http://example.com/opensearchextensions/1.0/}color=blue'
~~~

## 更新

OSDD 内に `<Url rel="self" type="application/opensearchdescription+xml" template="..."/>` の定義がある場合は、OSDD を更新することが可能です。

~~~
opensearch update example
~~~

## 一覧を表示

利用が可能な OSDD の識別子と検索エンジン名が一覧で表示されます。

~~~
opensearch list
~~~

## OSDD の詳細を表示

`opensearch show` で OSDD の詳細の表示が可能です。

~~~
opensearch show example
~~~

デフォルトでは [YAML](https://yaml.org/) に似た形式で表示されます。XML で表示を行うには、`-f`, `--format` を指定します。

~~~
opensearch show --format xml example
~~~

# ToDo

 * ShellSpec で `opensearch` の全ての機能のテストを行う。

# リンク

 * [OpenSearch 1.1 Draft 6](https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md)
 * [Open Search 仕様書 1.1 ドラフト4版](https://sites.google.com/site/tsukamoto/doc/opensearch/spec-1-1-draft4)

kgyubinuki
=========

yubinuki pattern simulator.

## how to play

### install and setup

```
bundle install
bower install
npm install
grunt install
```

### build

```
grunt bower
grunt build
```

### start server and play

```
bundle exec rackup

```

open [localhost:9292/index.html](http://localhost:9292/index.html)

### generate static html

1. Edit site.json, this specify page to access.
1. Exec command `grunt generate`. Pages are generated into 'static' directory.

## 謝辞

- yamagata-kozo/modern-web-creating-environment
	静的ファイル生成には、yamagata-kozo/modern-web-creating-environment/static_file_maker.rb を使用しています。
	プロジェクトの取り込みが適さなかったため、該当ファイルのみを取得しています。
	また、ファイルを含まないフォルダが存在するときに、フォルダ生成に失敗する問題を修正しています。

<h2>FlutterアプリからJavascriptのメソッドを呼ぶ方法</h2>
Flutterアプリは１つのコードでデスクトップアプリ、iPhoneアプリ、Androidアプリ、ブラウザアプリを作れるので便利です。<br><br>
しかし、通常、Flutterアプリはブラウザ上で開発・デバッグされ、コードはDart言語で開発されるので最初からJavascript関数を呼ぶことは出来ません。<br><br>
JavascriptのメソッドをDartコードから呼びたい場合は以下のライブラリを使用して実行することができます。<br><br>
https://pub.dev/packages/js
<br><br>
中にはDartにも対応しているライブラリもありますが、そうでない場合、Javascriptの関数をデバッグのためにFlutterアプリの中から呼ぶ必要があります。
<br><br>
しかし、最近のJavascriptはNPMで配布されており、このNPMパッケージがimportやrequireなどのシンタックスを必要とする場合、packages:jsは使用できません。
<br><br>
これらの問題はStack Overflow上で議論され、誰かがすでに解決策について答えています。
<br><br>
https://stackoverflow.com/questions/59317194/how-to-use-npm-package-as-normal-javascript-in-html
<br>
> However, browser cannot read ES6 syntax directly. As a result, you need to use Babel to transpile your ES6 code to normal JS code. See
<br><br>
https://hackernoon.com/use-es6-javascript-syntax-require-import-etc-in-your-front-end-project-5eefcef745c2
<br><br>
Flutterアプリの中でこれらのjavascript関数を呼びたい場合、まず、NPMパッケージを普通のjavascriptにトランスパイルする必要があります。
<h4>プロセスは以下</h4>
<br><br>

```
1. ディレクトリを作成します。

mkdir es6-to-script
cd es6-to-script

2.

npm init

3. index.jsを作成

4. トランスパイルしたいライブラリをインストール（例：Flow Blockchainのライブラリ）

npm i --save @onflow/fcl @onflow/types 

5. browserify, babel等をインストールします。しかし、babelは頻繁に仕様が変わるため、上記記事を書いた作者と同じバージョンをpackage.jsonに書き、`npm install` を実行します。

  "dependencies": {
    "@onflow/fcl": "^1.3.2",
    "@onflow/types": "^1.0.5",
    "browserify": "^16.2.2"
  },
  "devDependencies": {
    "babel-core": "^6.26.3",
    "babel-preset-es2015": "^6.24.1",
    "babelify": "^8.0.0"
  }

6. 以下のようにindex.jsにコードを記載します。

import * as fcl from "@onflow/fcl"

window.authenticate = () => fcl.authenticate();
window.subscribe = fcl.currentUser.subscribe;

7. package.jsonに以下の内容を追記します。

  "browserify": {
    "transform": [
      [
        "babelify",
        {
          "presets": [
            "es2015"
          ]
        }
      ]
    ]
  }

8. scripts設定をいかに置き換えます。

  "scripts": {
    "build": "browserify index.js -o dist/index.js"
  },

9. 以下のコマンドを実行

npm run build

10. index.jsがdistフォルダの下に作成されます。
しかし、このファイルを使用する前にindex.jsの中の以下のパートを変更する必要があります。

  queueMicrotask__default["default"]
  から

  const queueMicrotask = queueMicrotask__default["default"];
  queueMicrotask(

  return fetchTransport__default["default"]
  から
  const fetchT = fetchTransport__default["default"];
  return fetchT

この変更を行わなければInvalid Invocationエラーがブラウザ上で発生します。

11. index.jsをFlutterプロジェクトフォルダの下のwebフォルダの下にあるindex.htmlが存在する場所に持っていきます。

12. 以下のコードをindex.htmlの中のheadタグが閉じる直前に書きます。

  <script src="index.js" defer></script>

13. 以下コマンドを実行します。

  dart pub add js

14. 以下をmain.dartに記載します。

@JS()
library index;

@JS('authenticate')
external void authenticate();

@JS('subscribe')
external void subscribe(dynamic user);

15. 最後にjavascript関数をDartのコードの中で呼びます。

onPressed: () => authenticate(),

subscribe(allowInterop(setupWallet));
```


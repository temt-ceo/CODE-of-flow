# CodeOfFlow

This game is paying an homage to the SEGA's arcade game, Code Of Joker.

<h3>JavascriptをDartの中から呼ぶ方法については以下のREADMEに記載しています。</h3>
https://github.com/temt-ceo/CODE-of-flow/tree/develop/es6_to_script
<br>

<h3>Flutter SDKのインストール</h3>
以下よりダウンロード<br>
https://docs.flutter.dev/get-started/install/macos

<h3>Webアプリビルド方法</h3>

```
flutter build web
```

<h4>amplify-cliをインストールする</h4>

```
curl -sL https://aws-amplify.github.io/amplify-cli/install | bash && $SHELL

cd
vim .zprofile

Press i, then paste this line
export PATH="$HOME/.amplify/bin:$PATH"

Restart your terminal
```

<h4>amplify configure</h4>
<br>
<h4>amplify init</h4>
> App type: にflutterを選ぶ。すると、<br>
Configuration file location: ./lib/<br>
が表示されるはず。<br>

<h4>main.dartに設定用のコード追加</h4>
https://docs.amplify.aws/start/getting-started/integrate/q/integration/flutter/<br>
を参考にする。又は、<br>
https://www.youtube.com/watch?v=KVAaQoV4c6I
<br>
コーディングの参考はこちら: https://docs.amplify.aws/lib/graphqlapi/mutate-data/q/platform/flutter/<br>
<br>
<h4>amplify add auth</h4>
<h4>main.dartの _configureAmplify に必要なコードを追加する</h4>
<h4>amplify push 実行</h4>

```
amplify push
```

<h4>amplify add api</h4>
/backend/api/[prj_name]/stacksにschema.graphqlファイルが生成される

<h4>amplify codegen models</h4>
でモデルが/lib/modelsフォルダに生成される。

<h4>amplify push 実行</h4>

```
amplify push
```

<h4>masonを使うとmason make amplify_startetが使える</h4>

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# CodeOfFlow(COF.ninja)

This game is paying an homage to the SEGA's arcade game, Code Of Joker.<br><br>

COF.ninja is a tribute to SEGA's Code Of Joker.  So let's enjoy the game COF.ninja and wait the revival of Code Of Joker which runs on the Flow! <br><br>

<h3>The following webpage describes how to call Javascript from within Dart.</h3>
https://medium.com/@tickets.on.flow/how-to-call-blockchains-wallet-in-flutter-apps-633416720f23<br>

<h3>Install Flutter SDK</h3>
https://docs.flutter.dev/get-started/install/macos

<h3>How to build web app</h3>

```
flutter build web
```

<h3>Install amplify-cli</h3>

```
curl -sL https://aws-amplify.github.io/amplify-cli/install | bash && $SHELL

cd
vim .zprofile

Press i, then paste this line
export PATH="$HOME/.amplify/bin:$PATH"

Restart your terminal
```
<h4>amplify configure</h4>
<h4>amplify init</h4>
Choose flutter as App type.<br>
And then, Configuration file location: will be set to ./lib/<br><br>

<h4>Configuration inside main.dart</h4>
Refer to https://docs.amplify.aws/start/getting-started/integrate/q/integration/flutter/<br>
or https://www.youtube.com/watch?v=KVAaQoV4c6I<br><br>
Official document: https://docs.amplify.aws/lib/graphqlapi/mutate-data/q/platform/flutter/<br><br>
<h4>amplify add auth</h4>
<h4>implement _configureAmplify inside main.dar.</h4>
<h4>amplify push</h4>

```
amplify push
```
<h4>amplify add api</h4>
/backend/api/[prj_name]/stacksにschema.graphql file will be created.
<h4>amplify codegen models</h4>
The model files will be created inside /lib/models folder.
<h4>amplify push</h4>

```
amplify push
```
<h3>How to use DevTools to analyze the performance such as memory or cpu.</h3>

```
dart devtools
```
or type below after "command + shift + p"
```
> devtools
```

<h3>The following webpage describes how to setup Direct Lambda Resolver.</h3>
https://medium.com/@tickets.on.flow/how-to-build-a-wallet-less-blockchain-game-with-graphql-80ab28d099a1<br>

<h3>The diagram of this app's program sequence</h3>
<h4>Except at battle</h4>

<h4>When battling</h4>

<h4>Youtube Channel</h4>
https://www.youtube.com/watch?v=brActSNMiZk<br>

<h4>Babeled js file ↓</h4>
https://github.com/temt-ceo/CODE-of-flow/blob/develop/web/index.js<br>

<h4>Lambda file used for GraphQL Server using Direct Lambda Resolver with AWS AppSync.</h4>
https://github.com/temt-ceo/CODE-of-flow/blob/develop/aws_lambda/src/index.js

<h4>Smart Contract</h4>
https://github.com/temt-ceo/game-built-on-flow/blob/hackathon/cadence/contracts/CODEOfFlow.cdc<br>
https://flow-view-source.com/mainnet/account/0x24466f7fc36e3388/contract/CodeOfFlow<br>


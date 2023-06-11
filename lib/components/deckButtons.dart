@JS()
library index;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:js/js.dart';

import 'package:CodeOfFlow/services/api_service.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';

const envFlavor = String.fromEnvironment('flavor');

@JS('authenticate')
external void authenticate();

@JS('unauthenticate')
external void unauthenticate();

@JS('subscribe')
external void subscribe(dynamic user);

@JS('createPlayer')
external void createPlayer(String? name);

@JS('buyCyberEN')
external void buyCyberEN();

@JS('getAddr')
external String? getAddr(dynamic user);

@JS('isRegistered')
external dynamic isRegistered(String? address);

@JS('getCurrentStatus')
external dynamic getCurrentStatus(String? address);

@JS('getMariganCards')
external dynamic getMariganCards(String? address, int playerId);

@JS('getBalance')
external dynamic getBalance(String? address, int? playerId);

@JS('getPlayerUUId')
external String? getPlayerUUId(dynamic player);

@JS('getPlayerId')
external String? getPlayerId(dynamic player);

@JS('getPlayerName')
external String? getPlayerName(dynamic player);

@JS('getCardInfo')
external dynamic getCardInfo();

@JS('jsonToString')
external String jsonToString(dynamic obj);

typedef void StringCallback(String val, GameObject? data,
    List<List<int>>? mariganCards, dynamic cardInfo);

class DeckButtons extends StatefulWidget {
  int gameProgressStatus;
  final StringCallback callback;

  DeckButtons(this.gameProgressStatus, this.callback);

  @override
  DeckButtonsState createState() => DeckButtonsState();
}

class WalletUser {
  late String addr;
  WalletUser(this.addr);
}

class PlayerResource {
  late String uuid;
  late String playerId;
  late String nickname;
  PlayerResource(this.uuid, this.playerId, this.nickname);
}

class DeckButtonsState extends State<DeckButtons> {
  final nameController = TextEditingController();
  APIService apiService = APIService();
  WalletUser walletUser = WalletUser('');
  PlayerResource player = PlayerResource('', '', '');
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool showBottomSheet = false;
  bool showBottomSheet2 = false;
  bool onTyping = false;
  bool onClickButton = false;
  bool gameStarted = false;
  double imagePosition = 0.0;
  double? balance;
  int? cyberEnergy;
  String yourScore = '';
  String enemyName = '';
  String enemyScore = '';
  BuildContext? dcontext1;
  BuildContext? dcontext2;
  BuildContext? loadingContext;

  late StreamController<bool> _wait;

  dynamic timerObj = null;
  @override
  void initState() {
    super.initState();
    _wait = StreamController<bool>();
    // setInterval by every 2 second
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      timerObj = timer;
      if (walletUser.addr == '') {
        print('Not Login.');
        widget.callback(
            'other-game-info', GameObject.getOtherGameInfo(), null, null);
      }
    });

    // カード情報取得
    getCardInfos();
  }

  void getCardInfos() async {
    // カード情報取得
    dynamic cardInfo = await promiseToFuture(getCardInfo());
    var objStr = jsonToString(cardInfo);
    var objJs = jsonDecode(objStr);
    widget.callback('card-info', null, null, objJs);
  }

  @override
  void dispose() {
    super.dispose();
    if (timerObj != null) {
      timerObj.cancel();
    }
  }

  void setupWallet(user) {
    if (walletUser.addr == '') {
      String? addr = getAddr(user);
      if (addr == null) {
        setState(() => walletUser = WalletUser(''));
      } else {
        setState(() => walletUser = WalletUser(addr));
        if (player.uuid == '') {
          getPlayerInfo();
          widget.callback('game-is-ready', null, null, null);
        }
      }
    }
  }

  void getPlayerInfo() async {
    var ret = await promiseToFuture(isRegistered(walletUser.addr));
    if (ret != null) {
      String? playerId = getPlayerId(ret);
      String? playerName = getPlayerName(ret);
      String? playerUUId = getPlayerUUId(ret);
      debugPrint('PlayerId: $playerId');
      setState(
          () => player = PlayerResource(playerUUId!, playerId!, playerName!));
    } else {
      print('Not Imporing.');
    }
  }

  void showGameLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (buildContext) {
        loadingContext = buildContext;

        return Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void closeGameLoading() {
    if (loadingContext != null) {
      Navigator.pop(loadingContext!);
    }
  }

  Future<void> gameStart() async {
    showGameLoading();
    // Call GraphQL method.
    var ret = await apiService.saveGameServerProcess(
        'player_matching', '', player.playerId);
    closeGameLoading();
    debugPrint('transaction published');
    if (ret != null) {
      debugPrint(ret.message);
    }
  }

  void countdown() {
    var timerComponent = TimerComponent();
    timerComponent.countdownStart(60, null);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builderContext) {
          dcontext1 = builderContext;
          return StreamBuilder<int>(
              stream: timerComponent.events.stream,
              builder:
                  (BuildContext builderContext, AsyncSnapshot<int> snapshot) {
                return Container(
                    width: 200.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('${imagePath}unit/bg-2.jpg'),
                          fit: BoxFit.contain),
                      boxShadow: [
                        BoxShadow(
                          color: Color(snapshot.data ?? 0xFFFFFFFF),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(2, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text(
                      '00:${snapshot.data.toString()}',
                      style:
                          const TextStyle(color: Colors.black, fontSize: 46.0),
                    )));
              });
        });
  }

  void battleStartAnimation() {
    _wait.add(true);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builderContext) {
          dcontext2 = builderContext;
          return StreamBuilder<bool>(
              stream: _wait.stream,
              builder:
                  (BuildContext builderContext, AsyncSnapshot<bool> snapshot) {
                return AnimatedContainer(
                    margin: EdgeInsetsDirectional.only(top: imagePosition),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInQuart,
                    child: Container(
                      width: 200.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                snapshot.data != null && snapshot.data == true
                                    ? '${imagePath}unit/battleStart.png'
                                    : '${imagePath}unit/battleStart2.png'),
                            fit: BoxFit.cover),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFFFFFF),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(2, 5), // changes position of shadow
                          ),
                        ],
                      ),
                    ));
              });
        });
    imagePosition = 80.0;
    Future.delayed(const Duration(milliseconds: 1800), () {
      imagePosition = 0.0;
      _wait.add(false);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (dcontext2 != null) {
        Navigator.pop(dcontext2!);
      }
    });
  }

  // EN購入
  void buyCyberEnergy() {
    if (showBottomSheet2 == false) {
      setState(() {
        showBottomSheet2 = true;
      });
      // EN購入
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          backgroundColor: Color.fromARGB(205, 248, 129, 2),
          barrierColor: Colors.transparent,
          builder: (context) {
            return SizedBox(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                    child: Column(children: <Widget>[
                      const Text('EN is insufficient.\n(ENが不足しています)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 20.0)),
                      const SizedBox(height: 35.0),
                      Center(
                          child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), //丸み具合
                            ),
                          ),
                        ),
                        onPressed: () {
                          // showGameLoading();
                          buyCyberEN();
                          Future.delayed(const Duration(seconds: 3000), () {
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text('Insert 1FLOW coin.'),
                      )),
                      const SizedBox(height: 10.0),
                      Text(L10n.of(context)!.insufficientEN(balance.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16.0)),
                      const SizedBox(height: 8.0),
                      Text(L10n.of(context)!.insufficientEN2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16.0)),
                      const SizedBox(height: 4.0),
                      Text(L10n.of(context)!.insufficientEN3,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16.0)),
                    ])));
          });
    }
  }

  List<List<int>> setMariganCards(arr) {
    final List<List<int>> retArr = [];
    for (int i = 0; i < 5; i++) {
      retArr.add([]);
      for (int j = 0; j < 4; j++) {
        retArr[i].add(int.parse(arr[i][j]));
      }
    }
    return retArr;
  }

  void signout() {
    unauthenticate();
    setState(() => walletUser = WalletUser(''));
    setState(() => player = PlayerResource('', '', ''));
    setState(() => showBottomSheet = false);
  }

  @override
  Widget build(BuildContext context) {
    subscribe(allowInterop(setupWallet));

    return Stack(children: <Widget>[
      const Positioned(
          left: 75,
          top: 0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    width: 220.0,
                    child: Text(
                      'Deck Editor',
                      style:
                          TextStyle(color: Colors.lightGreen, fontSize: 36.0),
                    )),
              ])),
      Visibility(
          visible: cyberEnergy != null,
          child: Positioned(
            left: 75,
            top: 32,
            child: SizedBox(
                width: 300.0,
                child: Row(children: <Widget>[
                  const Text(
                    'EN:  ',
                    style: TextStyle(
                        color: Color.fromARGB(255, 32, 243, 102),
                        fontSize: 16.0),
                  ),
                  Text(
                    '${cyberEnergy.toString()} / 200',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 32, 243, 102),
                        fontSize: 18.0),
                  ),
                  const SizedBox(width: 20.0),
                  Text(
                    yourScore,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 247, 245, 245),
                        fontSize: 18.0),
                  ),
                ])),
          )),
      Padding(
          padding: const EdgeInsets.only(top: .0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Visibility(
                visible: walletUser.addr == '',
                child: const SizedBox(width: 20)),
            Visibility(
                visible: walletUser.addr == '',
                child: const FloatingActionButton(
                  onPressed: authenticate,
                  tooltip: 'Authenticate',
                  child: Icon(Icons.key_outlined),
                )),
            SizedBox(
                width: 65.0,
                child: Visibility(
                    visible: walletUser.addr != '',
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () async {
                          if (gameStarted == true || cyberEnergy == null) {
                          } else {
                            if (cyberEnergy! < 30) {
                              buyCyberEnergy();
                            } else {
                              //GraphQL:player_matching
                              await gameStart();
                              countdown();
                            }
                          }
                        },
                        tooltip: 'SAVE',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.asset(
                            '${imagePath}button/save.png',
                            fit: BoxFit.cover,
                          ),
                        )))),
            Visibility(
                visible: walletUser.addr != '',
                child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    onPressed: () {},
                    tooltip: 'Reset',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: Image.asset(
                        '${imagePath}button/reset.png',
                        fit: BoxFit.cover,
                      ),
                    ))),
            const SizedBox(width: 25),
          ]))
    ]);
  }
}

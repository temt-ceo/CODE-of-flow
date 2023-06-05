@JS()
library index;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'dart:html' as html;
import 'package:js/js.dart';
import 'package:flutter/material.dart';
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

class StartButtons extends StatefulWidget {
  int gameProgressStatus;
  final StringCallback callback;

  StartButtons(this.gameProgressStatus, this.callback);

  @override
  StartButtonsState createState() => StartButtonsState();
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

class StartButtonsState extends State<StartButtons> {
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
      } else {
        if (player.uuid == '') {
          // Playerリソース未インポート
          if (showBottomSheet == false) {
            setState(() {
              showBottomSheet = true;
            });
            // Playerリソースをインポート
            showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                backgroundColor: const Color.fromARGB(195, 54, 219, 244),
                barrierColor: Colors.transparent,
                builder: (context) {
                  return SizedBox(
                      child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                          child: Column(children: <Widget>[
                            const Text(
                                'プレイヤー名を入力して下さい。\n(Please input a Player Name.)',
                                style: TextStyle(color: Color(0xFFFFFFFF))),
                            const SizedBox(height: 5.0),
                            SizedBox(
                                width: 250.0,
                                child: Focus(
                                  child: TextField(
                                    controller: nameController,
                                    style: const TextStyle(
                                        color: Color(0xFFFFFFFF)),
                                  ),
                                  onFocusChange: (hasFocus) {
                                    setState(() => onTyping = hasFocus);
                                  },
                                )),
                            const SizedBox(height: 60.0),
                            Visibility(
                              visible: onClickButton == true,
                              child: const CircularProgressIndicator(),
                            ),
                            const SizedBox(height: 10.0),
                            Visibility(
                                visible: onTyping == false &&
                                    nameController.text != '',
                                child: Text(
                                  'If you are satisfied with ${nameController.text}, please click the button below.',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 16.0,
                                  ),
                                )),
                            const SizedBox(height: 20.0),
                            Center(
                                child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), //丸み具合
                                  ),
                                ),
                              ),
                              onPressed: onTyping == false &&
                                      nameController.text != ''
                                  ? () {
                                      setState(() => onClickButton = true);
                                      // showGameLoading();
                                      createPlayer(nameController.text);
                                      Future.delayed(
                                          const Duration(seconds: 4000), () {
                                        Navigator.of(context).pop();
                                      });
                                      // setInterval by every 2 second
                                      Timer.periodic(const Duration(seconds: 2),
                                          (timer) {
                                        getPlayerInfo();
                                        if (player.uuid != '') {
                                          timer.cancel();
                                          setState(() => onClickButton = false);
                                          // Navigator.of(context).pop();
                                          widget.callback('game-is-ready', null,
                                              null, null);
                                        }
                                      });
                                    }
                                  : null,
                              child: const Text('Create a Player'),
                            )),
                            const SizedBox(height: 10.0),
                          ])));
                });
          }
        } else {
          // ゲーム状況(Current Status)取得
          dynamic ret =
              await promiseToFuture(getCurrentStatus(walletUser.addr));
          if (ret == null) {
            widget.callback(
                'other-game-info', GameObject.getOtherGameInfo(), null, null);
          } else if (ret.toString().startsWith('1')) {
            double num = double.parse(ret);
            if (num > 1685510325) {
              // debugPrint(
              //     'matching.. ${(timer.tick * 2).toString()}s');
            }
          } else if (ret.game_started == true || ret.game_started == false) {
            if (ret.game_started == false && gameStarted == false) {
              dynamic data = await promiseToFuture(
                  getMariganCards(walletUser.addr, int.parse(player.playerId)));
              widget.callback('matching-success', setGameInfo(ret),
                  setMariganCards(data), null);
              if (dcontext1 != null) {
                Navigator.pop(dcontext1!);
              }
              battleStartAnimation();
            } else if (ret.game_started == true) {
              widget.callback(
                  'started-game-info', setGameInfo(ret), null, null);
            }
            gameStarted = true;
          }
          // 残高を取得
          getBalances();
        }
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

  void getBalances() async {
    if (walletUser.addr != '') {
      // 保有$Flow残高取得
      dynamic ret = await promiseToFuture(getBalance(walletUser.addr,
          player.playerId == '' ? null : int.parse(player.playerId)));
      var objStr = jsonToString(ret);
      var objJs = jsonDecode(objStr);
      var yourInfo = objJs[0];
      setState(() {
        balance = double.parse(yourInfo['balance']);
      });
      setState(() => cyberEnergy = int.parse(yourInfo['cyber_energy']));
      int win = 0;
      for (int i = 0; i < yourInfo['score'].length; i++) {
        if (int.parse(yourInfo['score'][i]) == 1) {
          win++;
        }
      }
      setState(
          () => yourScore = '${yourInfo['score'].length} games ${win} win');

      print(objJs);
    }
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
                      Text(
                          'You currently have ${balance.toString()} FLOW coins.\n By pressing the button, you are asked to pay 1 coin.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16.0)),
                      const SizedBox(height: 8.0),
                      const Text(
                          'Press "Approve" button, then 100 EN will be added.\n But when you won this arcade game, you will get 0.5 FLOW in that time!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16.0)),
                      const SizedBox(height: 4.0),
                      const Text('So you can increase your FLOW coins!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFFFFFFF), fontSize: 16.0)),
                    ])));
          });
    }
  }

  GameObject setGameInfo(obj) {
    var objStr = jsonToString(obj);
    var objJs = jsonDecode(objStr);
    return GameObject(
      int.parse(obj.turn),
      obj.is_first,
      obj.is_first_turn,
      obj.matched_time,
      obj.game_started,
      obj.last_time_turnend,
      obj.enemy_attacking_cards,
      int.parse(player.playerId),
      int.parse(obj.your_cp),
      obj.your_field_unit,
      obj.your_field_unit_action,
      obj.your_field_unit_bp_amount_of_change,
      objJs['your_hand'],
      int.parse(obj.your_life),
      obj.your_remain_deck,
      obj.your_trigger_cards,
      int.parse(obj.opponent),
      int.parse(obj.opponent_cp),
      obj.opponent_field_unit,
      obj.opponent_field_unit_action,
      obj.opponent_field_unit_bp_amount_of_change,
      int.parse(obj.opponent_hand),
      int.parse(obj.opponent_life),
      int.parse(obj.opponent_remain_deck),
      int.parse(obj.opponent_trigger_cards),
    );
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
      Visibility(
          visible: balance != null,
          child: Positioned(
              left: 75,
              top: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: 220.0,
                        child: Text(
                          'Balance：${balance.toString()}',
                          style: const TextStyle(
                              color: Colors.lightGreen, fontSize: 26.0),
                        )),
                    Container(
                        width: 22.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('${imagePath}button/flowLogo.png'),
                              fit: BoxFit.contain),
                        )),
                  ]))),
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
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Text(
          walletUser.addr == ''
              ? 'connect to wallet→'
              : (player.uuid == ''
                  ? 'Address: ${walletUser.addr} '
                  : 'Player: ${player.nickname} '),
          style: const TextStyle(color: Colors.white, fontSize: 26.0),
        ),
        Visibility(
            visible: walletUser.addr == '', child: const SizedBox(width: 20)),
        Visibility(
            visible: walletUser.addr == '',
            child: const FloatingActionButton(
              onPressed: authenticate,
              tooltip: 'Authenticate',
              child: Icon(Icons.key_outlined),
            )),
        Visibility(
            visible: walletUser.addr != '' &&
                player.uuid != '' &&
                gameStarted == false,
            child: SizedBox(
                width: 150.0,
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
                    tooltip: 'Play',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        '${imagePath}button/playButton.png',
                        fit: BoxFit.cover,
                      ),
                    )))),
        Visibility(
            visible: walletUser.addr != '',
            child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                onPressed: () {
                  html.window.location.href = 'deck_edit';
                },
                tooltip: 'Play',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Image.asset(
                    '${imagePath}button/editDeck.png',
                    fit: BoxFit.cover,
                  ),
                ))),
        const SizedBox(width: 5),
        Visibility(
            visible: walletUser.addr != '',
            child: FloatingActionButton(
              onPressed: signout,
              tooltip: 'Sign Out',
              child: const Icon(Icons.logout),
            )),
      ])
    ]);
  }
}

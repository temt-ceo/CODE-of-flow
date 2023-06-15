@JS()
library index;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:js/js.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:quickalert/quickalert.dart';

import 'package:CodeOfFlow/services/api_service.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/components/expandableFAB.dart';
import 'package:CodeOfFlow/components/fabActionButton.dart';

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

@JS('getPlayerDeck')
external dynamic getPlayerDeck(String? address, int playerId);

@JS('jsonToString')
external String jsonToString(dynamic obj);

typedef void StringCallback(String val, String playerId, GameObject? data,
    List<List<int>>? mariganCards, dynamic cardInfo);
typedef double ResponsiveSizeChangeFunction(double data);

class StartButtons extends StatefulWidget {
  int gameProgressStatus;
  final StringCallback callback;
  final bool isEnglish;
  final ResponsiveSizeChangeFunction r;

  StartButtons(this.gameProgressStatus, this.callback, this.isEnglish, this.r);

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
  PlayerResource player = PlayerResource('', '_', '');
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool showBottomSheet = false;
  bool showBottomSheet2 = false;
  bool onTyping = false;
  bool onClickButton = false;
  bool gameStarted = false;
  bool getBalanceFlg = true;
  double imagePosition = 0.0;
  double? balance;
  int? cyberEnergy;
  String yourName = '';
  String yourScore = '';
  String enemyName = '';
  String enemyScore = '';
  BuildContext? dcontext1;
  BuildContext? dcontext2;
  BuildContext? loadingContext;
  BuildContext? loadingContext2;
  BuildContext? loadingContext3;
  bool showCarousel = false;
  bool showCarousel2 = false;
  int activeIndex = 0;
  final cController = CarouselController();
  dynamic cardList;
  List<dynamic> userDeck = [];

  late StreamController<bool> _wait;

  dynamic timerObj = null;
  @override
  void initState() {
    super.initState();
    _wait = StreamController<bool>();
    // setInterval by every 2 second
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      timerObj = timer;
      if (walletUser.addr == '') {
        print('Not Login.');
        widget.callback('other-game-info', player.playerId,
            GameObject.getOtherGameInfo(), null, null);
      } else {
        if (player.playerId == '_') {
          return;
        } else if (player.playerId == '') {
          // Playerリソース未インポート
          if (showBottomSheet == false && mounted) {
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
                builder: (buildContext) {
                  loadingContext2 = buildContext;

                  // プレイヤー名を入力させるダイアログを表示
                  return SizedBox(
                      child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                          child: Column(children: <Widget>[
                            Text(L10n.of(context)!.inputPlayerName,
                                style: const TextStyle(
                                    fontSize: 20.0, color: Color(0xFFFFFFFF))),
                            const SizedBox(height: 5.0),
                            SizedBox(
                              width: 250.0,
                              // child: Focus(
                              child: TextField(
                                controller: nameController,
                                onChanged: (text) {
                                  setState(() => onTyping = text.isNotEmpty);
                                },
                                style:
                                    const TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                              //   onFocusChange: (hasFocus) {
                              //     setState(() => onTyping = hasFocus);
                              //   },
                              // )
                            ),
                            const SizedBox(height: 60.0),
                            Visibility(
                              visible: onClickButton == true,
                              child: const CircularProgressIndicator(),
                            ),
                            const SizedBox(height: 10.0),
                            Visibility(
                                visible: onTyping,
                                child: Text(
                                  L10n.of(context)!
                                      .nameConfirmText(nameController.text),
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
                              onPressed: onTyping
                                  ? () {
                                      setState(() => onClickButton = true);
                                      // showGameLoading();
                                      createPlayer(nameController.text);
                                      Future.delayed(
                                          const Duration(seconds: 4000), () {
                                        if (loadingContext2 != null) {
                                          Navigator.pop(loadingContext2!);
                                        }
                                      });
                                      // setInterval by every 2 second
                                      Timer.periodic(const Duration(seconds: 2),
                                          (timer) {
                                        getPlayerInfo();
                                        if (player.uuid != '') {
                                          timer.cancel();
                                          setState(() => onClickButton = false);
                                          widget.callback(
                                              'game-is-ready',
                                              player.playerId,
                                              null,
                                              null,
                                              null);
                                        }
                                      });
                                    }
                                  : null,
                              child: const Text('Create a Player',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  )),
                            )),
                            const SizedBox(height: 10.0),
                          ])));
                });
          }
        } else {
          if (showBottomSheet == true) {
            showToast('Your Player Name is successfully registered.');
            setState(() {
              showBottomSheet = false;
            });
            if (loadingContext2 != null) {
              Navigator.pop(loadingContext2!);
            }
          }
          // ゲーム状況(Current Status)取得
          dynamic ret =
              await promiseToFuture(getCurrentStatus(walletUser.addr));
          var objStr = jsonToString(ret);
          var objJs = jsonDecode(objStr);
          if (ret == null) {
            widget.callback('other-game-info', player.playerId,
                GameObject.getOtherGameInfo(), null, null);
            gameStarted = false;
            getBalanceFlg = true;
          } else if (ret.toString().startsWith('1')) {
            double num = double.parse(ret);
            if (num > 1685510325) {
              // debugPrint(
              //     'matching.. ${(timer.tick * 2).toString()}s');
            }
            gameStarted = false;
            getBalanceFlg = true;
          } else if (objJs['game_started'] == true ||
              objJs['game_started'] == false) {
            if (objJs['game_started'] == false && gameStarted == false) {
              dynamic data = await promiseToFuture(
                  getMariganCards(walletUser.addr, int.parse(player.playerId)));
              widget.callback('matching-success', player.playerId,
                  setGameInfo(objJs), setMariganCards(data), null);
              if (dcontext1 != null) {
                Navigator.pop(dcontext1!);
              }
              battleStartAnimation();
            } else if (objJs['game_started'] == true) {
              widget.callback('started-game-info', player.playerId,
                  setGameInfo(objJs), null, null);
            }
            gameStarted = true;
          }
          if (getBalanceFlg == true) {
            // 残高を取得
            getBalances();
          }
        }
      }
    });

    // カード情報取得
    getCardInfos();
  }

  void getCardInfos() async {
    // カード情報取得
    try {
      dynamic cardInfo = await promiseToFuture(getCardInfo());
      var objStr = jsonToString(cardInfo);
      var objJs = jsonDecode(objStr);
      setState(() {
        cardList = objJs;
      });
      widget.callback('card-info', player.playerId, null, null, objJs);
    } catch (e) {}
  }

  void getBalances() async {
    getBalanceFlg = false;
    if (walletUser.addr != '') {
      // 保有$Flow残高取得
      dynamic ret = await promiseToFuture(getBalance(walletUser.addr,
          player.playerId == '' ? null : int.parse(player.playerId)));
      var objStr = jsonToString(ret);
      var objJs = jsonDecode(objStr);
      var yourInfo = objJs[0];
      if (mounted) {
        setState(() {
          balance = double.parse(yourInfo['balance']);
        });
        if (cyberEnergy != null &&
            cyberEnergy! < int.parse(yourInfo['cyber_energy'])) {
          showToast('EN is successfull charged.');
          if (loadingContext3 != null) {
            Navigator.pop(loadingContext3!);
          }
        }
        setState(() => cyberEnergy = int.parse(yourInfo['cyber_energy']));
        int win = 0;
        for (int i = 0; i < yourInfo['score'].length; i++) {
          for (final key in yourInfo['score'][i].keys) {
            final value = yourInfo['score'][i][key];
            if (value == '1') {
              win++;
            }
          }
        }
        setState(
            () => yourScore = '${yourInfo['score'].length} games ${win} win');
        setState(() => yourName = yourInfo['player_name']);
        if (gameStarted && objJs.length > 1) {
          var opponentInfo = objJs[1];
          int win2 = 0;
          for (int i = 0; i < opponentInfo['score'].length; i++) {
            for (final key in opponentInfo['score'][i].keys) {
              final value = opponentInfo['score'][i][key];
              if (value == '1') {
                win2++;
              }
            }
          }
          setState(() =>
              enemyScore = '${opponentInfo['score'].length} games ${win2} win');
          setState(() => enemyName = opponentInfo['player_name']);
        }
      }
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
    try {
      if (walletUser.addr == '') {
        String? addr = getAddr(user);
        if (addr == null) {
          setState(() => walletUser = WalletUser(''));
        } else {
          setState(() => walletUser = WalletUser(addr));
          if (player.uuid == '') {
            getPlayerInfo();
            widget.callback('game-is-ready', player.playerId, null, null, null);
          }
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
              title: Text('Oops!'),
              content: Text(
                  'Please reload the browser. Maybe because changing the browser size, something went ..')));
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
      userDeck = await promiseToFuture(
          getPlayerDeck(walletUser.addr, int.parse(playerId!)));
    } else {
      print('Not Imporing.');
      setState(() => player = PlayerResource('', '', ''));
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
    print('Matching Player: ${player.playerId}');
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
                if (snapshot.data == 0 && dcontext1 != null) {
                  Navigator.pop(dcontext1!);
                  showToast('Try Again!');
                }
                String tenStr = '';
                if (snapshot.data != null && snapshot.data! < 10) {
                  tenStr = '0';
                }
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
                      '00:$tenStr${snapshot.data.toString()}',
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
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          backgroundColor: const Color.fromARGB(205, 248, 129, 2),
          barrierColor: Colors.transparent,
          builder: (buildContext) {
            loadingContext3 = buildContext;
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          // showGameLoading();
                          buyCyberEN();
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

  GameObject setGameInfo(objJs) {
    int yourDefendableUnitLength = 0;
    for (int i = 1; i <= int.parse(objJs['your_field_unit_length']); i++) {
      if (objJs['your_field_unit_action'][i.toString()] == '1' ||
          objJs['your_field_unit_action'][i.toString()] == '2') {
        yourDefendableUnitLength++;
      }
    }
    int opponentDefendableUnitLength = 0;
    for (int i = 1; i <= int.parse(objJs['opponent_field_unit_length']); i++) {
      if (objJs['opponent_field_unit_action'][i.toString()] == '1' ||
          objJs['opponent_field_unit_action'][i.toString()] == '2') {
        opponentDefendableUnitLength++;
      }
    }
    return GameObject(
      int.parse(objJs['turn']),
      objJs['is_first'],
      objJs['is_first_turn'],
      objJs['matched_time'],
      objJs['game_started'],
      objJs['last_time_turnend'],
      int.parse(player.playerId),
      int.parse(objJs['your_cp']),
      objJs['your_field_unit'],
      yourDefendableUnitLength,
      opponentDefendableUnitLength,
      objJs['your_field_unit_action'],
      objJs['your_field_unit_bp_amount_of_change'],
      objJs['your_hand'],
      int.parse(objJs['your_life']),
      objJs['your_remain_deck'],
      objJs['your_trigger_cards'],
      int.parse(objJs['opponent']),
      int.parse(objJs['opponent_cp']),
      objJs['opponent_field_unit'],
      objJs['opponent_field_unit_action'],
      objJs['opponent_field_unit_bp_amount_of_change'],
      int.parse(objJs['opponent_hand']),
      int.parse(objJs['opponent_life']),
      int.parse(objJs['opponent_remain_deck']),
      int.parse(objJs['opponent_trigger_cards']),
      objJs['your_attacking_card'],
      objJs['enemy_attacking_card'],
    );
  }

  List<List<int>> setMariganCards(arr) {
    final List<List<int>> retArr = [];
    for (int i = 0; i < 5; i++) {
      retArr.add([]);
      for (int j = 0; j < 4; j++) {
        var card_id = userDeck[int.parse(arr[i][j])];
        retArr[i].add(card_id);
      }
    }
    return retArr;
  }

  void signout() {
    if (gameStarted == true) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.confirm,
          text: 'Do you want to surrender?',
          confirmBtnText: 'Yes',
          cancelBtnText: 'No',
          confirmBtnColor: Colors.blue,
          onConfirmBtnTap: () async {
            showGameLoading();
            var ret = await apiService.saveGameServerProcess(
                'surrender', '', player.playerId);
            closeGameLoading();
            if (ret != null) {
              debugPrint(ret.message);
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'You Lose...',
                text: 'Try Again!',
              );
            }
          });
    } else {
      unauthenticate();
      setState(() => walletUser = WalletUser(''));
      setState(() => player = PlayerResource('', '', ''));
      setState(() => showBottomSheet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    subscribe(allowInterop(setupWallet));

    return Stack(children: <Widget>[
      Visibility(
          visible: balance != null && walletUser.addr != '',
          child: Positioned(
              left: widget.r(75.0),
              top: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                        width: widget.isEnglish
                            ? widget.r(213.0)
                            : widget.r(172.0),
                        child: Text(
                          '${L10n.of(context)!.balance} ${balance.toString()}',
                          style: TextStyle(
                              color: Colors.lightGreen,
                              fontSize: widget.r(26.0)),
                        )),
                    Container(
                        width: widget.r(22.0),
                        height: widget.r(22.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('${imagePath}button/flowLogo.png'),
                              fit: BoxFit.contain),
                        )),
                  ]))),
      Visibility(
          visible: cyberEnergy != null && walletUser.addr != '',
          child: Positioned(
            left: widget.r(75.0),
            top: widget.r(32.0),
            child: SizedBox(
                width: 300.0,
                child: Row(children: <Widget>[
                  Text(
                    'EN:  ',
                    style: TextStyle(
                        color: Color.fromARGB(255, 32, 243, 102),
                        fontSize: widget.r(16.0)),
                  ),
                  Text(
                    '${cyberEnergy.toString()} / 200',
                    style: TextStyle(
                        color: Color.fromARGB(255, 32, 243, 102),
                        fontSize: widget.r(18.0)),
                  ),
                  SizedBox(width: widget.r(20.0)),
                  Visibility(
                      visible: gameStarted != true,
                      child: Text(
                        yourScore,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 247, 245, 245),
                            fontSize: widget.r(18.0)),
                      )),
                ])),
          )),
      Visibility(
        visible: gameStarted == true,
        child: Stack(children: [
          Positioned(
              left: 0.0,
              top: widget.r(82.0),
              child: Text(
                '$enemyName :',
                style: TextStyle(
                    color: const Color.fromARGB(255, 247, 245, 245),
                    fontSize: widget.r(20.0)),
              )),
          Positioned(
            left: widget.r(350.0),
            top: widget.r(82.0),
            child: Text(
              enemyScore,
              style: TextStyle(
                  color: const Color.fromARGB(255, 247, 245, 245),
                  fontSize: widget.r(16.0)),
            ),
          ),
          Positioned(
              left: 0.0,
              top: widget.r(222.0),
              child: Text(
                '$yourName :',
                style: TextStyle(
                    color: const Color.fromARGB(255, 247, 245, 245),
                    fontSize: widget.r(20.0)),
              )),
          Positioned(
            left: widget.r(350.0),
            top: widget.r(222.0),
            child: Text(
              yourScore,
              style: TextStyle(
                  color: const Color.fromARGB(255, 247, 245, 245),
                  fontSize: widget.r(16.0)),
            ),
          ),
        ]),
      ),
      Padding(
          padding: EdgeInsets.only(top: widget.r(5.0)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Visibility(
                visible: gameStarted == false,
                child: Text(
                  walletUser.addr == ''
                      ? 'connect to wallet→'
                      : (player.uuid == ''
                          ? 'Address: ${walletUser.addr} '
                          : 'Hello! ${player.nickname}. Click the button to start the game→'),
                  style:
                      TextStyle(color: Colors.white, fontSize: widget.r(26.0)),
                )),
            Visibility(
                visible: walletUser.addr == '',
                child: SizedBox(width: widget.r(10.0))),
            Visibility(
                visible: walletUser.addr == '',
                child: SizedBox(
                    width: widget.r(50.0),
                    height: widget.r(50.0),
                    child: const FloatingActionButton(
                      onPressed: authenticate,
                      tooltip: 'Authenticate',
                      child: Icon(Icons.key_outlined),
                    ))),
            Visibility(
                visible: walletUser.addr != '' &&
                    player.uuid != '' &&
                    gameStarted == false,
                child: SizedBox(
                    width: widget.r(130.0),
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
                visible: walletUser.addr != '' &&
                    player.uuid != '' &&
                    gameStarted == false,
                child: const SizedBox(width: 8)),
            Visibility(
                visible: walletUser.addr != '' &&
                    player.uuid != '' &&
                    gameStarted == false,
                child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    onPressed: () {
                      html.window.location.href = 'deck_edit';
                    },
                    tooltip: 'Edit your card deck',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.r(40.0)),
                      child: Image.asset(
                        '${imagePath}button/editDeck.png',
                        fit: BoxFit.cover,
                      ),
                    ))),
            const SizedBox(width: 5),
            Visibility(
                visible: walletUser.addr != '',
                child: SizedBox(
                    width: widget.r(40.0),
                    height: widget.r(40.0),
                    child: FloatingActionButton(
                      onPressed: signout,
                      tooltip: gameStarted ? 'Surrender' : 'Sign Out',
                      child: Icon(Icons.logout,
                          color: gameStarted ? Colors.amber : Colors.grey),
                    ))),
            SizedBox(width: widget.r(70)),
          ])),
      Visibility(
          visible: walletUser.addr == '',
          child: Stack(children: <Widget>[
            Positioned(
                left: widget.r(40),
                top: widget.r(30),
                child: CircularPercentIndicator(
                  radius: widget.r(45.0),
                  lineWidth: widget.r(10.0),
                  percent: 0.0,
                  backgroundWidth: 0.0,
                  center: Column(children: <Widget>[
                    SizedBox(height: widget.r(30.0)),
                    Text('${0.0.toString()}%',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: widget.r(22.0),
                        )),
                  ]),
                  progressColor: const Color.fromARGB(255, 6, 178, 246),
                )),
            Positioned(
                left: widget.r(50),
                top: widget.r(220),
                child: ExpandableFAB(distance: widget.r(120), children: [
                  FABActionButton(
                    icon: const Icon(Icons.create, color: Colors.white),
                    onPressed: () {
                      showToast('EN is successfully charged.');
                    },
                  ),
                  FABActionButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        showCarousel2 = true;
                      });
                    },
                  ),
                  FABActionButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        showCarousel = true;
                      });
                      ;
                    },
                  ),
                ])),
            Positioned(
              left: widget.r(168),
              top: widget.r(148),
              child: ExpandableFAB(
                distance: widget.r(120),
                children: [
                  FABActionButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(L10n.of(context)!.tutorial1),
                              content: Text(L10n.of(context)!.tutorial2)));
                    },
                  ),
                  FABActionButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(L10n.of(context)!.tutorial3),
                              content: Text(L10n.of(context)!.tutorial4)));
                    },
                  ),
                  FABActionButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text(L10n.of(context)!.tutorial5),
                              content: Text(L10n.of(context)!.tutorial6)));
                    },
                  ),
                ],
              ),
            ),
            Positioned(
                left: widget.r(240),
                top: widget.r(30),
                child: ExpandableFAB(distance: widget.r(120), children: [
                  FABActionButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text('My Title'),
                              content: Text('jdlskfldsjaldjksdfdslfksa')));
                    },
                  ),
                  FABActionButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text('My Title'),
                              content: Text('jdlskfldsjaldjksdfdslfksa')));
                    },
                  ),
                  FABActionButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                              title: Text('My Title'),
                              content: Text('jdlskfldsjaldjksdfdslfksa')));
                    },
                  ),
                ])),
          ])),
      Visibility(
          visible: walletUser.addr == '' && showCarousel == true,
          child: Stack(children: <Widget>[
            CarouselSlider.builder(
              options: CarouselOptions(
                  height: widget.r(700),
                  aspectRatio: 14 / 9,
                  viewportFraction: 0.75, // 1.0:1つが全体に出る
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.vertical),
              itemCount: 25,
              itemBuilder: (context, index, realIndex) {
                dynamic card = cardList != null
                    ? cardList[index >= 11
                        ? (index + 2).toString()
                        : (index + 1).toString()]
                    : null;
                return buildCarouselImage(index, card);
              },
            ),
            Positioned(
                top: widget.r(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showCarousel = false;
                    });
                  },
                  child: Text('Close',
                      style: TextStyle(
                          color: Colors.black, fontSize: widget.r(28.0))),
                )),
          ])),
      Visibility(
          visible: walletUser.addr == '' && showCarousel2 == true,
          child: Column(children: <Widget>[
            CarouselSlider.builder(
              carouselController: cController,
              options: CarouselOptions(
                  height: widget.r(300),
                  // aspectRatio: 9 / 9,
                  viewportFraction: 0.4, // 1.0:1つが全体に出る
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  }),
              itemCount: 4,
              itemBuilder: (context, index, realIndex) {
                return buildCarouselImage2(index);
              },
            ),
            SizedBox(height: widget.r(32.0)),
            buildIndicator(),
            ElevatedButton(
              onPressed: () => cController.animateToPage(2),
              child: const Text('jump->'),
            ),
          ]))
    ]);
  }

  Widget buildCarouselImage(int index, dynamic card) => Padding(
        padding: EdgeInsets.only(left: widget.r(80.0)),
        child: Row(children: <Widget>[
          card == null
              ? Container()
              : Image.asset(
                  '$imagePath${card['category'] == '0' ? 'unit' : 'trigger'}/card_${card['card_id']}.jpeg',
                  fit: BoxFit.cover,
                ),
          Container(
              color: card == null ? Colors.grey : Colors.white,
              child: card == null
                  ? Container()
                  : Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      defaultColumnWidth: IntrinsicColumnWidth(),
                      children: [
                          buildTableRow(['Name', card['name']], false),
                          buildTableRow([
                            'Card Type',
                            card['category'] == '0'
                                ? 'Unit'
                                : (card['category'] == '1'
                                    ? 'Trigger'
                                    : 'Intercept')
                          ], false),
                          buildTableRow([
                            'BP(Power)',
                            card['bp'] == '0' ? '-' : card['bp']
                          ], false),
                          buildTableRow(['CP(Cost)', card['cost']], false),
                          buildTableRow([
                            'Attribute',
                            card['type'] == '0'
                                ? 'Red'
                                : (card['type'] == '1' ? 'Yellow' : '-')
                          ], false),
                          buildTableRow([
                            'Ability',
                            L10n.of(context)!.cardDescription.split('|')[index]
                          ], true),
                        ]))
        ]),
      );
  TableRow buildTableRow(List<String> cells, bool high) => TableRow(
          children: cells.map((cell) {
        return TableCell(
            child: high && cell != 'Ability'
                ? Center(
                    child: SizedBox(
                        height: widget.r(165.0),
                        width: widget.r(750.0),
                        child: Text(cell,
                            style: TextStyle(fontSize: widget.r(28.0)))))
                : Padding(
                    padding: EdgeInsets.all(widget.r(12)),
                    child: Text(cell,
                        style: TextStyle(fontSize: widget.r(28.0)))));
      }).toList());
  Widget buildCarouselImage2(int index) => Container(
        width: MediaQuery.of(context).size.width,
        // margin: const EdgeInsets.symmetric(horizontal: 1.0),
        color: Colors.grey,
        // child: Text('text $index', style: TextStyle(fontSize: 16.0)),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: 4,
        onDotClicked: (index) {
          cController.animateToPage(index);
        },
        effect: JumpingDotEffect(
          verticalOffset: widget.r(5.0),
          activeDotColor: Colors.orange,
          // dotColor: Colors.black12,
        ),
      );
  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: widget.r(16.0));
  }
}

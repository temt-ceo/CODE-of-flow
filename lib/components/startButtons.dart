@JS()
library index;

import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'dart:html' as html;
import 'package:rxdart/rxdart.dart';
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
  final bool isMobile;

  StartButtons(this.gameProgressStatus, this.callback, this.isEnglish, this.r,
      this.isMobile);

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
  bool registerDoing = false;
  bool showBottomSheet2 = false;
  bool onTyping = false;
  bool getBalanceFlg = true;
  double imagePosition = 0.0;
  double? balance;
  bool gameStarted = false;
  bool wonFlow = false;
  int? cyberEnergy;
  String yourName = '';
  String yourScore = '';
  String enemyName = '';
  String enemyScore = '';
  BuildContext? dcontext1;
  BuildContext? dcontext2;
  BuildContext? loadingContext;
  bool showCarousel = false;
  bool showCarousel2 = false;
  int activeIndex = 0;
  final cController = CarouselController();
  dynamic cardList;
  List<dynamic> userDeck = [];

  late BehaviorSubject<bool> _wait;
  dynamic timerObj = null;

  ////////////////////////////
  ///////  initState   ///////
  ////////////////////////////
  @override
  void initState() {
    super.initState();
    subscribe(allowInterop(setupWallet));

    _wait = BehaviorSubject<bool>();
    // setInterval by every 1 second
    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      timerObj = timer;
      if (walletUser.addr == '') {
        // widget.callback('other-game-info', player.playerId,
        //     GameObject.getOtherGameInfo(), null, null);
      } else {
        if (player.playerId == '_') {
          return;
        } else if (player.playerId == '') {
          // Playerリソース未インポート
          if (showBottomSheet == false && registerDoing == false && mounted) {
            showBottomSheet = true;
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
                              visible: registerDoing == true,
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
                                      registerDoing = true;
                                      Navigator.pop(buildContext);
                                      // showGameLoading();
                                      createPlayer(nameController.text);
                                      // setInterval by every 2 second
                                      Timer.periodic(const Duration(seconds: 2),
                                          (timer) {
                                        getPlayerInfo();
                                        if (player.uuid != '') {
                                          timer.cancel();
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
                }).whenComplete(() {
              showBottomSheet = false;
            });
          }
        } else {
          if (registerDoing == true) {
            showToast('Your Player Name is successfully registered.');
            registerDoing = false;
          }
          // ゲーム状況(Current Status)取得
          dynamic ret =
              await promiseToFuture(getCurrentStatus(walletUser.addr));
          var objStr = jsonToString(ret);
          var objJs = jsonDecode(objStr);
          if (ret == null) {
            widget.callback(
                'not-game-starting', player.playerId, null, null, null);
            setState(() => gameStarted = false);
            getBalanceFlg = true;
          } else if (ret.toString().startsWith('1')) {
            double num = double.parse(ret);
            if (num > 1685510325) {
              // debugPrint(
              //     'matching.. ${(timer.tick * 2).toString()}s');
            }

            widget.callback(
                'not-game-starting', player.playerId, null, null, null);
            setState(() => gameStarted = false);
            getBalanceFlg = true;
          } else if (objJs['game_started'] == true ||
              objJs['game_started'] == false) {
            if (objJs['game_started'] == false && gameStarted == false) {
              getBalanceFlg = true;
              dynamic data = await promiseToFuture(
                  getMariganCards(walletUser.addr, int.parse(player.playerId)));
              widget.callback('matching-success', player.playerId,
                  setGameInfo(objJs), setMariganCards(data), null);
              if (dcontext1 != null) {
                try {
                  Navigator.pop(dcontext1!);
                } catch (e) {
                  debugPrint(e.toString());
                }
              }
              battleStartAnimation();
            } else if (objJs['game_started'] == true) {
              widget.callback('started-game-info', player.playerId,
                  setGameInfo(objJs), null, null);
            }
            setState(() => gameStarted = true);
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

  // カードBP
  String getCardBP(String cardId) {
    if (cardList != null) {
      var cardInfo = cardList[cardId];
      return cardInfo['bp'];
    } else {
      return '';
    }
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
      if (balance != null &&
          balance != double.parse(yourInfo['balance']) &&
          balance! + 0.499 <= double.parse(yourInfo['balance']) &&
          balance! + 0.501 >= double.parse(yourInfo['balance'])) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Congrats!',
          text: 'You won 0.5FLOW!',
        );
        setState(() {
          wonFlow = true;
          balance = double.parse(yourInfo['balance']);
        });
      } else {
        setState(() {
          balance = double.parse(yourInfo['balance']);
        });
      }
      if (cyberEnergy != null &&
          cyberEnergy! < int.parse(yourInfo['cyber_energy'])) {
        showToast('EN is successfully charged.');
      }
      setState(() => cyberEnergy = int.parse(yourInfo['cyber_energy']));
      setState(() => yourScore =
          '${yourInfo['score'].length} games ${yourInfo['win_count']} win');
      setState(() => yourName = yourInfo['player_name']);
      if (gameStarted == true && objJs.length > 1) {
        var opponentInfo = objJs[1];
        setState(() => enemyScore =
            '${opponentInfo['score'].length} games ${opponentInfo['win_count']} win');
        setState(() => enemyName = opponentInfo['player_name']);
      }
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    // cController.dispose();
    // _wait.dispose();
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
    if (walletUser.addr != '') {
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
        debugPrint('Not Imporing.');
        setState(() => player = PlayerResource('', '', ''));
      }
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
    if (widget.isMobile == true) {
      showGameLoading();
      // Call GraphQL method.
      apiService.saveGameServerProcess('player_matching', '', player.playerId);
      await Future.delayed(const Duration(seconds: 2));
      closeGameLoading();
    } else {
      showGameLoading();
      // Call GraphQL method.
      await apiService.saveGameServerProcess(
          'player_matching', '', player.playerId);
      closeGameLoading();
    }
  }

  void countdown() {
    var timerComponent = TimerComponent();
    timerComponent.countdownStart(70, null);
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
      if (mounted) {
        _wait.add(false);
      }
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (dcontext2 != null && mounted) {
        Navigator.pop(dcontext2!);
      }
    });
  }

  // EN購入
  void buyCyberEnergy() {
    if (showBottomSheet2 == false) {
      showBottomSheet2 = true;
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
                          showBottomSheet2 = false;
                          Navigator.pop(buildContext);
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
          }).whenComplete(() {
        showBottomSheet2 = false;
      });
    }
  }

  GameObject setGameInfo(objJs) {
    int yourDefendableUnitLength = 0;
    dynamic yourFiledUnitBps = {};
    dynamic opponentFiledUnitBps = {};
    for (int i = 1; i <= 5; i++) {
      if (objJs['your_field_unit_action'][i.toString()] == '1' ||
          objJs['your_field_unit_action'][i.toString()] == '2') {
        yourDefendableUnitLength++;
      }
      if (objJs['your_field_unit'][i.toString()] != null) {
        var unitBp = getCardBP(objJs['your_field_unit'][i.toString()]);
        if (objJs['your_field_unit_bp_amount_of_change'][i.toString()] ==
            null) {
          yourFiledUnitBps[i.toString()] = int.parse(unitBp);
        } else {
          yourFiledUnitBps[i.toString()] = int.parse(unitBp) +
              int.parse(
                  objJs['your_field_unit_bp_amount_of_change'][i.toString()]);
        }
      }
    }
    int opponentDefendableUnitLength = 0;
    for (int i = 1; i <= 5; i++) {
      if (objJs['opponent_field_unit_action'][i.toString()] == '1' ||
          objJs['opponent_field_unit_action'][i.toString()] == '2') {
        opponentDefendableUnitLength++;
      }
      if (objJs['opponent_field_unit'][i.toString()] != null) {
        var unitBp = getCardBP(objJs['opponent_field_unit'][i.toString()]);
        if (objJs['opponent_field_unit_bp_amount_of_change'][i.toString()] ==
            null) {
          opponentFiledUnitBps[i.toString()] = int.parse(unitBp);
        } else {
          opponentFiledUnitBps[i.toString()] = int.parse(unitBp) +
              int.parse(objJs['opponent_field_unit_bp_amount_of_change']
                  [i.toString()]);
        }
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
      int.parse(objJs['your_dead_count']),
      int.parse(objJs['opponent']),
      int.parse(objJs['opponent_cp']),
      objJs['opponent_field_unit'],
      objJs['opponent_field_unit_action'],
      objJs['opponent_field_unit_bp_amount_of_change'],
      int.parse(objJs['opponent_hand']),
      int.parse(objJs['opponent_life']),
      int.parse(objJs['opponent_remain_deck']),
      int.parse(objJs['opponent_trigger_cards']),
      int.parse(objJs['opponent_dead_count']),
      objJs['your_attacking_card'],
      objJs['enemy_attacking_card'],
      objJs['newly_drawed_cards'],
      yourFiledUnitBps,
      opponentFiledUnitBps,
    );
  }

  List<List<int>> setMariganCards(marignaCardIds) {
    final List<List<int>> retArr = [];
    for (int i = 0; i < 5; i++) {
      retArr.add([]);
      for (int j = 0; j < 4; j++) {
        retArr[i].add(int.parse(marignaCardIds[i][j]));
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
          // autoCloseDuration: const Duration(seconds: 5),
          onConfirmBtnTap: () async {
            Navigator.pop(context);
            if (widget.isMobile == true) {
              apiService.saveGameServerProcess(
                  'surrender', '', player.playerId);
              await Future.delayed(const Duration(seconds: 2));
              showSurrenderedPopup();
            } else {
              // showGameLoading();
              var ret = await apiService.saveGameServerProcess(
                  'surrender', '', player.playerId);
              // closeGameLoading();
              if (ret != null) {
                showSurrenderedPopup();
              }
            }
          });
    } else {
      unauthenticate();
      setState(() => walletUser = WalletUser(''));
      setState(() => player = PlayerResource('', '', ''));
      showBottomSheet = false;
      registerDoing = false;
      cyberEnergy = null;
    }
  }

  void showSurrenderedPopup() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'You Lose...',
      text: 'Try Again!',
    );
  }

  ////////////////////////////
  ///////    build     ///////
  ////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(width: widget.r(310.0)),
        Visibility(
            visible: gameStarted == false,
            child: Padding(
                padding:
                    EdgeInsets.only(right: widget.r(10.0), top: widget.r(7.0)),
                child: Text(
                  walletUser.addr == ''
                      ? 'connect to wallet →'
                      : (player.uuid == '' ? '' : ''),
                  style:
                      TextStyle(color: Colors.white, fontSize: widget.r(26.0)),
                ))),
        Visibility(
            visible: walletUser.addr == '',
            child: Padding(
                padding: EdgeInsets.only(top: widget.r(7.0)),
                child: SizedBox(
                    width: widget.isMobile ? widget.r(45.0) : widget.r(40.0),
                    height: widget.isMobile ? widget.r(45.0) : widget.r(40.0),
                    child: const FittedBox(
                        child: FloatingActionButton(
                      onPressed: authenticate,
                      tooltip: 'Authenticate',
                      child: Icon(Icons.key_outlined),
                    ))))),
        Visibility(
            visible: walletUser.addr != '' &&
                player.uuid != '' &&
                gameStarted == false,
            child: Padding(
                padding: EdgeInsets.only(top: widget.r(10.0)),
                child: SizedBox(
                    width: widget.r(120.0),
                    height: widget.r(50.0),
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
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.asset(
                            width: widget.r(96.0),
                            height: widget.r(40.0),
                            '${imagePath}button/playButton.png',
                          ),
                        ))))),
        Visibility(
            visible: walletUser.addr != '' &&
                player.uuid != '' &&
                gameStarted == false,
            child: SizedBox(width: widget.r(2))),
        Visibility(
            visible: walletUser.addr != '' &&
                player.uuid != '' &&
                gameStarted == false,
            child: Padding(
                padding: EdgeInsets.only(top: widget.r(10.0)),
                child: SizedBox(
                    width: widget.r(40.0),
                    height: widget.r(40.0),
                    child: FittedBox(
                        child: FloatingActionButton(
                            backgroundColor: Colors.transparent,
                            onPressed: () {
                              html.window.location.href = 'deck_edit';
                            },
                            tooltip: 'Edit your card deck',
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(widget.r(10.0)),
                              child: Image.asset(
                                '${imagePath}button/editDeck.png',
                                fit: BoxFit.cover,
                              ),
                            )))))),
        SizedBox(width: widget.r(12)),
        Visibility(
            visible: walletUser.addr != '',
            child: Padding(
                padding:
                    EdgeInsets.only(top: widget.r(16.0), left: widget.r(30.0)),
                child: SizedBox(
                    width: widget.r(30.0),
                    height: widget.r(30.0),
                    child: FittedBox(
                        child: FloatingActionButton(
                      onPressed: signout,
                      tooltip: gameStarted == true ? 'Surrender' : 'Sign Out',
                      child: Icon(Icons.logout,
                          color:
                              gameStarted == true ? Colors.amber : Colors.grey),
                    ))))),
        SizedBox(width: widget.r(85)),
      ]),
      Visibility(
          visible: balance != null && walletUser.addr != '',
          child: Positioned(
              left: widget.r(75.0),
              top: 0,
              child: Stack(children: <Widget>[
                SizedBox(
                    width: widget.r(290.0),
                    child: Text(
                      '${L10n.of(context)!.balance}   ${balance.toString()}${wonFlow ? "(UP!)" : ""}',
                      style: TextStyle(
                          color: wonFlow
                              ? const Color.fromARGB(255, 248, 224, 9)
                              : Colors.lightGreen,
                          fontSize: widget.r(25.0)),
                    )),
                Positioned(
                    left: widget.isEnglish ? widget.r(100.0) : widget.r(60.0),
                    top: widget.isEnglish ? widget.r(6.0) : widget.r(7.0),
                    child: Container(
                        width: widget.r(20.0),
                        height: widget.r(20.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('${imagePath}button/flowLogo.png'),
                              fit: BoxFit.contain),
                        ))),
              ]))),
      Visibility(
          visible: cyberEnergy != null && walletUser.addr != '',
          child: Positioned(
            left: widget.r(75.0),
            top: widget.r(32.0),
            child: SizedBox(
                width: 300.0,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                            fontSize: widget.r(16.0)),
                      ),
                      SizedBox(width: widget.r(20.0)),
                      Visibility(
                          visible: gameStarted != true,
                          child: Text(
                            yourScore,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 247, 245, 245),
                                fontSize: widget.r(16.0)),
                          )),
                    ])),
          )),
      Visibility(
        visible: gameStarted == true,
        child: Stack(children: [
          Positioned(
              left: 0.0,
              top: widget.r(85.0),
              child: Text(
                '$enemyName :',
                style: TextStyle(
                    color: const Color.fromARGB(255, 247, 245, 245),
                    fontSize: widget.r(20.0)),
              )),
          Positioned(
            left: widget.r(295.0),
            top: widget.r(87.0),
            child: Text(
              enemyScore,
              style: TextStyle(
                  color: const Color.fromARGB(255, 247, 245, 245),
                  fontSize: widget.r(16.0)),
            ),
          ),
          // PlayerName
          Positioned(
              left: 0.0,
              top: widget.r(218.0),
              child: Text(
                '$yourName :',
                style: TextStyle(
                    color: const Color.fromARGB(255, 247, 245, 245),
                    fontSize: widget.r(20.0)),
              )),
          Positioned(
            left: widget.r(340.0),
            top: widget.r(220.0),
            child: Text(
              yourScore,
              style: TextStyle(
                  color: const Color.fromARGB(255, 247, 245, 245),
                  fontSize: widget.r(16.0)),
            ),
          ),
        ]),
      ),
      Stack(children: <Widget>[
        Positioned(
            left: widget.r(18),
            top: widget.r(5),
            child:
                ExpandableFAB(distance: widget.r(150), r: widget.r, children: [
              FABActionButton(
                  icon: Icon(Icons.design_services,
                      size: widget.r(20.0), color: Colors.white),
                  onPressed: () {
                    showToast('EN is successfully charged.');
                  },
                  tooltip: 'White Paper'),
              FABActionButton(
                icon: Icon(Icons.how_to_vote,
                    size: widget.r(20.0), color: Colors.white),
                onPressed: () {
                  setState(() {
                    showCarousel2 = true;
                  });
                },
                tooltip: 'How to Play',
              ),
              FABActionButton(
                icon: Icon(Icons.view_carousel_outlined,
                    size: widget.r(20.0), color: Colors.white),
                onPressed: () {
                  setState(() {
                    showCarousel = true;
                  });
                },
                tooltip: 'Card List',
              ),
            ])),
      ]),
      Visibility(
          visible: showCarousel == true,
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
              itemCount: 26,
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
          visible: showCarousel2 == true,
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
            SizedBox(height: widget.r(10.0)),
            ElevatedButton(
              onPressed: () => cController.animateToPage(activeIndex + 1),
              child: const Text('Next->'),
            ),
            SizedBox(height: widget.r(10.0)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showCarousel2 = false;
                });
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)),
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
                            L10n.of(context)!
                                .cardDescription
                                .split('|')[index >= 11 ? index + 1 : index]
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
        backgroundColor: Colors.white,
        textColor: Colors.white,
        fontSize: widget.r(16.0));
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flash/flash.dart';

import 'package:CodeOfFlow/bloc/attack_status/attack_status_bloc.dart';
import 'package:CodeOfFlow/bloc/attack_status/attack_status_event.dart';
import 'package:CodeOfFlow/components/draggableCardWidget.dart';
import 'package:CodeOfFlow/components/dragTargetWidget.dart';
import 'package:CodeOfFlow/components/onGoingGameInfo.dart';
import 'package:CodeOfFlow/components/startButtons.dart';
import 'package:CodeOfFlow/components/timerComponent.dart';
import 'package:CodeOfFlow/components/deckCardInfo.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/putCardModel.dart';
import 'package:CodeOfFlow/models/GameServerProcess.dart';
import 'package:CodeOfFlow/services/api_service.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

class HomePage extends StatefulWidget {
  final bool enLocale;
  const HomePage({super.key, required this.enLocale});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double cardPosition = 0.0;
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  APIService apiService = APIService();
  final AttackStatusBloc attackStatusBloc = AttackStatusBloc();
  GameObject? gameObject;
  List<List<int>> mariganCardList = [];
  int mariganClickCount = 0;
  List<int> handCards = [];
  int gameProgressStatus = 0;
  int? tappedCardId;
  dynamic cardInfos;
  BuildContext? loadingContext;
  int? actedCardPosition;
  int? attackSignalPosition = 0;
  String playerId = '';
  bool canOperate = true;

  @override
  void initState() {
    super.initState();
    // GraphQL Subscription
    listenBCGGameServerProcess();
  }

  void listenBCGGameServerProcess() async {
    GameServerProcess? ret = await apiService.subscribeBCGGameServerProcess();
    if (ret != null) {
      print('$playerId , ${ret.playerId}');
      print(ret.message);
      if (playerId == ret.playerId) {
        if (ret.type == 'player_matching') {
          try {
            String transactionId = ret.message.split(',TransactionID:')[1];
            displayMessage(ret.type,
                "The transaction of Player Matching is in progress.\n ${ret.message.split(',TransactionID:')[1]}");
            await Clipboard.setData(ClipboardData(text: transactionId));
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      } else {
        if (ret.type == 'player_matching') {
          showToast("No. ${ret.playerId} has entered in Alcana. Let's battle!");
        }
      }
      if (ret.type == 'turn_change') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showFlash(
              context: context,
              duration: const Duration(seconds: 4),
              builder: (context, controller) {
                return Flash(
                  controller: controller,
                  position: FlashPosition.bottom,
                  child: FlashBar(
                    controller: controller,
                    title: const Text('Turn Change!'),
                    content: const Text(''),
                    indicatorColor: Colors.blue,
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue,
                    ),
                  ),
                );
              });
        });
      }
    }
  }

  void doAnimation() {
    setState(() => cardPosition = 400.0);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => cardPosition = 0.0);
    });
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

  String getCardInfo(int? cardId) {
    if (cardInfos != null) {
      if (cardInfos[cardId.toString()] != null) {
        String ret = L10n.of(context)!.cardDescription;
        return ret.split('|')[cardId! - 1];
      }
      return '';
    } else {
      return '';
    }
  }

  void tapCard(message, cardId, index) {
    if (message == 'tapped') {
      setState(() {
        tappedCardId = cardId;
      });
    } else if (message == 'attack') {
      setState(() {
        attackSignalPosition = index;
        actedCardPosition = index;
      });
    }
  }

  void putCard(cardId) async {
    // Unit case
    if (cardId > 16) {
      return;
    }
    if (mounted) {
      setState(() {
        gameObject!.yourCp = gameObject!.yourCp -
            int.parse(cardInfos[cardId.toString()]['cost']);
      });
    }

    List<int?> unitPositions = [null, null, null, null, null];
    for (int i = 1; i <= 5; i++) {
      if (gameObject!.yourFieldUnit[i.toString()] == null) {
        unitPositions[i - 1] = cardId;
        // print('フィールド$iにカードを置きました!');
        break;
        // } else {
        //   unitPositions[i - 1] =
        //       int.parse(gameObject!.yourFieldUnit[i.toString()]);
      }
    }
    var objStr2 = jsonToString(gameObject!.yourTriggerCards);
    var objJs2 = jsonDecode(objStr2);
    List<int?> triggerPositions = [null, null, null, null];
    for (int i = 1; i <= 4; i++) {
      if (objJs2[i.toString()] != null) {
        triggerPositions[i - 1] = objJs2[i.toString()];
      }
    }

    FieldUnits fieldUnit = FieldUnits(unitPositions[0], unitPositions[1],
        unitPositions[2], unitPositions[3], unitPositions[4]);
    int enemySkillTarget = 0;
    TriggerCards triggerCards = TriggerCards(triggerPositions[0],
        triggerPositions[1], triggerPositions[2], triggerPositions[3]);
    List<int> usedInterceptCard = [];
    showGameLoading();
    // Call GraphQL method.
    var message = PutCardModel(
        fieldUnit, enemySkillTarget, triggerCards, usedInterceptCard);
    var ret = await apiService.saveGameServerProcess('put_card_on_the_field',
        jsonEncode(message), gameObject!.you.toString());
    closeGameLoading();
    debugPrint('transaction published');
    if (ret != null) {
      debugPrint(ret.message);
    }
  }

  void battleStart() async {
    gameProgressStatus = 2;
    // Call GraphQL method.
    if (gameObject != null) {
      showGameLoading();
      var ret = await apiService.saveGameServerProcess(
          'game_start', jsonEncode(handCards), gameObject!.you.toString());
      closeGameLoading();
      debugPrint('transaction published');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  final _timer = TimerComponent();
  void setDataAndMarigan(GameObject? data, List<List<int>>? mariganCards) {
    if (gameProgressStatus < 2) {
      setState(() => gameProgressStatus = 2); // リロードなどの対応
    }
    if (data != null) {
      if (gameObject != null) {
        if (data.yourCp > gameObject!.yourCp) {
          data.yourCp = gameObject!.yourCp;
        }
      }
      setState(() => gameObject = data);
    }

    // マリガン時のみこちらへ
    if (mariganCards != null) {
      setState(() => mariganCardList = mariganCards!);
      setState(() => mariganClickCount = 0);
      setState(() => handCards = mariganCardList[mariganClickCount]);
      setState(() => gameProgressStatus = 1);
      // Start Marigan.
      _timer.countdownStart(8, battleStart);
    } else {
      // ハンドのブロックチェーンデータとの調整
      List<int> _hand = [];
      for (int i = 1; i <= 7; i++) {
        var cardId = gameObject!.yourHand[i.toString()];
        if (cardId != null) {
          _hand.add(int.parse(cardId));
        }
      }
      setState(() => handCards = _hand);
      if (gameObject!.isFirst == gameObject!.isFirstTurn) {
        if (gameObject!.lastTimeTurnend != null) {
          DateTime lastTurnEndTime = DateTime.fromMillisecondsSinceEpoch(
              double.parse(gameObject!.lastTimeTurnend!).toInt() * 1000);
          final turnEndTime = lastTurnEndTime.add(const Duration(seconds: 65));
          final now = DateTime.now();

          if (turnEndTime.difference(now).inSeconds > 0) {
            attackStatusBloc.canAttackEventSink.add(AttackAllowedEvent());
          } else {
            attackStatusBloc.canAttackEventSink.add(AttackNotAllowedEvent());
          }
        }
      } else {
        attackStatusBloc.canAttackEventSink.add(AttackNotAllowedEvent());
      }
    }
  }

  void setCardInfo(cardInfo) {
    setState(() => cardInfos = cardInfo);
  }

  void setCanOperate(flg) {
    setState(() {
      canOperate = flg;
    });
  }

  void displayMessage(type, transactionId) {
    if (type == 'player_matching') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              // title: const Text('You entered in Alcana.'),
              content: Text('$transactionId (Saved on clipboard.)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (layoutContext, constraints) {
      final wRes = constraints.maxWidth / desktopWidth;
      double r(double val) {
        return val * wRes;
      }

      return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(fit: StackFit.expand, children: <Widget>[
            Positioned(
                left: r(10.0),
                top: r(445.0),
                child: Row(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: r(10.0), top: r(20.0)),
                      child: Container(
                        width: r(300.0),
                        height: r(155.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('${imagePath}unit/bg-2.jpg'),
                              fit: BoxFit.cover),
                        ),
                      )),
                  gameProgressStatus >= 1
                      ? AnimatedContainer(
                          margin: EdgeInsetsDirectional.only(top: cardPosition),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.linear,
                          child: Row(
                            children: [
                              for (var cardId in handCards)
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tappedCardId = cardId;
                                      });
                                    },
                                    child: DragBox(cardId, putCard,
                                        cardInfos[cardId.toString()], r)),
                              SizedBox(width: r(5)),
                            ],
                          ),
                        )
                      : AnimatedContainer(
                          margin: EdgeInsetsDirectional.only(top: cardPosition),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.linear,
                          child: Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tappedCardId = 16;
                                    });
                                  },
                                  child: DragBox(
                                      16,
                                      putCard,
                                      cardInfos != null
                                          ? cardInfos['16']
                                          : null,
                                      r)),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tappedCardId = 17;
                                    });
                                  },
                                  child: DragBox(
                                      17,
                                      putCard,
                                      cardInfos != null
                                          ? cardInfos['17']
                                          : null,
                                      r)),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tappedCardId = 1;
                                    });
                                  },
                                  child: DragBox(
                                      1,
                                      putCard,
                                      cardInfos != null ? cardInfos['1'] : null,
                                      r)),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tappedCardId = 3;
                                    });
                                  },
                                  child: DragBox(
                                      3,
                                      putCard,
                                      cardInfos != null ? cardInfos['3'] : null,
                                      r)),
                              SizedBox(width: r(5)),
                            ],
                          ),
                        ),
                ])),
            Positioned(
                left: r(30.0),
                top: r(30.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            r(150.0), r(200.0), r(30.0), r(5.0)),
                        child: DragTargetWidget(
                            'trigger',
                            '${imagePath}trigger/trigger.png',
                            gameObject,
                            cardInfos,
                            tapCard,
                            actedCardPosition,
                            canOperate,
                            attackStatusBloc.attack_stream,
                            r),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            r(30.0), r(20.0), r(130.0), r(85.0)),
                        child: DragTargetWidget(
                            'unit',
                            '${imagePath}unit/bg-2.jpg',
                            gameObject,
                            cardInfos,
                            tapCard,
                            actedCardPosition,
                            canOperate,
                            attackStatusBloc.attack_stream,
                            r),
                      ),
                    ])),
            Visibility(
                visible: gameProgressStatus == 1,
                child: Positioned(
                    left: r(730),
                    top: r(500),
                    child: SizedBox(
                        width: r(100.0),
                        child: StreamBuilder<int>(
                            stream: _timer.events.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              return Center(
                                  child: Text(
                                '0:0${snapshot.data.toString()}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: r(42.0)),
                              ));
                            })))),
            Visibility(
                visible: mariganClickCount < 5 && gameProgressStatus == 1,
                child: Positioned(
                    left: r(900),
                    top: r(500),
                    child: SizedBox(
                        width: r(100.0),
                        child: FloatingActionButton(
                            backgroundColor: Colors.transparent,
                            onPressed: () {
                              if (mariganClickCount < 5) {
                                setState(() =>
                                    mariganClickCount = mariganClickCount + 1);
                                setState(() => handCards =
                                    mariganCardList[mariganClickCount]);
                              }
                            },
                            tooltip: 'Play',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                '${imagePath}button/redo.png',
                                fit: BoxFit.cover, //prefer cover over fill
                              ),
                            ))))),
            gameObject != null
                ? OnGoingGameInfo(
                    gameObject, getCardInfo(tappedCardId), setCanOperate, r)
                : DeckCardInfo(gameObject, getCardInfo(tappedCardId), 'home'),
            StreamBuilder(
                stream: attackStatusBloc.attack_stream,
                initialData: 0,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return snapshot.data == 1 || snapshot.data == 2
                      ? Positioned(
                          left: r(attackSignalPosition! == 2 ||
                                  attackSignalPosition! == 0
                              ? 760.0
                              : 850.0),
                          top: r(0.0),
                          child: Container(
                            width: r(50.0),
                            height: r(50.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                  opacity: 0.7,
                                  image: AssetImage(
                                      '${imagePath}unit/attackTarget.png'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        )
                      : Container();
                }),
          ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: SizedBox(
              height: r(1000),
              child: StartButtons(gameProgressStatus,
                  (status, _playerId, data, mariganCards, cardInfo) {
                if (playerId != _playerId) {
                  setState(() {
                    playerId = _playerId;
                  });
                }
                switch (status) {
                  case 'game-is-ready':
                    doAnimation();
                    break;
                  case 'matching-success':
                    setDataAndMarigan(data, mariganCards);
                    break;
                  case 'started-game-info':
                    setDataAndMarigan(data, null);
                    break;
                  case 'other-game-info':
                    // setDataAndMarigan(data, null);
                    break;
                  case 'card-info':
                    setCardInfo(cardInfo);
                    break;
                }
              }, widget.enLocale, r)));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.blue,
        fontSize: 22.0,
        webPosition: 'left');
  }
}

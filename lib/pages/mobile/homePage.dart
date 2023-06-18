import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import 'package:amplify_api/amplify_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flash/flash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

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
import 'package:CodeOfFlow/models/defenceActionModel.dart';
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
  String videoPath = envFlavor == 'prod' ? 'assets/video/' : 'video/';
  APIService apiService = APIService();
  final AttackStatusBloc attackStatusBloc = AttackStatusBloc();
  bool gameStarted = false;
  GameObject? gameObject;
  List<List<int>> mariganCardIdList = [];
  int mariganClickCount = 0;
  List<int> handCards = [];
  int gameProgressStatus = 0;
  int? tappedCardId;
  dynamic cardInfos;
  BuildContext? loadingContext;
  int? actedCardPosition;
  int? attackSignalPosition;
  String playerId = '';
  bool canOperate = true;
  final cController = CarouselController();
  int activeIndex = 0;
  bool showDefenceUnitsCarousel = false;
  int? opponentDefendPosition;
  List<int>? yourUsedInterceptCard;
  List<int>? opponentUsedInterceptCard;
  VideoPlayerController? vController;
  bool showVideo = true;

  @override
  void initState() {
    super.initState();
    // GraphQL Subscription
    listenBCGGameServerProcess();
    _initVideoPlayer();
  }

  void listenBCGGameServerProcess() async {
    Stream<GraphQLResponse<GameServerProcess>> operation =
        apiService.subscribeBCGGameServerProcess();
    operation.listen(
      (event) {
        print('*** Subscription event data received: ${event.data}');
        var ret = event.data;
        if (ret != null) {
          print('No. ${ret.playerId} : ${ret.type}');
          print(ret.message);
          if (ret.type == 'player_matching' && playerId == ret.playerId) {
            String transactionId = ret.message.split(',TransactionID:')[1];
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
                        title: const Text('Player Matching is in progress.'),
                        content: Text('Transaction ID: $transactionId'),
                        indicatorColor: Colors.blue,
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  });
            });
          } else if (ret.type == 'player_matching') {
            showToast(
                "No. ${ret.playerId} has entered in Alcana. Let's battle!");
          } else if (ret.type == 'turn_change' &&
              gameObject != null &&
              (gameObject!.you.toString() == ret.playerId ||
                  gameObject!.opponent.toString() == ret.playerId)) {
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
                        content: const Text('Turn Change!',
                            style: TextStyle(fontSize: 24.0)),
                        indicatorColor: Colors.blue,
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  });
            });
          } else if (ret.type == 'attack' &&
              gameObject != null &&
              (gameObject!.you.toString() == ret.playerId)) {
            attackStatusBloc.canAttackEventSink.add(BattlingEvent());
          } else if (ret.type == 'attack' &&
              gameObject != null &&
              (gameObject!.opponent.toString() == ret.playerId)) {
            showDefenceUnitsCarousel = true;
            attackStatusBloc.canAttackEventSink.add(BattlingEvent());
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
                        title: Text(L10n.of(context)!.opponentAttack),
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
          } else if (ret.type == 'battle_reaction' &&
              gameObject != null &&
              (gameObject!.you.toString() == ret.playerId ||
                  gameObject!.opponent.toString() == ret.playerId)) {
            attackStatusBloc.canAttackEventSink.add(BattlingEvent());
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
                        title: Text(L10n.of(context)!.opponentBlocking),
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
          } else if (ret.type == 'defence_action' &&
              gameObject != null &&
              (gameObject!.you.toString() == ret.playerId ||
                  gameObject!.opponent.toString() == ret.playerId)) {
            attackStatusBloc.canAttackEventSink.add(BattleFinishedEvent());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  attackSignalPosition = null;
                  actedCardPosition = null;
                });
              }
            });
          }
        }
      },
      onError: (Object e) => debugPrint('Error in subscription stream: $e'),
    );
  }

  void _initVideoPlayer() async {
    vController = VideoPlayerController.asset('${videoPath}sample-5s.mp4');
    Future.delayed(const Duration(seconds: 1), () async {
      // await vController!.initialize();
      // // Ensuring the first frame is shown after the video is initialized.
      // setState(() {});
      // vController!.setVolume(0);
      // vController!.play();
      Future.delayed(const Duration(seconds: 5), () async {
        setState(() => showVideo = false);
      });
    });
  }

  void block(int activeIndex) async {
    setState(() {
      showDefenceUnitsCarousel = false;
      opponentDefendPosition = activeIndex + 1;
      yourUsedInterceptCard = [];
      opponentUsedInterceptCard = [];
    });
    // Battle Reaction
    showGameLoading();
    var message = DefenceActionModel(opponentDefendPosition!,
        yourUsedInterceptCard!, opponentUsedInterceptCard!);
    var ret = await apiService.saveGameServerProcess(
        'battle_reaction', jsonEncode(message), gameObject!.you.toString());
    closeGameLoading();
    debugPrint('== transaction published ==');
    debugPrint('== ${ret.toString()} ==');
    if (ret != null) {
      debugPrint(ret.message);
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

  String getCardName(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['name'];
    } else {
      return '';
    }
  }

  String getCardBP(String cardId) {
    if (cardInfos != null) {
      var cardInfo = cardInfos[cardId];
      return cardInfo['bp'];
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
    if (gameObject == null) return;
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
                  content: const Text('Game Start.',
                      style: TextStyle(fontSize: 24.0)),
                  indicatorColor: Colors.blue,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                  ),
                ),
              );
            });
      });
      debugPrint('transaction published');
      if (ret != null) {
        debugPrint(ret.message);
      }
    }
  }

  final _timer = TimerComponent();
  void setDataAndMarigan(GameObject? data, List<List<int>>? mariganCardIds) {
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
    if (mariganCardIds != null) {
      setState(() => mariganCardIdList = mariganCardIds);
      setState(() => mariganClickCount = 0);
      setState(() => handCards = mariganCardIdList[mariganClickCount]);
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
            attackStatusBloc.canAttackEventSink.add(AttackAllowedEvent());
          }
        }
      } else {
        attackStatusBloc.canAttackEventSink.add(AttackAllowedEvent());
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
                left: r(320.0),
                top: r(445.0),
                child: Row(children: <Widget>[
                  gameProgressStatus >= 1 && gameStarted
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
            gameObject != null && gameStarted == true
                ? OnGoingGameInfo(
                    gameObject,
                    getCardInfo(tappedCardId),
                    setCanOperate,
                    attackStatusBloc.attack_stream,
                    opponentDefendPosition,
                    yourUsedInterceptCard,
                    opponentUsedInterceptCard,
                    actedCardPosition,
                    cardInfos,
                    r)
                : DeckCardInfo(gameObject, cardInfos, tappedCardId, 'home',
                    widget.enLocale, r),
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
                            const [],
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
                            const [],
                            r),
                      ),
                    ])),
            Visibility(
                visible: gameProgressStatus == 1,
                child: Positioned(
                    left: r(800),
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
                                    mariganCardIdList[mariganClickCount]);
                              }
                            },
                            tooltip: 'Redraw',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                '${imagePath}button/redo.png',
                                fit: BoxFit.cover, //prefer cover over fill
                              ),
                            ))))),
            Visibility(
                visible: attackSignalPosition != null,
                child: Positioned(
                  left: r(attackSignalPosition != null &&
                          (attackSignalPosition! == 2 ||
                              attackSignalPosition! == 0)
                      ? 760.0
                      : 850.0),
                  top: r(-2.0),
                  child: Container(
                    width: r(75.0),
                    height: r(75.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                          opacity: 0.7,
                          image:
                              AssetImage('${imagePath}unit/attackTarget.png'),
                          fit: BoxFit.cover),
                    ),
                  ),
                )),
            Positioned(
              left: r(648.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 1st Unit Name
            Positioned(
                left: r(650.0),
                top: r(157.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['1'] != null
                        ? (gameObject!.opponentFieldUnitAction['1'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 1st Unit BP
            Positioned(
                left: r(650.0),
                top: r(179.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['1'] != null
                        ? (gameObject!.opponentFieldUnitAction['1'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['1'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(783.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 2st Unit Name
            Positioned(
                left: r(785.0),
                top: r(157.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['2'] != null
                        ? (gameObject!.opponentFieldUnitAction['2'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 2st Unit BP
            Positioned(
                left: r(785.0),
                top: r(179.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['2'] != null
                        ? (gameObject!.opponentFieldUnitAction['2'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['2'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(918.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 3st Unit Name
            Positioned(
                left: r(920.0),
                top: r(157.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['3'] != null
                        ? (gameObject!.opponentFieldUnitAction['3'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 3st Unit BP
            Positioned(
                left: r(920.0),
                top: r(179.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['3'] != null
                        ? (gameObject!.opponentFieldUnitAction['3'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['3'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1053.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 4st Unit Name
            Positioned(
                left: r(1055.0),
                top: r(157.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['4'] != null
                        ? (gameObject!.opponentFieldUnitAction['4'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 4st Unit BP
            Positioned(
                left: r(1055.0),
                top: r(179.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['4'] != null
                        ? (gameObject!.opponentFieldUnitAction['4'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['4'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1188.0),
              top: r(154.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Enemy's 5st Unit Name
            Positioned(
                left: r(1190.0),
                top: r(157.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['5'] != null
                        ? (gameObject!.opponentFieldUnitAction['5'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.opponentFieldUnit['5'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Enemy's 5st Unit BP
            Positioned(
                left: r(1190.0),
                top: r(179.0),
                width: r(80.0),
                child: Text(
                    gameObject != null &&
                            gameObject!.opponentFieldUnit['5'] != null
                        ? (gameObject!.opponentFieldUnitAction['5'] == '1' ||
                                    gameObject!.opponentFieldUnitAction['5'] ==
                                        '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.opponentFieldUnit['5'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(648.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 1st Unit Name
            Positioned(
                left: r(650.0),
                top: r(383.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['1'] != null
                        ? (gameObject!.yourFieldUnitAction['1'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 1st Unit BP
            Positioned(
                left: r(650.0),
                top: r(405.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['1'] != null
                        ? (gameObject!.yourFieldUnitAction['1'] == '1' ||
                                    gameObject!.yourFieldUnitAction['1'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['1'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(783.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 2st Unit Name
            Positioned(
                left: r(785.0),
                top: r(383.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['2'] != null
                        ? (gameObject!.yourFieldUnitAction['2'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 2st Unit BP
            Positioned(
                left: r(785.0),
                top: r(405.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['2'] != null
                        ? (gameObject!.yourFieldUnitAction['2'] == '1' ||
                                    gameObject!.yourFieldUnitAction['2'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['2'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(918.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 3st Unit Name
            Positioned(
                left: r(920.0),
                top: r(383.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['3'] != null
                        ? (gameObject!.yourFieldUnitAction['3'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 3st Unit BP
            Positioned(
                left: r(920.0),
                top: r(405.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['3'] != null
                        ? (gameObject!.yourFieldUnitAction['3'] == '1' ||
                                    gameObject!.yourFieldUnitAction['3'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['3'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1053.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 4st Unit Name
            Positioned(
                left: r(1055.0),
                top: r(383.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['4'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 4st Unit BP
            Positioned(
                left: r(1055.0),
                top: r(405.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['4'] == '1' ||
                                    gameObject!.yourFieldUnitAction['4'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Positioned(
              left: r(1188.0),
              top: r(380.0),
              child: Container(
                width: r(90.0),
                height: r(50.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('${imagePath}unit/status.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            // Your 5st Unit Name
            Positioned(
                left: r(1190.0),
                top: r(383.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['5'] == '2'
                                ? '🗡️'
                                : '　') +
                            getCardName(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            // Your 5st Unit BP
            Positioned(
                left: r(1190.0),
                top: r(405.0),
                width: r(80.0),
                child: Text(
                    gameObject != null && gameObject!.yourFieldUnit['4'] != null
                        ? (gameObject!.yourFieldUnitAction['5'] == '1' ||
                                    gameObject!.yourFieldUnitAction['5x'] == '2'
                                ? '🛡️'
                                : '　') +
                            getCardBP(gameObject!.yourFieldUnit['4'])
                        : '',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: r(16.0),
                    ))),
            Visibility(
                visible: showDefenceUnitsCarousel == true,
                child: Column(children: <Widget>[
                  CarouselSlider.builder(
                    carouselController: cController,
                    options: CarouselOptions(
                        height: r(400),
                        // aspectRatio: 9 / 9,
                        viewportFraction: 1, // 1.0:1つが全体に出る
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          setState(() {
                            activeIndex = index;
                          });
                        }),
                    itemCount: gameObject == null
                        ? 0
                        : gameObject!.yourDefendableUnitLength,
                    itemBuilder: (context, index, realIndex) {
                      var cardId =
                          gameObject!.yourFieldUnit[(index + 1).toString()];
                      return Image.asset(
                        '${imagePath}unit/card_$cardId.jpeg',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  SizedBox(height: r(32.0)),
                  buildIndicator(),
                  ElevatedButton(
                    onPressed: () => block(activeIndex),
                    child: const Text('Block'),
                  ),
                ])),
            Visibility(
                visible: showVideo == true,
                child: Center(
                  child: vController != null && vController!.value.isInitialized
                      ? Padding(
                          padding: EdgeInsets.all(r(60.0)),
                          child: AspectRatio(
                            aspectRatio: vController!.value.aspectRatio,
                            child: VideoPlayer(vController!),
                          ))
                      : Container(),
                )),
          ]),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: SizedBox(
              height: r(1000),
              child: StartButtons(gameProgressStatus,
                  (status, _playerId, data, mariganCardIds, cardInfo) {
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
                    setState(() => gameStarted = true);
                    debugPrint('playerId: $playerId $status');
                    setDataAndMarigan(data, mariganCardIds);
                    break;
                  case 'started-game-info':
                    setState(() => gameStarted = true);
                    setDataAndMarigan(data, null);
                    break;
                  case 'not-game-starting':
                    setState(() => gameStarted = false);
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
        textColor: Colors.white,
        fontSize: 22.0,
        webPosition: 'left');
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: gameObject == null ? 0 : gameObject!.yourDefendableUnitLength,
        onDotClicked: (index) {
          cController.animateToPage(index);
        },
        effect: const JumpingDotEffect(
          verticalOffset: 4.0,
          activeDotColor: Colors.orange,
          // dotColor: Colors.black12,
        ),
      );
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flash/flash.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/TurnEndModel.dart';
import 'package:CodeOfFlow/models/defenceActionModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');
typedef void TimeupCallback(bool isOver);
typedef double ResponsiveSizeChangeFunction(double data);

class OnGoingGameInfo extends StatefulWidget {
  final GameObject? info;
  final TimeupCallback setCanOperate;
  final Stream<int> attack_stream;
  final int? opponentDefendPosition;
  final List<int> attackerUsedInterceptCard;
  final List<int> defenderUsedInterceptCard;
  final String yourBattleCardId;
  final String opponentBattleCardId;
  final dynamic cardInfos;
  final List<int?> currentTriggerCards;
  final bool? isEnemyAttack;
  final List<int> attackerUsedCardIds;
  final List<int> defenderUsedCardIds;
  final ResponsiveSizeChangeFunction r;
  final bool isMobile;

  OnGoingGameInfo(
      this.info,
      this.setCanOperate,
      this.attack_stream,
      this.opponentDefendPosition,
      this.attackerUsedInterceptCard,
      this.defenderUsedInterceptCard,
      this.yourBattleCardId,
      this.opponentBattleCardId,
      this.cardInfos,
      this.currentTriggerCards,
      this.isEnemyAttack,
      this.attackerUsedCardIds,
      this.defenderUsedCardIds,
      this.r,
      this.isMobile);

  @override
  OnGoingGameInfoState createState() => OnGoingGameInfoState();
}

class OnGoingGameInfoState extends State<OnGoingGameInfo> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  APIService apiService = APIService();
  BuildContext? loadingContext;
  late DateTime lastTurnEndTime;
  double percentIndicatorValue = 1.0;
  String percentIndicatorValueStr = '60';
  bool canTurnEnd = true;
  int turn = 0;
  bool isFirst = false;
  bool isFirstTurn = false;
  DateTime? battleReactionUpdateTime;
  int? reactionLimitTime;
  bool apiCalled = false;
  String flashMsg = '';

  ////////////////////////////
  ///////  initState   ///////
  ////////////////////////////
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
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
    try {
      if (loadingContext != null) {
        Navigator.of(loadingContext!, rootNavigator: true).pop();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Turn End
  void turnEnd(fromOpponent) async {
    // showGameLoading();
    var message;
    if (widget.currentTriggerCards.isEmpty || fromOpponent) {
      TriggerCards triggerCards = TriggerCards(null, null, null, null);
      message = TurnEndModel(fromOpponent, triggerCards);
    } else {
      TriggerCards triggerCards = TriggerCards(
          widget.currentTriggerCards[0],
          widget.currentTriggerCards[1],
          widget.currentTriggerCards[2],
          widget.currentTriggerCards[3]);
      message = TurnEndModel(fromOpponent, triggerCards);
    }
    if (fromOpponent == false) {
      showMessage(3, 'ok, the turn will soon change.', null);
    }
    await apiService.saveGameServerProcess(
        'turn_change',
        jsonEncode(message),
        fromOpponent
            ? widget.info!.opponent.toString()
            : widget.info!.you.toString());
    // closeGameLoading();
  }

  void showMessage(int second, String content, String? title) {
    try {
      showFlash(
          context: context,
          duration: Duration(seconds: second),
          builder: (context, controller) {
            return Flash(
              controller: controller,
              position: FlashPosition.bottom,
              child: FlashBar(
                controller: controller,
                content:
                    Text(content, style: TextStyle(fontSize: widget.r(20.0))),
                indicatorColor: Colors.blue,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.blue,
                ),
              ),
            );
          });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Defence Action
  void defenceActionDecision(DateTime? battleStartTime, DateTime now) {
    flashMsg = '';
    if (widget.opponentBattleCardId != '' && widget.yourBattleCardId != '') {
      flashMsg = widget.cardInfos[widget.yourBattleCardId]['name'] +
          ' VS ' +
          widget.cardInfos[widget.opponentBattleCardId]['name'];
    }
    // 15秒経過時は判定処理へ
    if (battleStartTime != null &&
        now.difference(battleStartTime).inSeconds > 15) {
      battleResultDecided();
      battleReactionUpdateTime = null;
    } else if (battleReactionUpdateTime != null &&
        now.difference(battleReactionUpdateTime!).inSeconds > 0) {
      reactionLimitTime =
          7 - now.difference(battleReactionUpdateTime!).inSeconds;
      if (reactionLimitTime != null && reactionLimitTime! < 0) {
        // 時間制限を超えた場合、バトル判定処理実行へ
        battleResultDecided();
        battleReactionUpdateTime = null;
      }
    }
  }

  void battleResultDecided() async {
    // 攻められる側またはリロードの跡がなければ実行
    if (widget.isEnemyAttack != null ||
        widget.info!.isFirst != widget.info!.isFirstTurn) {
      if (apiCalled == false) {
        apiCalled = true;
        debugPrint('===↓↓↓ defence_action ↓↓↓===');

        var message = DefenceActionModel(
            widget.opponentDefendPosition,
            widget.attackerUsedInterceptCard,
            widget.defenderUsedInterceptCard,
            widget.attackerUsedCardIds,
            widget.defenderUsedCardIds);
        if (widget.isMobile == true) {
          apiService.saveGameServerProcess('defence_action',
              jsonEncode(message), widget.info!.you.toString());
          await Future.delayed(const Duration(seconds: 1));
          showMessage(
              7,
              widget.opponentDefendPosition == null
                  ? 'Player Damage!'
                  : 'Battle!! $flashMsg',
              'Please wait until the transaction is complete.');
        } else {
          await apiService.saveGameServerProcess('defence_action',
              jsonEncode(message), widget.info!.you.toString());
          showMessage(
              7,
              widget.opponentDefendPosition == null
                  ? 'Player Damage!'
                  : 'Battle!! $flashMsg',
              'Please wait until the transaction is complete.');
        }
      }
    }
  }

  ////////////////////////////
  ///////    build     ///////
  ////////////////////////////
  @override
  Widget build(BuildContext context) {
    // ターン、先行後攻、現在は先行のターンか
    if (turn != widget.info!.turn) {
      setState(() {
        turn = widget.info!.turn;
      });
    }
    if (isFirst != widget.info!.isFirst) {
      setState(() {
        isFirst = widget.info!.isFirst;
      });
    }
    if (isFirstTurn != widget.info!.isFirstTurn) {
      setState(() {
        isFirstTurn = widget.info!.isFirstTurn;
      });
    }

    // ===============
    // === 判定開始 ===
    // ===============
    // 残り時間
    if (widget.info!.lastTimeTurnend != null) {
      lastTurnEndTime = DateTime.fromMillisecondsSinceEpoch(
          double.parse(widget.info!.lastTimeTurnend!).toInt() * 1000);
      var turnEndTime = lastTurnEndTime.add(const Duration(seconds: 65));
      final now = DateTime.now();
      DateTime? battleStartTime;

      // バトル中ならそれ以前の時間まで止める
      var attackedTime;
      if (widget.info!.yourAttackingCard != null) {
        attackedTime = widget.info!.yourAttackingCard['attacked_time'];
      } else if (widget.info!.enemyAttackingCard != null) {
        attackedTime = widget.info!.enemyAttackingCard['attacked_time'];
      }
      if (attackedTime != null) {
        battleStartTime = DateTime.fromMillisecondsSinceEpoch(
            double.parse(attackedTime).toInt() * 1000);
        if (now.difference(battleStartTime).inSeconds > 0) {
          turnEndTime = turnEndTime.add(
              Duration(seconds: now.difference(battleStartTime).inSeconds));
        }
      }
      defenceActionDecision(battleStartTime, now);

      if (turnEndTime.difference(now).inSeconds <= 0) {
        // ０になった後、6秒経過して10秒おきにターンが終わっていない場合も実施
        if (turnEndTime.difference(now).inSeconds == -6 ||
            turnEndTime.difference(now).inSeconds % 10 == 6) {
          // 対戦相手側の画面で実施(こちら側はターン終了ボタンがあるので)
          if (widget.info!.isFirst != widget.info!.isFirstTurn) {
            if (canTurnEnd == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                turnEnd(true);
              });
            }
            setState(() {
              canTurnEnd = false;
            });
          }
        }
        setState(() {
          percentIndicatorValue = 0.0;
          percentIndicatorValueStr = '0';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.setCanOperate(false);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.setCanOperate(true);
        });
        var displayValue = turnEndTime.difference(now).inSeconds / 60;
        setState(() {
          percentIndicatorValue = displayValue > 1 ? 1 : displayValue;
          percentIndicatorValueStr = displayValue > 1
              ? '60'
              : turnEndTime.difference(now).inSeconds.toString();
        });
        if (widget.info!.isFirst == widget.info!.isFirstTurn) {
          setState(() {
            canTurnEnd = true;
          });
          // }
        } else {
          setState(() {
            canTurnEnd = true;
          });
        }
      }
    }

    return StreamBuilder(
        stream: widget.attack_stream,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          // バトルリアクション時間更新
          if (snapshot.data == 2) {
            battleReactionUpdateTime = DateTime.now();
          }
          // バトル終了時刻検知
          if (snapshot.data == 3) {
            battleResultDecided();
          }
          if (snapshot.data == 4) {
            apiCalled = false;
          }

          return Stack(children: <Widget>[
            Positioned(
                left: widget.r(172.0),
                top: widget.r(70.0),
                child: Text(
                    '(Life ${widget.info != null ? (widget.info!.opponentLife < 10 ? '0${widget.info!.opponentLife}' : widget.info!.opponentLife) : '--'})',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(12.0),
                    ))),
            // EnemyLife
            Stack(children: <Widget>[
              for (var i = 0; i < widget.info!.opponentLife; i++)
                Positioned(
                  left: widget.r(170.0 + i * 19),
                  top: widget.r(90.0),
                  child: Container(
                    width: widget.r(18.0),
                    height: widget.r(18.0),
                    decoration: envFlavor == 'prod'
                        ? (widget.isMobile == true
                            ? const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/enemyLife.png'),
                                    fit: BoxFit.cover),
                              )
                            : const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/enemyLife.png'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow,
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(
                                        1, 1), // changes position of shadow
                                  ),
                                ],
                              ))
                        : const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('image/button/enemyLife.png'),
                                fit: BoxFit.cover),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow,
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset:
                                    Offset(1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                  ),
                ),
            ]),

            Positioned(
                left: widget.r(85.0),
                top: widget.r(120.0),
                child: Text(
                    'CP ${widget.info != null ? (widget.info!.opponentCp < 10 ? '0${widget.info!.opponentCp}' : widget.info!.opponentCp) : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            // EnemyCP
            Stack(children: <Widget>[
              for (var i = 0; i < widget.info!.opponentCp; i++)
                Positioned(
                  left: widget.r(172.0 + i * 16),
                  top: widget.r(128.0),
                  child: Container(
                    width: widget.r(15.0),
                    height: widget.r(15.0),
                    decoration: envFlavor == 'prod'
                        ? (widget.isMobile == true
                            ? const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/cp.png'),
                                    fit: BoxFit.cover),
                              )
                            : const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/cp.png'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow,
                                    blurRadius: 1, // changes position of shadow
                                  ),
                                ],
                              ))
                        : const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('image/button/cp.png'),
                                fit: BoxFit.cover),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.yellow,
                                  spreadRadius: 1,
                                  blurRadius: 1 // changes position of shadow
                                  ),
                            ],
                          ),
                  ),
                ),
            ]),
            Positioned(
                left: widget.r(360.0),
                top: widget.r(130.0),
                child: Text(
                    'Dead ${widget.info != null ? widget.info!.opponentDeadCount : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(16.0),
                    ))),
            Positioned(
                left: widget.r(360.0),
                top: widget.r(160.0),
                child: Text(
                    'Deck ${widget.info != null ? widget.info!.opponentRemainDeck : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(16.0),
                    ))),
            Positioned(
                left: widget.r(85.0),
                top: widget.r(155.0),
                child: Text('Hand',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            // EnemyHand
            Stack(children: <Widget>[
              for (var i = 0; i < widget.info!.opponentHand; i++)
                Positioned(
                  left: widget.r(170.0 + i * 21),
                  top: widget.r(158.0),
                  child: Container(
                    width: widget.r(20.0),
                    height: widget.r(20.0),
                    decoration: envFlavor == 'prod'
                        ? (widget.isMobile == true
                            ? const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/enemyHand.png'),
                                    fit: BoxFit.cover),
                              )
                            : const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/enemyHand.png'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 41, 39, 176),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(
                                        1, 1), // changes position of shadow
                                  ),
                                ],
                              ))
                        : const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('image/button/enemyHand.png'),
                                fit: BoxFit.cover),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 41, 39, 176),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset:
                                    Offset(1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                  ),
                ),
            ]),
            for (var i = 0; i < widget.info!.opponentTriggerCards; i++)
              Positioned(
                left: widget.r(471.0 + i * 31),
                top: widget.r(93.0),
                child: Container(
                  width: widget.r(27.0),
                  height: widget.r(27.0),
                  decoration: envFlavor == 'prod'
                      ? (widget.isMobile == true
                          ? const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/image/button/enemyHand.png'),
                                  fit: BoxFit.cover),
                            )
                          : const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/image/button/enemyHand.png'),
                                  fit: BoxFit.cover),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 41, 39, 176),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(
                                      1, 1), // changes position of shadow
                                ),
                              ],
                            ))
                      : const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('image/button/enemyHand.png'),
                              fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 41, 39, 176),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset:
                                  Offset(1, 1), // changes position of shadow
                            ),
                          ],
                        ),
                ),
              ),
            Positioned(
                left: widget.r(172.0),
                top: widget.r(196.0),
                child: Text(
                    '(Life ${widget.info != null ? (widget.info!.yourLife < 10 ? '0${widget.info!.yourLife}' : widget.info!.yourLife) : '--'})',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(15.0),
                    ))),
            // YourLife
            Stack(children: <Widget>[
              for (var i = 0; i < widget.info!.yourLife; i++)
                Positioned(
                  left: widget.r(170.0 + i * 24),
                  top: widget.r(220.0),
                  child: Container(
                    width: widget.r(23.0),
                    height: widget.r(23.0),
                    decoration: envFlavor == 'prod'
                        ? widget.isMobile == true
                            ? const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/yourLife.png'),
                                    fit: BoxFit.cover))
                            : const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/yourLife.png'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 41, 39, 176),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(
                                        1, 1), // changes position of shadow
                                  ),
                                ],
                              )
                        : const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('image/button/yourLife.png'),
                                fit: BoxFit.cover),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 41, 39, 176),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset:
                                    Offset(1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                  ),
                )
            ]),
            Positioned(
                left: widget.r(95.0),
                top: widget.r(248.0),
                child: Text(
                    'CP ${widget.info != null ? (widget.info!.yourCp < 10 ? '0${widget.info!.yourCp}' : widget.info!.yourCp) : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(24.0),
                    ))),
            // YourCP
            Stack(children: <Widget>[
              for (var i = 0; i < widget.info!.yourCp; i++)
                Positioned(
                  left: widget.r(184.0 + i * 26),
                  top: widget.r(252.0),
                  child: Container(
                    width: widget.r(25.0),
                    height: widget.r(25.0),
                    decoration: envFlavor == 'prod'
                        ? (widget.isMobile == true
                            ? const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/cp.png'),
                                    fit: BoxFit.cover),
                              )
                            : const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/image/button/cp.png'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow,
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(
                                        1, -1), // changes position of shadow
                                  ),
                                ],
                              ))
                        : const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('image/button/cp.png'),
                                fit: BoxFit.cover),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow,
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset:
                                    Offset(1, -1), // changes position of shadow
                              ),
                            ],
                          ),
                  ),
                ),
            ]),
            Positioned(
                left: widget.r(1255.0),
                top: widget.r(450.0),
                child: Text(
                    'Deck ${widget.info != null ? (widget.info!.gameStarted ? widget.info!.yourRemainDeck.length : 30) : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            Positioned(
                left: widget.r(1255.0),
                top: widget.r(490.0),
                child: Text(
                    'Dead ${widget.info != null ? widget.info!.yourDeadCount : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            Positioned(
                right: widget.r(60.0),
                top: widget.r(-3.0),
                child: Text(
                    'Round $turn : ${isFirstTurn ? L10n.of(context)!.isFirst : L10n.of(context)!.isNotFirst}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(16.0),
                    ))),
            Positioned(
              left: widget.r(500.0),
              top: 0.0,
              child: Visibility(
                  visible: widget.info != null
                      ? widget.info!.isFirst != widget.info!.isFirstTurn &&
                          widget.info!.gameStarted == true
                      : false,
                  child: CircularPercentIndicator(
                    radius: widget.r(45.0),
                    lineWidth: widget.r(10.0),
                    percent: percentIndicatorValue,
                    backgroundWidth: 0.0,
                    center: Column(children: <Widget>[
                      SizedBox(height: widget.r(30.0)),
                      Text('$percentIndicatorValueStr s',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: widget.r(22.0),
                          )),
                    ]),
                    progressColor: const Color.fromARGB(255, 1, 247, 42),
                  )),
            ),
            // ターンチェンジボタン
            Positioned(
                left: widget.r(1120.0),
                top: widget.r(430.0),
                child: Visibility(
                  visible: widget.info != null
                      ? widget.info!.isFirst == widget.info!.isFirstTurn &&
                          widget.info!.gameStarted == true
                      : false,
                  child: CircularPercentIndicator(
                    radius: widget.r(60.0),
                    lineWidth: widget.r(10.0),
                    percent: percentIndicatorValue,
                    backgroundWidth: 0.0,
                    center: Column(children: <Widget>[
                      SizedBox(height: widget.r(15.0)),
                      Text('$percentIndicatorValueStr s',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: widget.r(22.0),
                          )),
                      Visibility(
                          visible: canTurnEnd == true &&
                              widget.info!.yourAttackingCard == null,
                          child: SizedBox(
                              width: widget.r(90.0),
                              height: widget.r(35.0),
                              child: FloatingActionButton(
                                  backgroundColor: Colors.transparent,
                                  onPressed: () async {
                                    turnEnd(false);
                                  },
                                  tooltip: 'Turn End',
                                  child: Image.asset(
                                    '${imagePath}button/turnChangeEn.png',
                                    fit: BoxFit.cover,
                                  ))))
                    ]),
                    progressColor: const Color.fromARGB(255, 1, 247, 42),
                  ),
                )),
          ]);
        });
  }
}

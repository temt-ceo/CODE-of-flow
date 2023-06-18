import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flash/flash.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/TurnEndModel.dart';
import 'package:CodeOfFlow/models/defenceActionModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');
typedef void TimeupCallback(bool isOver);
typedef double ResponsiveSizeChangeFunction(double data);

class OnGoingGameInfo extends StatefulWidget {
  final GameObject? info;
  final String cardText;
  final TimeupCallback canOperate;
  final Stream<int> attack_stream;
  int? opponentDefendPosition;
  List<int>? yourUsedInterceptCard;
  List<int>? opponentUsedInterceptCard;
  int? actedCardPosition;
  final dynamic cardInfos;
  final ResponsiveSizeChangeFunction r;

  OnGoingGameInfo(
      this.info,
      this.cardText,
      this.canOperate,
      this.attack_stream,
      this.opponentDefendPosition,
      this.yourUsedInterceptCard,
      this.opponentUsedInterceptCard,
      this.actedCardPosition,
      this.cardInfos,
      this.r);

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
      Navigator.of(loadingContext!, rootNavigator: true).pop();
    }
  }

  @override
  void initState() {
    super.initState();
  }

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

    // Turn End
    void turnEnd(fromOpponent) async {
      showGameLoading();
      var message = TurnEndModel(fromOpponent);
      var ret = await apiService.saveGameServerProcess(
          'turn_change', jsonEncode(message), widget.info!.you.toString());
      closeGameLoading();
      debugPrint('transaction published');
      debugPrint(ret.toString());
      if (ret != null) {
        debugPrint(ret.message);
      }
    }

    void actionDecided(int? diff) async {
      if (widget.actedCardPosition != null ||
          (diff != null && diff % 10 == 0)) {
        if (apiCalled == false) {
          apiCalled = true;
          showGameLoading();
          var message = DefenceActionModel(
              widget.opponentDefendPosition,
              widget.yourUsedInterceptCard == null
                  ? []
                  : widget.yourUsedInterceptCard!,
              widget.opponentUsedInterceptCard == null
                  ? []
                  : widget.opponentUsedInterceptCard!);
          setState(() {
            widget.actedCardPosition = null;
            widget.opponentDefendPosition = null;
            widget.yourUsedInterceptCard = null;
            widget.opponentUsedInterceptCard = null;
          });
          var ret = await apiService.saveGameServerProcess('defence_action',
              jsonEncode(message), widget.info!.you.toString());
          print('defence_action $message');
          closeGameLoading();
          debugPrint('== defence_action transaction published ==');
          debugPrint('== ${ret.toString()} ==');
          if (ret != null) {
            debugPrint(ret.message);
          }
        }
      } else {
        apiCalled = false;
      }
    }

    // Defence Action
    void defenceActionDecided(DateTime battleStartTime, DateTime now) {
      if (battleReactionUpdateTime != null &&
          now.difference(battleReactionUpdateTime!).inSeconds > 0) {
        setState(() {
          reactionLimitTime =
              700 - now.difference(battleReactionUpdateTime!).inSeconds;
        });
        if (reactionLimitTime != null && reactionLimitTime! < 0) {
          String flashMsg = '';
          if (widget.opponentDefendPosition != null) {
            String y_card_id =
                widget.info!.yourFieldUnit[widget.actedCardPosition.toString()];
            String o_card_id = widget
                .info!.opponentFieldUnit[widget.actedCardPosition.toString()];
            flashMsg = widget.cardInfos[y_card_id]['name'] +
                ' VS ' +
                widget.cardInfos[o_card_id]['name'];
          }

          // 時間制限を超えた場合、バトル判定処理実行へ
          WidgetsBinding.instance.addPostFrameCallback((_) {
            actionDecided(null);
          });
          showFlash(
              context: context,
              duration: const Duration(seconds: 4),
              builder: (context, controller) {
                return Flash(
                  controller: controller,
                  position: FlashPosition.bottom,
                  child: FlashBar(
                    controller: controller,
                    title: Text(widget.opponentDefendPosition == null
                        ? 'Player Damage!'
                        : 'Battle!!'),
                    content: Text(
                        widget.opponentDefendPosition == null ? '' : flashMsg),
                    indicatorColor: Colors.blue,
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue,
                    ),
                  ),
                );
              });
        }
        // 10秒経過時も判定処理へ
      } else if (now.difference(battleStartTime).inSeconds > 1000) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          actionDecided(now.difference(battleStartTime).inSeconds);
        });
      }
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
      late DateTime battleStartTime;

      // バトル中ならそれ以前の時間まで止める
      if (widget.info!.yourAttackingCard != null &&
          widget.info!.isFirst == widget.info!.isFirstTurn) {
        var attackedTime = widget.info!.yourAttackingCard['attacked_time'];
        if (attackedTime != null) {
          battleStartTime = DateTime.fromMillisecondsSinceEpoch(
              double.parse(attackedTime).toInt() * 1000);
          if (now.difference(battleStartTime).inSeconds > 0) {
            turnEndTime = turnEndTime.add(
                Duration(seconds: now.difference(battleStartTime).inSeconds));
          }
        }
        defenceActionDecided(battleStartTime, now);
      } else if (widget.info!.enemyAttackingCard != null &&
          widget.info!.isFirst != widget.info!.isFirstTurn) {
        var attackedTime = widget.info!.enemyAttackingCard['attacked_time'];
        if (attackedTime != null) {
          battleStartTime = DateTime.fromMillisecondsSinceEpoch(
              double.parse(attackedTime).toInt() * 1000);
          if (now.difference(battleStartTime).inSeconds > 0) {
            turnEndTime = turnEndTime.add(
                Duration(seconds: now.difference(battleStartTime).inSeconds));
          }
        }
        defenceActionDecided(battleStartTime, now);
      }

      if (turnEndTime.difference(now).inSeconds <= 0) {
        // ０になった後、50秒経過してもターンが終わっていない場合も実施
        if (turnEndTime.difference(now).inSeconds == 0 ||
            turnEndTime.difference(now).inSeconds % 50 == 0) {
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
          widget.canOperate(false);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.canOperate(true);
        });
        var displayValue = turnEndTime.difference(now).inSeconds / 60;
        setState(() {
          percentIndicatorValue = displayValue > 1 ? 1 : displayValue;
          percentIndicatorValueStr = displayValue > 1
              ? '60'
              : turnEndTime.difference(now).inSeconds.toString();
        });
        if (widget.info!.isFirst == widget.info!.isFirstTurn) {
          // // 誤動作を防ぐために5秒経過後に押せるようにする
          // if (percentIndicatorValue < 0.55 &&
          //     widget.info!.yourAttackingCard == null) {
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                battleReactionUpdateTime = DateTime.now();
              });
            });
          }

          return Stack(children: <Widget>[
            for (var i = 0; i < widget.info!.opponentLife; i++)
              Positioned(
                left: widget.r(150.0 + i * 21),
                top: widget.r(70.0),
                child: Container(
                  width: widget.r(20.0),
                  height: widget.r(20.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('${imagePath}button/enemyLife.png'),
                        fit: BoxFit.cover),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.yellow,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
                left: widget.r(80.0),
                top: widget.r(100.0),
                child: Text(
                    'CP ${widget.info != null ? (widget.info!.opponentCp < 10 ? '0${widget.info!.opponentCp}' : widget.info!.opponentCp) : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            for (var i = 0; i < widget.info!.opponentCp; i++)
              Positioned(
                left: widget.r(152.0 + i * 16),
                top: widget.r(108.0),
                child: Container(
                  width: widget.r(15.0),
                  height: widget.r(15.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('${imagePath}button/cp.png'),
                        fit: BoxFit.cover),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.yellow,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(-1, 0), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
                left: widget.r(80.0),
                top: widget.r(130.0),
                child: Text(
                    'Dead - / Deck ${widget.info != null ? widget.info!.opponentRemainDeck : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            Positioned(
                left: widget.r(320.0),
                top: widget.r(100.0),
                child: Text('Hand',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            for (var i = 0; i < widget.info!.opponentHand; i++)
              Positioned(
                left: widget.r(400.0 + i * 21),
                top: widget.r(103.0),
                child: Container(
                  width: widget.r(20.0),
                  height: widget.r(20.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('${imagePath}button/enemyHand.png'),
                        fit: BoxFit.cover),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 41, 39, 176),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
                left: widget.r(320.0),
                top: widget.r(130.0),
                child: Text('Trigger',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            for (var i = 0; i < widget.info!.opponentTriggerCards; i++)
              Positioned(
                left: widget.r(400.0 + i * 26),
                top: widget.r(133.0),
                child: Container(
                  width: widget.r(25.0),
                  height: widget.r(25.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('${imagePath}button/enemyHand.png'),
                        fit: BoxFit.cover),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 41, 39, 176),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            for (var i = 0; i < widget.info!.yourLife; i++)
              Positioned(
                left: widget.r(150.0 + i * 21),
                top: widget.r(210.0),
                child: Container(
                  width: widget.r(20.0),
                  height: widget.r(20.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('${imagePath}button/yourLife.png'),
                        fit: BoxFit.cover),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 41, 39, 176),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
                left: widget.r(80.0),
                top: widget.r(240.0),
                child: Text(
                    'CP ${widget.info != null ? (widget.info!.yourCp < 10 ? '0${widget.info!.yourCp}' : widget.info!.yourCp) : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            for (var i = 0; i < widget.info!.yourCp; i++)
              Positioned(
                left: widget.r(152.0 + i * 16),
                top: widget.r(248.0),
                child: Container(
                  width: widget.r(15.0),
                  height: widget.r(15.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('${imagePath}button/cp.png'),
                        fit: BoxFit.cover),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.yellow,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(-1, 0), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
                left: widget.r(1255.0),
                top: widget.r(540.0),
                child: Text(
                    'Deck ${widget.info != null ? widget.info!.yourRemainDeck.length : '--'}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            Positioned(
                left: widget.r(1255.0),
                top: widget.r(500.0),
                child: Text('Dead -',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            Positioned(
                left: widget.r(1080.0),
                top: widget.r(0.0),
                child: Text(
                    'Turn $turn : ${isFirstTurn ? L10n.of(context)!.isFirst : L10n.of(context)!.isNotFirst}',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    ))),
            Positioned(
                left: widget.r(30.0),
                top: widget.r(490.0),
                width: widget.r(270.0),
                child: Text(widget.cardText,
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
                      ? widget.info!.isFirst != widget.info!.isFirstTurn
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
            Positioned(
                left: widget.r(1140.0),
                top: widget.r(480.0),
                child: Visibility(
                  visible: widget.info != null
                      ? widget.info!.isFirst == widget.info!.isFirstTurn
                      : true,
                  child: CircularPercentIndicator(
                    radius: widget.r(60.0),
                    lineWidth: widget.r(10.0),
                    percent: percentIndicatorValue,
                    backgroundWidth: 0.0,
                    center: Column(children: <Widget>[
                      SizedBox(height: widget.r(10.0)),
                      Text('$percentIndicatorValueStr s',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: widget.r(22.0),
                          )),
                      Visibility(
                          visible: canTurnEnd == true,
                          child: SizedBox(
                              width: widget.r(90.0),
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
            Visibility(
                visible: reactionLimitTime != null && reactionLimitTime! > 0,
                child: Positioned(
                    left: widget.r(900),
                    top: widget.r(300),
                    child: SizedBox(
                        width: widget.r(100.0),
                        child: Center(
                            child: Text(
                          '0:0${reactionLimitTime.toString()}',
                          style: TextStyle(
                              color: Colors.white, fontSize: widget.r(42.0)),
                        ))))),
          ]);
        });
  }
}

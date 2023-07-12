import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:quickalert/quickalert.dart';

import 'package:CodeOfFlow/bloc/bg_color/bg_color_bloc.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_event.dart';
import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/components/droppedCardWidget.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/attackModel.dart';
import 'package:CodeOfFlow/models/defenceActionModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');
typedef void StringCallback(String val, int cardId, int? position);
typedef double ResponsiveSizeChangeFunction(double data);

class DragTargetWidget extends StatefulWidget {
  final String label;
  final String imageUrl;
  final GameObject? info;
  final dynamic cardInfos;
  final StringCallback tapCardCallback;
  final int? actedCardPosition;
  final bool canOperate;
  final Stream<int> attack_stream;
  final List<dynamic> defaultDropedList;
  final List<int?> currentTriggerCards;
  final List<int> usedInterceptCardPosition;
  final List<int> usedTriggers;
  final int? enemySkillTargetPosition;
  final String skillMessage;
  final bool tmpCanOperate;
  final bool attackIsReady;
  final ResponsiveSizeChangeFunction r;
  final bool isMobile;

  DragTargetWidget(
      this.label,
      this.imageUrl,
      this.info,
      this.cardInfos,
      this.tapCardCallback,
      this.actedCardPosition,
      this.canOperate,
      this.attack_stream,
      this.defaultDropedList,
      this.currentTriggerCards,
      this.usedInterceptCardPosition,
      this.usedTriggers,
      this.enemySkillTargetPosition,
      this.skillMessage,
      this.tmpCanOperate,
      this.attackIsReady,
      this.r,
      this.isMobile);

  @override
  DragTargetState createState() => DragTargetState();
}

class DragTargetState extends State<DragTargetWidget> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  BuildContext? loadingContext;
  APIService apiService = APIService();
  List<Widget> dropedList = [];
  List<Widget> dropedListEnemy = [];
  List<Widget> dropedListSecond = [];
  final DropAllowBloc _dropBloc = DropAllowBloc();
  bool canAttack = false;
  int? attackSignalPosition;
  bool attackAPICalled = false;
  late bool canInit;

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

  void attack() async {
    if (widget.actedCardPosition != null && attackAPICalled == false) {
      attackAPICalled = true;
      bool canBlock =
          widget.info!.opponentDefendableUnitLength > 0 ? true : false;
      for (int i = 1; i <= 5; i++) {
        if (widget.info!.opponentFieldUnitAction[i.toString()] == '0') {
          canBlock = false;
        }
      }
      for (var i = 0; i < widget.usedTriggers.length; i++) {
        if (widget.usedTriggers[i] == 25) {
          // Judge
          canBlock = false;
        } else if (widget.usedTriggers[i] == 24 &&
            widget.info!.opponentDefendableUnitLength == 1) {
          // Titan's Lock
          canBlock = false;
        }
        debugPrint(
            'widget.info!.opponentDefendableUnitLength ${widget.info!.opponentDefendableUnitLength}');
      }
      if (widget.info!
              .yourFieldUnit[(widget.actedCardPosition! + 1).toString()] ==
          '6') {
        // Valkyrie
        canBlock = false;
      }
      // showGameLoading();
      var message;
      if (widget.currentTriggerCards.isEmpty) {
        TriggerCards triggerCards = TriggerCards(null, null, null, null);
        message = AttackModel(
          (widget.actedCardPosition! + 1),
          widget.enemySkillTargetPosition, // enemy_skill_target
          triggerCards,
          widget.usedInterceptCardPosition,
          widget.usedTriggers,
          canBlock,
          widget.skillMessage,
        );
      } else {
        TriggerCards triggerCards = TriggerCards(
            widget.currentTriggerCards[0],
            widget.currentTriggerCards[1],
            widget.currentTriggerCards[2],
            widget.currentTriggerCards[3]);
        message = AttackModel(
          (widget.actedCardPosition! + 1),
          widget.enemySkillTargetPosition, // enemy_skill_target
          triggerCards,
          widget.usedInterceptCardPosition,
          widget.usedTriggers,
          canBlock,
          widget.skillMessage,
        );
      }
      debugPrint(
          'widget.info!.opponentDefendableUnitLength ${widget.info!.opponentDefendableUnitLength}');
      await apiService.saveGameServerProcess(
          'attack', jsonEncode(message), widget.info!.you.toString());
      // closeGameLoading();

      if (widget.info!.opponentDefendableUnitLength == 0 || canBlock == false) {
        // 敵ユニットがいない場合、そのままダメージへ
        if (widget.isMobile == true) {
          showGameLoading();
          List<int> yourUsedInterceptCard = [];
          List<int> opponentUsedInterceptCard = [];
          List<int> attackerUsedCardIds = [];
          List<int> defenderUsedCardIds = [];
          var message2 = DefenceActionModel(
              null,
              yourUsedInterceptCard,
              opponentUsedInterceptCard,
              attackerUsedCardIds,
              defenderUsedCardIds);
          apiService.saveGameServerProcess('defence_action',
              jsonEncode(message2), widget.info!.you.toString());
          await Future.delayed(const Duration(seconds: 2));
          closeGameLoading();
        } else {
          showGameLoading();
          List<int> yourUsedInterceptCard = [];
          List<int> opponentUsedInterceptCard = [];
          List<int> attackerUsedCardIds = [];
          List<int> defenderUsedCardIds = [];
          var message2 = DefenceActionModel(
              null,
              yourUsedInterceptCard,
              opponentUsedInterceptCard,
              attackerUsedCardIds,
              defenderUsedCardIds);
          await apiService.saveGameServerProcess('defence_action',
              jsonEncode(message2), widget.info!.you.toString());
          closeGameLoading();
        }
      }
    }
  }

  void setMobileInitTrue() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    canInit = true;
  }

  ////////////////////////////
  ///////  initState   ///////
  ////////////////////////////
  @override
  void initState() {
    canInit = widget.isMobile == false;
    setMobileInitTrue();
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
    // _dropBloc.dispose();
    super.dispose();
  }

  ////////////////////////////
  ///////    build     ///////
  ////////////////////////////
  @override
  Widget build(BuildContext context) {
    if (widget.defaultDropedList.isNotEmpty) {
      if (widget.label == 'deck') {
        dropedList.clear();
        dropedListSecond.clear();
        for (int i = 0; i < widget.defaultDropedList.length; i++) {
          String cardIdStr = widget.defaultDropedList[i];
          var imageUrl = '';
          if (int.parse(cardIdStr) >= 17) {
            imageUrl =
                '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardIdStr}.jpeg';
          } else {
            imageUrl =
                '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${cardIdStr}.jpeg';
          }
          if (i < 15) {
            dropedList.add(DroppedCardWidget(
                widget.r(86.0 * dropedList.length - 1 + 10),
                imageUrl,
                widget.label,
                widget.cardInfos[cardIdStr],
                false,
                widget.tapCardCallback,
                dropedList.length,
                widget.attack_stream,
                widget.r));
          } else {
            dropedListSecond.add(DroppedCardWidget(
                widget.r(86.0 * dropedListSecond.length - 1 + 10),
                imageUrl,
                widget.label,
                widget.cardInfos[cardIdStr],
                true,
                widget.tapCardCallback,
                dropedList.length + dropedListSecond.length,
                widget.attack_stream,
                widget.r));
          }
        }
      } else if (widget.label == 'unit') {
        dropedList = [
          Container(),
          Container(),
          Container(),
          Container(),
          Container()
        ];
        for (int i = 0; i < widget.defaultDropedList.length; i++) {
          if (widget.defaultDropedList[i] != null) {
            String cardIdStr = widget.defaultDropedList[i];
            var imageUrl =
                '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_$cardIdStr.jpeg';
            dropedList[i] = DroppedCardWidget(
                widget.r(132.0 * i + 20),
                imageUrl,
                widget.label,
                widget.cardInfos[cardIdStr],
                false,
                widget.tapCardCallback,
                i,
                widget.attack_stream,
                widget.r);
          }
        }
      } else if (widget.label == 'trigger') {
        dropedList = [Container(), Container(), Container(), Container()];
        for (int i = 0; i < widget.defaultDropedList.length; i++) {
          if (widget.defaultDropedList[i] != null) {
            int cardId = widget.defaultDropedList[i];
            var imageUrl =
                '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg';
            dropedList[i] = DroppedCardWidget(
                widget.r(93.0 * i + 17), // TODO 380 / 440
                imageUrl,
                widget.label,
                widget.cardInfos[cardId.toString()],
                false,
                widget.tapCardCallback,
                i,
                widget.attack_stream,
                widget.r);
          }
        }
      }
    }

    if (widget.info != null && widget.label == 'unit') {
      dropedListEnemy.clear();
      // 敵フィールドユニットを最新にする
      for (int i = 1; i <= 5; i++) {
        if (widget.info!.opponentFieldUnit[i.toString()] != null) {
          var cardIdStr = widget.info!.opponentFieldUnit[i.toString()];
          var cardId = int.parse(cardIdStr);
          var imageUrl =
              '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg';
          dropedListEnemy.add(DroppedCardWidget(
              widget.r(135.0 * dropedListEnemy.length + 20), // TODO 690 / 700
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              true,
              widget.tapCardCallback,
              i - 1,
              widget.attack_stream,
              widget.r));
        } else {
          dropedListEnemy.add(Container());
        }
      }
    }

    if (widget.info == null && widget.label != 'deck') {
      dropedListEnemy.clear();
      dropedList.clear();
    }

    // Attack card.
    if (widget.label == 'unit' &&
        widget.actedCardPosition != null &&
        attackSignalPosition == null &&
        widget.attackIsReady == true) {
      attackSignalPosition = widget.actedCardPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        attack();
      });
    }

    // フィールド, Triggerゾーン
    if (widget.label != 'deck') {
      return DragTarget<String>(
          // onAccept
          onAccept: (String cardIdStr) {
        var cardId = int.parse(cardIdStr);
        var imageUrl = cardId > 16
            ? '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg'
            : '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg';
        if (widget.label == 'unit') {
          for (int i = 0; i < 5; i++) {
            if (dropedList[i].runtimeType.toString() ==
                Container().runtimeType.toString()) {
              dropedList[i] = DroppedCardWidget(
                  widget.r(132.0 * i + 20), // TODO 380 / 440
                  imageUrl,
                  widget.label,
                  widget.cardInfos[cardIdStr],
                  false,
                  widget.tapCardCallback,
                  i,
                  widget.attack_stream,
                  widget.r);
              break;
            }
          }
        } else if (widget.label == 'trigger') {
          for (int i = 0; i < 4; i++) {
            if (dropedList[i].runtimeType.toString() ==
                Container().runtimeType.toString()) {
              dropedList[i] = DroppedCardWidget(
                  widget.r(93.0 * i + 17), // TODO 380 / 440
                  imageUrl,
                  widget.label,
                  widget.cardInfos[cardIdStr],
                  false,
                  widget.tapCardCallback,
                  i,
                  widget.attack_stream,
                  widget.r);
              break;
            }
          }
        }
        _dropBloc.counterEventSink.add(DropLeaveEvent());
      },
          // onWillAccept
          onWillAccept: (String? cardIdStr) {
        if (widget.canOperate == false || widget.tmpCanOperate == false) {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
        if (widget.info != null &&
            widget.info!.isFirst != widget.info!.isFirstTurn) {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
        if (dropedList.isEmpty) {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
        if (widget.info!.yourAttackingCard != null) {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
        var cardId = int.parse(cardIdStr!);
        var imageUrl = cardId > 16
            ? '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg'
            : '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg';

        if (widget.label == 'unit' && imageUrl.startsWith('${imagePath}unit')) {
          if (widget.info != null) {
            // カード情報がない。
            if (widget.cardInfos == null ||
                widget.cardInfos[cardIdStr] == null) {
              _dropBloc.counterEventSink.add(DropDeniedEvent());
              return false;
            }
            var cardData = widget.cardInfos[cardIdStr];
            if (int.parse(cardData['cost']) > widget.info!.yourCp) {
              _dropBloc.counterEventSink.add(DropDeniedEvent());
              return false;
            }
          }
          bool noSpace = true;
          for (int i = 0; i < 5; i++) {
            if (dropedList[i].runtimeType.toString() ==
                Container().runtimeType.toString()) {
              noSpace = false;
            }
          }
          if (noSpace) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            return false;
          }
          _dropBloc.counterEventSink.add(DropAllowedEvent());
          return true;
        } else if (widget.label == 'trigger' &&
            imageUrl.startsWith('${imagePath}trigger')) {
          bool noSpace = true;
          for (int i = 0; i < 4; i++) {
            if (dropedList[i].runtimeType.toString() ==
                Container().runtimeType.toString()) {
              noSpace = false;
            }
          }
          if (noSpace) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            return false;
          }
          _dropBloc.counterEventSink.add(DropAllowedEvent());
          return true;
        } else {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
      }, onLeave: (String? item) {
        _dropBloc.counterEventSink.add(DropLeaveEvent());
      }, builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return StreamBuilder(
            stream: widget.attack_stream,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              // バトル終了検知
              if (snapshot.data == 4) {
                attackSignalPosition = null;
                attackAPICalled = false;
              }
              return StreamBuilder(
                  stream: _dropBloc.bg_color,
                  initialData: 0xFFFFFFFF,
                  builder:
                      (BuildContext context, AsyncSnapshot<int> snapshot2) {
                    if (canInit == false) {
                      return Container();
                    }
                    return Container(
                      width: widget.label == 'unit'
                          ? widget.r(690.0)
                          : widget.r(380.0),
                      height: widget.label == 'unit'
                          ? widget.r(380.0)
                          : widget.r(112.0),
                      decoration: widget.isMobile
                          ? BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(widget.imageUrl),
                                  fit: BoxFit.cover),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(snapshot2.data ?? 0xFFFFFFFF),
                                  spreadRadius: widget.r(3),
                                ),
                              ],
                            )
                          : BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(widget.imageUrl),
                                  fit: BoxFit.cover),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(snapshot2.data ?? 0xFFFFFFFF),
                                  spreadRadius: widget.r(4),
                                  blurRadius: widget.r(6),
                                  offset: Offset(
                                      widget.r(2),
                                      widget
                                          .r(3)), // changes position of shadow
                                ),
                              ],
                            ),
                      child: widget.label == 'unit'
                          // フィールド
                          ? Stack(children: <Widget>[
                              // 攻撃シグナル画像
                              Visibility(
                                  visible: attackSignalPosition != null,
                                  child: Positioned(
                                    left: widget.r((attackSignalPosition !=
                                                    null &&
                                                attackSignalPosition! >= 2
                                            ? widget.r(-40.0)
                                            : widget.r(50.0)) +
                                        (attackSignalPosition != null
                                            ? widget.r(attackSignalPosition! *
                                                widget.r(180.0))
                                            : 0)),
                                    top: widget.r(-5.0),
                                    child: Container(
                                      width: widget.r(
                                          attackSignalPosition != null &&
                                                  attackSignalPosition! >= 2
                                              ? widget.r(340.0)
                                              : widget.r(180.0)),
                                      height: widget.r(240.0),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                            opacity: 0.8,
                                            image: AssetImage(attackSignalPosition !=
                                                        null &&
                                                    attackSignalPosition! >= 2
                                                ? '${imagePath}unit/attackSignal2.png'
                                                : '${imagePath}unit/attackSignal.png'),
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                  )),
                              // 敵ユニット
                              Stack(children: dropedListEnemy),
                              // 味方ユニット
                              Stack(children: dropedList),
                            ])
                          : Stack(
                              children: dropedList,
                            ),
                    );
                  });
            });
      });
      // デッキ編集
    } else {
      return DragTarget<String>(
          // onAccept
          onAccept: (String cardIdStr) {
        var cardId = int.parse(cardIdStr);
        var imageUrl = cardId > 16
            ? '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg'
            : '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${cardId.toString()}.jpeg';
        if (dropedList.length >= 15) {
          dropedListSecond.add(DroppedCardWidget(
              widget.r(86.0 * dropedListSecond.length - 1 + 10),
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              true,
              widget.tapCardCallback,
              dropedList.length + dropedListSecond.length,
              widget.attack_stream,
              widget.r));
        } else {
          dropedList.add(DroppedCardWidget(
              widget.r(86.0 * dropedList.length - 1 + 10), // TODO 380 / 440
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              false,
              widget.tapCardCallback,
              dropedList.length,
              widget.attack_stream,
              widget.r));
        }
        _dropBloc.counterEventSink.add(DropLeaveEvent());
      },
          // onWillAccept
          onWillAccept: (String? cardIdStr) {
        if (dropedListSecond.length >= 15) {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
        int cardCount = 0;
        for (int i = 0; i < widget.defaultDropedList.length; i++) {
          if (cardIdStr == widget.defaultDropedList[i]) {
            cardCount++;
          }
          if (cardCount >= 3) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            QuickAlert.show(
              context: context,
              type: QuickAlertType.info,
              title: 'Up to 3 identical cards can be inserted.',
              text: '',
            );

            return false;
          }
        }
        _dropBloc.counterEventSink.add(DropAllowedEvent());
        return true;
      }, onLeave: (String? item) {
        _dropBloc.counterEventSink.add(DropLeaveEvent());
      }, builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return StreamBuilder(
            stream: _dropBloc.bg_color,
            initialData: 0xFFFFFFFF,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Container(
                width: widget.r(1320.0),
                height: widget.r(310.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.imageUrl), fit: BoxFit.cover),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFFFFF),
                      spreadRadius: widget.r(4),
                      blurRadius: widget.r(6),
                      offset: Offset(widget.r(2),
                          widget.r(3)), // changes position of shadow
                    ),
                  ],
                ),
                child: Stack(children: <Widget>[
                  Stack(children: dropedList),
                  Stack(children: dropedListSecond)
                ]),
              );
            });
      });
    }
  }
}

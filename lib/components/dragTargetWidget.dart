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
  int? actedCardPosition;
  final bool canOperate;
  final Stream<int> attack_stream;
  final List<dynamic> defaultDropedList;
  final ResponsiveSizeChangeFunction r;

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
      this.r);

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
    if (widget.actedCardPosition != null) {
      showGameLoading();
      var objStr2 = jsonToString(widget.info!.yourTriggerCards);
      var objJs2 = jsonDecode(objStr2);
      List<int?> triggerPositions = [null, null, null, null];
      for (int i = 1; i <= 4; i++) {
        if (objJs2[i.toString()] != null) {
          triggerPositions[i - 1] = objJs2[i.toString()];
        }
      }
      TriggerCards triggerCards = TriggerCards(triggerPositions[0],
          triggerPositions[1], triggerPositions[2], triggerPositions[3]);
      List<int> usedInterceptCard = [];
      var message = AttackModel((widget.actedCardPosition! + 1), null,
          triggerCards, usedInterceptCard);
      var ret = await apiService.saveGameServerProcess(
          'attack', jsonEncode(message), widget.info!.you.toString());
      closeGameLoading();
      debugPrint('== attack transaction published ==');
      debugPrint('== ${ret.toString()} ==');
      if (ret != null) {
        debugPrint(ret.message);
      }
      if (widget.info!.opponentDefendableUnitLength == 0) {
        // 敵ユニットがいない場合、そのままダメージへ
        showGameLoading();
        List<int> yourUsedInterceptCard = [];
        List<int> opponentUsedInterceptCard = [];
        var message2 = DefenceActionModel(
            null, yourUsedInterceptCard, opponentUsedInterceptCard);
        var ret2 = await apiService.saveGameServerProcess('defence_action',
            jsonEncode(message2), widget.info!.you.toString());
        closeGameLoading();
        debugPrint('== NO GARD defence_action transaction published ==');
        debugPrint('== ${ret2.toString()} ==');
        if (ret2 != null) {
          debugPrint(ret2.message);
        }
      }
    }
  }

  ////////////////////////////
  ///////  initState   ///////
  ////////////////////////////
  @override
  void initState() {
    super.initState();
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
            imageUrl = '${imagePath}trigger/card_${cardIdStr}.jpeg';
          } else {
            imageUrl = '${imagePath}unit/card_${cardIdStr}.jpeg';
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
            var imageUrl = '${imagePath}unit/card_$cardIdStr.jpeg';
            dropedList[i] = DroppedCardWidget(
                widget.r(132.0 * i + 20), // TODO 690 / 700
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
        dropedList = [
          Container(),
          Container(),
          Container(),
          Container(),
          Container()
        ];
        for (int i = 0; i < widget.defaultDropedList.length; i++) {
          if (widget.defaultDropedList[i] != null) {
            int cardId = widget.defaultDropedList[i];
            var imageUrl = '${imagePath}trigger/card_${cardId.toString()}.jpeg';
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
          var imageUrl = '${imagePath}unit/card_${cardId.toString()}.jpeg';
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
        attackSignalPosition == null) {
      attackSignalPosition = widget.actedCardPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        attack();
      });
    }

    return StreamBuilder(
        stream: widget.attack_stream,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          // バトル終了検知
          if (snapshot.data == 3) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                attackSignalPosition = null;
              });
            });
          }

          return DragTarget<String>(
              // onAccept
              onAccept: (String cardIdStr) {
            var cardId = int.parse(cardIdStr);
            var imageUrl = cardId > 16
                ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
                : '${imagePath}unit/card_${cardId.toString()}.jpeg';
            if (widget.label == 'deck' && dropedList.length >= 15) {
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
            } else if (widget.label == 'deck') {
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
            } else if (widget.label == 'unit') {
              for (int i = 0; i < 5; i++) {
                if (dropedList[i].runtimeType.toString() == 'Container') {
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
                if (dropedList[i].runtimeType.toString() == 'Container') {
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
            if (widget.label == 'deck') {
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
              // フィールド, Triggerゾーン
            } else {
              if (widget.canOperate == false) {
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
              var cardId = int.parse(cardIdStr!);
              var imageUrl = cardId > 16
                  ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
                  : '${imagePath}unit/card_${cardId.toString()}.jpeg';

              if (widget.label == 'unit' &&
                  imageUrl.startsWith('${imagePath}unit')) {
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
                  if (dropedList[i].runtimeType.toString() == 'Container') {
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
                  if (dropedList[i].runtimeType.toString() == 'Container') {
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
            }
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
                    width: widget.label == 'deck'
                        ? widget.r(1320.0)
                        : (widget.label == 'unit'
                            ? widget.r(690.0)
                            : widget.r(380.0)),
                    height: widget.label == 'deck'
                        ? widget.r(310.0)
                        : (widget.label == 'unit'
                            ? widget.r(380.0)
                            : widget.r(112.0)),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(widget.imageUrl),
                          fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(
                          color: Color(snapshot.data ?? 0xFFFFFFFF),
                          spreadRadius: widget.r(5),
                          blurRadius: widget.r(7),
                          offset: Offset(widget.r(2),
                              widget.r(5)), // changes position of shadow
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
                                          ? widget.r(-150.0)
                                          : widget.r(40.0)) +
                                      (attackSignalPosition != null
                                          ? widget
                                              .r(attackSignalPosition! * 120.0)
                                          : 0)),
                                  top: widget.r(-5.0),
                                  child: Container(
                                    width: widget.r(
                                        attackSignalPosition != null &&
                                                attackSignalPosition! >= 2
                                            ? widget.r(350.0)
                                            : widget.r(186.0)),
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
                            SizedBox(height: widget.r(30.0)),
                            // 敵ユニット
                            Stack(children: dropedListEnemy),
                            // 味方ユニット
                            Stack(children: dropedList),
                          ])
                        // デッキ編集画面
                        : (widget.label == 'deck'
                            ? Stack(children: <Widget>[
                                Stack(children: dropedList),
                                Stack(children: dropedListSecond),
                              ])
                            : Stack(
                                children: dropedList,
                              )),
                  );
                });
          });
        });
  }
}

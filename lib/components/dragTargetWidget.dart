import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_bloc.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_event.dart';
import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/components/droppedCardWidget.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/models/attackModel.dart';
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
  dynamic yourFieldUnit;
  dynamic opponentFieldUnit;
  bool canAttack = false;
  int? attackSignalPosition = 0;

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
    print(2222);
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
    var message = AttackModel(
        widget.actedCardPosition!, null, triggerCards, usedInterceptCard);
    var ret = await apiService.saveGameServerProcess('put_card_on_the_field',
        jsonEncode(message), widget.info!.you.toString());
    closeGameLoading();
    debugPrint('transaction published');
    debugPrint(ret.toString());
    if (ret != null) {
      debugPrint(ret.message);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.info != null) {
      setState(() {
        yourFieldUnit = widget.info!.yourFieldUnit;
      });
      setState(() {
        opponentFieldUnit = widget.info!.opponentFieldUnit;
      });
    }

    // print(
    //     '除去orアタック(remove or attack card position): ${widget.actedCardPosition}');
    if (widget.info != null && widget.label == 'unit') {
      for (int i = 1; i <= 5; i++) {
        if (yourFieldUnit[i.toString()] != null && i > dropedList.length) {
          var cardIdStr = yourFieldUnit[i.toString()];
          var cardId = int.parse(cardIdStr);
          var imageUrl = '${imagePath}unit/card_${cardId.toString()}.jpeg';
          dropedList.add(DroppedCardWidget(
              widget.r(135.0 * dropedList.length + 20), // TODO 690 / 700
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              false,
              widget.tapCardCallback,
              i - 1,
              widget.attack_stream,
              widget.r));
        }
      }
      for (int i = 1; i <= 5; i++) {
        if (opponentFieldUnit[i.toString()] != null &&
            i > dropedListEnemy.length) {
          var cardIdStr = opponentFieldUnit[i.toString()];
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
        }
      }
    }
    if (widget.info != null && widget.label == 'trigger') {
      var objStr = jsonToString(widget.info!.yourTriggerCards);
      var objJs = jsonDecode(objStr);
      for (int i = 1; i <= 4; i++) {
        if (objJs[i.toString()] != null && i >= dropedList.length) {
          var cardIdStr = objJs[i.toString()];
          var cardId = int.parse(cardIdStr);
          var imageUrl = '${imagePath}trigger/card_${cardId.toString()}.jpeg';
          dropedList.add(DroppedCardWidget(
              widget.r(108.0 * dropedList.length + 20), // TODO 380 / 440
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              false,
              widget.tapCardCallback,
              i - 1,
              widget.attack_stream,
              widget.r));
        }
      }
    }

    if (widget.label == 'deck') {
      // Remove a deck card.
      if (widget.actedCardPosition != null) {
        dropedList.removeAt(widget.actedCardPosition!);
        setState(() => widget.actedCardPosition = null);
      }
    } else if (widget.label == 'unit') {
      // Attack card.
      if (widget.actedCardPosition != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          attack();
        });
        setState(() => {
              attackSignalPosition = widget.actedCardPosition,
              widget.actedCardPosition = null
            });
      }
    }

    return DragTarget<String>(onAccept: (String cardIdStr) {
      var cardId = int.parse(cardIdStr);
      var imageUrl = cardId > 16
          ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
          : '${imagePath}unit/card_${cardId.toString()}.jpeg';
      if (widget.label == 'deck' && dropedList.length >= 15) {
        dropedListSecond.add(DroppedCardWidget(
            widget.r(90.0 * dropedListSecond.length - 1 + 10),
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
            widget.label == 'deck'
                ? widget.r(86.0 * dropedList.length - 1 + 10)
                : (widget.label == 'unit'
                    ? widget.r(132.0 * dropedList.length - 1 + 20)
                    : widget.r(
                        93.0 * dropedList.length - 1 + 17)), // TODO 380 / 440
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
    }, onWillAccept: (String? cardIdStr) {
      if (widget.label == 'deck') {
        if (dropedListSecond.length >= 15) {
          _dropBloc.counterEventSink.add(DropDeniedEvent());
          return false;
        }
        _dropBloc.counterEventSink.add(DropAllowedEvent());
        return true;
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
        var cardId = int.parse(cardIdStr!);
        var imageUrl = cardId > 16
            ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
            : '${imagePath}unit/card_${cardId.toString()}.jpeg';

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
          if (dropedList.length >= 5) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            return false;
          }
          _dropBloc.counterEventSink.add(DropAllowedEvent());
          return true;
        } else if (widget.label == 'trigger' &&
            imageUrl!.startsWith('${imagePath}trigger')) {
          _dropBloc.counterEventSink.add(DropAllowedEvent());
          return true;
        } else {
          if (dropedList.length >= 4) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            return false;
          }
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
                  ? widget.r(350.0)
                  : (widget.label == 'unit'
                      ? widget.r(380.0)
                      : widget.r(112.0)),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(widget.imageUrl), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Color(snapshot.data ?? 0xFFFFFFFF),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(
                        widget.r(2), widget.r(5)), // changes position of shadow
                  ),
                ],
              ),
              child: widget.label == 'unit'
                  ? Stack(children: <Widget>[
                      Positioned(
                        left: widget.r(
                            (attackSignalPosition! >= 2 ? -150.0 : 20.0) +
                                attackSignalPosition! * 120.0),
                        top: widget.r(-5.0),
                        child: Container(
                          width: widget
                              .r(attackSignalPosition! >= 2 ? 350.0 : 186.0),
                          height: widget.r(240.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                                opacity: 0.7,
                                image: AssetImage(attackSignalPosition! >= 2
                                    ? '${imagePath}unit/attackSignal2.png'
                                    : '${imagePath}unit/attackSignal.png'),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Stack(children: dropedListEnemy),
                      Stack(children: dropedList),
                    ])
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
  }
}

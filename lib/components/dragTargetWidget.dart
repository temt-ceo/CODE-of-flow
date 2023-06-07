import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_bloc.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_event.dart';
import 'package:CodeOfFlow/components/deckButtons.dart';
import 'package:CodeOfFlow/components/droppedCardWidget.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';

const envFlavor = String.fromEnvironment('flavor');
typedef void StringCallback(String val, int cardId, int? position);

class DragTargetWidget extends StatefulWidget {
  final String label;
  final String imageUrl;
  final GameObject? info;
  final dynamic cardInfos;
  final StringCallback tapCardCallback;
  int? actedCardPosition;

  DragTargetWidget(this.label, this.imageUrl, this.info, this.cardInfos,
      this.tapCardCallback, this.actedCardPosition);

  @override
  DragTargetState createState() => DragTargetState();
}

class DragTargetState extends State<DragTargetWidget> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  List<Widget> dropedList = [];
  List<Widget> dropedListEnemy = [];
  List<Widget> dropedListSecond = [];
  final DropAllowBloc _dropBloc = DropAllowBloc();

  @override
  Widget build(BuildContext context) {
    // print(
    //     '除去orアタック(remove or attack card position): ${widget.actedCardPosition}');
    if (widget.info != null && widget.label == 'unit') {
      var objStr = jsonToString(widget.info!.yourFieldUnit);
      var objJs = jsonDecode(objStr);
      for (int i = 1; i <= 5; i++) {
        if (objJs[i.toString()] != null && i > dropedList.length) {
          var cardIdStr = objJs[i.toString()];
          var cardId = int.parse(cardIdStr);
          var imageUrl = '${imagePath}unit/card_${cardId.toString()}.jpeg';
          dropedList.add(DroppedCardWidget(
              widget.label == 'unit'
                  ? 135.0 * dropedList.length + 20
                  : 108.0 * dropedList.length + 20,
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              false,
              widget.tapCardCallback,
              dropedList.length,
              false));
        }
      }
      var objStr2 = jsonToString(widget.info!.opponentFieldUnit);
      var objJs2 = jsonDecode(objStr2);
      for (int i = 1; i <= 5; i++) {
        if (objJs2[i.toString()] != null && i > dropedListEnemy.length) {
          var cardIdStr = objJs2[i.toString()];
          var cardId = int.parse(cardIdStr);
          var imageUrl = '${imagePath}unit/card_${cardId.toString()}.jpeg';
          dropedListEnemy.add(DroppedCardWidget(
              widget.label == 'unit'
                  ? 135.0 * dropedListEnemy.length + 20
                  : 108.0 * dropedListEnemy.length + 20,
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              true,
              widget.tapCardCallback,
              dropedList.length,
              false));
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
              widget.label == 'unit'
                  ? 135.0 * dropedList.length + 20
                  : 108.0 * dropedList.length + 20,
              imageUrl,
              widget.label,
              widget.cardInfos[cardIdStr],
              false,
              widget.tapCardCallback,
              dropedList.length,
              false));
        }
      }
    }

    if (widget.label == 'deck') {
      // Remove a deck card.
      if (widget.actedCardPosition != null) {
        dropedList.removeAt(widget.actedCardPosition!);
        setState(() => widget.actedCardPosition = null);
      }
    }

    return DragTarget<String>(onAccept: (String cardIdStr) {
      var cardId = int.parse(cardIdStr);
      var imageUrl = cardId > 16
          ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
          : '${imagePath}unit/card_${cardId.toString()}.jpeg';
      if (widget.label == 'deck' && dropedList.length >= 15) {
        dropedListSecond.add(DroppedCardWidget(
            90.0 * dropedListSecond.length - 1 + 10,
            imageUrl,
            widget.label,
            widget.cardInfos[cardIdStr],
            true,
            widget.tapCardCallback,
            dropedList.length + dropedListSecond.length,
            false));
      } else {
        dropedList.add(DroppedCardWidget(
            widget.label == 'deck'
                ? 90.0 * dropedList.length - 1 + 10
                : (widget.label == 'unit'
                    ? 135.0 * dropedList.length - 1 + 20
                    : 108.0 * dropedList.length - 1 + 20),
            imageUrl,
            widget.label,
            widget.cardInfos[cardIdStr],
            false,
            widget.tapCardCallback,
            dropedList.length,
            widget.label == 'unit' && widget.info != null
                ? (widget.info!.isFirst == widget.info!.isFirstTurn
                    ? true
                    : false)
                : false));
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
                  ? 1380.0
                  : (widget.label == 'unit' ? 700.0 : 440.0),
              height: widget.label == 'deck'
                  ? 350.0
                  : (widget.label == 'unit' ? 400.0 : 132.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(widget.imageUrl), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Color(snapshot.data ?? 0xFFFFFFFF),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(2, 5), // changes position of shadow
                  ),
                ],
              ),
              child: widget.label == 'unit'
                  ? Stack(children: <Widget>[
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

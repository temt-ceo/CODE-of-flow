import 'package:flutter/material.dart';

import 'package:CodeOfFlow/bloc/attack_status/attack_status_bloc.dart';
import 'package:CodeOfFlow/bloc/attack_status/attack_status_event.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef void StringCallback(String val, int cardId, int? position);
typedef double ResponsiveSizeChangeFunction(double data);

class DroppedCardWidget extends StatefulWidget {
  final double left;
  final String imageUrl;
  final String label;
  final dynamic cardInfo;
  final bool isSecondRow;
  final StringCallback tapCardCallback;
  final int index;
  final Stream<int> attack_stream;
  final bool btnShowFlg;
  final ResponsiveSizeChangeFunction r;

  const DroppedCardWidget(
      this.left,
      this.imageUrl,
      this.label,
      this.cardInfo,
      this.isSecondRow,
      this.tapCardCallback,
      this.index,
      this.attack_stream,
      this.btnShowFlg,
      this.r);

  @override
  DroppedCardState createState() => DroppedCardState();
}

class DroppedCardState extends State<DroppedCardWidget> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool isTapped = false;
  bool canAttack = false;

  ////////////////////////////
  ///////    build     ///////
  ////////////////////////////
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.attack_stream,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          return Positioned(
              left: widget.left,
              bottom: widget.label == 'deck'
                  ? (widget.isSecondRow ? widget.r(20.0) : widget.r(170.0))
                  : (widget.isSecondRow ? widget.r(227.0) : widget.r(7.0)),
              child: Stack(children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isTapped = !isTapped;
                      });
                      widget.tapCardCallback('tapped',
                          int.parse(widget.cardInfo['card_id']), widget.index);
                    },
                    child: widget.label == 'deck'
                        // デッキ編集画面
                        ? Container(
                            width: widget.r(81.0),
                            height: widget.r(115.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(widget.imageUrl),
                                  fit: BoxFit.contain),
                            ),
                            child: Stack(children: <Widget>[
                              // デッキ編集のコストの表示
                              Positioned(
                                  left: 0.0,
                                  top: 0.0,
                                  child: SizedBox(
                                      width: widget.r(20.0),
                                      height: widget.r(26.0),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              widget.r(2.0)),
                                          child: Container(
                                              alignment: Alignment.topCenter,
                                              color: widget.cardInfo?['type'] ==
                                                      '0'
                                                  ? Colors.red
                                                  : (widget.cardInfo?['type'] ==
                                                          '1'
                                                      ? const Color.fromARGB(
                                                          255, 170, 153, 1)
                                                      : Colors.grey),
                                              child: Text(
                                                  widget.cardInfo == null
                                                      ? ''
                                                      : widget
                                                          .cardInfo?['cost'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: widget.r(20.0),
                                                  )))))),
                              widget.cardInfo?['bp'] == '0'
                                  ? Container()
                                  // デッキ編集のBPの表示
                                  : Positioned(
                                      right: 0.0,
                                      bottom: 0.0,
                                      child: SizedBox(
                                          width: widget.r(60.0),
                                          height: widget.r(19.0),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      widget.r(2.0)),
                                              child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  color: const Color.fromARGB(
                                                      255, 52, 51, 51),
                                                  child: Text(
                                                      widget.cardInfo == null
                                                          ? ''
                                                          : widget
                                                              .cardInfo?['bp'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontSize: 16.0,
                                                      )))))),
                            ]))
                        // デッキ編集以外の画面
                        : Container(
                            width: widget.label == 'unit'
                                ? widget.r(105)
                                : widget.r(76), // TODO 380 / 440
                            height: widget.label == 'unit'
                                ? widget.r(150)
                                : widget.r(108), // TODO 380 / 440
                            child: widget.label == 'unit'
                                // フィールド
                                ? Stack(children: <Widget>[
                                    // ユニットの画像
                                    Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              alignment: Alignment.topLeft,
                                              image:
                                                  AssetImage(widget.imageUrl),
                                              fit: BoxFit.cover)),
                                    )
                                  ])
                                // トリガーゾーン
                                : Center(
                                    child: Padding(
                                    padding:
                                        EdgeInsets.only(bottom: widget.r(19.0)),
                                    child: Container(
                                      // トリガーカードの画像
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              alignment:
                                                  FractionalOffset.topCenter,
                                              image:
                                                  AssetImage(widget.imageUrl),
                                              fit: BoxFit.fitWidth)),
                                    ),
                                  )))),
                // タップ時のみ表示
                isTapped
                    ? (widget.label == 'deck'
                        ? Positioned(
                            left: widget.r(16.0),
                            top: widget.r(30.0),
                            child: FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                onPressed: () {
                                  widget.tapCardCallback(
                                      'remove',
                                      int.parse(widget.cardInfo['card_id']),
                                      widget.index);
                                  isTapped = false;
                                },
                                tooltip: 'Remove',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40.0),
                                  child: Image.asset(
                                    '${imagePath}button/remove.png',
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          )
                        : widget.label == 'unit' && snapshot.data == 1
                            ? Positioned(
                                left: widget.r(28.0),
                                top: widget.r(50.0),
                                child: FloatingActionButton(
                                    backgroundColor: Colors.transparent,
                                    onPressed: () {
                                      widget.tapCardCallback(
                                          'attack',
                                          int.parse(widget.cardInfo['card_id']),
                                          widget.index);
                                    },
                                    tooltip: 'Attack',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(widget.r(40.0)),
                                      child: Image.asset(
                                        '${imagePath}button/attack.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              )
                            : Container())
                    : Container(),
                widget.btnShowFlg
                    ? (widget.label == 'trigger'
                        ? Positioned(
                            left: widget.r(16.0),
                            top: widget.r(35.0),
                            child: FloatingActionButton(
                                backgroundColor: Colors.transparent,
                                onPressed: () {
                                  widget.tapCardCallback(
                                      'use',
                                      int.parse(widget.cardInfo['card_id']),
                                      widget.index);
                                  isTapped = false;
                                },
                                tooltip: 'Use',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40.0),
                                  child: Image.asset(
                                    '${imagePath}button/use.png',
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          )
                        : Container())
                    : Container()
              ]));
        });
  }
}

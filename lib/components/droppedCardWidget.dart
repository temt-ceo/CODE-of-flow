import 'package:flutter/material.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef void StringCallback(String val, int cardId, int? position);

class DroppedCardWidget extends StatefulWidget {
  final double left;
  final String imageUrl;
  final String label;
  final dynamic cardInfo;
  final bool isSecondRow;
  final StringCallback tapCardCallback;
  final int index;
  final bool canAttack;

  const DroppedCardWidget(this.left, this.imageUrl, this.label, this.cardInfo,
      this.isSecondRow, this.tapCardCallback, this.index, this.canAttack);

  @override
  DroppedCardState createState() => DroppedCardState();
}

class DroppedCardState extends State<DroppedCardWidget> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.left,
        bottom: widget.label == 'deck'
            ? (widget.isSecondRow ? 40.0 : 220.0)
            : (widget.isSecondRow ? 240.0 : 5.0),
        child: Stack(children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  isTapped = !isTapped;
                });
                widget.tapCardCallback(
                    'tapped', int.parse(widget.cardInfo['card_id']), null);
              },
              child: widget.label == 'deck'
                  ? Container(
                      width: 85.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(widget.imageUrl),
                            fit: BoxFit.contain),
                      ),
                      child: Stack(children: <Widget>[
                        Positioned(
                            left: 0.0,
                            top: 0.0,
                            child: SizedBox(
                                width: 20.0,
                                height: 26.0,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.0),
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        color: widget.cardInfo?['type'] == '0'
                                            ? Colors.red
                                            : (widget.cardInfo?['type'] == '1'
                                                ? const Color.fromARGB(
                                                    255, 170, 153, 1)
                                                : Colors.grey),
                                        child: Text(
                                            widget.cardInfo == null
                                                ? ''
                                                : widget.cardInfo?['cost'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              decoration: TextDecoration.none,
                                              fontSize: 20.0,
                                            )))))),
                        widget.cardInfo?['bp'] == '0'
                            ? Container()
                            : Positioned(
                                right: 0.0,
                                bottom: 0.0,
                                child: SizedBox(
                                    width: 60.0,
                                    height: 19.0,
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                        child: Container(
                                            alignment: Alignment.centerRight,
                                            color:
                                                Color.fromARGB(255, 52, 51, 51),
                                            child: Text(
                                                widget.cardInfo == null
                                                    ? ''
                                                    : widget.cardInfo?['bp'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 16.0,
                                                )))))),
                      ]))
                  : Container(
                      width: widget.label == 'unit' ? 110 : 88,
                      height: widget.label == 'unit' ? 155 : 125,
                      child: widget.label == 'unit'
                          ? Stack(children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        alignment: Alignment.topLeft,
                                        image: AssetImage(widget.imageUrl),
                                        fit: BoxFit.cover)),
                              )
                            ])
                          : Center(
                              child: Padding(
                              padding: const EdgeInsets.only(bottom: 19.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        alignment: FractionalOffset.topCenter,
                                        image: AssetImage(widget.imageUrl),
                                        fit: BoxFit.fitWidth)),
                              ),
                            )))),
          isTapped
              ? (widget.label == 'deck'
                  ? Positioned(
                      left: 16.0,
                      top: 30.0,
                      child: FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          onPressed: () {
                            widget.tapCardCallback(
                                'remove',
                                int.parse(widget.cardInfo['card_id']),
                                widget.index);
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
                  : widget.label == 'unit' && widget.canAttack
                      ? Positioned(
                          left: 28.0,
                          top: 50.0,
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
                                borderRadius: BorderRadius.circular(40.0),
                                child: Image.asset(
                                  '${imagePath}button/attack.png',
                                  fit: BoxFit.cover,
                                ),
                              )),
                        )
                      : Container())
              : Container(),
        ]));
  }
}

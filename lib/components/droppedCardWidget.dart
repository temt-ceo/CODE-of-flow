import 'package:flutter/material.dart';

class DroppedCardWidget extends StatefulWidget {
  final double left;
  final String imageUrl;
  final String label;
  final String cardIdStr;
  final bool isEnemy;

  const DroppedCardWidget(
      this.left, this.imageUrl, this.label, this.cardIdStr, this.isEnemy);

  @override
  DroppedCardState createState() => DroppedCardState();
}

class DroppedCardState extends State<DroppedCardWidget> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.left,
        bottom: widget.label == 'deck' ? 220.0 : (widget.isEnemy ? 240.0 : 5.0),
        child: Stack(children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  isTapped = !isTapped;
                });
              },
              child: Image.asset(
                widget.imageUrl,
                width: widget.label == 'deck'
                    ? 85
                    : (widget.label == 'unit' ? 110 : 88),
              )),
          isTapped
              ? FloatingActionButton(
                  onPressed: () => (),
                  tooltip: 'Use the card',
                  child: const Text('Use the card'),
                )
              : Container(),
        ]));
  }
}

import 'package:flutter/material.dart';

class DroppedCardWidget extends StatefulWidget {
  final double left;
  final String imageUrl;

  const DroppedCardWidget(this.left, this.imageUrl);

  @override
  DroppedCardState createState() => DroppedCardState();
}

class DroppedCardState extends State<DroppedCardWidget> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.left,
        bottom: 5.0,
        child: Stack(children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  isTapped = !isTapped;
                });
              },
              child: Image.asset(
                widget.imageUrl,
                width: 110,
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

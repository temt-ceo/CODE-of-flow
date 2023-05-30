import 'package:flutter/material.dart';

class DragBox extends StatefulWidget {
  final int cardId;
  final String imageUrl;

  const DragBox(this.cardId, this.imageUrl);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  bool isDroped = false;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      // delay: const Duration(milliseconds: 100),
      maxSimultaneousDrags: 1,
      data: widget.imageUrl,
      childWhenDragging: Container(
        width: 115,
      ),
      feedback: Container(
        margin: const EdgeInsets.only(left: 15.0),
        width: 100.0,
        height: 150.0,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(widget.imageUrl), fit: BoxFit.contain),
        ),
        child: Center(
          child: Text(widget.cardId.toString(),
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 18.0,
              )),
        ),
      ),
      onDragCompleted: () {
        setState(() {
          isDroped = true;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          isDroped = false;
        });
      },
      child: isDroped
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                width: 100.0,
                height: 150.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.imageUrl), fit: BoxFit.contain),
                ),
                child: Center(
                    child: Text(widget.cardId.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 20.0,
                        ))),
              ),
            ),
    );
  }
}

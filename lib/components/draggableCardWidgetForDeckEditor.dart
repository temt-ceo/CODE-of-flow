import 'package:flutter/material.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef void StringCallback(int? data);

class DragBoxForDeckEditor extends StatefulWidget {
  final int cardId;
  final StringCallback putCardCallback;

  const DragBoxForDeckEditor(this.cardId, this.putCardCallback);

  @override
  DragBoxForDeckEditorState createState() => DragBoxForDeckEditorState();
}

class DragBoxForDeckEditorState extends State<DragBoxForDeckEditor> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool isDroped = false;
  int maxCount = 3;

  @override
  Widget build(BuildContext context) {
    var imageUrl = widget.cardId > 16
        ? '${imagePath}trigger/card_${widget.cardId.toString()}.jpeg'
        : '${imagePath}unit/card_${widget.cardId.toString()}.jpeg';
    return Draggable(
      // delay: const Duration(milliseconds: 100),
      maxSimultaneousDrags: 1,
      data: widget.cardId.toString(),
      childWhenDragging: Container(
        width: 115,
      ),
      feedback: Container(
        margin: const EdgeInsets.only(left: 15.0),
        width: 100.0,
        height: 150.0,
        decoration: BoxDecoration(
          image:
              DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.contain),
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
          maxCount = maxCount - 1;
          isDroped = true;
        });
        widget.putCardCallback(widget.cardId);
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          isDroped = false;
        });
      },
      child: isDroped && maxCount == 0
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                width: 100.0,
                height: 150.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(imageUrl), fit: BoxFit.contain),
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

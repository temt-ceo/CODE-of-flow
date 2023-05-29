import 'package:flutter/material.dart';

class DragBox extends StatefulWidget {
  final String label;
  final String imageUrl;

  const DragBox(this.label, this.imageUrl);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  bool isDroped = false;

  @override
  Widget build(BuildContext context) {
    return Draggable(
      maxSimultaneousDrags: 1,
      data: widget.imageUrl,
      feedback: Container(
        width: 100.0,
        height: 150.0,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(widget.imageUrl), fit: BoxFit.contain),
        ),
        child: Center(
          child: Text(widget.label,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 18.0,
              )),
        ),
      ),
      childWhenDragging: Container(),
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
                    child: Text(widget.label,
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

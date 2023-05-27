import 'package:flutter/material.dart';

class DragBox extends StatefulWidget {
  final Offset initPos;
  final String label;
  final Color itemColor;
  final String imageUrl;

  const DragBox(this.initPos, this.label, this.itemColor, this.imageUrl);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          data: widget.imageUrl,
          feedback: Container(
            width: 120.0,
            height: 120.0,
            color: widget.itemColor.withOpacity(0.5),
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
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              position = offset;
            });
          },
          child: Container(
              width: 100.0,
              height: 150.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(widget.imageUrl), fit: BoxFit.contain),
              ),
              // color: widget.itemColor,
              child: Center(
                  child: Text(widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 20.0,
                      )))),
        ));
  }
}

import 'package:flutter/material.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef void StringCallback(int? data);

class DragBox extends StatefulWidget {
  final int cardId;
  final StringCallback putCardCallback;
  final dynamic cardInfo;

  const DragBox(this.cardId, this.putCardCallback, this.cardInfo);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool isDroped = false;

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
          isDroped = true;
        });
        widget.putCardCallback(widget.cardId);
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
                      image: AssetImage(imageUrl), fit: BoxFit.contain),
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
                                  borderRadius: BorderRadius.circular(2.0),
                                  child: Container(
                                      alignment: Alignment.centerRight,
                                      color: Color.fromARGB(255, 52, 51, 51),
                                      child: Text(
                                          widget.cardInfo == null
                                              ? ''
                                              : widget.cardInfo?['bp'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            decoration: TextDecoration.none,
                                            fontSize: 16.0,
                                          )))))),
                ]),
              ),
            ),
    );
  }
}

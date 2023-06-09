import 'package:flutter/material.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef void StringCallback(int? data);
typedef double ResponsiveSizeChangeFunction(double data);

class DragBoxForDeckEditor extends StatefulWidget {
  final int cardId;
  final StringCallback putCardCallback;
  final dynamic cardInfo;
  int? pushBackedCardId;
  final ResponsiveSizeChangeFunction r;

  DragBoxForDeckEditor(this.cardId, this.putCardCallback, this.cardInfo,
      this.pushBackedCardId, this.r);

  @override
  DragBoxForDeckEditorState createState() => DragBoxForDeckEditorState();
}

class DragBoxForDeckEditorState extends State<DragBoxForDeckEditor> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool isDroped = false;
  int maxCount = 3;

  @override
  Widget build(BuildContext context) {
    // デッキから返却されたカードを+1
    if (widget.pushBackedCardId != null &&
        widget.pushBackedCardId == widget.cardId &&
        maxCount < 3) {
      setState(() => maxCount = maxCount + 1);
      setState(() => widget.pushBackedCardId = null);
    }
    var imageUrl = widget.cardId > 16
        ? '${imagePath}trigger/card_${widget.cardId.toString()}.jpeg'
        : '${imagePath}unit/card_${widget.cardId.toString()}.jpeg';

    return Draggable(
        // delay: const Duration(milliseconds: 100),
        maxSimultaneousDrags: 1,
        data: widget.cardId.toString(),
        childWhenDragging: Container(
          width: widget.r(115),
        ),
        feedback: Container(
            margin: EdgeInsets.only(left: widget.r(15.0)),
            width: widget.r(100.0),
            height: widget.r(150.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageUrl), fit: BoxFit.contain),
            ),
            child: Stack(children: <Widget>[
              Positioned(
                  left: 0.0,
                  top: 0.0,
                  child: SizedBox(
                      width: widget.r(20.0),
                      height: widget.r(26.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.r(2.0)),
                          child: Container(
                              alignment: Alignment.topCenter,
                              color: widget.cardInfo?['type'] == '0'
                                  ? Colors.red
                                  : (widget.cardInfo?['type'] == '1'
                                      ? const Color.fromARGB(255, 170, 153, 1)
                                      : Colors.grey),
                              child: Text(
                                  widget.cardInfo == null
                                      ? ''
                                      : widget.cardInfo?['cost'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                    fontSize: widget.r(20.0),
                                  )))))),
            ])),
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
                padding: EdgeInsets.only(left: widget.r(15.0)),
                child: Container(
                  width: widget.r(100.0),
                  height: widget.r(150.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(imageUrl), fit: BoxFit.contain),
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                        left: 0.0,
                        top: 0.0,
                        child: SizedBox(
                            width: widget.r(20.0),
                            height: widget.r(26.0),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(widget.r(2.0)),
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                          fontSize: widget.r(20.0),
                                        )))))),
                    Positioned(
                        right: 0.0,
                        bottom: 0.0,
                        child: SizedBox(
                            width: widget.r(26.0),
                            height: widget.r(26.0),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(widget.r(2.0)),
                                child: Container(
                                    alignment: Alignment.bottomRight,
                                    color: Colors.white,
                                    child: Text('x${maxCount.toString()}',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 52, 51, 51),
                                          decoration: TextDecoration.none,
                                          fontSize: widget.r(20.0),
                                        )))))),
                  ]),
                ),
              ));
  }
}

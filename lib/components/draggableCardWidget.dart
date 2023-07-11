import 'package:flutter/material.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef void StringCallback(int? data);
typedef double ResponsiveSizeChangeFunction(double data);

class DragBox extends StatefulWidget {
  final int? index;
  final int cardId;
  final StringCallback putCardCallback;
  final dynamic cardInfo;
  final ResponsiveSizeChangeFunction r;
  final bool isMobile;

  const DragBox(this.index, this.cardId, this.putCardCallback, this.cardInfo,
      this.r, this.isMobile);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  bool isDroped = false;
  int currentIndex = -1;
  int currentId = -1;

  ////////////////////////////
  ///////    build     ///////
  ////////////////////////////
  @override
  Widget build(BuildContext context) {
    var imageUrl = widget.cardId > 16
        ? '${imagePath}trigger/${widget.isMobile ? 'mobile/' : ''}card_${widget.cardId.toString()}.jpeg'
        : '${imagePath}unit/${widget.isMobile ? 'mobile/' : ''}card_${widget.cardId.toString()}.jpeg';
    if (widget.index != null) {
      if (currentIndex == -1) {
        currentIndex = widget.index!;
        currentId = widget.cardId;
      } else if (currentIndex != widget.index! || currentId != widget.cardId) {
        setState(() {
          isDroped = false;
        });
        currentIndex = widget.index!;
        currentId = widget.cardId;
      }
    }
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
          image:
              DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.contain),
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
              padding: EdgeInsets.only(left: widget.r(10.0)),
              child:
                  // child: Column(children: [
                  Container(
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
                  widget.cardInfo?['bp'] == '0'
                      ? Container()
                      : Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: SizedBox(
                              width: widget.r(60.0),
                              height: widget.r(19.0),
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(widget.r(2.0)),
                                  child: Container(
                                      alignment: Alignment.centerRight,
                                      color:
                                          const Color.fromARGB(255, 52, 51, 51),
                                      child: Text(
                                          widget.cardInfo == null
                                              ? ''
                                              : widget.cardInfo?['bp'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            decoration: TextDecoration.none,
                                            fontSize: widget.r(16.0),
                                          )))))),
                  Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: SizedBox(
                          width: widget.r(65.0),
                          height: widget.r(18.0),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0)),
                              child: Container(
                                  alignment: Alignment.topCenter,
                                  color: const Color.fromARGB(255, 52, 51, 51),
                                  child: Text(
                                      widget.cardInfo == null
                                          ? ''
                                          : widget.cardInfo?['category'] == '0'
                                              ? 'Unit'
                                              : (widget.cardInfo?['category'] ==
                                                      '1'
                                                  ? 'Trigger'
                                                  : 'Intercept'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
                                        // textBaseline: TextBaseline.ideographic,
                                        fontSize: widget.r(13.0),
                                      )))))),
                ]),
              ),
              // ]),
            ),
    );
  }
}

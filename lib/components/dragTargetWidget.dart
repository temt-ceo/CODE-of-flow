import 'package:flutter/material.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_bloc.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_event.dart';
import 'package:CodeOfFlow/components/droppedCardWidget.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';

const envFlavor = String.fromEnvironment('flavor');

class DragTargetWidget extends StatefulWidget {
  final String label;
  final String imageUrl;
  final GameObject? info;
  final dynamic cardInfos;

  const DragTargetWidget(this.label, this.imageUrl, this.info, this.cardInfos);

  @override
  DragTargetState createState() => DragTargetState();
}

class DragTargetState extends State<DragTargetWidget> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  List<Widget> dropedList = [
    const Positioned(
        left: 225.0,
        top: 30.0,
        child: Text(
          "",
          style: TextStyle(color: Colors.white, fontSize: 28.0),
        )),
  ];
  final DropAllowBloc _dropBloc = DropAllowBloc();

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(onAccept: (String cardIdStr) {
      var cardId = int.parse(cardIdStr);
      var imageUrl = cardId > 16
          ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
          : '${imagePath}unit/card_${cardId.toString()}.jpeg';
      dropedList.add(DroppedCardWidget(
        widget.label == 'unit'
            ? 135.0 * (dropedList.length - 1) + 20
            : 108.0 * (dropedList.length - 1) + 20,
        imageUrl,
        widget.label,
      ));
      _dropBloc.counterEventSink.add(DropLeaveEvent());
    }, onWillAccept: (String? cardIdStr) {
      var cardId = int.parse(cardIdStr!);
      var imageUrl = cardId > 16
          ? '${imagePath}trigger/card_${cardId.toString()}.jpeg'
          : '${imagePath}unit/card_${cardId.toString()}.jpeg';

      if (widget.label == 'unit' && imageUrl.startsWith('${imagePath}unit')) {
        if (widget.info != null) {
          // カード情報がない。
          if (widget.cardInfos == null || widget.cardInfos[cardIdStr] == null) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            return false;
          }
          var cardData = widget.cardInfos[cardIdStr];
          if (int.parse(cardData['cost']) > widget.info!.yourCp) {
            _dropBloc.counterEventSink.add(DropDeniedEvent());
            return false;
          }
        }
        _dropBloc.counterEventSink.add(DropAllowedEvent());
        return true;
      } else if (widget.label == 'trigger' &&
          imageUrl!.startsWith('${imagePath}trigger')) {
        _dropBloc.counterEventSink.add(DropAllowedEvent());
        return true;
      } else {
        _dropBloc.counterEventSink.add(DropDeniedEvent());
        return false;
      }
    }, onLeave: (String? item) {
      _dropBloc.counterEventSink.add(DropLeaveEvent());
    }, builder: (
      BuildContext context,
      List<dynamic> accepted,
      List<dynamic> rejected,
    ) {
      return StreamBuilder(
          stream: _dropBloc.bg_color,
          initialData: 0xFFFFFFFF,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            return Container(
              width: widget.label == 'unit' ? 700.0 : 440.0,
              height: widget.label == 'unit' ? 400.0 : 132.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(widget.imageUrl), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Color(snapshot.data ?? 0xFFFFFFFF),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(2, 5), // changes position of shadow
                  ),
                ],
              ),
              child: Stack(
                children: dropedList,
              ),
            );
          });
    });
  }
}

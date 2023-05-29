import 'package:flutter/material.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_bloc.dart';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_event.dart';
import 'package:CodeOfFlow/components/droppedCardWidget.dart';

const env_flavor = String.fromEnvironment('flavor');

class DragTargetWidget extends StatefulWidget {
  final String label;
  final String imageUrl;

  const DragTargetWidget(this.label, this.imageUrl);

  @override
  DragTargetState createState() => DragTargetState();
}

class DragTargetState extends State<DragTargetWidget> {
  String imagePath = env_flavor == 'prod' ? 'assets/image/' : 'image/';
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
    return DragTarget<String>(onAccept: (String imageUrl) {
      dropedList.add(DroppedCardWidget(
        135.0 * (dropedList.length - 1) + 20,
        imageUrl,
      ));
      _dropBloc.counterEventSink.add(DropLeaveEvent());
    }, onWillAccept: (String? imageUrl) {
      if (widget.label == 'unit' && imageUrl!.startsWith('${imagePath}unit')) {
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
              width: widget.label == 'unit' ? 700.0 : 550.0,
              height: widget.label == 'unit' ? 400.0 : 165.0,
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

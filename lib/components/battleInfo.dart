import 'package:flutter/material.dart';

class BattleInfo extends StatefulWidget {
  final String label;

  const BattleInfo(this.label);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<BattleInfo> {
  // Offset position = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    // position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return const Stack(children: <Widget>[
      Positioned(
          left: 20.0,
          top: 10.0,
          child: Text('Opponent Life: 7 🔷🔷🔷🔷🔷🔷🔷',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 70.0,
          top: 50.0,
          child: Text('CP 04',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 70.0,
          top: 80.0,
          child: Text('Dead 0',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 400.0,
          top: 10.0,
          child: Text('Deck 22',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 320.0,
          top: 50.0,
          child: Text('Hand 5 🔶🔶🔶🔶🔶',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 320.0,
          top: 80.0,
          child: Text('Trigger Zone: 🔲🔲🔳🔳',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 20.0,
          top: 120.0,
          child: Text('You Life: 7 🔷🔷🔷🔷🔷🔷🔷',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 70.0,
          top: 160.0,
          child: Text('CP 04',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 1250.0,
          bottom: 140.0,
          child: Text('Deck 22',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 1250.0,
          bottom: 100.0,
          child: Text('Dead 0',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 30.0,
          bottom: 100.0,
          width: 270.0,
          child: Text('テキストテキストテキストテキストテキストテキストテキストテキスト',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 16.0,
              ))),
    ]);
  }
}

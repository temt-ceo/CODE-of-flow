import 'package:flutter/material.dart';
import 'package:CodeOfFlow/models/on_going_info_model.dart';

const envFlavor = String.fromEnvironment('flavor');

class OnGoingGameInfo extends StatefulWidget {
  final GameObject? info;
  final String cardText;

  const OnGoingGameInfo(this.info, this.cardText);

  @override
  OnGoingGameInfoState createState() => OnGoingGameInfoState();
}

class OnGoingGameInfoState extends State<OnGoingGameInfo> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  // Offset position = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    // position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      const Positioned(
          left: 20.0,
          top: 65.0,
          child: Text('Enemy:',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var index in [0, 1, 2, 3, 4, 5])
        Positioned(
          left: 120.0 + index * 26,
          top: 68.0,
          child: Container(
            width: 25.0,
            height: 25.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}button/enemyLife.png'),
                  fit: BoxFit.cover),
              boxShadow: const [
                BoxShadow(
                  color: Colors.yellow,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      Positioned(
          left: 70.0,
          top: 100.0,
          child: Text('CP 04',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var index in [0, 1, 2, 3])
        Positioned(
          left: 140.0 + index * 20,
          top: 105.0,
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}button/cp.png'),
                  fit: BoxFit.cover),
              boxShadow: const [
                BoxShadow(
                  color: Colors.yellow,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(-1, 0), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      Positioned(
          left: 70.0,
          top: 130.0,
          child: Text('Dead 0 / Deck 22',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      const Positioned(
          left: 320.0,
          top: 100.0,
          child: Text('Hand',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var index in [0, 1, 2, 3, 4])
        Positioned(
          left: 400.0 + index * 21,
          top: 103.0,
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}button/enemyHand.png'),
                  fit: BoxFit.cover),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 41, 39, 176),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      Positioned(
          left: 320.0,
          top: 130.0,
          child: Text('Trigger',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var index in [0, 1])
        Positioned(
          left: 400.0 + index * 26,
          top: 133.0,
          child: Container(
            width: 25.0,
            height: 25.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}button/enemyHand.png'),
                  fit: BoxFit.cover),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 41, 39, 176),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      const Positioned(
          left: 20.0,
          top: 175.0,
          child: Text('Your Life:',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var index in [0, 1, 2, 3, 4, 5])
        Positioned(
          left: 120.0 + index * 26,
          top: 178.0,
          child: Container(
            width: 25.0,
            height: 25.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}button/yourLife.png'),
                  fit: BoxFit.cover),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 41, 39, 176),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      Positioned(
          left: 70.0,
          top: 210.0,
          child: Text('CP 04',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var index in [0, 1, 2, 3])
        Positioned(
          left: 140.0 + index * 20,
          top: 215.0,
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('${imagePath}button/cp.png'),
                  fit: BoxFit.cover),
              boxShadow: const [
                BoxShadow(
                  color: Colors.yellow,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(-1, 0), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      Positioned(
          left: 1250.0,
          top: 540.0,
          child: Text('Deck 22',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 1250.0,
          top: 500.0,
          child: Text('Dead 0',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 30.0,
          top: 490.0,
          width: 270.0,
          child: Text(widget.cardText,
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 16.0,
              ))),
    ]);
  }
}

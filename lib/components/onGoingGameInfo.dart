import 'package:flutter/material.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
      for (var i = 0; i < widget.info!.opponentLife; i++)
        Positioned(
          left: 120.0 + i * 26,
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
          child: Text(
              'CP ${widget.info != null ? (widget.info!.opponentCp < 10 ? '0${widget.info!.opponentCp}' : widget.info!.opponentCp) : '--'}',
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var i = 0; i < widget.info!.opponentCp; i++)
        Positioned(
          left: 140.0 + i * 20,
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
          child: Text(
              'Dead - / Deck ${widget.info != null ? widget.info!.opponentRemainDeck : '--'}',
              style: const TextStyle(
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
      for (var i = 0; i < widget.info!.opponentHand; i++)
        Positioned(
          left: 400.0 + i * 21,
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
      const Positioned(
          left: 320.0,
          top: 130.0,
          child: Text('Trigger',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var i = 0; i < widget.info!.opponentTriggerCards; i++)
        Positioned(
          left: 400.0 + i * 26,
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
      for (var i = 0; i < widget.info!.yourLife; i++)
        Positioned(
          left: 120.0 + i * 26,
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
          child: Text(
              'CP ${widget.info != null ? (widget.info!.yourCp < 10 ? '0${widget.info!.yourCp}' : widget.info!.yourCp) : '--'}',
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      for (var i = 0; i < widget.info!.yourCp; i++)
        Positioned(
          left: 140.0 + i * 20,
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
          left: 1320.0,
          top: 540.0,
          child: Text(
              'Deck ${widget.info != null ? widget.info!.yourRemainDeck.length : '--'}',
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 22.0,
              ))),
      Positioned(
          left: 1320.0,
          top: 500.0,
          child: Text('Dead -',
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
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 16.0,
              ))),
      Positioned(
        left: 330.0,
        top: 0.0,
        child: Visibility(
            visible: widget.info != null
                ? widget.info!.isFirst != widget.info!.isFirstTurn
                : false,
            child: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: 0.5,
              center: const Column(children: <Widget>[
                SizedBox(height: 30.0),
                Text("50%",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 22.0,
                    )),
              ]),
              progressColor: const Color.fromARGB(255, 1, 247, 42),
            )),
      ),
      Positioned(
          left: 1190.0,
          top: 480.0,
          child: Visibility(
            visible: widget.info != null
                ? widget.info!.isFirst == widget.info!.isFirstTurn
                : true,
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: 0.5,
              center: Column(children: <Widget>[
                const SizedBox(height: 10.0),
                const Text("50%",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 22.0,
                    )),
                SizedBox(
                    width: 90.0,
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () async {
                          // if (gameStarted == true || cyberEnergy == null) {
                          // } else {
                          //   if (cyberEnergy! < 30) {
                          //     buyCyberEnergy();
                          //   } else {
                          //     //GraphQL:player_matching
                          //     await gameStart();
                          //     countdown();
                          //   }
                          // }
                        },
                        tooltip: 'Play',
                        child: Image.asset(
                          '${imagePath}button/turnChangeEn.png',
                          fit: BoxFit.cover,
                        )))
              ]),
              progressColor: const Color.fromARGB(255, 1, 247, 42),
            ),
          )),
    ]);
  }
}

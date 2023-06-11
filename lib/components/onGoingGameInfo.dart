import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:CodeOfFlow/models/onGoingInfoModel.dart';
import 'package:CodeOfFlow/services/api_service.dart';

const envFlavor = String.fromEnvironment('flavor');
typedef double ResponsiveSizeChangeFunction(double data);

class OnGoingGameInfo extends StatefulWidget {
  final GameObject? info;
  final String cardText;
  final ResponsiveSizeChangeFunction r;

  const OnGoingGameInfo(this.info, this.cardText, this.r);

  @override
  OnGoingGameInfoState createState() => OnGoingGameInfoState();
}

class OnGoingGameInfoState extends State<OnGoingGameInfo> {
  String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  APIService apiService = APIService();
  BuildContext? loadingContext;

  void showGameLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (buildContext) {
        loadingContext = buildContext;
        return Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void closeGameLoading() {
    if (loadingContext != null) {
      Navigator.pop(loadingContext!);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime lastTurnEndTime;
    double percentIndicatorValue = 1.0;
    int turn = 0;
    bool isFirst = false;
    bool isFirstTurn = false;

    // ターン、先行後攻、現在は先行のターンか
    if (turn != widget.info!.turn) {
      setState(() {
        turn = widget.info!.turn;
      });
    }
    if (isFirst != widget.info!.isFirst) {
      setState(() {
        isFirst = widget.info!.isFirst;
      });
    }
    if (isFirstTurn != widget.info!.isFirstTurn) {
      setState(() {
        isFirstTurn = widget.info!.isFirstTurn;
      });
    }

    // 残り時間
    if (widget.info!.lastTimeTurnend != null) {
      lastTurnEndTime = DateTime.fromMillisecondsSinceEpoch(
          double.parse(widget.info!.lastTimeTurnend!).toInt() * 1000);
      final turnEndTime = lastTurnEndTime.add(const Duration(seconds: 65));
      final now = DateTime.now();

      if (turnEndTime.difference(now).inSeconds < 0) {
        setState(() {
          percentIndicatorValue = 0.0;
        });
      } else {
        var displayValue = turnEndTime.difference(now).inSeconds / 65;
        setState(() {
          percentIndicatorValue = displayValue > 1 ? 1 : displayValue;
        });
      }
    }

    return Stack(children: <Widget>[
      Positioned(
          left: widget.r(20.0),
          top: widget.r(65.0),
          child: Text('Enemy:',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      for (var i = 0; i < widget.info!.opponentLife; i++)
        Positioned(
          left: widget.r(150.0 + i * 26),
          top: widget.r(68.0),
          child: Container(
            width: widget.r(25.0),
            height: widget.r(25.0),
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
          left: widget.r(80.0),
          top: widget.r(100.0),
          child: Text(
              'CP ${widget.info != null ? (widget.info!.opponentCp < 10 ? '0${widget.info!.opponentCp}' : widget.info!.opponentCp) : '--'}',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      for (var i = 0; i < widget.info!.opponentCp; i++)
        Positioned(
          left: widget.r(152.0 + i * 20),
          top: widget.r(105.0),
          child: Container(
            width: widget.r(20.0),
            height: widget.r(20.0),
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
          left: widget.r(80.0),
          top: widget.r(130.0),
          child: Text(
              'Dead - / Deck ${widget.info != null ? widget.info!.opponentRemainDeck : '--'}',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      Positioned(
          left: widget.r(320.0),
          top: widget.r(100.0),
          child: Text('Hand',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      for (var i = 0; i < widget.info!.opponentHand; i++)
        Positioned(
          left: widget.r(400.0 + i * 21),
          top: widget.r(103.0),
          child: Container(
            width: widget.r(20.0),
            height: widget.r(20.0),
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
          left: widget.r(320.0),
          top: widget.r(130.0),
          child: Text('Trigger',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      for (var i = 0; i < widget.info!.opponentTriggerCards; i++)
        Positioned(
          left: widget.r(400.0 + i * 26),
          top: widget.r(133.0),
          child: Container(
            width: widget.r(25.0),
            height: widget.r(25.0),
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
          left: widget.r(20.0),
          top: widget.r(205.0),
          child: Text('Your Life:',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      for (var i = 0; i < widget.info!.yourLife; i++)
        Positioned(
          left: widget.r(150.0 + i * 26),
          top: widget.r(208.0),
          child: Container(
            width: widget.r(25.0),
            height: widget.r(25.0),
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
          left: widget.r(80.0),
          top: widget.r(240.0),
          child: Text(
              'CP ${widget.info != null ? (widget.info!.yourCp < 10 ? '0${widget.info!.yourCp}' : widget.info!.yourCp) : '--'}',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      for (var i = 0; i < widget.info!.yourCp; i++)
        Positioned(
          left: widget.r(152.0 + i * 20),
          top: widget.r(245.0),
          child: Container(
            width: widget.r(20.0),
            height: widget.r(20.0),
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
          left: widget.r(1320.0),
          top: widget.r(540.0),
          child: Text(
              'Deck ${widget.info != null ? widget.info!.yourRemainDeck.length : '--'}',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      Positioned(
          left: widget.r(1320.0),
          top: widget.r(500.0),
          child: Text('Dead -',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(22.0),
              ))),
      Positioned(
          left: widget.r(30.0),
          top: widget.r(490.0),
          width: widget.r(270.0),
          child: Text(widget.cardText,
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: widget.r(16.0),
              ))),
      Positioned(
        left: widget.r(330.0),
        top: 0.0,
        child: Visibility(
            visible: widget.info != null
                ? widget.info!.isFirst != widget.info!.isFirstTurn
                : false,
            child: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: percentIndicatorValue,
              backgroundWidth: 0.0,
              center: Column(children: <Widget>[
                SizedBox(height: widget.r(30.0)),
                Text(
                    int.parse((percentIndicatorValue * 100).toString())
                        .toString(),
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    )),
              ]),
              progressColor: const Color.fromARGB(255, 1, 247, 42),
            )),
      ),
      Positioned(
          left: widget.r(1190.0),
          top: widget.r(480.0),
          child: Visibility(
            visible: widget.info != null
                ? widget.info!.isFirst == widget.info!.isFirstTurn
                : true,
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: percentIndicatorValue,
              backgroundWidth: 0.0,
              center: Column(children: <Widget>[
                const SizedBox(height: 10.0),
                Text('${percentIndicatorValue.toString()} s',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: widget.r(22.0),
                    )),
                SizedBox(
                    width: widget.r(90.0),
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () async {
                          showGameLoading();
                          var ret = await apiService.saveGameServerProcess(
                              'turn_change', '', widget.info!.you.toString());
                          closeGameLoading();
                          debugPrint('transaction published');
                          debugPrint(ret.toString());
                          if (ret != null) {
                            debugPrint(ret.message);
                          }
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

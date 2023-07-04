import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flash/flash.dart';
import 'package:percent_indicator/percent_indicator.dart';

const envFlavor = String.fromEnvironment('flavor');

typedef double ResponsiveSizeChangeFunction(double data);

class PlayerInfo extends StatelessWidget {
  final ResponsiveSizeChangeFunction r;

  const PlayerInfo(
      {Key? key,
      required this.onPressed,
      required this.rank,
      required this.point,
      required this.playerName,
      required this.win,
      required this.icon,
      required this.rank1win,
      required this.rank2win,
      required this.r})
      : super(key: key);

  final VoidCallback? onPressed;
  final int rank;
  final int point;
  final String playerName;
  final int win;
  final Image icon;
  final int rank1win;
  final int rank2win;
  final String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';

  @override
  Widget build(BuildContext context) {
    return Container(
        height: r(50.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Container(
            height: r(50.0),
            color: rank == 1
                ? const Color.fromARGB(255, 175, 149, 0)
                : rank == 2
                    ? const Color.fromARGB(255, 215, 215, 215)
                    : rank == 3
                        ? const Color.fromARGB(255, 106, 56, 5)
                        : const Color.fromARGB(255, 251, 249, 249),
            child: Stack(children: <Widget>[
              Padding(
                padding: rank <= 3
                    ? EdgeInsets.only(top: r(4.0))
                    : rank <= 9
                        ? EdgeInsets.only(top: r(10.0), left: r(7.0))
                        : EdgeInsets.only(top: r(10.0), left: r(10.0)),
                child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: rank <= 9
                        ? IconButton(
                            onPressed: onPressed,
                            iconSize: rank <= 3 ? r(50.0) : r(30.0),
                            icon: icon)
                        : Text(rank.toString(),
                            style: TextStyle(
                                color: rank <= 3
                                    ? const Color.fromARGB(255, 247, 245, 245)
                                    : const Color.fromARGB(255, 0, 0, 0),
                                fontSize: r(18.0)))),
              ),
              Positioned(
                left: r(70.0),
                top: r(12.0),
                child: Container(
                  width: r(20.0),
                  height: r(20.0),
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
                  left: r(100.0),
                  top: r(7.0),
                  child: Text('$point Point',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(18.0)))),
              Positioned(
                  left: r(250.0),
                  top: r(7.0),
                  child: Text(playerName,
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(18.0)))),
              Positioned(
                  left: r(400.0),
                  top: r(7.0),
                  child: Text('$win Win',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(14.0)))),
              Positioned(
                  left: r(100.0),
                  top: r(27.0),
                  child: Text('History',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(12.0)))),
              Positioned(
                  left: r(170.0),
                  top: r(27.0),
                  child: Text('Ranking 1st. 0 times Win',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(12.0)))),
              Positioned(
                  left: r(360.0),
                  top: r(27.0),
                  child: Text('Ranking 2nd. 0 times Win',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(12.0)))),
            ])));
  }
}

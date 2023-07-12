import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flash/flash.dart';
import 'package:percent_indicator/percent_indicator.dart';

const envFlavor = String.fromEnvironment('flavor');

class PlayerInfo extends StatelessWidget {
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
      required this.wRes})
      : super(key: key);

  final VoidCallback? onPressed;
  final int rank;
  final int point;
  final String playerName;
  final int win;
  final String icon;
  final int rank1win;
  final int rank2win;
  final double wRes;
  final String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  double r(double val) {
    return val * wRes;
  }

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
              Positioned(
                  left: r(10.0),
                  top: r(14.0),
                  child: rank <= 9
                      ? Container(
                          width: r(20.0),
                          height: r(20.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(icon), fit: BoxFit.cover),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.yellow,
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset:
                                    Offset(1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                        )
                      : Text(rank.toString(),
                          style: TextStyle(
                              color: rank == 1 || rank == 3
                                  ? const Color.fromARGB(255, 247, 245, 245)
                                  : const Color.fromARGB(255, 0, 0, 0),
                              fontSize: r(18.0)))),
              Positioned(
                left: r(70.0),
                top: r(14.0),
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
                  left: r(120.0),
                  top: r(7.0),
                  child: Text('$point Points',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 221, 32, 32)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(18.0)))),
              Positioned(
                  left: r(260.0),
                  top: r(7.0),
                  child: Text(playerName,
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(18.0)))),
              Positioned(
                  left: r(500.0),
                  top: r(10.0),
                  child: Text('$win Win',
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(14.0)))),
              Positioned(
                  left: r(120.0),
                  top: r(30.0),
                  child: Text('History',
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(12.0)))),
              Positioned(
                  left: r(220.0),
                  top: r(30.0),
                  child: Text('Ranking 1st. 0 times Win',
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(12.0)))),
              Positioned(
                  left: r(460.0),
                  top: r(30.0),
                  child: Text('Ranking 2nd. 0 times Win',
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(12.0)))),
            ])));
  }
}

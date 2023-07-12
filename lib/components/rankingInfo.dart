import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flash/flash.dart';
import 'package:percent_indicator/percent_indicator.dart';

const envFlavor = String.fromEnvironment('flavor');

class RankingInfo extends StatelessWidget {
  const RankingInfo({
    Key? key,
    required this.onPressed,
    required this.rank,
    required this.point,
    required this.playerName,
    required this.win,
    required this.icon,
    required this.wRes,
    required this.prizePosition,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final int rank;
  final int point;
  final String playerName;
  final int win;
  final String icon;
  final double wRes;
  final String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';
  final int prizePosition;
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
                top: r(15.0),
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
                  top: r(9.0),
                  child: Text('$point Points',
                      style: TextStyle(
                          color: rank <= 3
                              ? const Color.fromARGB(255, 221, 32, 32)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(23.0)))),
              Positioned(
                  left: r(250.0),
                  top: r(9.0),
                  child: Text(playerName,
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(23.0)))),
              Positioned(
                  left: r(480.0),
                  top: r(12.0),
                  child: Text('$win Win',
                      style: TextStyle(
                          color: rank == 1 || rank == 3
                              ? const Color.fromARGB(255, 247, 245, 245)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: r(19.0)))),
              Visibility(
                  visible: prizePosition == 1,
                  child: Positioned(
                    left: r(520.0),
                    top: r(5.0),
                    child: Container(
                      width: r(129.0),
                      height: r(36.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('${imagePath}button/20_FLOW.png'),
                        ),
                      ),
                    ),
                  )),
              Visibility(
                  visible: prizePosition == 2,
                  child: Positioned(
                    left: r(520.0),
                    top: r(5.0),
                    child: Container(
                      width: r(129.0),
                      height: r(36.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('${imagePath}button/10_FLOW.png'),
                        ),
                      ),
                    ),
                  )),
              Visibility(
                  visible: prizePosition == 3,
                  child: Positioned(
                    left: r(520.0),
                    top: r(5.0),
                    child: Container(
                      width: r(129.0),
                      height: r(36.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('${imagePath}button/5_FLOW.png'),
                        ),
                      ),
                    ),
                  )),
            ])));
  }
}

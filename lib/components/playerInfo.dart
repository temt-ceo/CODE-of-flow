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
      {Key? key, required this.onPressed, required this.icon, required this.r})
      : super(key: key);

  final VoidCallback? onPressed;
  final Icon icon;
  final String imagePath = envFlavor == 'prod' ? 'assets/image/' : 'image/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(children: <Widget>[
      Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.primary,
          elevation: 4.0,
          child: IconButton(onPressed: onPressed, icon: icon)),
      Positioned(
          left: r(150.0), top: r(7.0), child: const Text("AAAAAAAAAAAA")),
      Positioned(
        left: r(50.0),
        top: r(7.0),
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
    ]);
  }
}

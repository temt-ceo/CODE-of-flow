import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

import 'package:CodeOfFlow/pages/desktop/homePage.dart';
import 'package:CodeOfFlow/pages/desktop/deckEditPage.dart';
import 'package:CodeOfFlow/pages/desktop/rankingPage.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

typedef void StringCallback(Locale val);

class MobileBody extends StatefulWidget {
  final String title;
  final String route;
  final StringCallback localeCallback;
  MobileBody(
      {super.key,
      required this.title,
      required this.route,
      required this.localeCallback});

  @override
  State<MobileBody> createState() => MobileBodyState();
}

class MobileBodyState extends State<MobileBody> {
  bool activeLocale = ui.window.locale.toString() == 'ja' ? false : true;

  @override
  Widget build(BuildContext context) {
    void changeSwitch(bool changed) {
      setState(() {
        activeLocale = changed;
      });
      Locale _locale = changed == true ? Locale('en') : Locale('ja');
      widget.localeCallback(_locale);
    }

    final wRes = MediaQuery.of(context).size.width / desktopWidth;
    double r(double val) {
      return val * wRes;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.route == 'Home'
          ? AppBar(
              backgroundColor: Colors.transparent,
              title: Text(widget.title,
                  style: TextStyle(color: Colors.white, fontSize: r(30.0))),
              flexibleSpace: Stack(children: <Widget>[
                Positioned(
                    top: r(22.0),
                    left: r(40.0),
                    child: SizedBox(
                        width: r(50),
                        height: r(35),
                        child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              value: activeLocale,
                              activeColor: Colors.black,
                              activeTrackColor: Colors.blueGrey,
                              inactiveThumbColor: Colors.black,
                              inactiveTrackColor: Colors.blueGrey,
                              onChanged: changeSwitch,
                            )))),
                Positioned(
                  top: r(25.0),
                  left: r(90.0),
                  child: Text(activeLocale == true ? 'EN' : 'JP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r(20.0),
                      )),
                ),
                Positioned(
                  top: r(105.0),
                  left: r(240.0),
                  child: Text(L10n.of(context)!.rollScreen,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: r(36.0),
                      )),
                ),
                Positioned(
                  top: r(140.0),
                  left: r(120.0),
                  child: Text(L10n.of(context)!.crashHappen,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: r(32.0),
                      )),
                ),
              ]),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.reply, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(widget.title,
                  style: TextStyle(color: Colors.white, fontSize: r(30.0))),
              flexibleSpace: Stack(children: <Widget>[
                Positioned(
                    top: r(4.0),
                    right: r(40.0),
                    child: SizedBox(
                        width: r(50),
                        height: r(35),
                        child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              value: activeLocale,
                              activeColor: Colors.black,
                              activeTrackColor: Colors.blueGrey,
                              inactiveThumbColor: Colors.black,
                              inactiveTrackColor: Colors.blueGrey,
                              onChanged: changeSwitch,
                            )))),
                Positioned(
                  top: r(10.0),
                  right: r(100.0),
                  child: Text(activeLocale == true ? 'EN' : 'JP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r(20.0),
                      )),
                )
              ]),
            ),
      body: widget.route == 'Home'
          ? HomePage(enLocale: activeLocale)
          : widget.route == 'DeckEditor'
              ? DeckEditPage(enLocale: activeLocale)
              : RankingPage(enLocale: activeLocale),
    );
  }
}

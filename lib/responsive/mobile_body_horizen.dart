import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

import 'package:CodeOfFlow/pages/desktop/homePage.dart';
import 'package:CodeOfFlow/pages/desktop/deckEditPage.dart';
import 'package:CodeOfFlow/pages/desktop/rankingPage.dart';
import 'package:CodeOfFlow/pages/desktop/whitePaperPage.dart';
import 'package:CodeOfFlow/pages/desktop/ruleBookPage.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

typedef void StringCallback(Locale val);

class MobileBodyHorizen extends StatefulWidget {
  final String title;
  final String route;
  final StringCallback localeCallback;
  MobileBodyHorizen(
      {super.key,
      required this.title,
      required this.route,
      required this.localeCallback});

  @override
  State<MobileBodyHorizen> createState() => MobileBodyHorizenState();
}

class MobileBodyHorizenState extends State<MobileBodyHorizen> {
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
      appBar: PreferredSize(
          preferredSize: widget.route == 'Home'
              ? Size.fromHeight(14.0)
              : Size.fromHeight(45.0), // here the desired height
          child: widget.route == 'Home'
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(widget.title,
                      style: TextStyle(color: Colors.white, fontSize: r(18.0))),
                  flexibleSpace: Stack(children: <Widget>[
                    Positioned(
                        top: r(2.0),
                        right: r(50.0),
                        child: SizedBox(
                            width: r(40),
                            height: r(25),
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
                      top: r(5.0),
                      right: r(100.0),
                      child: Text(activeLocale == true ? 'EN' : 'JP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r(15.0),
                          )),
                    ),
                    // Positioned(
                    //   top: 32,
                    //   left: r(390.0),
                    //   child: Text('(${L10n.of(context)!.crashHappen})',
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: r(16.0),
                    //       )),
                    // ),
                  ]),
                )
              : widget.route == 'Ranking'
                  ? AppBar(
                      backgroundColor: Color.fromARGB(155, 106, 56, 5),
                      leading: IconButton(
                        icon: const Icon(Icons.reply, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: Text("👑 COF.ninja Player's Ranking 👑",
                          style: TextStyle(
                              color: Colors.white, fontSize: r(40.0))),
                      flexibleSpace: Stack(children: <Widget>[
                        Positioned(
                            top: r(28.0),
                            right: r(50.0),
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
                          top: r(35.0),
                          right: r(100.0),
                          child: Text(activeLocale == true ? 'EN' : 'JP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r(20.0),
                              )),
                        )
                      ]),
                    )
                  : widget.route == 'WhitePaper'
                      ? AppBar(
                          backgroundColor: Color.fromARGB(155, 106, 56, 5),
                          leading: IconButton(
                            icon: const Icon(Icons.reply, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          title: Text("White Paper | Code Of Flow",
                              style: TextStyle(
                                  color: Colors.white, fontSize: r(40.0))),
                          flexibleSpace: Stack(children: <Widget>[
                            Positioned(
                                top: r(28.0),
                                right: r(50.0),
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
                              top: r(35.0),
                              right: r(100.0),
                              child: Text(activeLocale == true ? 'EN' : 'JP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r(20.0),
                                  )),
                            )
                          ]),
                        )
                      : widget.route == 'RuleBook'
                          ? AppBar(
                              backgroundColor: Color.fromARGB(155, 106, 56, 5),
                              leading: IconButton(
                                icon: const Icon(Icons.reply,
                                    color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              title: Text("Rule Book | COF.ninja",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: r(40.0))),
                              flexibleSpace: Stack(children: <Widget>[
                                Positioned(
                                    top: r(28.0),
                                    right: r(50.0),
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
                                              inactiveTrackColor:
                                                  Colors.blueGrey,
                                              onChanged: changeSwitch,
                                            )))),
                                Positioned(
                                  top: r(35.0),
                                  right: r(100.0),
                                  child:
                                      Text(activeLocale == true ? 'EN' : 'JP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: r(20.0),
                                          )),
                                )
                              ]),
                            )
                          : AppBar(
                              backgroundColor: Colors.transparent,
                              leading: IconButton(
                                icon: const Icon(Icons.reply,
                                    color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              title: Text(widget.title,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: r(30.0))),
                              flexibleSpace: Stack(children: <Widget>[
                                Positioned(
                                    top: r(28.0),
                                    right: r(50.0),
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
                                              inactiveTrackColor:
                                                  Colors.blueGrey,
                                              onChanged: changeSwitch,
                                            )))),
                                Positioned(
                                  top: r(35.0),
                                  right: r(100.0),
                                  child:
                                      Text(activeLocale == true ? 'EN' : 'JP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: r(20.0),
                                          )),
                                )
                              ]),
                            )),
      body: widget.route == 'Home'
          ? HomePage(
              enLocale: activeLocale, isMobile: true, needEyeCatch: false)
          : widget.route == 'DeckEditor'
              ? DeckEditPage(enLocale: activeLocale, isMobile: true)
              : widget.route == 'Ranking'
                  ? RankingPage(enLocale: activeLocale)
                  : widget.route == 'WhitePaper'
                      ? WhitePaperPage(enLocale: activeLocale)
                      : widget.route == 'RuleBook'
                          ? RuleBookPage(enLocale: activeLocale)
                          : HomePage(
                              enLocale: activeLocale,
                              isMobile: true,
                              needEyeCatch: false),
    );
  }
}

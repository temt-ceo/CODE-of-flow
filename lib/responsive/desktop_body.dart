import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

import 'package:CodeOfFlow/pages/desktop/homePage.dart';
import 'package:CodeOfFlow/pages/desktop/deckEditPage.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

typedef void StringCallback(Locale val);

class DesktopBody extends StatefulWidget {
  final String title;
  final String route;
  final StringCallback localeCallback;
  DesktopBody(
      {super.key,
      required this.title,
      required this.route,
      required this.localeCallback});

  @override
  State<DesktopBody> createState() => DesktopBodyState();
}

class DesktopBodyState extends State<DesktopBody> {
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
                  style: const TextStyle(color: Colors.white)),
              flexibleSpace: Stack(children: <Widget>[
                Positioned(
                    top: r(4.0),
                    right: r(300.0),
                    child: Switch(
                      value: activeLocale,
                      activeColor: Colors.black,
                      activeTrackColor: Colors.blueGrey,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: Colors.blueGrey,
                      onChanged: changeSwitch,
                    )),
                Positioned(
                  right: r(270.0),
                  top: r(10.0),
                  child: Text(activeLocale == true ? 'EN' : 'JP',
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
                icon: const Icon(Icons.reply, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(widget.title,
                  style: const TextStyle(color: Colors.white)),
              flexibleSpace: Stack(children: <Widget>[
                Positioned(
                    top: r(4.0),
                    right: r(300.0),
                    child: Switch(
                      value: activeLocale,
                      activeColor: Colors.black,
                      activeTrackColor: Colors.blueGrey,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: Colors.blueGrey,
                      onChanged: changeSwitch,
                    )),
                Positioned(
                  right: r(270.0),
                  top: r(10.0),
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
          : DeckEditPage(enLocale: activeLocale),
    );
  }
}
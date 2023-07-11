import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:html' as html;

import 'package:CodeOfFlow/responsive/dimensions.dart';

const envFlavor = String.fromEnvironment('flavor');

class WhitePaperPage extends StatefulWidget {
  final bool enLocale;
  const WhitePaperPage({super.key, required this.enLocale});

  @override
  State<WhitePaperPage> createState() => WhitePaperPageState();
}

class WhitePaperPageState extends State<WhitePaperPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (layoutContext, constraints) {
      final wRes = constraints.maxWidth / desktopHeight;
      double r(double val) {
        return val * wRes;
      }

      final uri = Uri.parse(L10n.of(context)!.whitepaper34);
      final uriContract = Uri.parse(L10n.of(context)!.whitepaper36);

      return Container(
        color: Colors.white,
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(r(90.0), 50.0, r(90.0), 50.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    L10n.of(context)!.whitepaper01,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper02,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper03,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper04,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper05,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper06,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper07,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper08,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper09,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper10,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper11,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper12,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper13,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper14,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper15,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper16,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper17,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper18,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper19,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper21,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper22,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper23,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper24,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper25,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper26,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper27,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper28,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper29,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper20,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper30,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper31,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper32,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper33,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  InkWell(
                    onTap: () => html.window
                        .open(L10n.of(context)!.whitepaper34, 'github'),
                    child: Text(
                      L10n.of(context)!.whitepaper34,
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontSize: 15.0),
                    ),
                  ),
                  Text(
                    L10n.of(context)!.whitepaper35,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                  ),
                  InkWell(
                    onTap: () => html.window
                        .open(L10n.of(context)!.whitepaper36, 'view-source'),
                    child: Text(
                      L10n.of(context)!.whitepaper36,
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontSize: 15.0),
                    ),
                  ),
                ])),
      );
    });
  }
}
